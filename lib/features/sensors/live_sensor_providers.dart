import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';

/// How long a reading stays "live" before the device is treated as offline.
/// The ESP32 publishes every 2-5 s, so a minute of silence means something
/// is wrong (power, Wi-Fi, or a crashed sketch) rather than just jitter.
const Duration kSensorStaleAfter = Duration(seconds: 60);

/// Realtime Database path the ESP32 writes to:
///   devices/<deviceId>/live
String liveSensorPath(String deviceId) => 'devices/$deviceId/live';

/// Presentation override, written by the demo control page rather than the
/// device: devices/<deviceId>/demo  { enabled: bool, ph: number }
///
/// This exists so the app's pH bands can be shown during a demonstration
/// without altering the solution chemistry. It never touches the live node,
/// so real telemetry keeps flowing underneath, and the UI labels any
/// overridden reading as DEMO so it is not mistaken for a measurement.
String demoOverridePath(String deviceId) => 'devices/$deviceId/demo';

// ─────────────────────────────────────────────────────────
// pH classification
// ─────────────────────────────────────────────────────────
enum PhStatus { acidic, optimal, slightlyAlkaline, alkaline, unknown }

extension PhStatusInfo on PhStatus {
  String get label => switch (this) {
        PhStatus.acidic => 'Acidic',
        PhStatus.optimal => 'Optimal',
        PhStatus.slightlyAlkaline => 'Slightly Alkaline',
        PhStatus.alkaline => 'Alkaline',
        PhStatus.unknown => 'No Reading',
      };

  String get labelHindi => switch (this) {
        PhStatus.acidic => 'अम्लीय',
        PhStatus.optimal => 'आदर्श',
        PhStatus.slightlyAlkaline => 'हल्का क्षारीय',
        PhStatus.alkaline => 'क्षारीय',
        PhStatus.unknown => 'कोई रीडिंग नहीं',
      };

  /// What the grower should actually do about it.
  String get advice => switch (this) {
        PhStatus.acidic => 'Too acidic - add pH Up solution',
        PhStatus.optimal => 'Ideal range for nutrient uptake',
        PhStatus.slightlyAlkaline => 'Drifting high - monitor closely',
        PhStatus.alkaline => 'Too alkaline - add pH Down solution',
        PhStatus.unknown => 'Waiting for sensor data',
      };
}

/// Classify a pH reading using the standard hydroponic bands.
PhStatus classifyPh(double? ph) {
  // 0 is a real (if extreme) pH, so only null or physically impossible
  // values count as "no reading" - a 0 from the device still gets shown.
  if (ph == null || ph < 0 || ph > 14) return PhStatus.unknown;
  if (ph < 5.5) return PhStatus.acidic;
  if (ph <= 6.5) return PhStatus.optimal;
  if (ph <= 7.5) return PhStatus.slightlyAlkaline;
  return PhStatus.alkaline;
}

// ─────────────────────────────────────────────────────────
// Reading model
// ─────────────────────────────────────────────────────────
class LiveSensorReading {
  final double? ph;
  final double? temperature;
  final double? humidity;
  final double? ec;
  final double? waterLevel;
  final DateTime? updatedAt;
  final int? rssi;
  final String? firmware;

  /// True when the value came from the manual demo override, not the device.
  final bool isDemo;

  const LiveSensorReading({
    this.ph,
    this.temperature,
    this.humidity,
    this.ec,
    this.waterLevel,
    this.updatedAt,
    this.rssi,
    this.firmware,
    this.isDemo = false,
  });

  static const empty = LiveSensorReading();

  LiveSensorReading asDemo(double overridePh) => LiveSensorReading(
        ph: overridePh,
        temperature: temperature,
        humidity: humidity,
        ec: ec,
        waterLevel: waterLevel,
        // Keep the device's own timestamp so freshness and the online dot
        // still reflect the real hardware, not the override.
        updatedAt: updatedAt,
        rssi: rssi,
        firmware: firmware,
        isDemo: true,
      );

  bool get hasData => ph != null || temperature != null || humidity != null;

  PhStatus get phStatus => classifyPh(ph);

  /// The device is considered online only while readings keep arriving.
  bool get isOnline {
    final t = updatedAt;
    if (t == null) return false;
    return DateTime.now().difference(t) <= kSensorStaleAfter;
  }

  Duration? get age =>
      updatedAt == null ? null : DateTime.now().difference(updatedAt!);

  /// Human-readable freshness, e.g. "Just now", "12s ago", "3m ago".
  String get lastUpdatedLabel {
    final a = age;
    if (a == null) return 'Never';
    if (a.inSeconds < 5) return 'Just now';
    if (a.inSeconds < 60) return '${a.inSeconds}s ago';
    if (a.inMinutes < 60) return '${a.inMinutes}m ago';
    if (a.inHours < 24) return '${a.inHours}h ago';
    return '${a.inDays}d ago';
  }

  static double? _num(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// Parse the RTDB payload the ESP32 publishes.
  ///
  /// `updatedAt` accepts either seconds or milliseconds since epoch so the
  /// firmware can use whichever is convenient, including Firebase's
  /// ServerValue.timestamp (which is milliseconds).
  factory LiveSensorReading.fromRtdb(Map<dynamic, dynamic> data) {
    DateTime? ts;
    final raw = data['updatedAt'] ?? data['timestamp'] ?? data['ts'];
    final rawNum = _num(raw);
    if (rawNum != null && rawNum > 0) {
      final ms = rawNum > 100000000000 ? rawNum : rawNum * 1000;
      ts = DateTime.fromMillisecondsSinceEpoch(ms.toInt());
    }
    return LiveSensorReading(
      ph: _num(data['ph']),
      temperature: _num(data['temperature'] ?? data['temp']),
      humidity: _num(data['humidity'] ?? data['hum']),
      ec: _num(data['ec']),
      waterLevel: _num(data['waterLevel']),
      updatedAt: ts,
      rssi: _num(data['rssi'])?.toInt(),
      firmware: data['firmware'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────
// Device id (persisted locally so the ESP32 pairs once)
// ─────────────────────────────────────────────────────────
const String _kDeviceIdKey = 'esp32_device_id';
const String kDefaultDeviceId = 'hydro-smart-01';

class DeviceIdNotifier extends StateNotifier<String?> {
  DeviceIdNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_kDeviceIdKey);
  }

  Future<void> setDeviceId(String id) async {
    final trimmed = id.trim();
    final prefs = await SharedPreferences.getInstance();
    if (trimmed.isEmpty) {
      await prefs.remove(_kDeviceIdKey);
      state = null;
    } else {
      await prefs.setString(_kDeviceIdKey, trimmed);
      state = trimmed;
    }
  }
}

final deviceIdProvider =
    StateNotifierProvider<DeviceIdNotifier, String?>((ref) {
  return DeviceIdNotifier();
});

// ─────────────────────────────────────────────────────────
// Live stream
// ─────────────────────────────────────────────────────────
/// Streams the newest reading for a device straight from Realtime Database.
/// RTDB pushes changes over an open socket, so the UI updates the moment the
/// ESP32 writes - no polling.
/// Pin the instance to the explicit regional URL. FirebaseDatabase.instance
/// resolves from whatever the platform app was configured with, which
/// silently points at the wrong region if google-services.json and
/// firebase_options.dart ever disagree.
FirebaseDatabase _db() => FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: kHydroSmartDatabaseUrl,
    );

final liveSensorStreamProvider =
    StreamProvider.family<LiveSensorReading, String>((ref, deviceId) {
  final ref0 = _db().ref(liveSensorPath(deviceId));
  return ref0.onValue.map((event) {
    final value = event.snapshot.value;
    if (value is Map) return LiveSensorReading.fromRtdb(value);
    return LiveSensorReading.empty;
  });
});

/// Streams the manual demo override. Returns null when the override is
/// absent or disabled, which is the normal state.
final demoOverrideStreamProvider =
    StreamProvider.family<double?, String>((ref, deviceId) {
  final ref0 = _db().ref(demoOverridePath(deviceId));
  return ref0.onValue.map((event) {
    final v = event.snapshot.value;
    if (v is! Map) return null;
    if (v['enabled'] != true) return null;
    final raw = v['ph'];
    final ph = raw is num ? raw.toDouble() : double.tryParse('$raw');
    if (ph == null || ph < 0 || ph > 14) return null;
    return ph;
  });
});

/// Ticks once a second so "last updated" and the online dot stay honest even
/// when no new reading arrives (that silence is exactly what marks it offline).
final sensorClockProvider = StreamProvider<DateTime>((ref) {
  return Stream<DateTime>.periodic(
      const Duration(seconds: 1), (_) => DateTime.now());
});

/// Convenience: the live reading for the currently paired device, or null
/// when the user has not paired an ESP32 yet.
final currentLiveReadingProvider = Provider<AsyncValue<LiveSensorReading>?>((ref) {
  final deviceId = ref.watch(deviceIdProvider);
  if (deviceId == null || deviceId.isEmpty) return null;
  ref.watch(sensorClockProvider);

  final live = ref.watch(liveSensorStreamProvider(deviceId));
  final override = ref.watch(demoOverrideStreamProvider(deviceId)).valueOrNull;
  if (override == null) return live;

  // Override only substitutes the pH value. Freshness, RSSI and the
  // online dot still come from the device, so the card cannot claim a
  // dead sensor is alive just because a demo value was set.
  return live.whenData((r) => r.asDemo(override));
});

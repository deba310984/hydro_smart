import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'growth_model.dart';
import '../crop_recommendation/data/models/crop.dart';

// ── Active Growth Notifier ────────────────────────────────────────────────────

class ActiveGrowthNotifier extends StateNotifier<ActiveGrowthSession?> {
  ActiveGrowthNotifier() : super(null);

  /// Start a new growth session for [crop], planting today.
  void startGrowing(Crop crop, {DateTime? plantedDate}) {
    state = ActiveGrowthSession.fromCrop(crop, plantedDate ?? DateTime.now());
  }

  /// Stop / clear the active session.
  void stopGrowing() => state = null;

  /// Called periodically (or on app resume) to refresh computed values.
  void refresh() {
    if (state != null) {
      // Trigger a re-build by recreating with the same data.
      state = state!.copyWithSensors();
    }
  }

  // ── Sensor integration hook ───────────────────────────────────────────────
  // When physical sensors are connected, call this method with the latest
  // readings from Firebase Realtime Database / MQTT / BLE etc.
  void updateSensorReadings({
    double? ph,
    double? ec,
    double? waterTempC,
    double? ambientTempC,
    double? humidityPct,
    double? lightHrs,
  }) {
    if (state == null) return;
    state = state!.copyWithSensors(
      phLevel: ph != null ? state!.phLevel.copyWithValue(ph) : null,
      ecLevel: ec != null ? state!.ecLevel.copyWithValue(ec) : null,
      waterTemp: waterTempC != null
          ? state!.waterTemp.copyWithValue(waterTempC)
          : null,
      ambientTemp: ambientTempC != null
          ? state!.ambientTemp.copyWithValue(ambientTempC)
          : null,
      humidity: humidityPct != null
          ? state!.humidity.copyWithValue(humidityPct)
          : null,
      lightHours:
          lightHrs != null ? state!.lightHours.copyWithValue(lightHrs) : null,
    );
  }
}

/// Global provider for the active growth session.
/// ConsumerWidgets can watch this to react to crop selection / sensor updates.
final activeGrowthProvider =
    StateNotifierProvider<ActiveGrowthNotifier, ActiveGrowthSession?>(
  (ref) => ActiveGrowthNotifier(),
);

// ── Legacy compat ─────────────────────────────────────────────────────────────

final growthDataProvider = Provider<GrowthData>((ref) {
  return GrowthData(
    cropName: 'Lettuce',
    daysSincePlantation: 15,
    totalGrowthDays: 30,
    expectedHarvestDate: DateTime.now().add(const Duration(days: 15)),
  );
});

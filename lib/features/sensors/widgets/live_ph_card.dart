import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/krishi_theme.dart';
import '../device_pairing_sheet.dart';
import '../live_sensor_providers.dart';

/// Live pH readout backed by the ESP32 stream.
///
/// Shows the current value, which hydroponic band it falls in, how fresh the
/// reading is, and whether the device is still reporting.
class LivePhCard extends ConsumerWidget {
  final String currentLanguage;
  const LivePhCard({super.key, this.currentLanguage = 'EN'});

  Color _statusColor(PhStatus s) {
    switch (s) {
      case PhStatus.acidic:
      case PhStatus.alkaline:
        return KrishiTheme.alertRed;
      case PhStatus.optimal:
        return KrishiTheme.primaryGreen;
      case PhStatus.slightlyAlkaline:
        // Card is white; the base gold reads at ~1.8:1 here.
        return KrishiTheme.goldenWheatOnLight;
      case PhStatus.unknown:
        return KrishiTheme.monsoonSky;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceId = ref.watch(deviceIdProvider);
    final isHindi = currentLanguage == 'HI';

    if (deviceId == null || deviceId.isEmpty) {
      return _PairPrompt(isHindi: isHindi);
    }

    final async = ref.watch(currentLiveReadingProvider);
    if (async == null) return _PairPrompt(isHindi: isHindi);

    return async.when(
      loading: () => _shell(
        context,
        deviceId,
        isHindi,
        child: const SizedBox(
          height: 92,
          child: Center(
            child: CircularProgressIndicator(color: KrishiTheme.primaryGreen),
          ),
        ),
      ),
      error: (e, _) => _shell(
        context,
        deviceId,
        isHindi,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: KrishiTheme.alertRed, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Could not reach the sensor database.\n$e',
                  style: KrishiTheme.bodySmall
                      .copyWith(color: KrishiTheme.alertRed, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (r) => _shell(
        context,
        deviceId,
        isHindi,
        reading: r,
        child: _body(r, isHindi),
      ),
    );
  }

  Widget _body(LiveSensorReading r, bool isHindi) {
    final status = r.phStatus;
    final color = _statusColor(status);
    // Show whatever the device reports, including 0.
    final hasPh = r.ph != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              hasPh ? r.ph!.toStringAsFixed(2) : '--',
              style: KrishiTheme.displayLarge.copyWith(
                color: color,
                fontSize: 44,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'pH',
                style: KrishiTheme.bodyMedium
                    .copyWith(color: KrishiTheme.monsoonSky),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isHindi ? status.labelHindi : status.label,
                style:
                    KrishiTheme.labelStyle.copyWith(color: color, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _PhScale(ph: hasPh ? r.ph : null),
        const SizedBox(height: 10),
        Text(
          status.advice,
          style: KrishiTheme.bodySmall
              .copyWith(color: KrishiTheme.monsoonSky, fontSize: 12),
        ),
        if (r.temperature != null || r.ec != null || r.waterLevel != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (r.temperature != null)
                _mini(Icons.thermostat_rounded,
                    '${r.temperature!.toStringAsFixed(1)}C'),
              if (r.ec != null)
                _mini(Icons.bolt_rounded, '${r.ec!.toStringAsFixed(2)} mS/cm'),
              if (r.waterLevel != null)
                _mini(Icons.waves_rounded,
                    '${r.waterLevel!.toStringAsFixed(0)}%'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _mini(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: KrishiTheme.monsoonSky),
          const SizedBox(width: 4),
          Text(
            text,
            style: KrishiTheme.bodySmall
                .copyWith(color: KrishiTheme.deepSoil, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _shell(
    BuildContext context,
    String deviceId,
    bool isHindi, {
    required Widget child,
    LiveSensorReading? reading,
  }) {
    final online = reading?.isOnline ?? false;
    final dotColor = online ? KrishiTheme.primaryGreen : KrishiTheme.alertRed;
    final freshness = reading?.updatedAt != null
        ? ' - ${reading!.lastUpdatedLabel}'
        : '';
    final subtitle = online
        ? '$deviceId$freshness'
        : '$deviceId - ${isHindi ? 'ऑफ़लाइन' : 'offline'}$freshness';
    final isDemo = reading?.isDemo ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KrishiTheme.radiusLarge),
        boxShadow: KrishiTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: KrishiTheme.primaryGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.science_rounded,
                    color: KrishiTheme.primaryGreen, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isHindi ? 'लाइव pH' : 'Live pH',
                          style: KrishiTheme.titleLarge.copyWith(
                              color: KrishiTheme.deepSoil, fontSize: 16),
                        ),
                        // Overridden values are labelled so a demo reading is
                        // never mistaken for a real measurement.
                        if (isDemo) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: KrishiTheme.goldenWheat.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'DEMO',
                              style: KrishiTheme.labelStyle.copyWith(
                                color: KrishiTheme.earthBrown,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              color: dotColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            subtitle,
                            style: KrishiTheme.bodySmall.copyWith(
                                color: KrishiTheme.monsoonSky, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Device settings',
                icon: const Icon(Icons.settings_outlined,
                    size: 19, color: KrishiTheme.monsoonSky),
                onPressed: () => showDevicePairingSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

/// Horizontal pH scale (4-9) with a marker at the current reading.
class _PhScale extends StatelessWidget {
  final double? ph;
  const _PhScale({this.ph});

  @override
  Widget build(BuildContext context) {
    const lo = 4.0;
    const hi = 9.0;
    final t = ph == null ? null : ((ph! - lo) / (hi - lo)).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 26,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE53935), // acidic
                      Color(0xFF43A047), // optimal 5.5-6.5
                      Color(0xFF43A047),
                      Color(0xFFFDD835), // slightly alkaline
                      Color(0xFFE53935), // alkaline
                    ],
                    stops: [0.0, 0.30, 0.50, 0.70, 1.0],
                  ),
                ),
              ),
              if (t != null)
                Positioned(
                  left: (constraints.maxWidth - 12) * t,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      border:
                          Border.all(color: KrishiTheme.deepSoil, width: 2),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Text('4',
                    style: KrishiTheme.bodySmall.copyWith(
                        fontSize: 9, color: KrishiTheme.monsoonSky)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Text('9',
                    style: KrishiTheme.bodySmall.copyWith(
                        fontSize: 9, color: KrishiTheme.monsoonSky)),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shown until an ESP32 has been paired.
class _PairPrompt extends StatelessWidget {
  final bool isHindi;
  const _PairPrompt({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KrishiTheme.radiusLarge),
        border: Border.all(color: KrishiTheme.primaryGreen.withOpacity(0.25)),
        boxShadow: KrishiTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: KrishiTheme.primaryGreen.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sensors_rounded,
                color: KrishiTheme.primaryGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'सेंसर जोड़ें' : 'Connect your pH sensor',
                  style: KrishiTheme.titleLarge
                      .copyWith(color: KrishiTheme.deepSoil, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  isHindi
                      ? 'ESP32 डिवाइस आईडी दर्ज करें'
                      : 'Pair your ESP32 to see live readings',
                  style: KrishiTheme.bodySmall
                      .copyWith(color: KrishiTheme.monsoonSky, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => showDevicePairingSheet(context),
            child: Text(isHindi ? 'जोड़ें' : 'Pair'),
          ),
        ],
      ),
    );
  }
}

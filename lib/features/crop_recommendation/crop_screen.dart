import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'crop_controller.dart';
import 'providers/weather_providers.dart';
import 'models/weather_model.dart';
import 'services/location_service.dart';
import 'weather_config_screen.dart';

class CropRecommendationScreen extends ConsumerWidget {
  const CropRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendations = ref.watch(cropRecommendationProvider);
    final weatherAsync = ref.watch(weatherProvider);
    final weatherDisplay = ref.watch(weatherDisplayProvider);
    final weatherStatus = ref.watch(weatherServiceStatusDisplayProvider);

    // Initialize weather on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherNotifier = ref.read(weatherProvider.notifier);

      // Only initialize once — the notifier tracks this internally
      if (!weatherNotifier.isInitialized) {
        weatherNotifier.initializeWeather();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Recommendations'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openWeatherConfig(context),
            tooltip: 'Weather Settings',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshWeather(ref),
            tooltip: 'Refresh Weather',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Current Conditions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        // Weather service status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                                    weatherStatus['statusColor'] as String)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getStatusColor(
                                      weatherStatus['statusColor'] as String)
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                weatherStatus['statusIcon'] as String,
                                style: const TextStyle(fontSize: 10),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                (weatherStatus['isRealApi'] as bool)
                                    ? 'Live'
                                    : 'Demo',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(
                                      weatherStatus['statusColor'] as String),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Location status row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        weatherAsync.when(
                          data: (_) => GestureDetector(
                            onTap: () => _refreshWeather(ref),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.green[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    weatherDisplay['location']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          loading: () => Container(
                            padding: const EdgeInsets.all(4),
                            child: const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                          ),
                          error: (_, __) => GestureDetector(
                            onTap: () =>
                                _requestLocationPermission(context, ref),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 14,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Enable location',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ConditionItem(
                          label: 'Soil pH',
                          value: weatherDisplay['soilPh']!,
                        ),
                        _ConditionItem(
                          label: 'Temperature',
                          value: weatherDisplay['temperature']!,
                        ),
                        _ConditionItem(
                          label: 'Humidity',
                          value: weatherDisplay['humidity']!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Updated: ${weatherDisplay['lastUpdated']}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recommended Crops',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final crop = recommendations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(crop.icon,
                                style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    crop.cropName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Risk Level: ${crop.riskLevel}',
                                    style: TextStyle(
                                      color: crop.riskLevel == 'Low'
                                          ? Colors.green
                                          : crop.riskLevel == 'Medium'
                                              ? Colors.orange
                                              : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CropDetail(
                              label: 'Duration',
                              value: '${crop.durationDays} days',
                            ),
                            _CropDetail(
                              label: 'Profit',
                              value: '${crop.profitMarginPercent}%',
                            ),
                            _CropDetail(
                              label: 'Water',
                              value: crop.waterUsage,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${crop.cropName} selected for plantation'),
                                ),
                              );
                            },
                            child: const Text('Select Crop'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Refresh weather data
  void _refreshWeather(WidgetRef ref) {
    ref.read(weatherProvider.notifier).refreshWeather();
  }

  /// Open weather configuration screen
  void _openWeatherConfig(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeatherConfigScreen()),
    );
  }

  /// Get color from status string
  Color _getStatusColor(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'grey':
      default:
        return Colors.grey;
    }
  }

  /// Request location permission and show dialog
  Future<void> _requestLocationPermission(
      BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => _LocationPermissionDialog(ref: ref),
    );
  }
}

/// Location Permission Dialog Widget
class _LocationPermissionDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _LocationPermissionDialog({required this.ref});

  @override
  _LocationPermissionDialogState createState() =>
      _LocationPermissionDialogState();
}

class _LocationPermissionDialogState
    extends ConsumerState<_LocationPermissionDialog> {
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.location_on, color: Colors.green),
          SizedBox(width: 8),
          Text('Location Permission'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We need location access to provide accurate weather conditions for crop recommendations.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text('• Real-time temperature',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text('• Local humidity levels',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text('• Better crop suggestions',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isRequesting ? null : () => Navigator.pop(context),
          child: const Text('Maybe Later'),
        ),
        ElevatedButton(
          onPressed: _isRequesting ? null : _handleLocationRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isRequesting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Allow Location'),
        ),
      ],
    );
  }

  Future<void> _handleLocationRequest() async {
    if (_isRequesting) return;

    setState(() => _isRequesting = true);

    try {
      await widget.ref
          .read(weatherProvider.notifier)
          .requestLocationAndUpdateWeather();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weather data updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final permissionStatus =
            await LocationService.checkLocationPermission();
        if (permissionStatus == LocationPermissionStatus.permanentlyDenied) {
          _showSettingsDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to get location: $e'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _handleLocationRequest,
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Location permission has been permanently denied. Please enable it in app settings to get weather updates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class _ConditionItem extends StatelessWidget {
  final String label;
  final String value;

  const _ConditionItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}

class _CropDetail extends StatelessWidget {
  final String label;
  final String value;

  const _CropDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

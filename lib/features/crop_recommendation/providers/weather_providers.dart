import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_model.dart';
import '../services/hybrid_weather_service.dart';
import '../services/location_service.dart';

/// State notifier for weather conditions
class WeatherNotifier extends StateNotifier<AsyncValue<WeatherConditions>> {
  bool _initialized = false;
  bool _fetching = false;

  WeatherNotifier() : super(AsyncValue.data(WeatherConditions.empty()));

  /// Initialize and fetch weather data
  Future<void> initializeWeather() async {
    if (_fetching) return; // Prevent duplicate calls
    _fetching = true;
    _initialized = true;

    state = const AsyncValue.loading();
    print('[Weather] initializeWeather called');

    try {
      final result = await HybridWeatherService.getCurrentWeatherConditions();

      if (result.isSuccess && result.conditions != null) {
        state = AsyncValue.data(result.conditions!);
        print(
            '[Weather] State updated with real data: ${result.conditions!.temperature}°C');
      } else {
        print('[Weather] initializeWeather failed: ${result.error}');
        state = AsyncValue.error(
          result.error ?? 'Unknown error occurred',
          StackTrace.current,
        );
      }
    } catch (e) {
      print('[Weather] initializeWeather exception: $e');
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _fetching = false;
    }
  }

  /// Refresh weather data
  Future<void> refreshWeather() async {
    if (_fetching) return; // Prevent duplicate calls
    _fetching = true;

    print('[Weather] refreshWeather called');

    try {
      final result = await HybridWeatherService.refreshWeatherData();
      if (result.isSuccess && result.conditions != null) {
        state = AsyncValue.data(result.conditions!);
        print('[Weather] Refresh success: ${result.conditions!.temperature}°C');
      } else {
        print('[Weather] Refresh failed: ${result.error}');
        state = AsyncValue.error(
          result.error ?? 'Failed to refresh weather data',
          StackTrace.current,
        );
      }
    } catch (e) {
      print('[Weather] Refresh exception: $e');
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _fetching = false;
    }
  }

  /// Whether weather was already initialized
  bool get isInitialized => _initialized;

  /// Request location permission and update weather
  Future<void> requestLocationAndUpdateWeather() async {
    state = const AsyncValue.loading();

    try {
      final permissionStatus =
          await LocationService.requestLocationPermission();

      if (permissionStatus == LocationPermissionStatus.granted) {
        await initializeWeather();
      } else {
        String errorMessage;
        switch (permissionStatus) {
          case LocationPermissionStatus.denied:
            errorMessage =
                'Location permission denied. Please allow location access to get weather updates.';
            break;
          case LocationPermissionStatus.permanentlyDenied:
            errorMessage =
                'Location permission permanently denied. Please enable it in app settings.';
            break;
          default:
            errorMessage = 'Location permission required for weather updates.';
        }
        state = AsyncValue.error(errorMessage, StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error(
        'Failed to request location permission: $e',
        StackTrace.current,
      );
    }
  }

  /// Check if current data is stale and needs refresh
  bool get needsRefresh {
    return state.when(
      data: (weather) =>
          HybridWeatherService.isWeatherDataStale(weather.lastUpdated),
      loading: () => false,
      error: (_, __) => true,
    );
  }
}

/// Provider for weather conditions
final weatherProvider =
    StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherConditions>>(
        (ref) {
  return WeatherNotifier();
});

/// Provider for current location permission status
final locationPermissionProvider =
    FutureProvider<LocationPermissionStatus>((ref) {
  return LocationService.checkLocationPermission();
});

/// Provider to check if location service is enabled
final locationServiceEnabledProvider = FutureProvider<bool>((ref) {
  return LocationService.isLocationServiceEnabled();
});

/// Provider for weather conditions (only the data, no AsyncValue wrapper)
final currentWeatherProvider = Provider<WeatherConditions?>((ref) {
  final weatherAsync = ref.watch(weatherProvider);
  return weatherAsync.when(
    data: (weather) => weather,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for formatted weather display data
final weatherDisplayProvider = Provider<Map<String, String>>((ref) {
  final weather = ref.watch(currentWeatherProvider);

  if (weather == null) {
    return {
      'temperature': '22°C',
      'humidity': '65%',
      'soilPh': '6.5',
      'location': 'Getting location...',
      'lastUpdated': 'Never',
    };
  }

  final lastUpdate = weather.lastUpdated;
  final now = DateTime.now();
  final timeDiff = now.difference(lastUpdate);

  String lastUpdatedText;
  if (timeDiff.inMinutes < 1) {
    lastUpdatedText = 'Just now';
  } else if (timeDiff.inMinutes < 60) {
    lastUpdatedText = '${timeDiff.inMinutes}m ago';
  } else if (timeDiff.inHours < 24) {
    lastUpdatedText = '${timeDiff.inHours}h ago';
  } else {
    lastUpdatedText = '${timeDiff.inDays}d ago';
  }

  return {
    'temperature': '${weather.temperature.toStringAsFixed(1)}°C',
    'humidity': '${weather.humidity.toStringAsFixed(0)}%',
    'soilPh': weather.soilPh.toStringAsFixed(1),
    'location': weather.locationName,
    'lastUpdated': lastUpdatedText,
  };
});

/// Provider for weather service status (real API vs simulated)
final weatherServiceStatusProvider =
    FutureProvider<WeatherServiceStatus>((ref) {
  return HybridWeatherService.getServiceStatus();
});

/// Provider for formatted weather service status display
final weatherServiceStatusDisplayProvider =
    Provider<Map<String, dynamic>>((ref) {
  final statusAsync = ref.watch(weatherServiceStatusProvider);

  return statusAsync.when(
    data: (status) => {
      'isRealApi': status.isUsingRealApi,
      'statusText': status.description,
      'statusIcon': status.isUsingRealApi ? '🌍' : '🧪',
      'statusColor': status.isUsingRealApi ? 'green' : 'orange',
    },
    loading: () => {
      'isRealApi': false,
      'statusText': 'Checking weather service...',
      'statusIcon': '⏳',
      'statusColor': 'grey',
    },
    error: (_, __) => {
      'isRealApi': false,
      'statusText': 'Using simulated weather data',
      'statusIcon': '🧪',
      'statusColor': 'orange',
    },
  );
});

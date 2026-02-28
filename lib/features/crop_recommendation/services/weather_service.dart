import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'location_service.dart';

/// Service to fetch weather data based on location
class WeatherService {
  static const double _defaultSoilPh = 6.5;

  /// Fetch weather conditions for current location
  static Future<WeatherUpdateResult> getCurrentWeatherConditions() async {
    try {
      // Get current position
      final position = await LocationService.getCurrentLocation();

      // Simulate weather API call based on coordinates
      final weather = await _fetchWeatherData(
        position.latitude,
        position.longitude,
      );

      return WeatherUpdateResult.success(weather);
    } on AppLocationServiceDisabledException {
      return WeatherUpdateResult.failure(
        'Location services are disabled. Please enable them in device settings.',
      );
    } on LocationPermissionException catch (e) {
      return WeatherUpdateResult.failure(
        'Location permission required: ${e.message}',
      );
    } on LocationException catch (e) {
      return WeatherUpdateResult.failure(e.message);
    } catch (e) {
      return WeatherUpdateResult.failure(
        'Failed to get weather data: $e',
      );
    }
  }

  /// Get weather conditions stream for continuous updates
  static Stream<WeatherUpdateResult> getWeatherStream() async* {
    try {
      await for (final position in LocationService.getLocationStream()) {
        try {
          final weather = await _fetchWeatherData(
            position.latitude,
            position.longitude,
          );
          yield WeatherUpdateResult.success(weather);
        } catch (e) {
          yield WeatherUpdateResult.failure('Failed to update weather: $e');
        }
      }
    } catch (e) {
      yield WeatherUpdateResult.failure('Location stream error: $e');
    }
  }

  /// Simulate weather API call (replace with real API)
  static Future<WeatherConditions> _fetchWeatherData(
    double latitude,
    double longitude,
  ) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Get location name based on coordinates
    final locationName = _getLocationName(latitude, longitude);

    // Generate realistic weather data based on location and time
    final weather = _generateWeatherData(latitude, longitude);

    return WeatherConditions(
      temperature: weather['temperature']!,
      humidity: weather['humidity']!,
      soilPh: _defaultSoilPh,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      lastUpdated: DateTime.now(),
    );
  }

  /// Generate realistic weather data based on coordinates and season
  static Map<String, double> _generateWeatherData(
    double latitude,
    double longitude,
  ) {
    final random = Random();
    final now = DateTime.now();

    // Base temperature calculation based on latitude (seasonal variation)
    double baseTemp;
    final month = now.month;

    // Seasonal temperature variation (simplified)
    if (latitude.abs() < 23.5) {
      // Tropical region
      baseTemp = 25 + (month - 6).abs() * -0.5; // 22-28°C range
    } else if (latitude.abs() < 35) {
      // Subtropical region
      baseTemp = 20 + (month - 6).abs() * -2; // 15-25°C range
    } else {
      // Temperate region
      baseTemp = 15 + (month - 6).abs() * -3; // 5-20°C range
    }

    // Add random variation ±5°C
    final temperature = (baseTemp + random.nextDouble() * 10 - 5).clamp(5, 45);

    // Humidity calculation (inversely related to temperature with some variation)
    final baseHumidity = 100 - (temperature - 10) * 1.5;
    final humidity =
        (baseHumidity + random.nextDouble() * 20 - 10).clamp(30, 95);

    return {
      'temperature': double.parse(temperature.toStringAsFixed(1)),
      'humidity': double.parse(humidity.toStringAsFixed(1)),
    };
  }

  /// Get simplified location name based on coordinates
  static String _getLocationName(double latitude, double longitude) {
    // This would normally use reverse geocoding API
    // For now, return a simple region-based name

    if (latitude >= 8 && latitude <= 37 && longitude >= 68 && longitude <= 97) {
      // India region approximation
      if (latitude >= 28 && longitude >= 77) return 'New Delhi Region';
      if (latitude >= 19 &&
          latitude <= 28 &&
          longitude >= 72 &&
          longitude <= 77) {
        return 'Mumbai Region';
      }
      if (latitude >= 12 &&
          latitude <= 13 &&
          longitude >= 77 &&
          longitude <= 78) {
        return 'Bangalore Region';
      }
      if (latitude >= 22 &&
          latitude <= 23 &&
          longitude >= 88 &&
          longitude <= 89) {
        return 'Kolkata Region';
      }
      return 'India';
    }

    // Default region names based on latitude
    if (latitude.abs() < 23.5) {
      return 'Tropical Region';
    } else if (latitude.abs() < 35) {
      return 'Subtropical Region';
    } else {
      return 'Temperate Region';
    }
  }

  /// Refresh weather data manually
  static Future<WeatherUpdateResult> refreshWeatherData() async {
    return await getCurrentWeatherConditions();
  }

  /// Check if weather data is stale (older than 5 minutes)
  static bool isWeatherDataStale(DateTime lastUpdated) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inMinutes > 5;
  }
}

import '../models/weather_model.dart';
import 'real_weather_service.dart';
import 'weather_service.dart';

/// Hybrid Weather Service - Uses real API when available, falls back to simulation
class HybridWeatherService {
  /// Fetch weather conditions with API preference
  static Future<WeatherUpdateResult> getCurrentWeatherConditions() async {
    try {
      // Try real API first if configured
      if (RealWeatherService.isApiKeyConfigured) {
        try {
          print('[Weather] Fetching real-time weather from Open-Meteo API...');
          final result = await RealWeatherService.getCurrentWeatherConditions();
          if (result.isSuccess) {
            print(
                '[Weather] Got real weather: ${result.conditions?.temperature}°C, ${result.conditions?.humidity}% humidity at ${result.conditions?.locationName}');
          }
          return result;
        } catch (e) {
          // API failed, fall back to simulated data
          print('[Weather] Real weather API failed, using simulated data: $e');
          return await WeatherService.getCurrentWeatherConditions();
        }
      } else {
        // No API key configured, use simulated data
        print('[Weather] No API configured, using simulated data');
        return await WeatherService.getCurrentWeatherConditions();
      }
    } catch (e) {
      return WeatherUpdateResult.failure('Failed to get weather data: $e');
    }
  }

  /// Refresh weather data
  static Future<WeatherUpdateResult> refreshWeatherData() async {
    return await getCurrentWeatherConditions();
  }

  /// Get weather service status
  static Future<WeatherServiceStatus> getServiceStatus() async {
    if (!RealWeatherService.isApiKeyConfigured) {
      return WeatherServiceStatus.simulatedOnly;
    }

    try {
      final isValid = await RealWeatherService.validateApiKey();
      return isValid
          ? WeatherServiceStatus.realApiActive
          : WeatherServiceStatus.apiKeyInvalid;
    } catch (e) {
      return WeatherServiceStatus.apiUnavailable;
    }
  }

  /// Check if weather data is stale (older than 5 minutes)
  static bool isWeatherDataStale(DateTime lastUpdated) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inMinutes > 5;
  }
}

/// Weather service status enum
enum WeatherServiceStatus {
  simulatedOnly('Using simulated weather data'),
  realApiActive('Using real-time weather API'),
  apiKeyInvalid('API key invalid - using simulated data'),
  apiUnavailable('API unavailable - using simulated data');

  const WeatherServiceStatus(this.description);
  final String description;

  bool get isUsingRealApi => this == WeatherServiceStatus.realApiActive;
}

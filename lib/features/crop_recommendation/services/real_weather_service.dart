import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import 'location_service.dart';

/// Real Weather API Service using Open-Meteo (free, no API key required)
class RealWeatherService {
  static const String _weatherBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const String _geocodeBaseUrl =
      'https://nominatim.openstreetmap.org/reverse';

  static const double _defaultSoilPh = 6.5;
  static final Dio _dio = Dio();

  /// Fetch real weather conditions for current location
  static Future<WeatherUpdateResult> getCurrentWeatherConditions() async {
    try {
      // Get current position
      final position = await LocationService.getCurrentLocation();

      // Fetch real weather data from API
      final weather = await _fetchRealWeatherData(
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

  /// Fetch real weather data from Open-Meteo API
  static Future<WeatherConditions> _fetchRealWeatherData(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _dio.get(
        _weatherBaseUrl,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': 'temperature_2m,relative_humidity_2m',
          'timezone': 'auto',
        },
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final locationName = await _reverseGeocode(latitude, longitude);
        return _parseWeatherResponse(
            response.data, latitude, longitude, locationName);
      } else {
        throw Exception('Weather API error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout - check internet connection');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Weather service is slow - please try again');
      } else {
        throw Exception('Failed to fetch weather: ${e.message}');
      }
    } catch (e) {
      throw Exception('Weather service error: $e');
    }
  }

  /// Parse Open-Meteo API response
  static WeatherConditions _parseWeatherResponse(
    Map<String, dynamic> data,
    double latitude,
    double longitude,
    String locationName,
  ) {
    final current = data['current'] as Map<String, dynamic>;

    final temperature = (current['temperature_2m'] as num).toDouble();
    final humidity = (current['relative_humidity_2m'] as num).toDouble();

    return WeatherConditions(
      temperature: temperature,
      humidity: humidity,
      soilPh: _defaultSoilPh,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      lastUpdated: DateTime.now(),
    );
  }

  /// Reverse geocode coordinates to a location name
  static Future<String> _reverseGeocode(
      double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        _geocodeBaseUrl,
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'format': 'json',
          'zoom': 10,
        },
        options: Options(
          headers: {'User-Agent': 'HydroSmartApp/1.0'},
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['county'] ??
              '';
          final state = address['state'] ?? '';
          final country =
              address['country_code']?.toString().toUpperCase() ?? '';

          if (city.toString().isNotEmpty) {
            return '$city${state.toString().isNotEmpty ? ', $state' : ''}, $country';
          }
        }
      }
    } catch (_) {
      // Silently fall back to coordinates
    }
    return '${latitude.toStringAsFixed(2)}°, ${longitude.toStringAsFixed(2)}°';
  }

  /// Open-Meteo is free and always available - no API key needed
  static bool get isApiKeyConfigured => true;

  /// Validate API by making a test call
  static Future<bool> validateApiKey() async {
    try {
      final response = await _dio.get(
        _weatherBaseUrl,
        queryParameters: {
          'latitude': 28.61,
          'longitude': 77.21,
          'current': 'temperature_2m',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

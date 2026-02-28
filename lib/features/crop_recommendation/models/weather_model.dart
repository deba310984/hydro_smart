/// Weather Conditions Model for Crop Recommendations

class WeatherConditions {
  final double temperature; // in Celsius
  final double humidity; // in percentage
  final double soilPh; // default from sensor
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime lastUpdated;

  WeatherConditions({
    required this.temperature,
    required this.humidity,
    required this.soilPh,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.lastUpdated,
  });

  factory WeatherConditions.empty() {
    return WeatherConditions(
      temperature: 22.0,
      humidity: 65.0,
      soilPh: 6.5,
      latitude: 0.0,
      longitude: 0.0,
      locationName: 'Unknown Location',
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
          0), // Mark as stale so location is requested
    );
  }

  WeatherConditions copyWith({
    double? temperature,
    double? humidity,
    double? soilPh,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? lastUpdated,
  }) {
    return WeatherConditions(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      soilPh: soilPh ?? this.soilPh,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Location Permission Status
enum LocationPermissionStatus {
  unknown,
  denied,
  granted,
  permanentlyDenied,
}

/// Weather Update Result
class WeatherUpdateResult {
  final WeatherConditions? conditions;
  final String? error;
  final bool isSuccess;

  WeatherUpdateResult._({
    this.conditions,
    this.error,
    required this.isSuccess,
  });

  factory WeatherUpdateResult.success(WeatherConditions conditions) {
    return WeatherUpdateResult._(
      conditions: conditions,
      isSuccess: true,
    );
  }

  factory WeatherUpdateResult.failure(String error) {
    return WeatherUpdateResult._(
      error: error,
      isSuccess: false,
    );
  }
}

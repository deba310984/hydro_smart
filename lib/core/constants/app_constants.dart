/// Application-wide constants
class AppConstants {
  // Firebase paths
  static const String sensorsPath = 'sensors';
  static const String usersPath = 'users';
  static const String farmsPath = 'farms';
  static const String sensorReadingsPath = 'readings';

  // Sensor thresholds
  static const double minTemperature = 15.0;
  static const double maxTemperature = 35.0;
  static const double minHumidity = 40.0;
  static const double maxHumidity = 90.0;
  static const double minPH = 5.5;
  static const double maxPH = 7.5;
  static const double minWaterLevel = 20.0;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration databaseTimeout = Duration(seconds: 15);

  // UI
  static const String appName = 'Hydro Smart';
  static const String appVersion = '1.0.0';

  // Cache keys
  static const String userCacheKey = 'user_cache';
  static const String farmsCacheKey = 'farms_cache';
  static const String sensorCacheKey = 'sensor_cache';
  static const String themeCacheKey = 'theme_preference';

  // AI Service
  static const String aiApiUrl = 'https://api.hydroai.example.com/v1'; // Replace with actual URL
  static const String aiApiKey = ''; // If needed
}

/// Sensor types
enum SensorType {
  temperature('Temperature', '°C'),
  humidity('Humidity', '%'),
  ph('pH Level', ''),
  waterLevel('Water Level', '%'),
  ec('EC', 'µS/cm'),
  dissolved_oxygen('Dissolved Oxygen', 'mg/L');

  final String displayName;
  final String unit;

  const SensorType(this.displayName, this.unit);
}

/// Alert severity levels
enum AlertSeverity {
  info('Info', 0xFF2196F3),
  warning('Warning', 0xFFFFA726),
  critical('Critical', 0xFFEF5350);

  final String label;
  final int colorValue;

  const AlertSeverity(this.label, this.colorValue);
}

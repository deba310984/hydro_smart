import '../../data/models/sensor_model.dart';

abstract class SensorRepository {
  /// Stream sensor data from Realtime Database
  Stream<Map<String, double>> streamSensorData(String deviceId);

  /// Get single sensor reading
  Future<SensorModel?> getSensorReading(String deviceId, String sensorType);

  /// Get sensor history from Firestore
  Future<List<SensorModel>> getSensorHistory(String deviceId, int limit);

  /// Save sensor reading to Firestore
  Future<void> saveSensorReading(String deviceId, SensorModel sensor);

  /// Cache sensor data locally
  Future<void> cacheSensorData(String deviceId, Map<String, double> data);

  /// Get cached sensor data
  Future<Map<String, double>?> getCachedSensorData(String deviceId);
}

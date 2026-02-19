import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/repositories/sensor_repository.dart';
import '../models/sensor_model.dart';

class SensorRepositoryImpl implements SensorRepository {
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestoreDb = FirebaseFirestore.instance;

  @override
  Stream<Map<String, double>> streamSensorData(String deviceId) {
    return _realtimeDb.ref('sensors/$deviceId').onValue.map((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
        return {
          'temperature': (data['temperature'] as num?)?.toDouble() ?? 0,
          'humidity': (data['humidity'] as num?)?.toDouble() ?? 0,
          'ph': (data['ph'] as num?)?.toDouble() ?? 0,
          'waterLevel': (data['waterLevel'] as num?)?.toDouble() ?? 0,
          'ec': (data['ec'] as num?)?.toDouble() ?? 0,
          'dissolved_oxygen':
              (data['dissolved_oxygen'] as num?)?.toDouble() ?? 0,
        };
      }
      return {};
    });
  }

  @override
  Future<SensorModel?> getSensorReading(
    String deviceId,
    String sensorType,
  ) async {
    try {
      final snapshot = await _realtimeDb
          .ref('sensors/$deviceId/$sensorType')
          .get();
      if (snapshot.exists) {
        return SensorModel.fromRtdb(
          sensorType,
          snapshot.value as Map<dynamic, dynamic>,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get sensor reading: $e');
    }
  }

  @override
  Future<List<SensorModel>> getSensorHistory(String deviceId, int limit) async {
    try {
      final snapshot = await _firestoreDb
          .collection('sensors/$deviceId/history')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SensorModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sensor history: $e');
    }
  }

  @override
  Future<void> saveSensorReading(String deviceId, SensorModel sensor) async {
    try {
      await _firestoreDb
          .collection('sensors/$deviceId/history')
          .doc()
          .set(sensor.toJson());
    } catch (e) {
      throw Exception('Failed to save sensor reading: $e');
    }
  }

  @override
  Future<void> cacheSensorData(
    String deviceId,
    Map<String, double> data,
  ) async {
    // TODO: Implement local caching with Hive
  }

  @override
  Future<Map<String, double>?> getCachedSensorData(String deviceId) async {
    // TODO: Implement local cache retrieval
    return null;
  }
}

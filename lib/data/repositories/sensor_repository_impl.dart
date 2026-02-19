import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydro_smart/domain/repositories/sensor_repository.dart';
import '../models/sensor_model.dart';
import 'dart:convert';

/// Implementation of SensorRepository using Firestore and local caching
class SensorRepositoryImpl implements SensorRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Stream<Map<String, double>> streamSensorData(String deviceId) {
    return _firestore
        .collection('devices')
        .doc(deviceId)
        .collection('sensors')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return {};
          }
          final data = snapshot.docs.first.data();
          return {
            'temperature': (data['temperature'] as num?)?.toDouble() ?? 0.0,
            'humidity': (data['humidity'] as num?)?.toDouble() ?? 0.0,
            'ph': (data['ph'] as num?)?.toDouble() ?? 0.0,
            'ec': (data['ec'] as num?)?.toDouble() ?? 0.0,
            'dissolved_oxygen':
                (data['dissolved_oxygen'] as num?)?.toDouble() ?? 0.0,
          };
        });
  }

  @override
  Future<SensorModel?> getSensorReading(
    String deviceId,
    String sensorType,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('devices')
          .doc(deviceId)
          .collection('sensors')
          .where('type', isEqualTo: sensorType)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return SensorModel.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveSensorReading(String deviceId, SensorModel sensor) async {
    try {
      await _firestore
          .collection('devices')
          .doc(deviceId)
          .collection('sensors')
          .add({...sensor.toJson(), 'timestamp': FieldValue.serverTimestamp()});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SensorModel>> getSensorHistory(String deviceId, int limit) async {
    try {
      final snapshot = await _firestore
          .collection('devices')
          .doc(deviceId)
          .collection('sensors')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return SensorModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cacheSensorData(
    String deviceId,
    Map<String, double> data,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sensor_cache_$deviceId', jsonEncode(data));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, double>?> getCachedSensorData(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('sensor_cache_$deviceId');
      if (cached == null) {
        return null;
      }
      final Map<String, dynamic> decoded = jsonDecode(cached);
      return decoded.cast<String, double>();
    } catch (e) {
      return null;
    }
  }
}

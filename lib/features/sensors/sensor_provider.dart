import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/sensor_repository_impl.dart';
import '../../data/models/sensor_model.dart';
import '../../domain/repositories/sensor_repository.dart';

/// Provides the sensor repository
final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return SensorRepositoryImpl();
});

/// Streams live sensor data for a device
final sensorDataStreamProvider =
    StreamProvider.family<Map<String, double>, String>((ref, deviceId) {
  final sensorRepository = ref.watch(sensorRepositoryProvider);
  return sensorRepository.streamSensorData(deviceId);
});

/// Manages sensor-related operations
final sensorControllerProvider =
    StateNotifierProvider.family<SensorController, AsyncValue<void>, String>((
  ref,
  deviceId,
) {
  final sensorRepository = ref.watch(sensorRepositoryProvider);
  return SensorController(sensorRepository, deviceId);
});

class SensorController extends StateNotifier<AsyncValue<void>> {
  final SensorRepository _sensorRepository;
  final String _deviceId;

  SensorController(this._sensorRepository, this._deviceId)
      : super(const AsyncValue.data(null));

  Future<void> saveSensorReading(SensorModel sensor) async {
    state = const AsyncValue.loading();
    try {
      await _sensorRepository.saveSensorReading(_deviceId, sensor);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<List<SensorModel>> getSensorHistory(int limit) async {
    try {
      return await _sensorRepository.getSensorHistory(_deviceId, limit);
    } catch (e) {
      rethrow;
    }
  }
}

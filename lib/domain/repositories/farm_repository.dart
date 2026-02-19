import '../../data/models/farm_model.dart';

abstract class FarmRepository {
  /// Get all farms for current user
  Future<List<FarmModel>> getUserFarms(String userId);

  /// Get single farm
  Future<FarmModel?> getFarm(String farmId);

  /// Create new farm
  Future<String> createFarm(String userId, FarmModel farm);

  /// Update farm
  Future<void> updateFarm(String farmId, FarmModel farm);

  /// Delete farm
  Future<void> deleteFarm(String farmId);

  /// Stream farms for user
  Stream<List<FarmModel>> streamUserFarms(String userId);
}

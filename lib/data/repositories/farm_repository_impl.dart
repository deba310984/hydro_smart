import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hydro_smart/core/services/error_handler.dart';
import 'package:hydro_smart/data/models/farm_model.dart';
import 'package:hydro_smart/domain/repositories/farm_repository.dart';

class FarmRepositoryImpl implements FarmRepository {
  final FirebaseFirestore _firestore;

  FarmRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _farmsCollection = 'farms';

  // ---------------- CREATE FARM ----------------

  @override
  Future<String> createFarm(String userId, FarmModel farm) async {
    try {
      final docRef = await _firestore.collection(_farmsCollection).add({
        ...farm.toJson(),
        'ownerId': userId,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      ErrorHandler.logError(e, context: 'createFarm');
      rethrow;
    }
  }

  // ---------------- GET USER FARMS ----------------

  @override
  Future<List<FarmModel>> getUserFarms(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_farmsCollection)
          .where('ownerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => FarmModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'getUserFarms');
      rethrow;
    }
  }

  // ---------------- STREAM USER FARMS ----------------

  @override
  Stream<List<FarmModel>> streamUserFarms(String userId) {
    return _firestore
        .collection(_farmsCollection)
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FarmModel.fromJson(doc.data()))
            .toList());
  }

  // ---------------- UPDATE FARM ----------------

  @override
  Future<void> updateFarm(String farmId, FarmModel farm) async {
    try {
      await _firestore
          .collection(_farmsCollection)
          .doc(farmId)
          .update(farm.toJson());
    } catch (e) {
      ErrorHandler.logError(e, context: 'updateFarm');
      rethrow;
    }
  }

  // ---------------- DELETE FARM ----------------

  @override
  Future<void> deleteFarm(String farmId) async {
    try {
      await _firestore.collection(_farmsCollection).doc(farmId).delete();
    } catch (e) {
      ErrorHandler.logError(e, context: 'deleteFarm');
      rethrow;
    }
  }

  // ---------------- GET SINGLE FARM ----------------

  @override
  Future<FarmModel?> getFarm(String farmId) async {
    try {
      final doc =
          await _firestore.collection(_farmsCollection).doc(farmId).get();

      if (!doc.exists) return null;

      return FarmModel.fromJson(doc.data()!);
    } catch (e) {
      ErrorHandler.logError(e, context: 'getFarm');
      rethrow;
    }
  }
}

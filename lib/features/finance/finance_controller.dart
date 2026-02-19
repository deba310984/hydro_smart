import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'finance_model.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository();
});

final financeDataProvider = StreamProvider<FinanceData?>((ref) {
  final repository = ref.watch(financeRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value(null);
  }

  return repository.getFinanceDataStream(user.uid);
});

final financeControllerProvider =
    StateNotifierProvider<FinanceController, AsyncValue<void>>((ref) {
  final repository = ref.watch(financeRepositoryProvider);
  return FinanceController(repository);
});

class FinanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<FinanceData?> getFinanceDataStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('finance')
        .doc('monthly')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        // Return default values if document doesn't exist
        return FinanceData(
          userId: userId,
          electricityCost: 1200,
          waterCost: 300,
          nutrientCost: 800,
          laborCost: 500,
          estimatedRevenue: 4500,
          lastUpdated: DateTime.now(),
        );
      }
      return FinanceData.fromJson(snapshot.data()!, userId);
    });
  }

  Future<void> updateExpense(
    String userId,
    String expenseType,
    double amount,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('finance')
          .doc('monthly')
          .update({
        expenseType: amount,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // If document doesn't exist, create it
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('finance')
          .doc('monthly')
          .set({
        expenseType: amount,
        'lastUpdated': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateRevenue(String userId, double amount) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('finance')
          .doc('monthly')
          .update({
        'estimatedRevenue': amount,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('finance')
          .doc('monthly')
          .set({
        'estimatedRevenue': amount,
        'lastUpdated': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }
  }
}

class FinanceController extends StateNotifier<AsyncValue<void>> {
  final FinanceRepository _repository;

  FinanceController(this._repository) : super(const AsyncValue.data(null));

  Future<void> updateElectricity(String userId, double amount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repository.updateExpense(userId, 'electricityCost', amount));
  }

  Future<void> updateWater(String userId, double amount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repository.updateExpense(userId, 'waterCost', amount));
  }

  Future<void> updateNutrients(String userId, double amount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repository.updateExpense(userId, 'nutrientCost', amount));
  }

  Future<void> updateLabor(String userId, double amount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repository.updateExpense(userId, 'laborCost', amount));
  }

  Future<void> updateRevenue(String userId, double amount) async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() => _repository.updateRevenue(userId, amount));
  }
}

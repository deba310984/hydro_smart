import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydro_smart/data/models/farm_model.dart';
import 'package:hydro_smart/data/repositories/farm_repository_impl.dart';
import 'package:hydro_smart/domain/repositories/farm_repository.dart';

/// Riverpod provider for FarmRepository singleton
final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepositoryImpl();
});

/// Riverpod provider for streaming user farms
/// Dependencies: current authenticated user
final userFarmsStreamProvider = StreamProvider.family<List<FarmModel>, String>((
  ref,
  userId,
) {
  final farmRepository = ref.watch(farmRepositoryProvider);
  return farmRepository.streamUserFarms(userId);
});

/// Farm state for StateNotifier
class FarmState {
  final List<FarmModel> farms;
  final FarmModel? selectedFarm;
  final bool isLoading;
  final String? error;

  FarmState({
    this.farms = const [],
    this.selectedFarm,
    this.isLoading = false,
    this.error,
  });

  FarmState copyWith({
    List<FarmModel>? farms,
    FarmModel? selectedFarm,
    bool? isLoading,
    String? error,
  }) {
    return FarmState(
      farms: farms ?? this.farms,
      selectedFarm: selectedFarm ?? this.selectedFarm,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// StateNotifier for managing farm operations
class FarmController extends StateNotifier<FarmState> {
  final FarmRepository _farmRepository;
  final String _userId;

  FarmController({
    required FarmRepository farmRepository,
    required String userId,
  })  : _farmRepository = farmRepository,
        _userId = userId,
        super(FarmState());

  /// Load all farms for current user
  Future<void> loadFarms() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final farms = await _farmRepository.getUserFarms(_userId);
      state = state.copyWith(farms: farms, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      rethrow;
    }
  }

  /// Create a new farm
  Future<String> createFarm({
    required String name,
    required String location,
    required String deviceId,
    required double area,
    required String cropType,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final farm = FarmModel(
        id: '', // Will be set by repository
        name: name,
        location: location,
        deviceId: deviceId,
        area: area,
        cropType: cropType,
        createdAt: DateTime.now(),
        isActive: true,
      );

      final farmId = await _farmRepository.createFarm(_userId, farm);

      // Reload farms to update state
      await loadFarms();
      state = state.copyWith(isLoading: false);

      return farmId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      rethrow;
    }
  }

  /// Update existing farm
  Future<void> updateFarm({
    required String farmId,
    required String name,
    required String location,
    required String deviceId,
    required double area,
    required String cropType,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final currentFarm = state.farms.firstWhere(
        (farm) => farm.id == farmId,
        orElse: () => throw Exception('Farm not found'),
      );

      final updatedFarm = currentFarm.copyWith(
        name: name,
        location: location,
        deviceId: deviceId,
        area: area,
        cropType: cropType,
      );

      await _farmRepository.updateFarm(farmId, updatedFarm);

      // Reload farms to update state
      await loadFarms();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      rethrow;
    }
  }

  /// Delete a farm
  Future<void> deleteFarm(String farmId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _farmRepository.deleteFarm(farmId);

      // Reload farms to update state
      await loadFarms();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      rethrow;
    }
  }

  /// Select a farm
  void selectFarm(FarmModel farm) {
    state = state.copyWith(selectedFarm: farm);
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(selectedFarm: null);
  }

  /// Format error message for user display
  String _formatError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}

/// StateNotifierProvider for FarmController
/// Depends on current authenticated user
final farmControllerProvider =
    StateNotifierProvider.family<FarmController, FarmState, String>((
  ref,
  userId,
) {
  final farmRepository = ref.watch(farmRepositoryProvider);
  return FarmController(farmRepository: farmRepository, userId: userId);
});

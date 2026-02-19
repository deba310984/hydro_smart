import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydro_smart/data/models/recommendation_model.dart';
// import 'package:hydro_smart/data/repositories/mock_recommendation_repository.dart';
import 'package:hydro_smart/data/repositories/recommendation_repository_impl.dart';
import 'package:hydro_smart/domain/repositories/recommendation_repository.dart';

/// Riverpod provider for RecommendationRepository singleton
final recommendationRepositoryProvider = Provider<RecommendationRepository>((
  ref,
) {
  // Use real repository implementation pointing to local Python backend
  return RecommendationRepositoryImpl();
  // return MockRecommendationRepository();
});

/// Get single crop recommendation based on current sensor readings
/// Parameters: (temperature, humidity, pH, farmSize)
final getRecommendationProvider = FutureProvider.family<RecommendationModel,
    (double, double, double, double)>((ref, params) {
  final repository = ref.watch(recommendationRepositoryProvider);
  final (temperature, humidity, ph, farmSize) = params;

  return repository.getRecommendation(
    currentTemperature: temperature,
    currentHumidity: humidity,
    currentPh: ph,
    farmSize: farmSize,
  );
});

/// Get multiple crop recommendations for comparison
/// Parameters: (temperature, humidity, pH, farmSize, recommendationCount)
final getMultipleRecommendationsProvider = FutureProvider.family<
    List<RecommendationModel>,
    (double, double, double, double, int)>((ref, params) {
  final repository = ref.watch(recommendationRepositoryProvider);
  final (temperature, humidity, ph, farmSize, count) = params;

  return repository.getMultipleRecommendations(
    currentTemperature: temperature,
    currentHumidity: humidity,
    currentPh: ph,
    farmSize: farmSize,
    count: count,
  );
});

/// Evaluate crop compatibility with current conditions
/// Parameters: (cropName, temperature, humidity, pH)
final evaluateCropCompatibilityProvider =
    FutureProvider.family<double, (String, double, double, double)>((
  ref,
  params,
) {
  final repository = ref.watch(recommendationRepositoryProvider);
  final (cropName, temperature, humidity, ph) = params;

  return repository.evaluateCropCompatibility(
    cropName: cropName,
    currentTemperature: temperature,
    currentHumidity: humidity,
    currentPh: ph,
  );
});

/// Recommendation controller state
class RecommendationState {
  final RecommendationModel? primaryRecommendation;
  final List<RecommendationModel> alternativeRecommendations;
  final bool isLoading;
  final String? error;
  final Map<String, double> compatibilityScores;

  RecommendationState({
    this.primaryRecommendation,
    this.alternativeRecommendations = const [],
    this.isLoading = false,
    this.error,
    this.compatibilityScores = const {},
  });

  RecommendationState copyWith({
    RecommendationModel? primaryRecommendation,
    List<RecommendationModel>? alternativeRecommendations,
    bool? isLoading,
    String? error,
    Map<String, double>? compatibilityScores,
  }) {
    return RecommendationState(
      primaryRecommendation:
          primaryRecommendation ?? this.primaryRecommendation,
      alternativeRecommendations:
          alternativeRecommendations ?? this.alternativeRecommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      compatibilityScores: compatibilityScores ?? this.compatibilityScores,
    );
  }
}

/// StateNotifier for managing crop recommendations
class RecommendationController extends StateNotifier<RecommendationState> {
  final RecommendationRepository _repository;

  RecommendationController(this._repository) : super(RecommendationState());

  /// Fetch primary recommendation and alternatives
  Future<void> fetchRecommendations({
    required double temperature,
    required double humidity,
    required double ph,
    required double farmSize,
    int alternativeCount = 2,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Fetch primary recommendation and alternatives in parallel
      final (primary, alternatives) = await Future.wait([
        _repository.getRecommendation(
          currentTemperature: temperature,
          currentHumidity: humidity,
          currentPh: ph,
          farmSize: farmSize,
        ),
        _repository.getMultipleRecommendations(
          currentTemperature: temperature,
          currentHumidity: humidity,
          currentPh: ph,
          farmSize: farmSize,
          count: alternativeCount,
        ),
      ]).then(
        (values) => (
          values[0] as RecommendationModel,
          values[1] as List<RecommendationModel>,
        ),
      );

      state = state.copyWith(
        primaryRecommendation: primary,
        alternativeRecommendations: alternatives,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      rethrow;
    }
  }

  /// Evaluate compatibility score for a specific crop
  Future<double> evaluateCompatibility({
    required String cropName,
    required double temperature,
    required double humidity,
    required double ph,
  }) async {
    try {
      final score = await _repository.evaluateCropCompatibility(
        cropName: cropName,
        currentTemperature: temperature,
        currentHumidity: humidity,
        currentPh: ph,
      );

      // Store score in map
      final updatedScores = {...state.compatibilityScores};
      updatedScores[cropName] = score;

      state = state.copyWith(compatibilityScores: updatedScores);
      return score;
    } catch (e) {
      state = state.copyWith(error: _formatError(e));
      rethrow;
    }
  }

  /// Get compatibility score for crop (returns cached value if available)
  double? getCompatibilityScore(String cropName) {
    return state.compatibilityScores[cropName];
  }

  /// Clear recommendations
  void clearRecommendations() {
    state = RecommendationState();
  }

  /// Format error message for user display
  String _formatError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}

/// StateNotifierProvider for RecommendationController
final recommendationControllerProvider =
    StateNotifierProvider<RecommendationController, RecommendationState>((ref) {
  final repository = ref.watch(recommendationRepositoryProvider);
  return RecommendationController(repository);
});

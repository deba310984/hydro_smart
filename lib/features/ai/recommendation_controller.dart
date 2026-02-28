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

/// Get the repository implementation for extended methods
final recommendationRepoImplProvider = Provider<RecommendationRepositoryImpl>((
  ref,
) {
  return RecommendationRepositoryImpl();
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
  final String? selectedState;
  final String? selectedCategory;
  final String? selectedDifficulty;
  final SeasonalRecommendation? seasonalData;

  RecommendationState({
    this.primaryRecommendation,
    this.alternativeRecommendations = const [],
    this.isLoading = false,
    this.error,
    this.compatibilityScores = const {},
    this.selectedState,
    this.selectedCategory,
    this.selectedDifficulty,
    this.seasonalData,
  });

  RecommendationState copyWith({
    RecommendationModel? primaryRecommendation,
    List<RecommendationModel>? alternativeRecommendations,
    bool? isLoading,
    String? error,
    Map<String, double>? compatibilityScores,
    String? selectedState,
    String? selectedCategory,
    String? selectedDifficulty,
    SeasonalRecommendation? seasonalData,
  }) {
    return RecommendationState(
      primaryRecommendation:
          primaryRecommendation ?? this.primaryRecommendation,
      alternativeRecommendations:
          alternativeRecommendations ?? this.alternativeRecommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      compatibilityScores: compatibilityScores ?? this.compatibilityScores,
      selectedState: selectedState ?? this.selectedState,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      seasonalData: seasonalData ?? this.seasonalData,
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
    int alternativeCount = 5,
    String? state,
    String? category,
    String? difficulty,
  }) async {
    try {
      state ??= this.state.selectedState;
      category ??= this.state.selectedCategory;
      difficulty ??= this.state.selectedDifficulty;

      this.state = this.state.copyWith(
            isLoading: true,
            error: null,
            selectedState: state,
            selectedCategory: category,
            selectedDifficulty: difficulty,
          );

      final currentMonth = DateTime.now().month;

      // Fetch primary recommendation and alternatives in parallel
      final (primary, alternatives) = await Future.wait([
        _repository.getRecommendation(
          currentTemperature: temperature,
          currentHumidity: humidity,
          currentPh: ph,
          farmSize: farmSize,
          state: state,
          month: currentMonth,
        ),
        _repository.getMultipleRecommendations(
          currentTemperature: temperature,
          currentHumidity: humidity,
          currentPh: ph,
          farmSize: farmSize,
          count: alternativeCount,
          state: state,
          month: currentMonth,
          category: category,
          difficulty: difficulty,
        ),
      ]).then(
        (values) => (
          values[0] as RecommendationModel,
          values[1] as List<RecommendationModel>,
        ),
      );

      this.state = this.state.copyWith(
            primaryRecommendation: primary,
            alternativeRecommendations: alternatives,
            isLoading: false,
          );
    } catch (e) {
      this.state =
          this.state.copyWith(isLoading: false, error: _formatError(e));
      rethrow;
    }
  }

  /// Update selected state for regional recommendations
  void setSelectedState(String? stateName) {
    state = state.copyWith(selectedState: stateName);
  }

  /// Update selected category filter
  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Update selected difficulty filter
  void setSelectedDifficulty(String? difficulty) {
    state = state.copyWith(selectedDifficulty: difficulty);
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

/// List of Indian states for dropdown
const List<String> indianStates = [
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
  'Delhi',
  'Jammu and Kashmir',
  'Ladakh',
  'Puducherry',
];

/// Crop categories for filtering
const List<Map<String, String>> cropCategories = [
  {'id': 'leafy_greens', 'name': 'Leafy Greens', 'emoji': '🥬'},
  {'id': 'herbs', 'name': 'Herbs', 'emoji': '🌿'},
  {'id': 'fruiting_vegetables', 'name': 'Fruiting Vegetables', 'emoji': '🍅'},
  {'id': 'asian_vegetables', 'name': 'Asian Vegetables', 'emoji': '🥢'},
  {'id': 'root_vegetables', 'name': 'Root Vegetables', 'emoji': '🥕'},
];

/// Difficulty levels
const List<Map<String, String>> difficultyLevels = [
  {'id': 'beginner', 'name': 'Beginner', 'color': '#4CAF50'},
  {'id': 'intermediate', 'name': 'Intermediate', 'color': '#FF9800'},
  {'id': 'advanced', 'name': 'Advanced', 'color': '#F44336'},
];

import '../../data/models/recommendation_model.dart';

abstract class RecommendationRepository {
  /// Get AI crop recommendation based on current sensor readings
  /// [currentTemperature] Current temperature in °C
  /// [currentHumidity] Current humidity in %
  /// [currentPh] Current pH level
  /// [farmSize] Farm area in m²
  /// [state] Optional Indian state for regional recommendations
  /// [month] Optional month (1-12) for seasonal recommendations
  /// Returns a [RecommendationModel] with crop suggestion and optimal conditions
  Future<RecommendationModel> getRecommendation({
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
    required double farmSize,
    String? state,
    int? month,
  });

  /// Get multiple crop recommendations for comparison
  /// [category] Optional filter by crop category (leafy_greens, herbs, etc.)
  /// [difficulty] Optional filter by difficulty level (beginner, intermediate, advanced)
  Future<List<RecommendationModel>> getMultipleRecommendations({
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
    required double farmSize,
    required int count,
    String? state,
    int? month,
    String? category,
    String? difficulty,
  });

  /// Evaluate compatibility between current conditions and a specific crop
  /// Returns a score 0-100 indicating how suitable the conditions are
  Future<double> evaluateCropCompatibility({
    required String cropName,
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
  });
}

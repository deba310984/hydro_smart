import '../../data/models/recommendation_model.dart';

abstract class RecommendationRepository {
  /// Get AI crop recommendation based on current sensor readings
  /// [currentTemperature] Current temperature in °C
  /// [currentHumidity] Current humidity in %
  /// [currentPh] Current pH level
  /// [farmSize] Farm area in m²
  /// Returns a [RecommendationModel] with crop suggestion and optimal conditions
  Future<RecommendationModel> getRecommendation({
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
    required double farmSize,
  });

  /// Get multiple crop recommendations for comparison
  Future<List<RecommendationModel>> getMultipleRecommendations({
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
    required double farmSize,
    required int count,
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

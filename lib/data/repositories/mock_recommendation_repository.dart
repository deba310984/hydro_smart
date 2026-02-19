import 'package:hydro_smart/data/models/recommendation_model.dart';
import 'package:hydro_smart/domain/repositories/recommendation_repository.dart';

/// Mock implementation of RecommendationRepository
class MockRecommendationRepository implements RecommendationRepository {
  @override
  Future<RecommendationModel> getRecommendation({
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
    required double farmSize,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple logic to return different crops based on temp
    if (currentTemperature > 20) {
      return RecommendationModel(
        id: 'mock_1',
        recommendedCrop: 'Tomato',
        reasoning: 'Temperature and humidity are optimal for tomatoes.',
        optimalTemperature: 25.0,
        optimalHumidity: 70.0,
        optimalPh: 6.5,
        optimalWaterLevel: 80.0,
        growthDaysEstimate: 60.0,
        difficulty: 'Medium',
        benefits: const ['High yield', 'Popular market crop'],
        challenges: const ['Requires support/staking', 'Sensitive to pests'],
        timestamp: DateTime.now(), // This will be dynamic
      );
    } else {
      return RecommendationModel(
        id: 'mock_2',
        recommendedCrop: 'Lettuce',
        reasoning: 'Cooler temperature is perfect for lettuce.',
        optimalTemperature: 18.0,
        optimalHumidity: 60.0,
        optimalPh: 6.0,
        optimalWaterLevel: 70.0,
        growthDaysEstimate: 30.0,
        difficulty: 'Easy',
        benefits: const ['Fast growth', 'Low light requirement'],
        challenges: const ['Bolting in heat', 'Needs consistent water'],
        timestamp: DateTime.now(), // This will be dynamic
      );
    }
  }

  @override
  Future<List<RecommendationModel>> getMultipleRecommendations({
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
    required double farmSize,
    required int count,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      RecommendationModel(
        id: 'mock_1',
        recommendedCrop: 'Tomato',
        reasoning: 'Good match for warm conditions.',
        optimalTemperature: 25.0,
        optimalHumidity: 70.0,
        optimalPh: 6.5,
        optimalWaterLevel: 80.0,
        growthDaysEstimate: 60.0,
        difficulty: 'Medium',
        benefits: const ['High yield', 'Popular'],
        challenges: const ['Support needed'],
        timestamp: DateTime.now(),
      ),
      RecommendationModel(
        id: 'mock_2',
        recommendedCrop: 'Peppers',
        reasoning: 'Also thrives in current setup.',
        optimalTemperature: 26.0,
        optimalHumidity: 65.0,
        optimalPh: 6.8,
        optimalWaterLevel: 75.0,
        growthDaysEstimate: 70.0,
        difficulty: 'Medium',
        benefits: const ['High value', 'Colorful'],
        challenges: const ['Slow start'],
        timestamp: DateTime.now(),
      ),
      RecommendationModel(
        id: 'mock_3',
        recommendedCrop: 'Cucumber',
        reasoning: 'Alternative fast grower.',
        optimalTemperature: 24.0,
        optimalHumidity: 80.0,
        optimalPh: 6.0,
        optimalWaterLevel: 90.0,
        growthDaysEstimate: 50.0,
        difficulty: 'Easy',
        benefits: const ['Fast harvest'],
        challenges: const ['Needs space/trellis'],
        timestamp: DateTime.now(),
      ),
    ].take(count).toList();
  }

  @override
  Future<double> evaluateCropCompatibility({
    required String cropName,
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Randomish score
    return 0.85;
  }
}

import 'package:hydro_smart/data/models/recommendation_model.dart';
import 'package:hydro_smart/domain/repositories/recommendation_repository.dart';

/// Mock implementation of [RecommendationRepository] for offline demos and tests.
class MockRecommendationRepository implements RecommendationRepository {
  @override
  Future<RecommendationModel> getRecommendation({
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
    required double farmSize,
    String? state,
    int? month,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (currentTemperature > 20) {
      return _sample(
        id: 'mock_1',
        crop: 'Tomato',
        emoji: '🍅',
        tempMin: 20,
        tempMax: 28,
        humidityMin: 60,
        humidityMax: 80,
        phMin: 5.8,
        phMax: 6.8,
        days: 60,
        difficulty: 'intermediate',
        description:
            'Temperature and humidity are optimal for tomatoes in your setup.',
      );
    }

    return _sample(
      id: 'mock_2',
      crop: 'Lettuce',
      emoji: '🥬',
      tempMin: 15,
      tempMax: 22,
      humidityMin: 50,
      humidityMax: 70,
      phMin: 5.5,
      phMax: 6.5,
      days: 30,
      difficulty: 'beginner',
      description: 'Cooler temperature is well suited for lettuce.',
    );
  }

  @override
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
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final all = [
      _sample(
        id: 'mock_1',
        crop: 'Tomato',
        emoji: '🍅',
        tempMin: 20,
        tempMax: 28,
        humidityMin: 60,
        humidityMax: 80,
        phMin: 5.8,
        phMax: 6.8,
        days: 60,
        difficulty: 'intermediate',
        description: 'Good match for warm conditions.',
      ),
      _sample(
        id: 'mock_2',
        crop: 'Peppers',
        emoji: '🌶️',
        tempMin: 22,
        tempMax: 30,
        humidityMin: 55,
        humidityMax: 75,
        phMin: 5.8,
        phMax: 7.0,
        days: 70,
        difficulty: 'intermediate',
        description: 'Also thrives in your current setup.',
      ),
      _sample(
        id: 'mock_3',
        crop: 'Cucumber',
        emoji: '🥒',
        tempMin: 18,
        tempMax: 26,
        humidityMin: 65,
        humidityMax: 85,
        phMin: 5.5,
        phMax: 6.5,
        days: 50,
        difficulty: 'beginner',
        description: 'Fast-growing alternative for hydroponic farms.',
      ),
    ];

    return all.take(count).toList();
  }

  @override
  Future<double> evaluateCropCompatibility({
    required String cropName,
    required double currentTemperature,
    required double currentHumidity,
    required double currentPh,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 0.85;
  }

  static RecommendationModel _sample({
    required String id,
    required String crop,
    required String emoji,
    required double tempMin,
    required double tempMax,
    required double humidityMin,
    required double humidityMax,
    required double phMin,
    required double phMax,
    required int days,
    required String difficulty,
    required String description,
  }) {
    return RecommendationModel(
      id: id,
      recommendedCrop: crop,
      cropEmoji: emoji,
      category: 'vegetables',
      description: description,
      compatibilityScore: 85,
      difficultyLevel: difficulty,
      daysToHarvest: days,
      yieldPerSqm: 8,
      profitMargin: 35,
      waterConsumption: 'medium',
      marketDemand: 'high',
      temperatureRange: {'min': tempMin, 'max': tempMax},
      humidityRange: {'min': humidityMin, 'max': humidityMax},
      phRange: {'min': phMin, 'max': phMax},
      bestHydroponicSystems: const ['NFT', 'DWC'],
      tips: const ['Monitor EC weekly', 'Ensure adequate airflow'],
      timestamp: DateTime.now(),
    );
  }
}

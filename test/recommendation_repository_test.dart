import 'package:flutter_test/flutter_test.dart';
import 'package:hydro_smart/data/models/recommendation_model.dart';
import 'package:hydro_smart/data/repositories/mock_recommendation_repository.dart';

void main() {
  late MockRecommendationRepository repository;

  setUp(() {
    repository = MockRecommendationRepository();
  });

  group('MockRecommendationRepository Tests', () {
    test('getRecommendation returns Tomato for high temperature', () async {
      final result = await repository.getRecommendation(
        currentTemperature: 25.0,
        currentHumidity: 60.0,
        currentPh: 6.5,
        farmSize: 100.0,
      );

      expect(result, isA<RecommendationModel>());
      expect(result.recommendedCrop, 'Tomato');
      expect(result.optimalTemperature, 25.0);
    });

    test('getRecommendation returns Lettuce for low temperature', () async {
      final result = await repository.getRecommendation(
        currentTemperature: 18.0,
        currentHumidity: 60.0,
        currentPh: 6.5,
        farmSize: 100.0,
      );

      expect(result, isA<RecommendationModel>());
      expect(result.recommendedCrop, 'Lettuce');
      expect(result.optimalTemperature, 18.0);
    });

    test('getMultipleRecommendations returns requested count', () async {
      final results = await repository.getMultipleRecommendations(
        currentTemperature: 25.0,
        currentHumidity: 60.0,
        currentPh: 6.5,
        farmSize: 100.0,
        count: 2,
      );

      expect(results.length, 2);
      expect(results[0].recommendedCrop, 'Tomato');
      expect(results[1].recommendedCrop, 'Peppers');
    });

    test('evaluateCropCompatibility returns a score', () async {
      final score = await repository.evaluateCropCompatibility(
        cropName: 'Tomato',
        currentTemperature: 25.0,
        currentHumidity: 60.0,
        currentPh: 6.5,
      );

      expect(score, isA<double>());
      expect(score, greaterThanOrEqualTo(0.0));
      expect(score, lessThanOrEqualTo(1.0));
    });
  });
}

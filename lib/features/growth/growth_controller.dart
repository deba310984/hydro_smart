import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'growth_model.dart';

final growthDataProvider = Provider<GrowthData>((ref) {
  return GrowthData(
    cropName: 'Lettuce',
    daysSincePlantation: 15,
    totalGrowthDays: 30,
    expectedHarvestDate: DateTime.now().add(const Duration(days: 15)),
  );
});

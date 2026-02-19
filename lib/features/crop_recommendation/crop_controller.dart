import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'crop_model.dart';

final cropRecommendationProvider = Provider<List<CropRecommendation>>((ref) {
  return [
    CropRecommendation(
      cropName: 'Lettuce',
      durationDays: 30,
      profitMarginPercent: 40,
      waterUsage: 'Low',
      soilPh: 6.5,
      temperature: 18,
      humidity: 65,
      riskLevel: 'Low',
      icon: '🥬',
    ),
    CropRecommendation(
      cropName: 'Spinach',
      durationDays: 25,
      profitMarginPercent: 35,
      waterUsage: 'Medium',
      soilPh: 6.8,
      temperature: 15,
      humidity: 70,
      riskLevel: 'Low',
      icon: '🌿',
    ),
    CropRecommendation(
      cropName: 'Tomato',
      durationDays: 60,
      profitMarginPercent: 55,
      waterUsage: 'High',
      soilPh: 6.2,
      temperature: 22,
      humidity: 60,
      riskLevel: 'Medium',
      icon: '🍅',
    ),
    CropRecommendation(
      cropName: 'Basil',
      durationDays: 20,
      profitMarginPercent: 45,
      waterUsage: 'Medium',
      soilPh: 6.5,
      temperature: 20,
      humidity: 75,
      riskLevel: 'Low',
      icon: '🌱',
    ),
  ];
});

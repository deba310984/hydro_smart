import 'package:flutter/material.dart';
import '../models/crop.dart';
import '../../domain/models/crop_filters.dart';

class CropRepository {
  // Mock crops data for testing
  static final List<Crop> _mockCrops = [
    Crop(
      id: 'crop_tomato_001',
      cropName: 'Cherry Tomato',
      imageUrl: 'https://via.placeholder.com/300x200?text=Cherry+Tomato',
      commonNames: ['Sweet Tomato', 'Tiny Tim'],
      phRange: {'min': 6.0, 'max': 6.8, 'optimal': 6.5},
      temperatureRange: {
        'min': 15,
        'max': 28,
        'optimal': 22,
        'unit': 'celsius'
      },
      lightRequirement: {
        'daily_hours': 16,
        'lux_min': 300,
        'lux_recommended': 500
      },
      waterRequirement: {
        'daily_liters_per_sqm': 2.5,
        'change_frequency': 'every 2-3 weeks'
      },
      seedToHarvestDays: 60,
      yieldPerSqm: 25.0,
      expectedPlantsPerSqm: 6,
      hydroponicTechniques: {
        'NFT': {'compatible': true, 'yield_adjustment': 1.0},
        'DWC': {'compatible': true, 'yield_adjustment': 0.95},
        'Drip': {'compatible': true, 'yield_adjustment': 1.05},
        'Aeroponics': {'compatible': true, 'yield_adjustment': 1.1},
      },
      bestSeason: 'summer',
      marketDemandLevel: 'very-high',
      profitMargin: 65.0,
      retailPrice: 5.5,
      wholesalePrice: 2.0,
      difficultyLevel: 'beginner',
      mainChallenges: ['Pest management', 'Flower drop in heat'],
      suitableForBeginners: true,
      description:
          'Cherry tomatoes are prolific producers ideal for hydroponic systems. Perfect for beginners with excellent year-round yield potential.',
      advantages: [
        'High yield in compact spaces',
        'Multiple harvests per season',
        'Disease resistance in controlled environment',
        'Year-round production possible'
      ],
      challenges: [
        'Pest management (whiteflies, mites)',
        'Flower drop in high temperatures',
        'Nutrient burn susceptibility'
      ],
      createdAt: DateTime.now(),
    ),
    Crop(
      id: 'crop_lettuce_001',
      cropName: 'Butterhead Lettuce',
      imageUrl: 'https://via.placeholder.com/300x200?text=Butterhead+Lettuce',
      commonNames: ['Butter Lettuce', 'Boston Lettuce'],
      phRange: {'min': 6.0, 'max': 7.0, 'optimal': 6.5},
      temperatureRange: {
        'min': 10,
        'max': 25,
        'optimal': 18,
        'unit': 'celsius'
      },
      lightRequirement: {
        'daily_hours': 12,
        'lux_min': 200,
        'lux_recommended': 400
      },
      waterRequirement: {
        'daily_liters_per_sqm': 1.5,
        'change_frequency': 'every 2-3 weeks'
      },
      seedToHarvestDays: 45,
      yieldPerSqm: 18.0,
      expectedPlantsPerSqm: 9,
      hydroponicTechniques: {
        'NFT': {'compatible': true, 'yield_adjustment': 1.2},
        'DWC': {'compatible': true, 'yield_adjustment': 1.15},
        'Drip': {'compatible': true, 'yield_adjustment': 1.0},
        'Aeroponics': {'compatible': true, 'yield_adjustment': 1.1},
      },
      bestSeason: 'spring',
      marketDemandLevel: 'high',
      profitMargin: 55.0,
      retailPrice: 3.2,
      wholesalePrice: 1.2,
      difficultyLevel: 'beginner',
      mainChallenges: ['Bolting in heat', 'Tip burn from calcium deficiency'],
      suitableForBeginners: true,
      description:
          'Butterhead lettuces are ideal for NFT systems with rapid growth cycles. Perfect for commercial high-volume production.',
      advantages: [
        'Fast growing (45 days)',
        'Year-round production in cool conditions',
        'High plant density possible',
        'Minimal pest pressure with good sanitation'
      ],
      challenges: [
        'Bolting in warm temperatures',
        'Tip burn from calcium imbalance',
        'Requires consistent humidity'
      ],
      createdAt: DateTime.now(),
    ),
    Crop(
      id: 'crop_spinach_001',
      cropName: 'Spinach',
      imageUrl: 'https://via.placeholder.com/300x200?text=Spinach',
      commonNames: ['Baby Spinach', 'Flat-leaf Spinach'],
      phRange: {'min': 6.5, 'max': 7.0, 'optimal': 6.8},
      temperatureRange: {
        'min': 12,
        'max': 24,
        'optimal': 18,
        'unit': 'celsius'
      },
      lightRequirement: {
        'daily_hours': 12,
        'lux_min': 250,
        'lux_recommended': 450
      },
      waterRequirement: {
        'daily_liters_per_sqm': 1.8,
        'change_frequency': 'every 2-3 weeks'
      },
      seedToHarvestDays: 40,
      yieldPerSqm: 20.0,
      expectedPlantsPerSqm: 16,
      hydroponicTechniques: {
        'NFT': {'compatible': true, 'yield_adjustment': 1.25},
        'DWC': {'compatible': true, 'yield_adjustment': 1.2},
        'Drip': {'compatible': true, 'yield_adjustment': 1.0},
        'Aeroponics': {'compatible': true, 'yield_adjustment': 1.15},
      },
      bestSeason: 'winter',
      marketDemandLevel: 'very-high',
      profitMargin: 60.0,
      retailPrice: 4.0,
      wholesalePrice: 1.5,
      difficultyLevel: 'beginner',
      mainChallenges: ['Powdery mildew in humid conditions'],
      suitableForBeginners: true,
      description:
          'Spinach is one of the most profitable hydroponic crops with fast growth and year-round demand.',
      advantages: [
        'Very fast growth (40 days)',
        'High market demand year-round',
        'Excellent profit margins',
        'Good for stacked vertical systems'
      ],
      challenges: [
        'Powdery mildew in high humidity',
        'Requires excellent air circulation',
        'Bolting in warm temperatures'
      ],
      createdAt: DateTime.now(),
    ),
    Crop(
      id: 'crop_cucumber_001',
      cropName: 'Cucumber',
      imageUrl: 'https://via.placeholder.com/300x200?text=Cucumber',
      commonNames: ['English Cucumber', 'Pickling Cucumber'],
      phRange: {'min': 5.5, 'max': 6.8, 'optimal': 6.0},
      temperatureRange: {
        'min': 18,
        'max': 30,
        'optimal': 24,
        'unit': 'celsius'
      },
      lightRequirement: {
        'daily_hours': 14,
        'lux_min': 400,
        'lux_recommended': 600
      },
      waterRequirement: {
        'daily_liters_per_sqm': 3.0,
        'change_frequency': 'every 1-2 weeks'
      },
      seedToHarvestDays: 50,
      yieldPerSqm: 30.0,
      expectedPlantsPerSqm: 4,
      hydroponicTechniques: {
        'NFT': {'compatible': false, 'yield_adjustment': 0.8},
        'DWC': {'compatible': true, 'yield_adjustment': 0.9},
        'Drip': {'compatible': true, 'yield_adjustment': 1.2},
        'Aeroponics': {'compatible': false, 'yield_adjustment': 0.7},
      },
      bestSeason: 'summer',
      marketDemandLevel: 'high',
      profitMargin: 50.0,
      retailPrice: 2.8,
      wholesalePrice: 1.0,
      difficultyLevel: 'intermediate',
      mainChallenges: ['Powdery mildew', 'Pollination requirements'],
      suitableForBeginners: false,
      description:
          'Cucumbers offer strong yields in drip and DWC systems but require careful pollination and disease management.',
      advantages: [
        'High yields (30 kg/m²)',
        'Good market demand',
        'Extended harvest period',
        'Grows vertically for space savings'
      ],
      challenges: [
        'Requires pollination (manual or bees)',
        'Powdery mildew susceptibility',
        'High nutrient demand',
        'Sensitive to pH fluctuations'
      ],
      createdAt: DateTime.now(),
    ),
    Crop(
      id: 'crop_basil_001',
      cropName: 'Sweet Basil',
      imageUrl: 'https://via.placeholder.com/300x200?text=Sweet+Basil',
      commonNames: ['Italian Basil', 'Genovese Basil'],
      phRange: {'min': 6.0, 'max': 7.0, 'optimal': 6.5},
      temperatureRange: {
        'min': 15,
        'max': 28,
        'optimal': 22,
        'unit': 'celsius'
      },
      lightRequirement: {
        'daily_hours': 14,
        'lux_min': 300,
        'lux_recommended': 500
      },
      waterRequirement: {
        'daily_liters_per_sqm': 1.5,
        'change_frequency': 'every 2-3 weeks'
      },
      seedToHarvestDays: 35,
      yieldPerSqm: 15.0,
      expectedPlantsPerSqm: 8,
      hydroponicTechniques: {
        'NFT': {'compatible': true, 'yield_adjustment': 1.1},
        'DWC': {'compatible': true, 'yield_adjustment': 1.0},
        'Drip': {'compatible': true, 'yield_adjustment': 1.2},
        'Aeroponics': {'compatible': true, 'yield_adjustment': 1.15},
      },
      bestSeason: 'year-round',
      marketDemandLevel: 'medium',
      profitMargin: 70.0,
      retailPrice: 12.0,
      wholesalePrice: 4.0,
      difficultyLevel: 'beginner',
      mainChallenges: ['Bolting when exposed to cold'],
      suitableForBeginners: true,
      description:
          'Basil is a premium herb crop with excellent profit margins and quick turnover. Perfect for year-round production.',
      advantages: [
        'Very fast growth (35 days)',
        'Premium pricing',
        'Compact growth habit',
        'Multiple harvests per plant',
        'High profit margins (70%+)'
      ],
      challenges: [
        'Sensitive to cold temperatures',
        'Requires warm conditions (>60°F)',
        'Limited shelf life after harvest'
      ],
      createdAt: DateTime.now(),
    ),
    Crop(
      id: 'crop_pepper_001',
      cropName: 'Bell Pepper',
      imageUrl: 'https://via.placeholder.com/300x200?text=Bell+Pepper',
      commonNames: ['Sweet Pepper', 'Capsicum'],
      phRange: {'min': 6.0, 'max': 6.8, 'optimal': 6.5},
      temperatureRange: {
        'min': 18,
        'max': 30,
        'optimal': 24,
        'unit': 'celsius'
      },
      lightRequirement: {
        'daily_hours': 14,
        'lux_min': 400,
        'lux_recommended': 600
      },
      waterRequirement: {
        'daily_liters_per_sqm': 2.5,
        'change_frequency': 'every 1-2 weeks'
      },
      seedToHarvestDays: 90,
      yieldPerSqm: 20.0,
      expectedPlantsPerSqm: 2,
      hydroponicTechniques: {
        'NFT': {'compatible': false, 'yield_adjustment': 0.7},
        'DWC': {'compatible': true, 'yield_adjustment': 0.8},
        'Drip': {'compatible': true, 'yield_adjustment': 1.1},
        'Aeroponics': {'compatible': false, 'yield_adjustment': 0.6},
      },
      bestSeason: 'summer',
      marketDemandLevel: 'high',
      profitMargin: 45.0,
      retailPrice: 3.5,
      wholesalePrice: 1.5,
      difficultyLevel: 'advanced',
      mainChallenges: [
        'Long growth cycle',
        'Pollination required',
        'Spider mites'
      ],
      suitableForBeginners: false,
      description:
          'Bell peppers require longer growing cycles but offer solid yields. Best in drip and DWC systems with pollination support.',
      advantages: [
        'Good yields over extended period',
        'Strong market demand',
        'Long shelf life',
        'Premium pricing in off-season'
      ],
      challenges: [
        'Long growth cycle (90 days)',
        'Requires pollination (bees/manual)',
        'High light requirement',
        'Spider mite susceptibility',
        'Higher operational costs'
      ],
      createdAt: DateTime.now(),
    ),
  ];

  /// Get all crops
  Future<List<Crop>> getAllCrops() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    return _mockCrops;
  }

  /// Filter crops based on criteria
  Future<List<Crop>> filterCrops(CropFilters filters) async {
    await Future.delayed(Duration(milliseconds: 300));

    var filtered = _mockCrops.where((crop) => crop.active).toList();

    // Filter by hydroponic technique
    if (filters.hydroponicTechniques != null &&
        filters.hydroponicTechniques!.isNotEmpty) {
      filtered = filtered.where((crop) {
        final compatible = crop.getCompatibleTechniques();
        return filters.hydroponicTechniques!
            .any((technique) => compatible.contains(technique));
      }).toList();
    }

    // Filter by growing season
    if (filters.growingSeasons != null && filters.growingSeasons!.isNotEmpty) {
      filtered = filtered.where((crop) {
        return filters.growingSeasons!.contains(crop.bestSeason) ||
            crop.bestSeason == 'year-round';
      }).toList();
    }

    // Filter by growth duration
    if (filters.growthDurationRange != null) {
      filtered = filtered.where((crop) {
        return crop.seedToHarvestDays >= filters.growthDurationRange!.start &&
            crop.seedToHarvestDays <= filters.growthDurationRange!.end;
      }).toList();
    }

    // Filter by profit margin
    if (filters.profitMarginRange != null) {
      filtered = filtered.where((crop) {
        return crop.profitMargin >= filters.profitMarginRange!.start &&
            crop.profitMargin <= filters.profitMarginRange!.end;
      }).toList();
    }

    // Filter by difficulty level
    if (filters.difficultyLevel != null) {
      filtered = filtered.where((crop) {
        return crop.difficultyLevel == filters.difficultyLevel;
      }).toList();
    }

    // Filter by market demand
    if (filters.marketDemandLevel != null) {
      filtered = filtered.where((crop) {
        return crop.marketDemandLevel == filters.marketDemandLevel;
      }).toList();
    }

    return filtered;
  }

  /// Get single crop by ID
  Future<Crop?> getCropById(String cropId) async {
    try {
      return _mockCrops.firstWhere((crop) => crop.id == cropId);
    } catch (e) {
      return null;
    }
  }

  /// Search crops by name
  Future<List<Crop>> searchCrops(String query) async {
    final lowerQuery = query.toLowerCase();
    return _mockCrops
        .where((crop) =>
            crop.cropName.toLowerCase().contains(lowerQuery) ||
            crop.commonNames
                .any((name) => name.toLowerCase().contains(lowerQuery)))
        .toList();
  }
}

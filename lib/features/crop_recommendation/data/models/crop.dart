class Crop {
  final String id;
  final String cropName;
  final String imageUrl;
  final List<String> commonNames;

  // Growing Conditions
  final Map<String, dynamic> phRange; // {min: 6.0, max: 7.0, optimal: 6.5}
  final Map<String, dynamic>
      temperatureRange; // {min: 20, max: 28, optimal: 24, unit: 'celsius'}
  final Map<String, dynamic>
      lightRequirement; // {daily_hours: 14, lux_min: 300}
  final Map<String, dynamic> waterRequirement;

  // Growth Metrics
  final int seedToHarvestDays;
  final double yieldPerSqm; // kg/m²
  final double expectedPlantsPerSqm;

  // Hydroponic Techniques
  final Map<String, dynamic>
      hydroponicTechniques; // {NFT: {compatible: true}, DWC: {compatible: false}}

  // Market Data
  final String bestSeason; // summer, winter, year-round, spring, autumn
  final String marketDemandLevel; // low, medium, high, very-high
  final double profitMargin; // percentage
  final double retailPrice; // USD/kg
  final double wholesalePrice; // USD/kg

  // Difficulty
  final String difficultyLevel; // beginner, intermediate, advanced, expert
  final List<String> mainChallenges;
  final bool suitableForBeginners;

  // Description & Info
  final String description;
  final List<String> advantages;
  final List<String> challenges;

  // Metadata
  final DateTime createdAt;
  final bool active;

  Crop({
    required this.id,
    required this.cropName,
    required this.imageUrl,
    required this.commonNames,
    required this.phRange,
    required this.temperatureRange,
    required this.lightRequirement,
    required this.waterRequirement,
    required this.seedToHarvestDays,
    required this.yieldPerSqm,
    required this.expectedPlantsPerSqm,
    required this.hydroponicTechniques,
    required this.bestSeason,
    required this.marketDemandLevel,
    required this.profitMargin,
    required this.retailPrice,
    required this.wholesalePrice,
    required this.difficultyLevel,
    required this.mainChallenges,
    required this.suitableForBeginners,
    required this.description,
    required this.advantages,
    required this.challenges,
    required this.createdAt,
    this.active = true,
  });

  /// Get compatible hydroponic techniques
  List<String> getCompatibleTechniques() {
    return hydroponicTechniques.entries
        .where((e) => e.value['compatible'] == true)
        .map((e) => e.key)
        .toList();
  }

  /// Get pH range as string
  String getPhRangeString() {
    final min = phRange['min'] ?? 0;
    final max = phRange['max'] ?? 0;
    return '$min - $max';
  }

  /// Get temperature range as string
  String getTemperatureRangeString() {
    final min = temperatureRange['min'] ?? 0;
    final max = temperatureRange['max'] ?? 0;
    return '$min - $max°C';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'imageUrl': imageUrl,
      'commonNames': commonNames,
      'phRange': phRange,
      'temperatureRange': temperatureRange,
      'lightRequirement': lightRequirement,
      'waterRequirement': waterRequirement,
      'seedToHarvestDays': seedToHarvestDays,
      'yieldPerSqm': yieldPerSqm,
      'expectedPlantsPerSqm': expectedPlantsPerSqm,
      'hydroponicTechniques': hydroponicTechniques,
      'bestSeason': bestSeason,
      'marketDemandLevel': marketDemandLevel,
      'profitMargin': profitMargin,
      'retailPrice': retailPrice,
      'wholesalePrice': wholesalePrice,
      'difficultyLevel': difficultyLevel,
      'mainChallenges': mainChallenges,
      'suitableForBeginners': suitableForBeginners,
      'description': description,
      'advantages': advantages,
      'challenges': challenges,
      'createdAt': createdAt.toIso8601String(),
      'active': active,
    };
  }

  /// Create from JSON
  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'] ?? '',
      cropName: json['cropName'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      commonNames: List<String>.from(json['commonNames'] ?? []),
      phRange: json['phRange'] ?? {'min': 6.0, 'max': 7.0},
      temperatureRange: json['temperatureRange'] ?? {'min': 20, 'max': 28},
      lightRequirement: json['lightRequirement'] ?? {'daily_hours': 14},
      waterRequirement: json['waterRequirement'] ?? {},
      seedToHarvestDays: json['seedToHarvestDays'] ?? 60,
      yieldPerSqm: (json['yieldPerSqm'] ?? 0.0).toDouble(),
      expectedPlantsPerSqm: (json['expectedPlantsPerSqm'] ?? 0.0).toDouble(),
      hydroponicTechniques: json['hydroponicTechniques'] ?? {},
      bestSeason: json['bestSeason'] ?? 'year-round',
      marketDemandLevel: json['marketDemandLevel'] ?? 'medium',
      profitMargin: (json['profitMargin'] ?? 0.0).toDouble(),
      retailPrice: (json['retailPrice'] ?? 0.0).toDouble(),
      wholesalePrice: (json['wholesalePrice'] ?? 0.0).toDouble(),
      difficultyLevel: json['difficultyLevel'] ?? 'intermediate',
      mainChallenges: List<String>.from(json['mainChallenges'] ?? []),
      suitableForBeginners: json['suitableForBeginners'] ?? false,
      description: json['description'] ?? '',
      advantages: List<String>.from(json['advantages'] ?? []),
      challenges: List<String>.from(json['challenges'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      active: json['active'] ?? true,
    );
  }
}

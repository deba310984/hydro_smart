import 'package:equatable/equatable.dart';

/// Comprehensive crop recommendation model with detailed hydroponic data
class RecommendationModel extends Equatable {
  final String id;
  final String recommendedCrop;
  final String cropEmoji;
  final String category;
  final String scientificName;
  final String description;
  final double compatibilityScore;
  final String difficultyLevel;

  // Growth parameters
  final int daysToHarvest;
  final double yieldPerSqm; // kg per sq meter
  final double profitMargin; // percentage
  final String waterConsumption;
  final String marketDemand;

  // Optimal ranges
  final Map<String, double> temperatureRange;
  final Map<String, double> humidityRange;
  final Map<String, double> phRange;
  final Map<String, double> ecRange;
  final int lightHours;

  // Growing information
  final List<String> bestHydroponicSystems;
  final Map<String, dynamic> nutrientRequirements;
  final List<String> growingSeasons;
  final List<String> commonPests;
  final List<String> commonDiseases;
  final List<String> companionCrops;
  final int storageDays;

  // Additional info
  final List<String> nutritionalHighlights;
  final List<String> tips;
  final DateTime timestamp;

  const RecommendationModel({
    required this.id,
    required this.recommendedCrop,
    this.cropEmoji = '🌱',
    this.category = 'general',
    this.scientificName = '',
    this.description = '',
    this.compatibilityScore = 0,
    this.difficultyLevel = 'medium',
    this.daysToHarvest = 45,
    this.yieldPerSqm = 0,
    this.profitMargin = 0,
    this.waterConsumption = 'medium',
    this.marketDemand = 'medium',
    this.temperatureRange = const {'min': 18, 'max': 30},
    this.humidityRange = const {'min': 50, 'max': 80},
    this.phRange = const {'min': 5.5, 'max': 7.0},
    this.ecRange = const {'min': 1.0, 'max': 2.5},
    this.lightHours = 12,
    this.bestHydroponicSystems = const [],
    this.nutrientRequirements = const {},
    this.growingSeasons = const [],
    this.commonPests = const [],
    this.commonDiseases = const [],
    this.companionCrops = const [],
    this.storageDays = 7,
    this.nutritionalHighlights = const [],
    this.tips = const [],
    required this.timestamp,
  });

  /// Create from API response
  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      recommendedCrop: json['recommendedCrop'] as String? ?? '',
      cropEmoji: json['cropEmoji'] as String? ?? '🌱',
      category: json['category'] as String? ?? 'general',
      scientificName: json['scientificName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      compatibilityScore: (json['compatibilityScore'] as num?)?.toDouble() ?? 0,
      difficultyLevel: json['difficultyLevel'] as String? ?? 'medium',
      daysToHarvest: (json['daysToHarvest'] as num?)?.toInt() ?? 45,
      yieldPerSqm: (json['yieldPerSqm'] as num?)?.toDouble() ?? 0,
      profitMargin: (json['profitMargin'] as num?)?.toDouble() ?? 0,
      waterConsumption: json['waterConsumption'] as String? ?? 'medium',
      marketDemand: json['marketDemand'] as String? ?? 'medium',
      temperatureRange: _parseRange(json['temperatureRange']),
      humidityRange: _parseRange(json['humidityRange']),
      phRange: _parseRange(json['phRange']),
      ecRange: _parseRange(json['ecRange']),
      lightHours: (json['lightHours'] as num?)?.toInt() ?? 12,
      bestHydroponicSystems: _parseStringList(json['bestHydroponicSystems']),
      nutrientRequirements:
          json['nutrientRequirements'] as Map<String, dynamic>? ?? {},
      growingSeasons: _parseStringList(json['growingSeasons']),
      commonPests: _parseStringList(json['commonPests']),
      commonDiseases: _parseStringList(json['commonDiseases']),
      companionCrops: _parseStringList(json['companionCrops']),
      storageDays: (json['storageDays'] as num?)?.toInt() ?? 7,
      nutritionalHighlights: _parseStringList(json['nutritionalHighlights']),
      tips: _parseStringList(json['tips']),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  static Map<String, double> _parseRange(dynamic range) {
    if (range == null) return {'min': 0, 'max': 0};
    if (range is Map) {
      return {
        'min': (range['min'] as num?)?.toDouble() ?? 0,
        'max': (range['max'] as num?)?.toDouble() ?? 0,
      };
    }
    return {'min': 0, 'max': 0};
  }

  static List<String> _parseStringList(dynamic list) {
    if (list == null) return [];
    if (list is List) {
      return list.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recommendedCrop': recommendedCrop,
      'cropEmoji': cropEmoji,
      'category': category,
      'scientificName': scientificName,
      'description': description,
      'compatibilityScore': compatibilityScore,
      'difficultyLevel': difficultyLevel,
      'daysToHarvest': daysToHarvest,
      'yieldPerSqm': yieldPerSqm,
      'profitMargin': profitMargin,
      'waterConsumption': waterConsumption,
      'marketDemand': marketDemand,
      'temperatureRange': temperatureRange,
      'humidityRange': humidityRange,
      'phRange': phRange,
      'ecRange': ecRange,
      'lightHours': lightHours,
      'bestHydroponicSystems': bestHydroponicSystems,
      'nutrientRequirements': nutrientRequirements,
      'growingSeasons': growingSeasons,
      'commonPests': commonPests,
      'commonDiseases': commonDiseases,
      'companionCrops': companionCrops,
      'storageDays': storageDays,
      'nutritionalHighlights': nutritionalHighlights,
      'tips': tips,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Get difficulty color for UI
  String get difficultyColor {
    switch (difficultyLevel.toLowerCase()) {
      case 'beginner':
        return '#4CAF50'; // Green
      case 'intermediate':
        return '#FF9800'; // Orange
      case 'advanced':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get water consumption icon
  String get waterIcon {
    switch (waterConsumption.toLowerCase()) {
      case 'low':
        return '💧';
      case 'medium':
        return '💧💧';
      case 'high':
        return '💧💧💧';
      default:
        return '💧';
    }
  }

  /// Get market demand indicator
  String get demandIndicator {
    switch (marketDemand.toLowerCase()) {
      case 'low':
        return '📉';
      case 'medium':
        return '📊';
      case 'high':
        return '📈';
      case 'very_high':
        return '🚀';
      default:
        return '📊';
    }
  }

  /// Get temperature range string
  String get temperatureRangeString =>
      '${temperatureRange['min']?.toStringAsFixed(0)}°C - ${temperatureRange['max']?.toStringAsFixed(0)}°C';

  /// Get humidity range string
  String get humidityRangeString =>
      '${humidityRange['min']?.toStringAsFixed(0)}% - ${humidityRange['max']?.toStringAsFixed(0)}%';

  /// Get pH range string
  String get phRangeString =>
      '${phRange['min']?.toStringAsFixed(1)} - ${phRange['max']?.toStringAsFixed(1)}';

  /// Get EC range string
  String get ecRangeString =>
      '${ecRange['min']?.toStringAsFixed(1)} - ${ecRange['max']?.toStringAsFixed(1)} mS/cm';

  RecommendationModel copyWith({
    String? id,
    String? recommendedCrop,
    String? cropEmoji,
    String? category,
    String? scientificName,
    String? description,
    double? compatibilityScore,
    String? difficultyLevel,
    int? daysToHarvest,
    double? yieldPerSqm,
    double? profitMargin,
    String? waterConsumption,
    String? marketDemand,
    Map<String, double>? temperatureRange,
    Map<String, double>? humidityRange,
    Map<String, double>? phRange,
    Map<String, double>? ecRange,
    int? lightHours,
    List<String>? bestHydroponicSystems,
    Map<String, dynamic>? nutrientRequirements,
    List<String>? growingSeasons,
    List<String>? commonPests,
    List<String>? commonDiseases,
    List<String>? companionCrops,
    int? storageDays,
    List<String>? nutritionalHighlights,
    List<String>? tips,
    DateTime? timestamp,
  }) {
    return RecommendationModel(
      id: id ?? this.id,
      recommendedCrop: recommendedCrop ?? this.recommendedCrop,
      cropEmoji: cropEmoji ?? this.cropEmoji,
      category: category ?? this.category,
      scientificName: scientificName ?? this.scientificName,
      description: description ?? this.description,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      daysToHarvest: daysToHarvest ?? this.daysToHarvest,
      yieldPerSqm: yieldPerSqm ?? this.yieldPerSqm,
      profitMargin: profitMargin ?? this.profitMargin,
      waterConsumption: waterConsumption ?? this.waterConsumption,
      marketDemand: marketDemand ?? this.marketDemand,
      temperatureRange: temperatureRange ?? this.temperatureRange,
      humidityRange: humidityRange ?? this.humidityRange,
      phRange: phRange ?? this.phRange,
      ecRange: ecRange ?? this.ecRange,
      lightHours: lightHours ?? this.lightHours,
      bestHydroponicSystems:
          bestHydroponicSystems ?? this.bestHydroponicSystems,
      nutrientRequirements: nutrientRequirements ?? this.nutrientRequirements,
      growingSeasons: growingSeasons ?? this.growingSeasons,
      commonPests: commonPests ?? this.commonPests,
      commonDiseases: commonDiseases ?? this.commonDiseases,
      companionCrops: companionCrops ?? this.companionCrops,
      storageDays: storageDays ?? this.storageDays,
      nutritionalHighlights:
          nutritionalHighlights ?? this.nutritionalHighlights,
      tips: tips ?? this.tips,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        id,
        recommendedCrop,
        cropEmoji,
        category,
        scientificName,
        description,
        compatibilityScore,
        difficultyLevel,
        daysToHarvest,
        yieldPerSqm,
        profitMargin,
        waterConsumption,
        marketDemand,
        temperatureRange,
        humidityRange,
        phRange,
        ecRange,
        lightHours,
        bestHydroponicSystems,
        nutrientRequirements,
        growingSeasons,
        commonPests,
        commonDiseases,
        companionCrops,
        storageDays,
        nutritionalHighlights,
        tips,
        timestamp,
      ];

  @override
  String toString() =>
      'RecommendationModel(crop: $recommendedCrop, score: $compatibilityScore, difficulty: $difficultyLevel)';
}

/// Seasonal recommendation response model
class SeasonalRecommendation extends Equatable {
  final String state;
  final String season;
  final String climateZone;
  final double estimatedTemperature;
  final List<RecommendationModel> recommendations;

  const SeasonalRecommendation({
    required this.state,
    required this.season,
    required this.climateZone,
    required this.estimatedTemperature,
    required this.recommendations,
  });

  factory SeasonalRecommendation.fromJson(Map<String, dynamic> json) {
    return SeasonalRecommendation(
      state: json['state'] as String? ?? '',
      season: json['season'] as String? ?? '',
      climateZone: json['climateZone'] as String? ?? '',
      estimatedTemperature:
          (json['estimatedTemperature'] as num?)?.toDouble() ?? 25.0,
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) =>
                  RecommendationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props =>
      [state, season, climateZone, estimatedTemperature, recommendations];
}

/// Crop category model
class CropCategory extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int cropCount;

  const CropCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.cropCount,
  });

  factory CropCategory.fromJson(Map<String, dynamic> json) {
    return CropCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🌱',
      description: json['description'] as String? ?? '',
      cropCount: (json['cropCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, emoji, description, cropCount];
}

/// Indian state with climate zone
class IndianState extends Equatable {
  final String name;
  final String climateZone;

  const IndianState({
    required this.name,
    required this.climateZone,
  });

  factory IndianState.fromJson(String name, String climateZone) {
    return IndianState(name: name, climateZone: climateZone);
  }

  @override
  List<Object?> get props => [name, climateZone];
}

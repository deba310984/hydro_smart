import 'package:equatable/equatable.dart';

class RecommendationModel extends Equatable {
  final String id;
  final String recommendedCrop;
  final String reasoning;
  final double optimalTemperature; // °C
  final double optimalHumidity; // %
  final double optimalPh;
  final double optimalWaterLevel; // %
  final double growthDaysEstimate;
  final String difficulty; // easy, medium, hard
  final List<String> benefits;
  final List<String> challenges;
  final DateTime timestamp;

  const RecommendationModel({
    required this.id,
    required this.recommendedCrop,
    required this.reasoning,
    required this.optimalTemperature,
    required this.optimalHumidity,
    required this.optimalPh,
    required this.optimalWaterLevel,
    required this.growthDaysEstimate,
    required this.difficulty,
    required this.benefits,
    required this.challenges,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recommendedCrop': recommendedCrop,
      'reasoning': reasoning,
      'optimalTemperature': optimalTemperature,
      'optimalHumidity': optimalHumidity,
      'optimalPh': optimalPh,
      'optimalWaterLevel': optimalWaterLevel,
      'growthDaysEstimate': growthDaysEstimate,
      'difficulty': difficulty,
      'benefits': benefits,
      'challenges': challenges,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] as String? ?? '',
      recommendedCrop: json['recommendedCrop'] as String? ?? '',
      reasoning: json['reasoning'] as String? ?? '',
      optimalTemperature:
          (json['optimalTemperature'] as num?)?.toDouble() ?? 25.0,
      optimalHumidity: (json['optimalHumidity'] as num?)?.toDouble() ?? 65.0,
      optimalPh: (json['optimalPh'] as num?)?.toDouble() ?? 6.5,
      optimalWaterLevel:
          (json['optimalWaterLevel'] as num?)?.toDouble() ?? 75.0,
      growthDaysEstimate:
          (json['growthDaysEstimate'] as num?)?.toDouble() ?? 45.0,
      difficulty: json['difficulty'] as String? ?? 'medium',
      benefits: List<String>.from(json['benefits'] as List<dynamic>? ?? []),
      challenges: List<String>.from(json['challenges'] as List<dynamic>? ?? []),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  RecommendationModel copyWith({
    String? id,
    String? recommendedCrop,
    String? reasoning,
    double? optimalTemperature,
    double? optimalHumidity,
    double? optimalPh,
    double? optimalWaterLevel,
    double? growthDaysEstimate,
    String? difficulty,
    List<String>? benefits,
    List<String>? challenges,
    DateTime? timestamp,
  }) {
    return RecommendationModel(
      id: id ?? this.id,
      recommendedCrop: recommendedCrop ?? this.recommendedCrop,
      reasoning: reasoning ?? this.reasoning,
      optimalTemperature: optimalTemperature ?? this.optimalTemperature,
      optimalHumidity: optimalHumidity ?? this.optimalHumidity,
      optimalPh: optimalPh ?? this.optimalPh,
      optimalWaterLevel: optimalWaterLevel ?? this.optimalWaterLevel,
      growthDaysEstimate: growthDaysEstimate ?? this.growthDaysEstimate,
      difficulty: difficulty ?? this.difficulty,
      benefits: benefits ?? this.benefits,
      challenges: challenges ?? this.challenges,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
    id,
    recommendedCrop,
    reasoning,
    optimalTemperature,
    optimalHumidity,
    optimalPh,
    optimalWaterLevel,
    growthDaysEstimate,
    difficulty,
    benefits,
    challenges,
    timestamp,
  ];

  @override
  String toString() =>
      'RecommendationModel(crop: $recommendedCrop, difficulty: $difficulty)';
}

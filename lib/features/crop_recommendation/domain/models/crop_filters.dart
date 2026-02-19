import 'package:flutter/material.dart';

class CropFilters {
  final List<String>? hydroponicTechniques; // NFT, DWC, Drip, Aeroponics
  final List<String>?
      growingSeasons; // spring, summer, autumn, winter, year-round
  final RangeValues? growthDurationRange; // min-max days
  final RangeValues? profitMarginRange; // min-max percentage
  final String? difficultyLevel; // beginner, intermediate, advanced, expert
  final String? marketDemandLevel; // low, medium, high, very-high

  CropFilters({
    this.hydroponicTechniques,
    this.growingSeasons,
    this.growthDurationRange,
    this.profitMarginRange,
    this.difficultyLevel,
    this.marketDemandLevel,
  });

  /// Check if any filter is applied
  bool hasActiveFilters() {
    return (hydroponicTechniques?.isNotEmpty ?? false) ||
        (growingSeasons?.isNotEmpty ?? false) ||
        growthDurationRange != null ||
        profitMarginRange != null ||
        difficultyLevel != null ||
        marketDemandLevel != null;
  }

  /// Create a copy with modifications
  CropFilters copyWith({
    List<String>? hydroponicTechniques,
    List<String>? growingSeasons,
    RangeValues? growthDurationRange,
    RangeValues? profitMarginRange,
    String? difficultyLevel,
    String? marketDemandLevel,
  }) {
    return CropFilters(
      hydroponicTechniques: hydroponicTechniques ?? this.hydroponicTechniques,
      growingSeasons: growingSeasons ?? this.growingSeasons,
      growthDurationRange: growthDurationRange ?? this.growthDurationRange,
      profitMarginRange: profitMarginRange ?? this.profitMarginRange,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      marketDemandLevel: marketDemandLevel ?? this.marketDemandLevel,
    );
  }

  void clear() {
    hydroponicTechniques?.clear();
    growingSeasons?.clear();
  }

  @override
  String toString() {
    return 'CropFilters(techniques: $hydroponicTechniques, seasons: $growingSeasons, duration: $growthDurationRange, margin: $profitMarginRange, difficulty: $difficultyLevel, demand: $marketDemandLevel)';
  }
}

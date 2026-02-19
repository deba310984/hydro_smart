class CropRecommendation {
  final String cropName;
  final int durationDays;
  final double profitMarginPercent;
  final String waterUsage;
  final double soilPh;
  final double temperature;
  final double humidity;
  final String riskLevel;
  final String icon;

  CropRecommendation({
    required this.cropName,
    required this.durationDays,
    required this.profitMarginPercent,
    required this.waterUsage,
    required this.soilPh,
    required this.temperature,
    required this.humidity,
    required this.riskLevel,
    required this.icon,
  });
}

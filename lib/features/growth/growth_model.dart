class GrowthData {
  final String cropName;
  final int daysSincePlantation;
  final int totalGrowthDays;
  final DateTime expectedHarvestDate;

  double get progressPercentage =>
      (daysSincePlantation / totalGrowthDays) * 100;

  int get daysRemaining => totalGrowthDays - daysSincePlantation;

  GrowthData({
    required this.cropName,
    required this.daysSincePlantation,
    required this.totalGrowthDays,
    required this.expectedHarvestDate,
  });
}

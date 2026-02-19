class FinanceData {
  final String userId;
  final double electricityCost;
  final double waterCost;
  final double nutrientCost;
  final double laborCost;
  final double estimatedRevenue;
  final DateTime lastUpdated;

  double get totalExpense =>
      electricityCost + waterCost + nutrientCost + laborCost;

  double get netProfit => estimatedRevenue - totalExpense;

  FinanceData({
    required this.userId,
    required this.electricityCost,
    required this.waterCost,
    required this.nutrientCost,
    required this.laborCost,
    required this.estimatedRevenue,
    required this.lastUpdated,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'electricityCost': electricityCost,
      'waterCost': waterCost,
      'nutrientCost': nutrientCost,
      'laborCost': laborCost,
      'estimatedRevenue': estimatedRevenue,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Create from JSON (Firestore)
  factory FinanceData.fromJson(Map<String, dynamic> json, String userId) {
    return FinanceData(
      userId: userId,
      electricityCost: (json['electricityCost'] ?? 0).toDouble(),
      waterCost: (json['waterCost'] ?? 0).toDouble(),
      nutrientCost: (json['nutrientCost'] ?? 0).toDouble(),
      laborCost: (json['laborCost'] ?? 0).toDouble(),
      estimatedRevenue: (json['estimatedRevenue'] ?? 0).toDouble(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  // Copy with method for updates
  FinanceData copyWith({
    String? userId,
    double? electricityCost,
    double? waterCost,
    double? nutrientCost,
    double? laborCost,
    double? estimatedRevenue,
    DateTime? lastUpdated,
  }) {
    return FinanceData(
      userId: userId ?? this.userId,
      electricityCost: electricityCost ?? this.electricityCost,
      waterCost: waterCost ?? this.waterCost,
      nutrientCost: nutrientCost ?? this.nutrientCost,
      laborCost: laborCost ?? this.laborCost,
      estimatedRevenue: estimatedRevenue ?? this.estimatedRevenue,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

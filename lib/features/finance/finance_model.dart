class FinanceData {
  final String userId;

  // Operating Expenses
  final double electricityCost;
  final double waterCost;
  final double nutrientCost;
  final double laborCost;

  // Additional Operating Expenses
  final double seedsCost;
  final double packagingCost;
  final double transportCost;
  final double maintenanceCost;
  final double marketingCost;
  final double insuranceCost;

  // Capital/Investment
  final double equipmentInvestment;
  final double infrastructureInvestment;

  // Revenue
  final double estimatedRevenue;
  final double processedGoodsSales; // For GST calculation
  final double rawProduceSales;

  // Tax Related
  final double gstPaid;
  final double gstCollected;
  final double advanceTaxPaid;
  final double tdsDeducted;

  // Deductions (80C, 80D, etc.)
  final double section80CInvestment;
  final double healthInsurance;
  final double homeLoanInterest;

  // Loans
  final double totalLoanAmount;
  final double loanInterestRate;
  final int loanTenureMonths;
  final double emiPaid;

  // Savings & Goals
  final double emergencyFund;
  final double savingsTarget;
  final double currentSavings;

  final DateTime lastUpdated;
  final bool isOrganic; // Affects GST calculation

  // Calculated Getters
  double get totalOperatingExpense =>
      electricityCost +
      waterCost +
      nutrientCost +
      laborCost +
      seedsCost +
      packagingCost +
      transportCost +
      maintenanceCost +
      marketingCost +
      insuranceCost;

  double get totalExpense => totalOperatingExpense + emiPaid;

  double get totalInvestment => equipmentInvestment + infrastructureInvestment;

  double get totalRevenue => estimatedRevenue;

  double get netProfit => estimatedRevenue - totalExpense;

  double get grossProfit =>
      estimatedRevenue - (nutrientCost + seedsCost + packagingCost);

  double get profitMargin =>
      estimatedRevenue > 0 ? (netProfit / estimatedRevenue) * 100 : 0;

  double get netGST => gstCollected - gstPaid;

  double get taxableIncome =>
      processedGoodsSales; // Only processed goods are taxable

  FinanceData({
    required this.userId,
    required this.electricityCost,
    required this.waterCost,
    required this.nutrientCost,
    required this.laborCost,
    this.seedsCost = 0,
    this.packagingCost = 0,
    this.transportCost = 0,
    this.maintenanceCost = 0,
    this.marketingCost = 0,
    this.insuranceCost = 0,
    this.equipmentInvestment = 0,
    this.infrastructureInvestment = 0,
    required this.estimatedRevenue,
    this.processedGoodsSales = 0,
    this.rawProduceSales = 0,
    this.gstPaid = 0,
    this.gstCollected = 0,
    this.advanceTaxPaid = 0,
    this.tdsDeducted = 0,
    this.section80CInvestment = 0,
    this.healthInsurance = 0,
    this.homeLoanInterest = 0,
    this.totalLoanAmount = 0,
    this.loanInterestRate = 0,
    this.loanTenureMonths = 0,
    this.emiPaid = 0,
    this.emergencyFund = 0,
    this.savingsTarget = 0,
    this.currentSavings = 0,
    required this.lastUpdated,
    this.isOrganic = false,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'electricityCost': electricityCost,
      'waterCost': waterCost,
      'nutrientCost': nutrientCost,
      'laborCost': laborCost,
      'seedsCost': seedsCost,
      'packagingCost': packagingCost,
      'transportCost': transportCost,
      'maintenanceCost': maintenanceCost,
      'marketingCost': marketingCost,
      'insuranceCost': insuranceCost,
      'equipmentInvestment': equipmentInvestment,
      'infrastructureInvestment': infrastructureInvestment,
      'estimatedRevenue': estimatedRevenue,
      'processedGoodsSales': processedGoodsSales,
      'rawProduceSales': rawProduceSales,
      'gstPaid': gstPaid,
      'gstCollected': gstCollected,
      'advanceTaxPaid': advanceTaxPaid,
      'tdsDeducted': tdsDeducted,
      'section80CInvestment': section80CInvestment,
      'healthInsurance': healthInsurance,
      'homeLoanInterest': homeLoanInterest,
      'totalLoanAmount': totalLoanAmount,
      'loanInterestRate': loanInterestRate,
      'loanTenureMonths': loanTenureMonths,
      'emiPaid': emiPaid,
      'emergencyFund': emergencyFund,
      'savingsTarget': savingsTarget,
      'currentSavings': currentSavings,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isOrganic': isOrganic,
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
      seedsCost: (json['seedsCost'] ?? 0).toDouble(),
      packagingCost: (json['packagingCost'] ?? 0).toDouble(),
      transportCost: (json['transportCost'] ?? 0).toDouble(),
      maintenanceCost: (json['maintenanceCost'] ?? 0).toDouble(),
      marketingCost: (json['marketingCost'] ?? 0).toDouble(),
      insuranceCost: (json['insuranceCost'] ?? 0).toDouble(),
      equipmentInvestment: (json['equipmentInvestment'] ?? 0).toDouble(),
      infrastructureInvestment:
          (json['infrastructureInvestment'] ?? 0).toDouble(),
      estimatedRevenue: (json['estimatedRevenue'] ?? 0).toDouble(),
      processedGoodsSales: (json['processedGoodsSales'] ?? 0).toDouble(),
      rawProduceSales: (json['rawProduceSales'] ?? 0).toDouble(),
      gstPaid: (json['gstPaid'] ?? 0).toDouble(),
      gstCollected: (json['gstCollected'] ?? 0).toDouble(),
      advanceTaxPaid: (json['advanceTaxPaid'] ?? 0).toDouble(),
      tdsDeducted: (json['tdsDeducted'] ?? 0).toDouble(),
      section80CInvestment: (json['section80CInvestment'] ?? 0).toDouble(),
      healthInsurance: (json['healthInsurance'] ?? 0).toDouble(),
      homeLoanInterest: (json['homeLoanInterest'] ?? 0).toDouble(),
      totalLoanAmount: (json['totalLoanAmount'] ?? 0).toDouble(),
      loanInterestRate: (json['loanInterestRate'] ?? 0).toDouble(),
      loanTenureMonths: (json['loanTenureMonths'] ?? 0).toInt(),
      emiPaid: (json['emiPaid'] ?? 0).toDouble(),
      emergencyFund: (json['emergencyFund'] ?? 0).toDouble(),
      savingsTarget: (json['savingsTarget'] ?? 0).toDouble(),
      currentSavings: (json['currentSavings'] ?? 0).toDouble(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      isOrganic: json['isOrganic'] ?? false,
    );
  }

  // Copy with method for updates
  FinanceData copyWith({
    String? userId,
    double? electricityCost,
    double? waterCost,
    double? nutrientCost,
    double? laborCost,
    double? seedsCost,
    double? packagingCost,
    double? transportCost,
    double? maintenanceCost,
    double? marketingCost,
    double? insuranceCost,
    double? equipmentInvestment,
    double? infrastructureInvestment,
    double? estimatedRevenue,
    double? processedGoodsSales,
    double? rawProduceSales,
    double? gstPaid,
    double? gstCollected,
    double? advanceTaxPaid,
    double? tdsDeducted,
    double? section80CInvestment,
    double? healthInsurance,
    double? homeLoanInterest,
    double? totalLoanAmount,
    double? loanInterestRate,
    int? loanTenureMonths,
    double? emiPaid,
    double? emergencyFund,
    double? savingsTarget,
    double? currentSavings,
    DateTime? lastUpdated,
    bool? isOrganic,
  }) {
    return FinanceData(
      userId: userId ?? this.userId,
      electricityCost: electricityCost ?? this.electricityCost,
      waterCost: waterCost ?? this.waterCost,
      nutrientCost: nutrientCost ?? this.nutrientCost,
      laborCost: laborCost ?? this.laborCost,
      seedsCost: seedsCost ?? this.seedsCost,
      packagingCost: packagingCost ?? this.packagingCost,
      transportCost: transportCost ?? this.transportCost,
      maintenanceCost: maintenanceCost ?? this.maintenanceCost,
      marketingCost: marketingCost ?? this.marketingCost,
      insuranceCost: insuranceCost ?? this.insuranceCost,
      equipmentInvestment: equipmentInvestment ?? this.equipmentInvestment,
      infrastructureInvestment:
          infrastructureInvestment ?? this.infrastructureInvestment,
      estimatedRevenue: estimatedRevenue ?? this.estimatedRevenue,
      processedGoodsSales: processedGoodsSales ?? this.processedGoodsSales,
      rawProduceSales: rawProduceSales ?? this.rawProduceSales,
      gstPaid: gstPaid ?? this.gstPaid,
      gstCollected: gstCollected ?? this.gstCollected,
      advanceTaxPaid: advanceTaxPaid ?? this.advanceTaxPaid,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      section80CInvestment: section80CInvestment ?? this.section80CInvestment,
      healthInsurance: healthInsurance ?? this.healthInsurance,
      homeLoanInterest: homeLoanInterest ?? this.homeLoanInterest,
      totalLoanAmount: totalLoanAmount ?? this.totalLoanAmount,
      loanInterestRate: loanInterestRate ?? this.loanInterestRate,
      loanTenureMonths: loanTenureMonths ?? this.loanTenureMonths,
      emiPaid: emiPaid ?? this.emiPaid,
      emergencyFund: emergencyFund ?? this.emergencyFund,
      savingsTarget: savingsTarget ?? this.savingsTarget,
      currentSavings: currentSavings ?? this.currentSavings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOrganic: isOrganic ?? this.isOrganic,
    );
  }
}

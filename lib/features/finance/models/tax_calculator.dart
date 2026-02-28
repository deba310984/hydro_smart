/// Indian Agricultural Tax Calculator
/// Handles GST, Income Tax, and farming-specific deductions

class TaxCalculator {
  // GST Rates for agricultural inputs/outputs
  static const double gstRateFertilizers = 5.0; // 5% GST on fertilizers
  static const double gstRateSeeds = 0.0; // Seeds are GST exempt
  static const double gstRateEquipment = 12.0; // 12% GST on equipment
  static const double gstRateProcessedGoods = 5.0; // 5% on processed farm goods
  static const double gstRateOrganicProduce = 0.0; // Organic is exempt
  static const double gstRatePackaging = 18.0; // 18% on packaging

  // Income Tax Slabs for FY 2025-26 (New Regime)
  static const List<TaxSlab> incomeTaxSlabs = [
    TaxSlab(minIncome: 0, maxIncome: 300000, rate: 0),
    TaxSlab(minIncome: 300001, maxIncome: 700000, rate: 5),
    TaxSlab(minIncome: 700001, maxIncome: 1000000, rate: 10),
    TaxSlab(minIncome: 1000001, maxIncome: 1200000, rate: 15),
    TaxSlab(minIncome: 1200001, maxIncome: 1500000, rate: 20),
    TaxSlab(minIncome: 1500001, maxIncome: double.infinity, rate: 30),
  ];

  /// Calculate GST on purchases
  static GSTBreakdown calculateInputGST({
    required double fertilizerPurchase,
    required double equipmentPurchase,
    required double packagingPurchase,
    required double otherPurchases,
  }) {
    final fertilizerGST = fertilizerPurchase * gstRateFertilizers / 100;
    final equipmentGST = equipmentPurchase * gstRateEquipment / 100;
    final packagingGST = packagingPurchase * gstRatePackaging / 100;
    final otherGST = otherPurchases * 0.18; // Assume 18% for others

    return GSTBreakdown(
      fertilizerGST: fertilizerGST,
      equipmentGST: equipmentGST,
      packagingGST: packagingGST,
      otherGST: otherGST,
      totalInputGST: fertilizerGST + equipmentGST + packagingGST + otherGST,
    );
  }

  /// Calculate GST on sales
  static double calculateOutputGST({
    required double rawProduceSales,
    required double processedSales,
    required bool isOrganic,
  }) {
    // Raw agricultural produce is GST exempt
    // Processed goods have 5% GST
    // Organic produce is exempt
    if (isOrganic) return 0;
    return processedSales * gstRateProcessedGoods / 100;
  }

  /// Calculate net GST payable/refundable
  static double calculateNetGST({
    required double inputGST,
    required double outputGST,
  }) {
    // If input GST > output GST, farmer gets refund
    return outputGST - inputGST;
  }

  /// Calculate Income Tax for agricultural income
  /// Note: Pure agricultural income is exempt from income tax in India
  /// But income from processing, trading gets taxed
  static IncomeTaxBreakdown calculateIncomeTax({
    required double agriculturalIncome, // Exempt
    required double nonAgriculturalIncome, // From processing, trading
    required double otherIncome, // Interest, rental, etc.
    required double deductions, // 80C, 80D, etc.
  }) {
    // Agricultural income is exempt
    final exemptIncome = agriculturalIncome;

    // Taxable income
    final totalTaxableIncome = nonAgriculturalIncome + otherIncome - deductions;
    final double taxableIncome =
        totalTaxableIncome > 0 ? totalTaxableIncome : 0.0;

    // Calculate tax based on slabs
    double incomeTax = 0;
    double remainingIncome = taxableIncome;

    for (final slab in incomeTaxSlabs) {
      if (remainingIncome <= 0) break;

      final double slabRange = slab.maxIncome - slab.minIncome + 1;
      final double taxableInSlab =
          remainingIncome > slabRange ? slabRange : remainingIncome;
      incomeTax += taxableInSlab * slab.rate / 100;
      remainingIncome -= taxableInSlab;
    }

    // Health & Education Cess (4%)
    final cess = incomeTax * 0.04;

    return IncomeTaxBreakdown(
      agriculturalIncome: exemptIncome,
      taxableIncome: taxableIncome,
      grossTax: incomeTax,
      cess: cess,
      totalTax: incomeTax + cess,
      effectiveRate:
          taxableIncome > 0 ? ((incomeTax + cess) / taxableIncome) * 100 : 0,
    );
  }

  /// Calculate available deductions for farmers
  static DeductionBreakdown calculateDeductions({
    required double section80C, // PPF, LIC, etc. (max 1.5L)
    required double section80D, // Health insurance (max 25K-50K)
    required double section80G, // Donations
    required double homeLoanInterest, // Section 24 (max 2L)
    required double educationLoanInterest, // Section 80E
    required double savingsInterest, // Section 80TTA (max 10K)
  }) {
    final double capped80C = section80C > 150000 ? 150000.0 : section80C;
    final double capped80D = section80D > 50000 ? 50000.0 : section80D;
    final double cappedHomeLoan =
        homeLoanInterest > 200000 ? 200000.0 : homeLoanInterest;
    final double capped80TTA =
        savingsInterest > 10000 ? 10000.0 : savingsInterest;

    return DeductionBreakdown(
      section80C: capped80C,
      section80D: capped80D,
      section80G: section80G,
      section24: cappedHomeLoan,
      section80E: educationLoanInterest,
      section80TTA: capped80TTA,
      totalDeductions: capped80C +
          capped80D +
          section80G +
          cappedHomeLoan +
          educationLoanInterest +
          capped80TTA,
    );
  }

  /// Calculate Advance Tax schedule
  /// [fyStartYear] is the starting year of the FY (e.g. 2025 for FY 2025-26)
  static List<AdvanceTaxInstallment> getAdvanceTaxSchedule(
    double totalTax, {
    int? fyStartYear,
  }) {
    if (totalTax < 10000) {
      return []; // No advance tax if total tax < 10K
    }

    final fy = fyStartYear ?? DateTime.now().year;

    return [
      AdvanceTaxInstallment(
        dueDate: '15 Jun $fy',
        percentage: 15,
        amount: totalTax * 0.15,
        cumulativePercentage: 15,
      ),
      AdvanceTaxInstallment(
        dueDate: '15 Sep $fy',
        percentage: 30,
        amount: totalTax * 0.30,
        cumulativePercentage: 45,
      ),
      AdvanceTaxInstallment(
        dueDate: '15 Dec $fy',
        percentage: 30,
        amount: totalTax * 0.30,
        cumulativePercentage: 75,
      ),
      AdvanceTaxInstallment(
        dueDate: '15 Mar ${fy + 1}',
        percentage: 25,
        amount: totalTax * 0.25,
        cumulativePercentage: 100,
      ),
    ];
  }
}

class TaxSlab {
  final double minIncome;
  final double maxIncome;
  final double rate;

  const TaxSlab({
    required this.minIncome,
    required this.maxIncome,
    required this.rate,
  });
}

class GSTBreakdown {
  final double fertilizerGST;
  final double equipmentGST;
  final double packagingGST;
  final double otherGST;
  final double totalInputGST;

  GSTBreakdown({
    required this.fertilizerGST,
    required this.equipmentGST,
    required this.packagingGST,
    required this.otherGST,
    required this.totalInputGST,
  });
}

class IncomeTaxBreakdown {
  final double agriculturalIncome;
  final double taxableIncome;
  final double grossTax;
  final double cess;
  final double totalTax;
  final double effectiveRate;

  IncomeTaxBreakdown({
    required this.agriculturalIncome,
    required this.taxableIncome,
    required this.grossTax,
    required this.cess,
    required this.totalTax,
    required this.effectiveRate,
  });
}

class DeductionBreakdown {
  final double section80C;
  final double section80D;
  final double section80G;
  final double section24;
  final double section80E;
  final double section80TTA;
  final double totalDeductions;

  DeductionBreakdown({
    required this.section80C,
    required this.section80D,
    required this.section80G,
    required this.section24,
    required this.section80E,
    required this.section80TTA,
    required this.totalDeductions,
  });
}

class AdvanceTaxInstallment {
  final String dueDate;
  final double percentage;
  final double amount;
  final double cumulativePercentage;

  AdvanceTaxInstallment({
    required this.dueDate,
    required this.percentage,
    required this.amount,
    required this.cumulativePercentage,
  });
}

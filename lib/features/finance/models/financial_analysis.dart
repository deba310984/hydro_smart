/// Advanced Financial Analysis Models

class FinancialAnalysis {
  /// Calculate Return on Investment (ROI)
  static ROIResult calculateROI({
    required double totalInvestment,
    required double totalRevenue,
    required double totalExpenses,
  }) {
    final netProfit = totalRevenue - totalExpenses;
    final double roi =
        totalInvestment > 0 ? (netProfit / totalInvestment) * 100 : 0.0;

    return ROIResult(
      totalInvestment: totalInvestment,
      netProfit: netProfit,
      roiPercentage: roi,
      paybackPeriod: netProfit > 0 ? totalInvestment / (netProfit / 12) : 0.0,
    );
  }

  /// Calculate Break-Even Point
  static BreakEvenResult calculateBreakEven({
    required double fixedCosts,
    required double variableCostPerUnit,
    required double sellingPricePerUnit,
  }) {
    final contributionMargin = sellingPricePerUnit - variableCostPerUnit;
    final double breakEvenUnits =
        contributionMargin > 0 ? fixedCosts / contributionMargin : 0.0;
    final double breakEvenRevenue = breakEvenUnits * sellingPricePerUnit;

    return BreakEvenResult(
      fixedCosts: fixedCosts,
      variableCostPerUnit: variableCostPerUnit,
      sellingPricePerUnit: sellingPricePerUnit,
      contributionMargin: contributionMargin,
      breakEvenUnits: breakEvenUnits,
      breakEvenRevenue: breakEvenRevenue,
    );
  }

  /// Calculate EMI for loans
  static EMIResult calculateEMI({
    required double principal,
    required double annualInterestRate,
    required int tenureMonths,
  }) {
    final monthlyRate = annualInterestRate / 12 / 100;
    double emi;

    if (monthlyRate == 0) {
      emi = principal / tenureMonths;
    } else {
      emi = principal *
          monthlyRate *
          (1 + monthlyRate).pow(tenureMonths) /
          ((1 + monthlyRate).pow(tenureMonths) - 1);
    }

    final totalPayment = emi * tenureMonths;
    final totalInterest = totalPayment - principal;

    return EMIResult(
      principal: principal,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
      monthlyEMI: emi,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
    );
  }

  /// Generate Cash Flow Projection
  static List<CashFlowMonth> generateCashFlowProjection({
    required double initialBalance,
    required double monthlyRevenue,
    required double monthlyExpenses,
    required double expectedGrowthRate, // percentage per month
    required int months,
    List<PlannedExpense>? plannedExpenses,
  }) {
    final projections = <CashFlowMonth>[];
    var balance = initialBalance;
    var revenue = monthlyRevenue;
    var expenses = monthlyExpenses;

    for (int i = 1; i <= months; i++) {
      // Check for planned large expenses
      double additionalExpense = 0;
      if (plannedExpenses != null) {
        for (final expense in plannedExpenses) {
          if (expense.month == i) {
            additionalExpense += expense.amount;
          }
        }
      }

      final totalExpenses = expenses + additionalExpense;
      final netCashFlow = revenue - totalExpenses;
      balance += netCashFlow;

      projections.add(CashFlowMonth(
        month: i,
        revenue: revenue,
        expenses: totalExpenses,
        netCashFlow: netCashFlow,
        closingBalance: balance,
        additionalExpenses: additionalExpense,
      ));

      // Apply growth rate
      revenue *= (1 + expectedGrowthRate / 100);
      expenses *=
          (1 + (expectedGrowthRate / 100) * 0.5); // Expenses grow slower
    }

    return projections;
  }

  /// Calculate Depreciation (Straight Line Method)
  static DepreciationSchedule calculateDepreciation({
    required double assetCost,
    required double salvageValue,
    required int usefulLifeYears,
  }) {
    final depreciableAmount = assetCost - salvageValue;
    final annualDepreciation = depreciableAmount / usefulLifeYears;
    final monthlyDepreciation = annualDepreciation / 12;

    final schedule = <DepreciationYear>[];
    var bookValue = assetCost;

    for (int i = 1; i <= usefulLifeYears; i++) {
      bookValue -= annualDepreciation;
      schedule.add(DepreciationYear(
        year: i,
        depreciation: annualDepreciation,
        accumulatedDepreciation: annualDepreciation * i,
        bookValue: bookValue < salvageValue ? salvageValue : bookValue,
      ));
    }

    return DepreciationSchedule(
      assetCost: assetCost,
      salvageValue: salvageValue,
      usefulLifeYears: usefulLifeYears,
      annualDepreciation: annualDepreciation,
      monthlyDepreciation: monthlyDepreciation,
      schedule: schedule,
    );
  }

  /// Calculate Profit Margins
  static ProfitMargins calculateProfitMargins({
    required double revenue,
    required double costOfGoodsSold,
    required double operatingExpenses,
    required double taxes,
    required double interest,
  }) {
    final grossProfit = revenue - costOfGoodsSold;
    final operatingProfit = grossProfit - operatingExpenses;
    final netProfit = operatingProfit - taxes - interest;

    return ProfitMargins(
      grossProfitMargin: revenue > 0 ? (grossProfit / revenue) * 100 : 0,
      operatingProfitMargin:
          revenue > 0 ? (operatingProfit / revenue) * 100 : 0,
      netProfitMargin: revenue > 0 ? (netProfit / revenue) * 100 : 0,
      grossProfit: grossProfit,
      operatingProfit: operatingProfit,
      netProfit: netProfit,
    );
  }
}

// Extension for power function
extension DoublePow on double {
  double pow(int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= this;
    }
    return result;
  }
}

class ROIResult {
  final double totalInvestment;
  final double netProfit;
  final double roiPercentage;
  final double paybackPeriod; // in months

  ROIResult({
    required this.totalInvestment,
    required this.netProfit,
    required this.roiPercentage,
    required this.paybackPeriod,
  });
}

class BreakEvenResult {
  final double fixedCosts;
  final double variableCostPerUnit;
  final double sellingPricePerUnit;
  final double contributionMargin;
  final double breakEvenUnits;
  final double breakEvenRevenue;

  BreakEvenResult({
    required this.fixedCosts,
    required this.variableCostPerUnit,
    required this.sellingPricePerUnit,
    required this.contributionMargin,
    required this.breakEvenUnits,
    required this.breakEvenRevenue,
  });
}

class EMIResult {
  final double principal;
  final double annualInterestRate;
  final int tenureMonths;
  final double monthlyEMI;
  final double totalPayment;
  final double totalInterest;

  EMIResult({
    required this.principal,
    required this.annualInterestRate,
    required this.tenureMonths,
    required this.monthlyEMI,
    required this.totalPayment,
    required this.totalInterest,
  });
}

class CashFlowMonth {
  final int month;
  final double revenue;
  final double expenses;
  final double netCashFlow;
  final double closingBalance;
  final double additionalExpenses;

  CashFlowMonth({
    required this.month,
    required this.revenue,
    required this.expenses,
    required this.netCashFlow,
    required this.closingBalance,
    required this.additionalExpenses,
  });
}

class PlannedExpense {
  final int month;
  final String description;
  final double amount;

  PlannedExpense({
    required this.month,
    required this.description,
    required this.amount,
  });
}

class DepreciationSchedule {
  final double assetCost;
  final double salvageValue;
  final int usefulLifeYears;
  final double annualDepreciation;
  final double monthlyDepreciation;
  final List<DepreciationYear> schedule;

  DepreciationSchedule({
    required this.assetCost,
    required this.salvageValue,
    required this.usefulLifeYears,
    required this.annualDepreciation,
    required this.monthlyDepreciation,
    required this.schedule,
  });
}

class DepreciationYear {
  final int year;
  final double depreciation;
  final double accumulatedDepreciation;
  final double bookValue;

  DepreciationYear({
    required this.year,
    required this.depreciation,
    required this.accumulatedDepreciation,
    required this.bookValue,
  });
}

class ProfitMargins {
  final double grossProfitMargin;
  final double operatingProfitMargin;
  final double netProfitMargin;
  final double grossProfit;
  final double operatingProfit;
  final double netProfit;

  ProfitMargins({
    required this.grossProfitMargin,
    required this.operatingProfitMargin,
    required this.netProfitMargin,
    required this.grossProfit,
    required this.operatingProfit,
    required this.netProfit,
  });
}

/// Budget Categories
class BudgetCategory {
  final String name;
  final double allocated;
  final double spent;
  final String icon;

  BudgetCategory({
    required this.name,
    required this.allocated,
    required this.spent,
    required this.icon,
  });

  double get remaining => allocated - spent;
  double get percentageUsed => allocated > 0 ? (spent / allocated) * 100 : 0;
  bool get isOverBudget => spent > allocated;
}

/// Investment Tracking
class Investment {
  final String id;
  final String name;
  final String category;
  final double amount;
  final DateTime date;
  final double expectedReturn;
  final int expectedMonths;
  final String status;

  Investment({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
    required this.expectedReturn,
    required this.expectedMonths,
    required this.status,
  });

  double get projectedValue => amount * (1 + expectedReturn / 100);
  double get monthlyReturn => (projectedValue - amount) / expectedMonths;
}

import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import 'finance_controller.dart';
import 'models/tax_calculator.dart';
import 'models/financial_analysis.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dynamic date selection state
  late int _selectedFYStartYear; // e.g. 2025 means FY 2025-26
  late int _selectedGSTMonth; // 1-12
  late int _selectedGSTYear;
  late DateTime _roiStartDate;
  late DateTime _roiEndDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Initialize with current FY
    final now = DateTime.now();
    _selectedFYStartYear = now.month >= 4 ? now.year : now.year - 1;
    _selectedGSTMonth = now.month;
    _selectedGSTYear = now.year;
    _roiStartDate = DateTime(now.year, now.month, 1);
    _roiEndDate = DateTime(now.year, now.month + 6, 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final financeAsync = ref.watch(financeDataProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.lotusWhite,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Royal Header
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppTheme.royalPurple,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.royalPurple,
                      AppTheme.royalMaroon,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.royalGold.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: AppTheme.royalGold,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Finance Hub',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Advanced Farm Financial Management',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppTheme.royalGold,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.dashboard, size: 20), text: 'Overview'),
                Tab(icon: Icon(Icons.receipt_long, size: 20), text: 'Taxation'),
                Tab(icon: Icon(Icons.calculate, size: 20), text: 'Loan/EMI'),
                Tab(icon: Icon(Icons.trending_up, size: 20), text: 'ROI'),
                Tab(icon: Icon(Icons.pie_chart, size: 20), text: 'Budget'),
              ],
            ),
          ),
        ],
        body: financeAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.royalPurple),
          ),
          error: (error, st) => Padding(
            padding: const EdgeInsets.all(24),
            child: _buildErrorCard(error.toString()),
          ),
          data: (finance) {
            if (finance == null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: _buildEmptyState(),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Overview
                _buildOverviewTab(context, user, finance),
                // Tab 2: Taxation
                _buildTaxationTab(context, finance),
                // Tab 3: Loan/EMI Calculator
                _buildLoanEMITab(context),
                // Tab 4: ROI Calculator
                _buildROITab(context, finance),
                // Tab 5: Budget Planner
                _buildBudgetTab(context, finance),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==================== TAB 1: OVERVIEW ====================
  Widget _buildOverviewTab(BuildContext context, User? user, dynamic finance) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards Row
          _buildFinancialSummaryCards(finance),
          const SizedBox(height: 24),
          // Monthly Expenses Section
          _buildSectionHeader(context, 'Monthly Expenses', Icons.receipt_long),
          const SizedBox(height: 16),
          _buildExpenseCard(context, ref, user, finance),
          const SizedBox(height: 24),
          // Revenue & Profit Section
          _buildSectionHeader(context, 'Revenue & Profit', Icons.trending_up),
          const SizedBox(height: 16),
          _buildRevenueCard(context, ref, user, finance),
          const SizedBox(height: 16),
          // Profit Margin Card
          _buildProfitMarginCard(finance),
          const SizedBox(height: 16),
          // Financial Health Score
          _buildFinancialHealthCard(finance),
          const SizedBox(height: 16),
          // Info Card
          _buildInfoCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCards(dynamic finance) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Revenue',
            '₹${_formatNumber(finance.totalRevenue)}',
            Icons.arrow_upward,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Expense',
            '₹${_formatNumber(finance.totalExpense)}',
            Icons.arrow_downward,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Net Profit',
            '₹${_formatNumber(finance.netProfit)}',
            finance.netProfit > 0 ? Icons.trending_up : Icons.trending_down,
            finance.netProfit > 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialHealthCard(dynamic finance) {
    final healthScore = _calculateHealthScore(finance);
    final healthStatus = _getHealthStatus(healthScore);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            healthStatus['color'].withAlpha(26),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: healthStatus['color'].withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety,
                  color: healthStatus['color'], size: 28),
              const SizedBox(width: 12),
              const Text(
                'Financial Health Score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: healthScore / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            healthStatus['color']),
                      ),
                    ),
                    Text(
                      '${healthScore.toInt()}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: healthStatus['color'],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: healthStatus['color'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        healthStatus['label'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      healthStatus['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateHealthScore(dynamic finance) {
    double score = 50;
    // Profit margin impact
    if (finance.profitMargin > 30) {
      score += 25;
    } else if (finance.profitMargin > 15) {
      score += 15;
    } else if (finance.profitMargin > 0) {
      score += 5;
    } else {
      score -= 20;
    }
    // Revenue vs Expense ratio
    if (finance.totalRevenue > finance.totalExpense * 1.5) score += 15;
    if (finance.totalRevenue > finance.totalExpense * 2) score += 10;
    return score.clamp(0, 100);
  }

  Map<String, dynamic> _getHealthStatus(double score) {
    if (score >= 80) {
      return {
        'label': 'Excellent',
        'color': Colors.green,
        'description': 'Your farm finances are in great shape!'
      };
    } else if (score >= 60) {
      return {
        'label': 'Good',
        'color': Colors.blue,
        'description': 'Finances healthy, minor improvements possible.'
      };
    } else if (score >= 40) {
      return {
        'label': 'Fair',
        'color': Colors.orange,
        'description': 'Consider reducing expenses or increasing revenue.'
      };
    } else {
      return {
        'label': 'Needs Attention',
        'color': Colors.red,
        'description': 'Review your expenses and revenue strategy.'
      };
    }
  }

  // ==================== MONTH NAMES HELPER ====================
  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _fullMonthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // ==================== DATE PICKER WIDGETS ====================
  Widget _buildFYSelector() {
    final currentYear = DateTime.now().year;
    // Generate list of FYs: from 5 years back to 2 years ahead
    final fyOptions = List.generate(8, (i) => currentYear - 5 + i);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.royalPurple.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today,
                color: AppTheme.royalPurple, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Financial Year',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.royalPurple,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppTheme.royalGold.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.royalGold.withAlpha(60)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedFYStartYear,
                icon: const Icon(Icons.arrow_drop_down,
                    color: AppTheme.royalPurple),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.royalPurple,
                ),
                items: fyOptions.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('FY $year-${(year + 1) % 100}'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null)
                    setState(() => _selectedFYStartYear = value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGSTPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.date_range, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'GST Period',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.royalPurple,
            ),
          ),
          const Spacer(),
          // Month selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withAlpha(50)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedGSTMonth,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.royalPurple,
                ),
                items: List.generate(12, (i) {
                  return DropdownMenuItem(
                    value: i + 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(_monthNames[i]),
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedGSTMonth = value);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Year selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withAlpha(50)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedGSTYear,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.royalPurple,
                ),
                items: List.generate(8, (i) {
                  final year = DateTime.now().year - 5 + i;
                  return DropdownMenuItem(
                    value: year,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('$year'),
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedGSTYear = value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildROIDateRangePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.analytics, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analysis Period',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.royalPurple,
                ),
              ),
              const Spacer(),
              // Quick period buttons
              _buildQuickPeriodChip('3M', 3),
              const SizedBox(width: 6),
              _buildQuickPeriodChip('6M', 6),
              const SizedBox(width: 6),
              _buildQuickPeriodChip('1Y', 12),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDatePickerButton(
                  label: 'From',
                  date: _roiStartDate,
                  onTap: () => _selectROIDate(isStart: true),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              ),
              Expanded(
                child: _buildDatePickerButton(
                  label: 'To',
                  date: _roiEndDate,
                  onTap: () => _selectROIDate(isStart: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPeriodChip(String label, int months) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + months, 0);
    final isSelected = _roiStartDate == start &&
        _roiEndDate.month == end.month &&
        _roiEndDate.year == end.year;

    return GestureDetector(
      onTap: () {
        setState(() {
          _roiStartDate = start;
          _roiEndDate = end;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.royalPurple
              : AppTheme.royalPurple.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.royalPurple
                : AppTheme.royalPurple.withAlpha(50),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppTheme.royalPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.royalPurple.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.royalPurple.withAlpha(40)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month,
                size: 16, color: AppTheme.royalPurple),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                Text(
                  '${date.day} ${_monthNames[date.month - 1]} ${date.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.royalPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectROIDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _roiStartDate : _roiEndDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.royalPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _roiStartDate = picked;
          if (_roiEndDate.isBefore(_roiStartDate)) {
            _roiEndDate = _roiStartDate.add(const Duration(days: 180));
          }
        } else {
          _roiEndDate = picked;
          if (_roiStartDate.isAfter(_roiEndDate)) {
            _roiStartDate = _roiEndDate.subtract(const Duration(days: 180));
          }
        }
      });
    }
  }

  // ==================== TAB 2: TAXATION ====================
  Widget _buildTaxationTab(BuildContext context, dynamic finance) {
    // Calculate GST
    final gstInput = TaxCalculator.calculateInputGST(
      fertilizerPurchase: finance.nutrientCost,
      equipmentPurchase: finance.equipmentInvestment / 12,
      packagingPurchase: finance.packagingCost,
      otherPurchases: finance.seedsCost,
    );

    final gstOutput = TaxCalculator.calculateOutputGST(
      rawProduceSales: finance.rawProduceSales,
      processedSales: finance.processedGoodsSales,
      isOrganic: finance.isOrganic,
    );

    // Calculate deductions first
    final deductions = TaxCalculator.calculateDeductions(
      section80C: finance.section80CInvestment,
      section80D: finance.healthInsurance,
      section80G: 0,
      homeLoanInterest: finance.homeLoanInterest,
      educationLoanInterest: 0,
      savingsInterest: 5000,
    );

    final taxableIncome = finance.processedGoodsSales * 12; // Annual
    final incomeTax = TaxCalculator.calculateIncomeTax(
      agriculturalIncome: finance.rawProduceSales * 12,
      nonAgriculturalIncome: taxableIncome,
      otherIncome: 0,
      deductions: deductions.totalDeductions,
    );

    final fyLabel =
        'FY $_selectedFYStartYear-${(_selectedFYStartYear + 1) % 100}';
    final gstPeriodLabel =
        '${_fullMonthNames[_selectedGSTMonth - 1]} $_selectedGSTYear';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GST Period Selector
          _buildGSTPeriodSelector(),
          const SizedBox(height: 16),
          // GST Section
          _buildSectionHeader(
              context, 'GST Calculator — $gstPeriodLabel', Icons.receipt),
          const SizedBox(height: 16),
          _buildGSTCard(gstInput, gstOutput, finance),
          const SizedBox(height: 24),
          // FY Selector
          _buildFYSelector(),
          const SizedBox(height: 16),
          // Income Tax Section
          _buildSectionHeader(
              context, 'Income Tax ($fyLabel)', Icons.account_balance),
          const SizedBox(height: 16),
          _buildIncomeTaxCard(incomeTax, taxableIncome),
          const SizedBox(height: 24),
          // Deductions Section
          _buildSectionHeader(
              context, 'Tax Deductions ($fyLabel)', Icons.savings),
          const SizedBox(height: 16),
          _buildDeductionsCard(deductions),
          const SizedBox(height: 24),
          // Advance Tax Schedule
          _buildSectionHeader(
              context, 'Advance Tax Schedule ($fyLabel)', Icons.calendar_month),
          const SizedBox(height: 16),
          _buildAdvanceTaxCard(incomeTax.totalTax),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGSTCard(
      GSTBreakdown gstInput, double gstOutput, dynamic finance) {
    final netGST = gstOutput - gstInput.totalInputGST;
    final isPayable = netGST > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Input GST
          _buildGSTRow(
            'Input GST (Purchases)',
            '₹${gstInput.totalInputGST.toStringAsFixed(0)}',
            Icons.shopping_cart,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildGSTSubItem('Fertilizers (5%)',
              '₹${gstInput.fertilizerGST.toStringAsFixed(0)}'),
          _buildGSTSubItem('Equipment (12%)',
              '₹${gstInput.equipmentGST.toStringAsFixed(0)}'),
          _buildGSTSubItem('Packaging (18%)',
              '₹${gstInput.packagingGST.toStringAsFixed(0)}'),
          _buildGSTSubItem(
              'Other (18%)', '₹${gstInput.otherGST.toStringAsFixed(0)}'),
          const Divider(height: 24),
          // Output GST
          _buildGSTRow(
            'Output GST (Sales)',
            '₹${gstOutput.toStringAsFixed(0)}',
            Icons.sell,
            Colors.green,
          ),
          const Divider(height: 24),
          // Net GST
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isPayable ? Colors.red : Colors.green).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isPayable ? Icons.payment : Icons.savings,
                      color: isPayable ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isPayable ? 'GST Payable' : 'Input Tax Credit',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${netGST.abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPayable ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Period Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing calculations for ${_fullMonthNames[_selectedGSTMonth - 1]} $_selectedGSTYear',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fresh agricultural produce is GST exempt. Only processed/packaged goods attract GST.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGSTRow(String label, String amount, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGSTSubItem(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(amount, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildIncomeTaxCard(IncomeTaxBreakdown taxInfo, double taxableIncome) {
    // Determine tax slab
    String taxSlab = 'NIL';
    if (taxInfo.taxableIncome > 1500000) {
      taxSlab = '30%';
    } else if (taxInfo.taxableIncome > 1200000) {
      taxSlab = '20%';
    } else if (taxInfo.taxableIncome > 1000000) {
      taxSlab = '15%';
    } else if (taxInfo.taxableIncome > 700000) {
      taxSlab = '10%';
    } else if (taxInfo.taxableIncome > 300000) {
      taxSlab = '5%';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Taxable Income
          _buildTaxInfoRow(
            'Taxable Income (Annual)',
            '₹${_formatNumber(taxInfo.taxableIncome)}',
            Icons.account_balance_wallet,
            AppTheme.royalPurple,
          ),
          const SizedBox(height: 12),
          _buildTaxInfoRow(
            'Tax Slab',
            taxSlab,
            Icons.layers,
            Colors.blue,
          ),
          const Divider(height: 24),
          // Tax Calculation
          _buildTaxInfoRow(
            'Gross Tax',
            '₹${_formatNumber(taxInfo.grossTax)}',
            Icons.calculate,
            Colors.orange,
          ),
          const SizedBox(height: 8),
          _buildTaxInfoRow(
            'Agricultural Income (Exempt)',
            '₹${_formatNumber(taxInfo.agriculturalIncome)}',
            Icons.eco,
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildTaxInfoRow(
            'Add: Cess (4%)',
            '₹${_formatNumber(taxInfo.cess)}',
            Icons.add_circle_outline,
            Colors.red,
          ),
          const Divider(height: 24),
          // Net Tax Payable
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.royalPurple.withAlpha(26),
                  AppTheme.royalGold.withAlpha(26),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance, color: AppTheme.royalPurple),
                    SizedBox(width: 12),
                    Text(
                      'Net Tax Payable',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${_formatNumber(taxInfo.totalTax)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.royalPurple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Agricultural Income Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.eco, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Agricultural income is exempt from income tax under Section 10(1).',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxInfoRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDeductionsCard(DeductionBreakdown deductions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDeductionRow(
            'Section 80C',
            deductions.section80C,
            150000,
            'PPF, ELSS, LIC, NSC',
          ),
          const SizedBox(height: 16),
          _buildDeductionRow(
            'Section 80D',
            deductions.section80D,
            50000,
            'Health Insurance Premium',
          ),
          const SizedBox(height: 16),
          _buildDeductionRow(
            'Section 24',
            deductions.section24,
            200000,
            'Home Loan Interest',
          ),
          const SizedBox(height: 16),
          _buildDeductionRow(
            'Section 80TTA',
            deductions.section80TTA,
            10000,
            'Savings Account Interest',
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Deductions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '₹${_formatNumber(deductions.totalDeductions)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionRow(
      String section, double claimed, double limit, String description) {
    final percentage = (claimed / limit * 100).clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(section, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '₹${_formatNumber(claimed)} / ₹${_formatNumber(limit)}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage >= 100 ? Colors.green : AppTheme.royalPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvanceTaxCard(double totalTax) {
    final schedule = TaxCalculator.getAdvanceTaxSchedule(
      totalTax,
      fyStartYear: _selectedFYStartYear,
    );

    if (schedule.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'No advance tax required (Total tax < ₹10,000)',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: schedule.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.royalGold.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.event,
                      color: AppTheme.royalGold, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${schedule.indexOf(item) + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Due: ${item.dueDate}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${_formatNumber(item.amount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.royalPurple,
                      ),
                    ),
                    Text(
                      '${item.percentage.toInt()}%',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== TAB 3: LOAN/EMI ====================
  Widget _buildLoanEMITab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'EMI Calculator', Icons.calculate),
          const SizedBox(height: 16),
          const _EMICalculatorWidget(),
          const SizedBox(height: 24),
          _buildSectionHeader(
              context, 'Agricultural Loan Schemes', Icons.agriculture),
          const SizedBox(height: 16),
          _buildLoanSchemesCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLoanSchemesCard() {
    final schemes = [
      {
        'name': 'Kisan Credit Card (KCC)',
        'rate': '4% (upto ₹3 Lakh)',
        'tenure': 'Upto 5 years',
        'icon': Icons.credit_card,
        'url': 'https://www.pmkisan.gov.in/KCC.aspx',
      },
      {
        'name': 'PM-KISAN',
        'rate': 'Interest subvention',
        'tenure': 'Annual',
        'icon': Icons.account_balance,
        'url': 'https://pmkisan.gov.in/',
      },
      {
        'name': 'Agri Infrastructure Fund',
        'rate': '3% subvention',
        'tenure': 'Upto 7 years',
        'icon': Icons.warehouse,
        'url': 'https://agriinfra.dac.gov.in/',
      },
      {
        'name': 'NABARD Loan',
        'rate': '7-9%',
        'tenure': 'Upto 15 years',
        'icon': Icons.business,
        'url': 'https://www.nabard.org/content1.aspx?id=591&catid=8&mid=488',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: schemes.map((scheme) {
          return ListTile(
            onTap: () => _launchLoanSchemeUrl(scheme['url'] as String),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.royalGold.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(scheme['icon'] as IconData,
                  color: AppTheme.royalGold, size: 24),
            ),
            title: Text(
              scheme['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Rate: ${scheme['rate']} | ${scheme['tenure']}'),
            trailing:
                Icon(Icons.open_in_new, size: 18, color: AppTheme.royalPurple),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _launchLoanSchemeUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==================== TAB 4: ROI ====================
  Widget _buildROITab(BuildContext context, dynamic finance) {
    // Calculate months in selected range for projections
    final roiMonths = ((_roiEndDate.year - _roiStartDate.year) * 12 +
            _roiEndDate.month -
            _roiStartDate.month)
        .clamp(1, 60);
    final roiPeriodLabel =
        '${_monthNames[_roiStartDate.month - 1]} ${_roiStartDate.year} — ${_monthNames[_roiEndDate.month - 1]} ${_roiEndDate.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Picker
          _buildROIDateRangePicker(),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'ROI Analysis', Icons.insights),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              roiPeriodLabel,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 12),
          _buildROIAnalysisCard(finance, months: roiMonths),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Break-Even Analysis', Icons.balance),
          const SizedBox(height: 16),
          _buildBreakEvenCard(finance),
          const SizedBox(height: 24),
          _buildSectionHeader(
              context, 'Cash Flow Projection', Icons.show_chart),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '$roiMonths-month projection',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 12),
          _buildCashFlowCard(finance, months: roiMonths),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildROIAnalysisCard(dynamic finance, {int months = 12}) {
    final roi = FinancialAnalysis.calculateROI(
      totalInvestment: finance.totalInvestment,
      totalRevenue: finance.totalRevenue * months,
      totalExpenses: finance.totalExpense * months,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildROIMetricCard(
                  '${months >= 12 ? "Annual" : "${months}M"} ROI',
                  '${roi.roiPercentage.toStringAsFixed(1)}%',
                  roi.roiPercentage > 0 ? Colors.green : Colors.red,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildROIMetricCard(
                  'Payback Period',
                  '${(roi.paybackPeriod / 12).toStringAsFixed(1)} yrs',
                  Colors.blue,
                  Icons.schedule,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildROIMetricCard(
                  'Net Profit',
                  '₹${_formatNumber(roi.netProfit)}',
                  Colors.green,
                  Icons.attach_money,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildROIMetricCard(
                  'Investment',
                  '₹${_formatNumber(finance.totalInvestment)}',
                  AppTheme.royalPurple,
                  Icons.savings,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.royalGold.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: AppTheme.royalGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    roi.roiPercentage > 20
                        ? 'Excellent ROI! Your farm is performing above industry average.'
                        : 'Consider optimizing costs or exploring higher-value crops.',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildROIMetricCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakEvenCard(dynamic finance) {
    final fixedCosts = finance.laborCost +
        finance.maintenanceCost +
        finance.insuranceCost +
        finance.emiPaid;
    final variableCostPerUnit =
        (finance.nutrientCost + finance.seedsCost + finance.packagingCost) /
            100; // per kg
    final sellingPricePerUnit = finance.totalRevenue / 100; // per kg

    final breakEven = FinancialAnalysis.calculateBreakEven(
      fixedCosts: fixedCosts,
      variableCostPerUnit: variableCostPerUnit,
      sellingPricePerUnit:
          sellingPricePerUnit > variableCostPerUnit ? sellingPricePerUnit : 50,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBreakEvenMetric(
                'Units',
                '${breakEven.breakEvenUnits.toStringAsFixed(0)} kg',
                Icons.scale,
              ),
              Container(height: 50, width: 1, color: Colors.grey[300]),
              _buildBreakEvenMetric(
                'Revenue',
                '₹${_formatNumber(breakEven.breakEvenRevenue)}',
                Icons.attach_money,
              ),
              Container(height: 50, width: 1, color: Colors.grey[300]),
              _buildBreakEvenMetric(
                'Margin',
                '${breakEven.contributionMargin.toStringAsFixed(0)}',
                Icons.pie_chart,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: breakEven.breakEvenRevenue > 0
                ? ((finance.totalRevenue / breakEven.breakEvenRevenue) * 100)
                        .clamp(0, 100) /
                    100
                : 0,
            backgroundColor: Colors.grey[200],
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.royalPurple),
          ),
          const SizedBox(height: 8),
          Text(
            breakEven.breakEvenRevenue > 0
                ? 'Current revenue is ${((finance.totalRevenue / breakEven.breakEvenRevenue) * 100).toStringAsFixed(0)}% of break-even point'
                : 'Break-even analysis unavailable',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakEvenMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.royalPurple, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.royalPurple,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCashFlowCard(dynamic finance, {int months = 6}) {
    final projection = FinancialAnalysis.generateCashFlowProjection(
      initialBalance: finance.currentSavings,
      monthlyRevenue: finance.totalRevenue,
      monthlyExpenses: finance.totalExpense,
      expectedGrowthRate: 5.0,
      months: months,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _CashFlowChartPainter(projection),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Revenue', Colors.green),
              const SizedBox(width: 24),
              _buildLegendItem('Expenses', Colors.red),
              const SizedBox(width: 24),
              _buildLegendItem('Net', AppTheme.royalPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // ==================== TAB 5: BUDGET ====================
  Widget _buildBudgetTab(BuildContext context, dynamic finance) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Budget Allocation', Icons.pie_chart),
          const SizedBox(height: 16),
          _buildBudgetAllocationCard(finance),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Savings Goal', Icons.savings),
          const SizedBox(height: 16),
          _buildSavingsGoalCard(finance),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Expense Breakdown', Icons.donut_small),
          const SizedBox(height: 16),
          _buildExpenseBreakdownCard(finance),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBudgetAllocationCard(dynamic finance) {
    // Create budget categories based on actual expense data
    final totalExpense = finance.totalExpense as double;
    final categories = <Map<String, dynamic>>[
      {
        'name': 'Utilities',
        'amount': finance.electricityCost + finance.waterCost,
        'color': const Color(0xFFFF9933),
        'percentage': totalExpense > 0
            ? ((finance.electricityCost + finance.waterCost) /
                    totalExpense *
                    100)
                .round()
            : 0,
      },
      {
        'name': 'Inputs',
        'amount': finance.nutrientCost + finance.seedsCost,
        'color': Colors.green,
        'percentage': totalExpense > 0
            ? ((finance.nutrientCost + finance.seedsCost) / totalExpense * 100)
                .round()
            : 0,
      },
      {
        'name': 'Labor',
        'amount': finance.laborCost,
        'color': AppTheme.peacockBlue,
        'percentage': totalExpense > 0
            ? (finance.laborCost / totalExpense * 100).round()
            : 0,
      },
      {
        'name': 'Operations',
        'amount': finance.packagingCost +
            finance.transportCost +
            finance.maintenanceCost,
        'color': AppTheme.royalPurple,
        'percentage': totalExpense > 0
            ? ((finance.packagingCost +
                        finance.transportCost +
                        finance.maintenanceCost) /
                    totalExpense *
                    100)
                .round()
            : 0,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: category['color'] as Color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      '₹${_formatNumber(category['amount'])} (${category['percentage']}%)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: category['color'] as Color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (category['percentage'] as int) / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(category['color'] as Color),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSavingsGoalCard(dynamic finance) {
    final goal = finance.savingsTarget > 0 ? finance.savingsTarget : 100000;
    final current = finance.currentSavings;
    final progress = (current / goal * 100).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.royalGold.withAlpha(26),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.royalGold.withAlpha(77)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Emergency Fund Goal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: progress >= 100 ? Colors.green : AppTheme.royalGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 100 ? Colors.green : AppTheme.royalGold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved: ₹${_formatNumber(current)}',
                style: const TextStyle(color: Colors.green),
              ),
              Text(
                'Goal: ₹${_formatNumber(goal)}',
                style: const TextStyle(color: AppTheme.royalPurple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdownCard(dynamic finance) {
    final expenses = [
      {
        'name': 'Electricity',
        'amount': finance.electricityCost,
        'color': const Color(0xFFFF9933)
      },
      {
        'name': 'Water',
        'amount': finance.waterCost,
        'color': AppTheme.peacockBlue
      },
      {
        'name': 'Nutrients',
        'amount': finance.nutrientCost,
        'color': AppTheme.royalMaroon
      },
      {
        'name': 'Labor',
        'amount': finance.laborCost,
        'color': AppTheme.royalPurple
      },
      {'name': 'Seeds', 'amount': finance.seedsCost, 'color': Colors.green},
      {
        'name': 'Packaging',
        'amount': finance.packagingCost,
        'color': Colors.brown
      },
    ];

    final total =
        expenses.fold<double>(0, (sum, e) => sum + (e['amount'] as double));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(180, 180),
              painter: _PieChartPainter(expenses, total),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: expenses.map((e) {
              final percentage = total > 0
                  ? ((e['amount'] as double) / total * 100).toStringAsFixed(0)
                  : '0';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: e['color'] as Color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${e['name']} ($percentage%)',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final n = number.toDouble();
    if (n >= 10000000) return '${(n / 10000000).toStringAsFixed(1)}Cr';
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.royalGold.withAlpha(38),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.royalGold, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.royalPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(
    BuildContext context,
    WidgetRef ref,
    User? user,
    dynamic finance,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppTheme.royalGold.withAlpha(51)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _EditableExpenseRow(
              icon: Icons.flash_on,
              iconColor: const Color(0xFFFF9933),
              label: 'Electricity',
              amount: finance.electricityCost,
              onEdit: () => _handleExpenseEdit(
                  context,
                  ref,
                  user,
                  'Electricity',
                  finance.electricityCost,
                  (amount) => ref
                      .read(financeControllerProvider.notifier)
                      .updateElectricity(user!.uid, amount)),
            ),
            _buildDivider(),
            _EditableExpenseRow(
              icon: Icons.water_drop,
              iconColor: AppTheme.peacockBlue,
              label: 'Water',
              amount: finance.waterCost,
              onEdit: () => _handleExpenseEdit(
                  context,
                  ref,
                  user,
                  'Water',
                  finance.waterCost,
                  (amount) => ref
                      .read(financeControllerProvider.notifier)
                      .updateWater(user!.uid, amount)),
            ),
            _buildDivider(),
            _EditableExpenseRow(
              icon: Icons.science,
              iconColor: AppTheme.royalMaroon,
              label: 'Nutrients',
              amount: finance.nutrientCost,
              onEdit: () => _handleExpenseEdit(
                  context,
                  ref,
                  user,
                  'Nutrients',
                  finance.nutrientCost,
                  (amount) => ref
                      .read(financeControllerProvider.notifier)
                      .updateNutrients(user!.uid, amount)),
            ),
            _buildDivider(),
            _EditableExpenseRow(
              icon: Icons.person,
              iconColor: AppTheme.royalPurple,
              label: 'Labor',
              amount: finance.laborCost,
              onEdit: () => _handleExpenseEdit(
                  context,
                  ref,
                  user,
                  'Labor',
                  finance.laborCost,
                  (amount) => ref
                      .read(financeControllerProvider.notifier)
                      .updateLabor(user!.uid, amount)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.royalMaroon.withAlpha(26),
                    AppTheme.royalPurple.withAlpha(26),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Monthly Expense',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.royalPurple,
                    ),
                  ),
                  Text(
                    '₹${finance.totalExpense.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.royalMaroon,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(
      BuildContext context, WidgetRef ref, User? user, dynamic finance) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppTheme.royalGold.withAlpha(51)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _handleExpenseEdit(
                  context,
                  ref,
                  user,
                  'Estimated Revenue',
                  finance.estimatedRevenue,
                  (amount) => ref
                      .read(financeControllerProvider.notifier)
                      .updateRevenue(user!.uid, amount)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(38),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.attach_money,
                            color: Colors.green, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Estimated Revenue',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '₹${finance.estimatedRevenue.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.edit, size: 16, color: Colors.grey[400]),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (finance.netProfit > 0
                            ? Colors.green
                            : AppTheme.royalMaroon)
                        .withAlpha(26),
                    AppTheme.royalGold.withAlpha(26),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        finance.netProfit > 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: finance.netProfit > 0
                            ? Colors.green
                            : AppTheme.royalMaroon,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Net Profit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹${finance.netProfit.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: finance.netProfit > 0
                          ? Colors.green
                          : AppTheme.royalMaroon,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitMarginCard(dynamic finance) {
    final margin = finance.estimatedRevenue > 0
        ? (finance.netProfit / finance.estimatedRevenue) * 100
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.royalGold.withAlpha(38),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.royalGold.withAlpha(77)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.royalGold.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.pie_chart,
                  color: AppTheme.royalGold, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profit Margin',
                    style: TextStyle(
                      color: AppTheme.royalPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${margin.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: margin > 0 ? Colors.green : AppTheme.royalMaroon,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: margin > 20
                    ? Colors.green
                    : margin > 0
                        ? Colors.orange
                        : AppTheme.royalMaroon,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                margin > 20
                    ? 'Excellent'
                    : margin > 0
                        ? 'Good'
                        : 'Low',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.royalPurple.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.royalPurple.withAlpha(51)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.royalPurple, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tap on any amount to edit. Changes are saved automatically.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.royalPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.royalMaroon.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline,
              color: AppTheme.royalMaroon, size: 48),
          const SizedBox(height: 12),
          Text('Error: $error', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: AppTheme.royalGold),
          SizedBox(height: 16),
          Text('No finance data available', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: AppTheme.royalGold.withAlpha(51)),
    );
  }

  void _handleExpenseEdit(
    BuildContext context,
    WidgetRef ref,
    User? user,
    String label,
    double currentAmount,
    Function(double) onSave,
  ) {
    if (user == null) return;
    _showEditDialog(context, ref, label, currentAmount, onSave);
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String label,
    double currentAmount,
    Function(double) onSave,
  ) {
    final controller = TextEditingController(text: currentAmount.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.royalGold.withAlpha(38),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.edit, color: AppTheme.royalGold, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Edit $label',
                style: const TextStyle(color: AppTheme.royalPurple)),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter amount',
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.royalPurple.withAlpha(77)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.royalPurple, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              onSave(amount);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label updated to ₹$amount'),
                  backgroundColor: AppTheme.royalPurple,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.royalPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// EMI Calculator Widget
class _EMICalculatorWidget extends StatefulWidget {
  const _EMICalculatorWidget();

  @override
  State<_EMICalculatorWidget> createState() => _EMICalculatorWidgetState();
}

class _EMICalculatorWidgetState extends State<_EMICalculatorWidget> {
  double _principal = 500000;
  double _interestRate = 9;
  int _tenure = 60;
  EMIResult? _result;

  void _calculateEMI() {
    setState(() {
      _result = FinancialAnalysis.calculateEMI(
        principal: _principal,
        annualInterestRate: _interestRate,
        tenureMonths: _tenure,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _calculateEMI();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalPurple.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Principal Slider
          _buildSliderRow(
            'Loan Amount',
            '₹${_formatNumber(_principal)}',
            _principal,
            50000,
            5000000,
            (value) {
              setState(() => _principal = value);
              _calculateEMI();
            },
          ),
          const SizedBox(height: 20),
          // Interest Rate Slider
          _buildSliderRow(
            'Interest Rate',
            '${_interestRate.toStringAsFixed(1)}%',
            _interestRate,
            4,
            20,
            (value) {
              setState(() => _interestRate = value);
              _calculateEMI();
            },
          ),
          const SizedBox(height: 20),
          // Tenure Slider
          _buildSliderRow(
            'Tenure',
            '$_tenure months',
            _tenure.toDouble(),
            12,
            180,
            (value) {
              setState(() => _tenure = value.toInt());
              _calculateEMI();
            },
          ),
          const SizedBox(height: 24),
          // Results
          if (_result != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.royalPurple.withAlpha(26),
                    AppTheme.royalGold.withAlpha(26),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monthly EMI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${_formatNumber(_result!.monthlyEMI)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.royalPurple,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildResultRow('Total Interest',
                      '₹${_formatNumber(_result!.totalInterest)}'),
                  const SizedBox(height: 8),
                  _buildResultRow('Total Payment',
                      '₹${_formatNumber(_result!.totalPayment)}'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSliderRow(
    String label,
    String value,
    double current,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.royalPurple,
              ),
            ),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          activeColor: AppTheme.royalPurple,
          inactiveColor: AppTheme.royalPurple.withAlpha(51),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 10000000)
      return '${(number / 10000000).toStringAsFixed(1)}Cr';
    if (number >= 100000) return '${(number / 100000).toStringAsFixed(1)}L';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toStringAsFixed(0);
  }
}

class _EditableExpenseRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final double amount;
  final VoidCallback onEdit;

  const _EditableExpenseRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(38),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Tap to edit',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.royalPurple,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painters for Charts
class _CashFlowChartPainter extends CustomPainter {
  final List<CashFlowMonth> data;

  _CashFlowChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final revenuePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final expensePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final netPaint = Paint()
      ..color = AppTheme.royalPurple
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final maxValue = data.fold<double>(
        0,
        (max, item) =>
            [item.revenue, item.expenses, max].reduce((a, b) => a > b ? a : b));

    final xStep = size.width / (data.length - 1);
    final yScale = size.height / (maxValue * 1.2);

    // Draw revenue line
    final revenuePath = Path();
    final expensePath = Path();
    final netPath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = i * xStep;
      final revenueY = size.height - data[i].revenue * yScale;
      final expenseY = size.height - data[i].expenses * yScale;
      final netY = size.height - data[i].netCashFlow * yScale;

      if (i == 0) {
        revenuePath.moveTo(x, revenueY);
        expensePath.moveTo(x, expenseY);
        netPath.moveTo(x, netY);
      } else {
        revenuePath.lineTo(x, revenueY);
        expensePath.lineTo(x, expenseY);
        netPath.lineTo(x, netY);
      }
    }

    canvas.drawPath(revenuePath, revenuePaint);
    canvas.drawPath(expensePath, expensePaint);
    canvas.drawPath(netPath, netPaint);

    // Draw data points
    for (var i = 0; i < data.length; i++) {
      final x = i * xStep;
      final revenueY = size.height - data[i].revenue * yScale;
      final expenseY = size.height - data[i].expenses * yScale;

      canvas.drawCircle(Offset(x, revenueY), 4, Paint()..color = Colors.green);
      canvas.drawCircle(Offset(x, expenseY), 4, Paint()..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;

  _PieChartPainter(this.data, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    var startAngle = -math.pi / 2;

    for (final item in data) {
      final amount = (item['amount'] as double?) ?? 0;
      if (amount <= 0) continue;

      final sweepAngle = (amount / total) * 2 * math.pi;
      final paint = Paint()
        ..color = item['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 30
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.02,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

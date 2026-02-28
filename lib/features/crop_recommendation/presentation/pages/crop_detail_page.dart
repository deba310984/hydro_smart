import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/crop.dart';
import '../../../growth/growth_controller.dart';
import '../../../growth/growth_screen.dart';

class CropDetailPage extends ConsumerStatefulWidget {
  final Crop crop;

  const CropDetailPage({Key? key, required this.crop}) : super(key: key);

  @override
  ConsumerState<CropDetailPage> createState() => _CropDetailPageState();
}

class _CropDetailPageState extends ConsumerState<CropDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Crop get crop => widget.crop;

  // Derived financial data
  double get estimatedRevenue =>
      crop.retailPrice * crop.yieldPerSqm * 10; // per 10 sqm
  double get estimatedWholesaleRevenue =>
      crop.wholesalePrice * crop.yieldPerSqm * 10;
  double get estimatedCost => estimatedRevenue * (1 - crop.profitMargin / 100);
  double get estimatedProfit => estimatedRevenue - estimatedCost;
  double get roi =>
      estimatedCost > 0 ? (estimatedProfit / estimatedCost) * 100 : 0;
  double get breakEvenDays =>
      crop.seedToHarvestDays * (estimatedCost / estimatedRevenue);

  // Monthly projection data (12 months)
  List<double> get monthlyRevenue {
    final cyclesPerYear = 365 / crop.seedToHarvestDays;
    final revenuePerCycle = estimatedRevenue;
    final monthlyBase = (revenuePerCycle * cyclesPerYear) / 12;
    // Simulate seasonal variation
    return List.generate(12, (i) {
      final seasonFactor = _getSeasonFactor(i, crop.bestSeason);
      return monthlyBase * seasonFactor;
    });
  }

  List<double> get monthlyCost {
    final cyclesPerYear = 365 / crop.seedToHarvestDays;
    final costPerCycle = estimatedCost;
    final monthlyBase = (costPerCycle * cyclesPerYear) / 12;
    return List.generate(12, (i) => monthlyBase * (0.9 + (i % 3) * 0.05));
  }

  List<double> get monthlyProfit {
    return List.generate(12, (i) => monthlyRevenue[i] - monthlyCost[i]);
  }

  List<double> get cumulativeROI {
    double cumCost = 0;
    double cumRevenue = 0;
    return List.generate(12, (i) {
      cumCost += monthlyCost[i];
      cumRevenue += monthlyRevenue[i];
      return cumCost > 0 ? ((cumRevenue - cumCost) / cumCost) * 100 : 0;
    });
  }

  double _getSeasonFactor(int month, String bestSeason) {
    // month 0 = Jan
    switch (bestSeason.toLowerCase()) {
      case 'summer':
        return [
          0.6,
          0.7,
          0.9,
          1.1,
          1.3,
          1.4,
          1.3,
          1.2,
          1.0,
          0.8,
          0.6,
          0.5
        ][month];
      case 'winter':
        return [
          1.3,
          1.2,
          1.0,
          0.8,
          0.6,
          0.5,
          0.5,
          0.6,
          0.8,
          1.0,
          1.2,
          1.4
        ][month];
      case 'spring':
        return [
          0.7,
          0.9,
          1.2,
          1.4,
          1.3,
          1.1,
          0.9,
          0.8,
          0.7,
          0.7,
          0.7,
          0.7
        ][month];
      case 'autumn':
        return [
          0.7,
          0.7,
          0.7,
          0.8,
          0.9,
          1.0,
          1.1,
          1.3,
          1.4,
          1.2,
          0.9,
          0.7
        ][month];
      default: // year-round
        return [
          1.0,
          1.0,
          1.05,
          1.05,
          1.1,
          1.1,
          1.05,
          1.0,
          1.0,
          0.95,
          0.95,
          0.95
        ][month];
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(activeGrowthProvider);
    final isGrowing = activeSession != null && activeSession.crop.id == crop.id;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startGrowing(context),
        backgroundColor: isGrowing ? Colors.orange[700] : Colors.green[700],
        foregroundColor: Colors.white,
        icon: Icon(isGrowing ? Icons.visibility : Icons.eco),
        label: Text(isGrowing ? 'View Growth' : 'Start Growing'),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildQuickStats()),
            SliverToBoxAdapter(child: _buildTabBar()),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFinancialTab(),
            _buildGrowthTab(),
            _buildConditionsTab(),
            _buildInfoTab(),
          ],
        ),
      ),
    );
  }

  void _startGrowing(BuildContext context) {
    final activeSession = ref.read(activeGrowthProvider);
    final isGrowing = activeSession != null && activeSession.crop.id == crop.id;

    if (isGrowing) {
      // Already growing this crop — just navigate to growth screen.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GrowthTrackerScreen()),
      );
      return;
    }

    if (activeSession != null) {
      // Another crop is active — confirm before switching.
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Switch Crop?'),
          content: Text(
              'You are already growing ${activeSession.crop.cropName}. Starting ${crop.cropName} will replace the current session.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Switch', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true && mounted) {
          _doStartGrowing(context);
        }
      });
    } else {
      _doStartGrowing(context);
    }
  }

  void _doStartGrowing(BuildContext context) {
    ref.read(activeGrowthProvider.notifier).startGrowing(crop);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GrowthTrackerScreen()),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppTheme.royalPurple,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          crop.cropName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.royalPurple, AppTheme.royalMaroon],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 56),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // Crop emoji
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            _getCropEmoji(),
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildHeaderBadge(
                                  crop.difficultyLevel,
                                  _getDifficultyColor(),
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderBadge(
                                  crop.bestSeason,
                                  Colors.blue.shade300,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildHeaderBadge(
                                  '${crop.profitMargin.toStringAsFixed(0)}% Profit',
                                  Colors.green.shade300,
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderBadge(
                                  crop.marketDemandLevel,
                                  Colors.orange.shade300,
                                ),
                              ],
                            ),
                          ],
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
    );
  }

  Widget _buildHeaderBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.royalGold.withOpacity(0.15),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.royalGold.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildQuickStatItem(
                  '💰',
                  'ROI',
                  '${roi.toStringAsFixed(1)}%',
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildQuickStatItem(
                  '📊',
                  'Profit Margin',
                  '${crop.profitMargin.toStringAsFixed(0)}%',
                  AppTheme.royalPurple,
                ),
              ),
              Expanded(
                child: _buildQuickStatItem(
                  '📅',
                  'Harvest',
                  '${crop.seedToHarvestDays}d',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatItem(
                  '🌾',
                  'Yield',
                  '${crop.yieldPerSqm} kg/m²',
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildQuickStatItem(
                  '💵',
                  'Revenue/10m²',
                  '₹${estimatedRevenue.toStringAsFixed(0)}',
                  Colors.teal,
                ),
              ),
              Expanded(
                child: _buildQuickStatItem(
                  '⏱️',
                  'Break-even',
                  '${breakEvenDays.toStringAsFixed(0)}d',
                  Colors.deepOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(
      String emoji, String label, String value, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.royalPurple,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.royalGold,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        tabs: const [
          Tab(text: 'Financial', icon: Icon(Icons.attach_money, size: 18)),
          Tab(text: 'Growth', icon: Icon(Icons.trending_up, size: 18)),
          Tab(text: 'Conditions', icon: Icon(Icons.thermostat, size: 18)),
          Tab(text: 'Info', icon: Icon(Icons.info_outline, size: 18)),
        ],
      ),
    );
  }

  // ==================== FINANCIAL TAB ====================
  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('📈 Revenue vs Cost (Monthly)'),
          const SizedBox(height: 8),
          _buildRevenueCostChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('💰 Cumulative ROI Over 12 Months'),
          const SizedBox(height: 8),
          _buildROIChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('📊 Profit Breakdown'),
          const SizedBox(height: 8),
          _buildProfitPieChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('💵 Financial Summary'),
          const SizedBox(height: 8),
          _buildFinancialSummaryCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('📋 Price Comparison'),
          const SizedBox(height: 8),
          _buildPriceComparisonCard(),
        ],
      ),
    );
  }

  Widget _buildRevenueCostChart() {
    final months = [
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
      'Dec'
    ];
    final maxY = monthlyRevenue.reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = rodIndex == 0 ? 'Revenue' : 'Cost';
                return BarTooltipItem(
                  '${months[groupIndex]}\n$label: ₹${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(color: Colors.white, fontSize: 11),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        months[value.toInt()].substring(0, 1),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 20,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₹${(value / 1000).toStringAsFixed(0)}k',
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade100,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(12, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: monthlyRevenue[i],
                  color: Colors.green.shade400,
                  width: 6,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(3)),
                ),
                BarChartRodData(
                  toY: monthlyCost[i],
                  color: Colors.red.shade300,
                  width: 6,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(3)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildROIChart() {
    final months = [
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
      'Dec'
    ];
    final maxY = cumulativeROI.isNotEmpty
        ? cumulativeROI.reduce((a, b) => a > b ? a : b) * 1.15
        : 100.0;
    final minY = cumulativeROI.isNotEmpty
        ? cumulativeROI.reduce((a, b) => a < b ? a : b)
        : 0.0;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minY: minY < 0 ? minY * 1.1 : 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  return LineTooltipItem(
                    '${months[spot.x.toInt()]}\nROI: ${spot.y.toStringAsFixed(1)}%',
                    const TextStyle(color: Colors.white, fontSize: 11),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade100,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < months.length && idx % 2 == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        months[idx].substring(0, 3),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 22,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                12,
                (i) => FlSpot(i.toDouble(), cumulativeROI[i]),
              ),
              isCurved: true,
              color: AppTheme.royalPurple,
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.royalPurple.withOpacity(0.1),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppTheme.royalPurple,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitPieChart() {
    final totalRevenue = monthlyRevenue.reduce((a, b) => a + b);
    final totalCost = monthlyCost.reduce((a, b) => a + b);
    final totalProfit = totalRevenue - totalCost;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(
                    value: totalProfit,
                    title:
                        '${(totalProfit / totalRevenue * 100).toStringAsFixed(0)}%',
                    color: Colors.green.shade400,
                    radius: 55,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalCost,
                    title:
                        '${(totalCost / totalRevenue * 100).toStringAsFixed(0)}%',
                    color: Colors.red.shade300,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Profit', Colors.green.shade400,
                    '₹${totalProfit.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                _buildLegendItem('Cost', Colors.red.shade300,
                    '₹${totalCost.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                const Divider(),
                _buildLegendItem('Revenue', Colors.blue,
                    '₹${totalRevenue.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
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
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummaryCard() {
    final annualRevenue = monthlyRevenue.reduce((a, b) => a + b);
    final annualCost = monthlyCost.reduce((a, b) => a + b);
    final annualProfit = annualRevenue - annualCost;
    final cyclesPerYear = (365 / crop.seedToHarvestDays).floor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          _buildFinancialRow(
              'Retail Price', '₹${crop.retailPrice.toStringAsFixed(0)}/kg'),
          _buildFinancialRow('Wholesale Price',
              '₹${crop.wholesalePrice.toStringAsFixed(0)}/kg'),
          const Divider(),
          _buildFinancialRow(
              'Yield per m²', '${crop.yieldPerSqm.toStringAsFixed(1)} kg'),
          _buildFinancialRow('Harvest Cycles/Year', '$cyclesPerYear'),
          const Divider(),
          _buildFinancialRow(
              'Annual Revenue (10m²)', '₹${annualRevenue.toStringAsFixed(0)}',
              valueColor: Colors.blue.shade700),
          _buildFinancialRow(
              'Annual Cost (10m²)', '₹${annualCost.toStringAsFixed(0)}',
              valueColor: Colors.red),
          _buildFinancialRow(
              'Annual Profit (10m²)', '₹${annualProfit.toStringAsFixed(0)}',
              valueColor: Colors.green.shade700, isBold: true),
          const Divider(),
          _buildFinancialRow('ROI', '${roi.toStringAsFixed(1)}%',
              valueColor: AppTheme.royalPurple, isBold: true),
          _buildFinancialRow(
              'Break-even', '${breakEvenDays.toStringAsFixed(0)} days',
              valueColor: Colors.deepOrange),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? Colors.black87,
              )),
        ],
      ),
    );
  }

  Widget _buildPriceComparisonCard() {
    final markup = crop.retailPrice > 0 && crop.wholesalePrice > 0
        ? ((crop.retailPrice - crop.wholesalePrice) / crop.wholesalePrice * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPriceCard(
                  'Wholesale',
                  '₹${crop.wholesalePrice.toStringAsFixed(0)}',
                  '/kg',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceCard(
                  'Retail',
                  '₹${crop.retailPrice.toStringAsFixed(0)}',
                  '/kg',
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Retail Markup: ${markup.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String label, String price, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(unit,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== GROWTH TAB ====================
  Widget _buildGrowthTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('📊 Monthly Profit Trend'),
          const SizedBox(height: 8),
          _buildMonthlyProfitChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('🌱 Growth Timeline'),
          const SizedBox(height: 8),
          _buildGrowthTimeline(),
          const SizedBox(height: 24),
          _buildSectionTitle('💧 Hydroponic Techniques'),
          const SizedBox(height: 8),
          _buildTechniquesCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('📈 Market Demand'),
          const SizedBox(height: 8),
          _buildMarketDemandIndicator(),
        ],
      ),
    );
  }

  Widget _buildMonthlyProfitChart() {
    final months = [
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
      'Dec'
    ];
    final maxProfit = monthlyProfit.reduce((a, b) => a > b ? a : b);
    final minProfit = monthlyProfit.reduce((a, b) => a < b ? a : b);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LineChart(
        LineChartData(
          minY: minProfit < 0 ? minProfit * 1.1 : 0,
          maxY: maxProfit * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade100,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < months.length && idx % 2 == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(months[idx].substring(0, 3),
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600])),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 22,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Text('₹${(value / 1000).toStringAsFixed(0)}k',
                      style: TextStyle(fontSize: 9, color: Colors.grey[500]));
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                12,
                (i) => FlSpot(i.toDouble(), monthlyProfit[i]),
              ),
              isCurved: true,
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.teal.shade400],
              ),
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade100.withOpacity(0.5),
                    Colors.teal.shade50.withOpacity(0.2),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthTimeline() {
    final totalDays = crop.seedToHarvestDays;
    final phases = [
      {
        'name': 'Germination',
        'days': (totalDays * 0.15).round(),
        'icon': '🌱',
        'color': Colors.green.shade300
      },
      {
        'name': 'Seedling',
        'days': (totalDays * 0.20).round(),
        'icon': '🌿',
        'color': Colors.green.shade400
      },
      {
        'name': 'Vegetative',
        'days': (totalDays * 0.35).round(),
        'icon': '🪴',
        'color': Colors.green.shade600
      },
      {
        'name': 'Flowering',
        'days': (totalDays * 0.15).round(),
        'icon': '🌸',
        'color': Colors.pink.shade300
      },
      {
        'name': 'Harvest',
        'days': (totalDays * 0.15).round(),
        'icon': '🌾',
        'color': Colors.orange
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ...phases.asMap().entries.map((entry) {
            final phase = entry.value;
            final isLast = entry.key == phases.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline indicator
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (phase['color'] as Color).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: phase['color'] as Color, width: 2),
                      ),
                      child: Center(
                        child: Text(phase['icon'] as String,
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 30,
                        color: Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Phase info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          phase['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (phase['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${phase['days']} days',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: phase['color'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, size: 18, color: AppTheme.royalPurple),
              const SizedBox(width: 8),
              Text(
                'Total: $totalDays days to harvest',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalPurple,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechniquesCard() {
    final techniques = crop.hydroponicTechniques;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: techniques.entries.map((entry) {
          final isCompatible = entry.value['compatible'] == true;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  isCompatible ? Icons.check_circle : Icons.cancel,
                  color: isCompatible ? Colors.green : Colors.red.shade300,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompatible ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompatible
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isCompatible ? 'Compatible' : 'Not Recommended',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCompatible
                          ? Colors.green.shade700
                          : Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMarketDemandIndicator() {
    final demandLevel = crop.marketDemandLevel.toLowerCase();
    final demandValue = {
          'low': 0.25,
          'medium': 0.5,
          'high': 0.75,
          'very-high': 0.95,
        }[demandLevel] ??
        0.5;
    final demandColor = {
          'low': Colors.red,
          'medium': Colors.orange,
          'high': Colors.green,
          'very-high': Colors.green.shade800,
        }[demandLevel] ??
        Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Market Demand',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700])),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: demandColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: demandColor.withOpacity(0.5)),
                ),
                child: Text(
                  crop.marketDemandLevel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: demandColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: demandValue,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(demandColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Season: ${crop.bestSeason}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ==================== CONDITIONS TAB ====================
  Widget _buildConditionsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🌡️ Growing Conditions'),
          const SizedBox(height: 8),
          _buildConditionsRadar(),
          const SizedBox(height: 24),
          _buildSectionTitle('📋 Detailed Conditions'),
          const SizedBox(height: 8),
          _buildConditionDetailCard(
            'pH Range',
            crop.getPhRangeString(),
            'Optimal: ${crop.phRange['optimal'] ?? 'N/A'}',
            Icons.water_drop,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildConditionDetailCard(
            'Temperature',
            crop.getTemperatureRangeString(),
            'Optimal: ${crop.temperatureRange['optimal'] ?? 'N/A'}°C',
            Icons.thermostat,
            Colors.red,
          ),
          const SizedBox(height: 8),
          _buildConditionDetailCard(
            'Light Requirement',
            '${crop.lightRequirement['daily_hours'] ?? 'N/A'} hrs/day',
            'Min Lux: ${crop.lightRequirement['lux_min'] ?? 'N/A'}',
            Icons.wb_sunny,
            Colors.orange,
          ),
          const SizedBox(height: 8),
          _buildConditionDetailCard(
            'Plants per m²',
            '${crop.expectedPlantsPerSqm}',
            'Yield: ${crop.yieldPerSqm} kg/m²',
            Icons.grid_view,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsRadar() {
    // Normalize values to 0-10 scale for radar chart
    final phNorm =
        ((crop.phRange['optimal'] ?? 6.5) / 14.0 * 10).clamp(0, 10).toDouble();
    final tempNorm = ((crop.temperatureRange['optimal'] ?? 24) / 40.0 * 10)
        .clamp(0, 10)
        .toDouble();
    final lightNorm = ((crop.lightRequirement['daily_hours'] ?? 14) / 24.0 * 10)
        .clamp(0, 10)
        .toDouble();
    final yieldNorm = (crop.yieldPerSqm / 50.0 * 10).clamp(0, 10).toDouble();
    final profitNorm = (crop.profitMargin / 100.0 * 10).clamp(0, 10).toDouble();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          radarBorderData: const BorderSide(color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.royalPurple,
          ),
          getTitle: (index, angle) {
            switch (index) {
              case 0:
                return const RadarChartTitle(text: 'pH');
              case 1:
                return const RadarChartTitle(text: 'Temp');
              case 2:
                return const RadarChartTitle(text: 'Light');
              case 3:
                return const RadarChartTitle(text: 'Yield');
              case 4:
                return const RadarChartTitle(text: 'Profit');
              default:
                return const RadarChartTitle(text: '');
            }
          },
          dataSets: [
            RadarDataSet(
              fillColor: AppTheme.royalPurple.withOpacity(0.15),
              borderColor: AppTheme.royalPurple,
              borderWidth: 2,
              entryRadius: 4,
              dataEntries: [
                RadarEntry(value: phNorm),
                RadarEntry(value: tempNorm),
                RadarEntry(value: lightNorm),
                RadarEntry(value: yieldNorm),
                RadarEntry(value: profitNorm),
              ],
            ),
          ],
          tickCount: 4,
          ticksTextStyle: TextStyle(fontSize: 8, color: Colors.grey[400]),
          tickBorderData: BorderSide(color: Colors.grey.shade200),
          gridBorderData: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildConditionDetailCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== INFO TAB ====================
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('📝 Description'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              crop.description.isEmpty
                  ? 'No description available.'
                  : crop.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (crop.commonNames.isNotEmpty) ...[
            _buildSectionTitle('🏷️ Common Names'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: crop.commonNames
                  .map((name) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.royalPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.royalPurple.withOpacity(0.3)),
                        ),
                        child: Text(name,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.royalPurple)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          if (crop.advantages.isNotEmpty) ...[
            _buildSectionTitle('✅ Advantages'),
            const SizedBox(height: 8),
            ...crop.advantages.map((adv) => _buildBulletItem(
                adv, Colors.green.shade700, Icons.check_circle)),
            const SizedBox(height: 20),
          ],
          if (crop.challenges.isNotEmpty) ...[
            _buildSectionTitle('⚠️ Challenges'),
            const SizedBox(height: 8),
            ...crop.challenges.map((ch) =>
                _buildBulletItem(ch, Colors.orange.shade700, Icons.warning)),
            const SizedBox(height: 20),
          ],
          if (crop.mainChallenges.isNotEmpty) ...[
            _buildSectionTitle('🔴 Main Challenges'),
            const SizedBox(height: 8),
            ...crop.mainChallenges
                .map((ch) => _buildBulletItem(ch, Colors.red, Icons.error)),
            const SizedBox(height: 20),
          ],
          // Quick info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.royalPurple.withOpacity(0.08),
                  AppTheme.royalGold.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.royalGold.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _buildInfoRow('Suitable for Beginners',
                    crop.suitableForBeginners ? '✅ Yes' : '❌ No'),
                _buildInfoRow('Difficulty', crop.difficultyLevel),
                _buildInfoRow('Best Season', crop.bestSeason),
                _buildInfoRow('Market Demand', crop.marketDemandLevel),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.royalPurple,
      ),
    );
  }

  String _getCropEmoji() {
    final name = crop.cropName.toLowerCase();
    if (name.contains('tomato')) return '🍅';
    if (name.contains('lettuce')) return '🥬';
    if (name.contains('spinach')) return '🌿';
    if (name.contains('cucumber')) return '🥒';
    if (name.contains('pepper')) return '🫑';
    if (name.contains('basil')) return '🌿';
    if (name.contains('herbs')) return '🌱';
    if (name.contains('strawberr')) return '🍓';
    if (name.contains('mint')) return '🌿';
    if (name.contains('kale')) return '🥬';
    return '🌱';
  }

  Color _getDifficultyColor() {
    switch (crop.difficultyLevel.toLowerCase()) {
      case 'beginner':
        return Colors.green.shade300;
      case 'intermediate':
        return Colors.orange.shade300;
      case 'advanced':
        return Colors.red.shade300;
      case 'expert':
        return Colors.purple.shade300;
      default:
        return Colors.grey.shade300;
    }
  }
}

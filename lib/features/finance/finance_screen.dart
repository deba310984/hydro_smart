import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'finance_controller.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(financeDataProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.lotusWhite,
      body: CustomScrollView(
        slivers: [
          // Royal Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.royalPurple,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.royalGold.withOpacity(0.2),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bills & Finance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Track your farm expenses',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: financeAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.royalPurple),
                ),
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

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Monthly Expenses Section
                      _buildSectionHeader(
                          context, 'Monthly Expenses', Icons.receipt_long),
                      const SizedBox(height: 16),
                      _buildExpenseCard(
                        context,
                        ref,
                        user,
                        finance,
                      ),
                      const SizedBox(height: 24),
                      // Revenue & Profit Section
                      _buildSectionHeader(
                          context, 'Revenue & Profit', Icons.trending_up),
                      const SizedBox(height: 16),
                      _buildRevenueCard(context, ref, user, finance),
                      const SizedBox(height: 16),
                      // Profit Margin Card
                      _buildProfitMarginCard(finance),
                      const SizedBox(height: 16),
                      // Info Card
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.royalGold.withOpacity(0.15),
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
            color: AppTheme.royalPurple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppTheme.royalGold.withOpacity(0.2)),
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
                    AppTheme.royalMaroon.withOpacity(0.1),
                    AppTheme.royalPurple.withOpacity(0.1),
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
            color: AppTheme.royalPurple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppTheme.royalGold.withOpacity(0.2)),
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
                          color: Colors.green.withOpacity(0.15),
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
                        .withOpacity(0.1),
                    AppTheme.royalGold.withOpacity(0.1),
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
            AppTheme.royalGold.withOpacity(0.15),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.royalGold.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.royalGold.withOpacity(0.2),
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
        color: AppTheme.royalPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.royalPurple.withOpacity(0.2)),
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
        color: AppTheme.royalMaroon.withOpacity(0.1),
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
      child: Divider(color: AppTheme.royalGold.withOpacity(0.2)),
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
                color: AppTheme.royalGold.withOpacity(0.15),
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
              borderSide:
                  BorderSide(color: AppTheme.royalPurple.withOpacity(0.3)),
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
                color: iconColor.withOpacity(0.15),
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

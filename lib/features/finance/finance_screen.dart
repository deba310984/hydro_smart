import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'finance_controller.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(financeDataProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills & Finance'),
        centerTitle: true,
      ),
      body: financeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(
          child: Text('Error: $error'),
        ),
        data: (finance) {
          if (finance == null) {
            return const Center(child: Text('No finance data'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Expenses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _EditableExpenseRow(
                          icon: Icons.flash_on,
                          label: 'Electricity',
                          amount: finance.electricityCost,
                          onEdit: () {
                            if (user != null) {
                              _showEditDialog(
                                context,
                                ref,
                                'Electricity',
                                finance.electricityCost,
                                (amount) {
                                  ref
                                      .read(financeControllerProvider.notifier)
                                      .updateElectricity(user.uid, amount);
                                },
                              );
                            }
                          },
                        ),
                        const Divider(),
                        _EditableExpenseRow(
                          icon: Icons.water_drop,
                          label: 'Water',
                          amount: finance.waterCost,
                          onEdit: () {
                            if (user != null) {
                              _showEditDialog(
                                context,
                                ref,
                                'Water',
                                finance.waterCost,
                                (amount) {
                                  ref
                                      .read(financeControllerProvider.notifier)
                                      .updateWater(user.uid, amount);
                                },
                              );
                            }
                          },
                        ),
                        const Divider(),
                        _EditableExpenseRow(
                          icon: Icons.science,
                          label: 'Nutrients',
                          amount: finance.nutrientCost,
                          onEdit: () {
                            if (user != null) {
                              _showEditDialog(
                                context,
                                ref,
                                'Nutrients',
                                finance.nutrientCost,
                                (amount) {
                                  ref
                                      .read(financeControllerProvider.notifier)
                                      .updateNutrients(user.uid, amount);
                                },
                              );
                            }
                          },
                        ),
                        const Divider(),
                        _EditableExpenseRow(
                          icon: Icons.person,
                          label: 'Labor',
                          amount: finance.laborCost,
                          onEdit: () {
                            if (user != null) {
                              _showEditDialog(
                                context,
                                ref,
                                'Labor',
                                finance.laborCost,
                                (amount) {
                                  ref
                                      .read(financeControllerProvider.notifier)
                                      .updateLabor(user.uid, amount);
                                },
                              );
                            }
                          },
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Monthly Expense',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '₹${finance.totalExpense.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Revenue & Profit',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (user != null) {
                              _showEditDialog(
                                context,
                                ref,
                                'Estimated Revenue',
                                finance.estimatedRevenue,
                                (amount) {
                                  ref
                                      .read(financeControllerProvider.notifier)
                                      .updateRevenue(user.uid, amount);
                                },
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Estimated Revenue',
                                style: Theme.of(context).textTheme.titleMedium,
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
                                  Icon(Icons.edit,
                                      size: 16, color: Colors.grey[600]),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Net Profit',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₹${finance.netProfit.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: finance.netProfit > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profit Margin',
                                style: TextStyle(color: Colors.green[700]),
                              ),
                              Text(
                                '${(finance.estimatedRevenue > 0 ? (finance.netProfit / finance.estimatedRevenue) * 100 : 0).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tap on any amount to edit it. Changes are saved to your account.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter amount',
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              onSave(amount);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label updated to ₹$amount'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _EditableExpenseRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final VoidCallback onEdit;

  const _EditableExpenseRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit, size: 16, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

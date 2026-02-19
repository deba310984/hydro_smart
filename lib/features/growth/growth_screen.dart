import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'growth_controller.dart';

class GrowthTrackerScreen extends ConsumerWidget {
  const GrowthTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growth = ref.watch(growthDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Tracker'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      growth.cropName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Days Since Plantation',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '${growth.daysSincePlantation}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Days Remaining',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '${growth.daysRemaining}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
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
            const SizedBox(height: 24),
            Text(
              'Growth Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: growth.progressPercentage / 100,
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          growth.progressPercentage < 50
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${growth.progressPercentage.toStringAsFixed(1)}% Complete',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${growth.daysSincePlantation}/${growth.totalGrowthDays} days',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Expected Harvest',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.green[700]),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expected Harvest Date',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                        Text(
                          '${growth.expectedHarvestDate.day}/${growth.expectedHarvestDate.month}/${growth.expectedHarvestDate.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Growth Milestones',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _MilestoneItem(
                      label: 'Germination',
                      completed: growth.daysSincePlantation >= 2,
                    ),
                    _MilestoneItem(
                      label: 'Early Growth',
                      completed: growth.daysSincePlantation >= 10,
                    ),
                    _MilestoneItem(
                      label: 'Full Maturity',
                      completed: growth.daysSincePlantation >= 25,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final String label;
  final bool completed;

  const _MilestoneItem({
    required this.label,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: completed ? Colors.green : Colors.grey[600],
              fontWeight: completed ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

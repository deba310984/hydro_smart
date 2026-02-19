import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydro_smart/data/models/recommendation_model.dart';
import 'package:hydro_smart/features/ai/recommendation_controller.dart';
import 'package:hydro_smart/features/auth/auth_controller.dart';
import 'package:hydro_smart/features/farm/farm_controller.dart';
import 'package:hydro_smart/features/sensors/sensor_provider.dart';

class RecommendationScreen extends ConsumerStatefulWidget {
  const RecommendationScreen({super.key});

  @override
  ConsumerState<RecommendationScreen> createState() =>
      _RecommendationScreenState();
}

class _RecommendationScreenState extends ConsumerState<RecommendationScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  /// Fetch AI recommendations based on current sensor data
  void _fetchRecommendations() async {
    final authState = ref.read(authStateProvider);

    authState.whenData((user) {
      if (user != null) {
        final farmState = ref.read(farmControllerProvider(user.uid));
        final selectedFarm = farmState.selectedFarm ?? farmState.farms.first;

        // Get current sensor readings
        final sensorAsync = ref.read(
          sensorDataStreamProvider(selectedFarm.deviceId).future,
        );

        sensorAsync
            .then((sensorData) {
              Future.microtask(() {
                ref
                    .read(recommendationControllerProvider.notifier)
                    .fetchRecommendations(
                      temperature: sensorData['temperature'] ?? 25.0,
                      humidity: sensorData['humidity'] ?? 65.0,
                      ph: sensorData['ph'] ?? 6.5,
                      farmSize: selectedFarm.area,
                      alternativeCount: 2,
                    );
              });
            })
            .catchError((e) {
              // Use default values if sensor data unavailable
              Future.microtask(() {
                ref
                    .read(recommendationControllerProvider.notifier)
                    .fetchRecommendations(
                      temperature: 25.0,
                      humidity: 65.0,
                      ph: 6.5,
                      farmSize: 50.0,
                      alternativeCount: 2,
                    );
              });
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final recommendationState = ref.watch(recommendationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Crop Recommendations'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: recommendationState.isLoading
          ? const _LoadingState()
          : recommendationState.error != null
          ? _ErrorState(error: recommendationState.error!)
          : recommendationState.primaryRecommendation == null
          ? const _NoRecommendationState()
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildPrimaryRecommendation(
                    context,
                    recommendationState.primaryRecommendation!,
                    isMobile,
                  ),
                  const SizedBox(height: 32),
                  if (recommendationState
                      .alternativeRecommendations
                      .isNotEmpty) ...[
                    _buildAlternativesSection(
                      context,
                      recommendationState.alternativeRecommendations,
                      isMobile,
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildComparisonSection(
                    context,
                    recommendationState.primaryRecommendation!,
                  ),
                ],
              ),
            ),
    );
  }

  /// Build screen header
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('🤖', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Recommendations',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'AI-powered crop suggestions based on your conditions',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build primary recommendation card
  Widget _buildPrimaryRecommendation(
    BuildContext context,
    RecommendationModel recommendation,
    bool isMobile,
  ) {
    final difficultyColor = _getDifficultyColor(recommendation.difficulty);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.15),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⭐ Recommended',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  recommendation.difficulty.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: difficultyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Crop name and emoji
          Text(
            recommendation.recommendedCrop,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 12),

          // Reasoning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              recommendation.reasoning,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Key metrics grid
          isMobile
              ? Column(
                  spacing: 12,
                  children: [
                    _buildMetricRow(
                      context,
                      '🌡️ Temperature',
                      '${recommendation.optimalTemperature}°C',
                    ),
                    _buildMetricRow(
                      context,
                      '💧 Humidity',
                      '${recommendation.optimalHumidity}%',
                    ),
                    _buildMetricRow(
                      context,
                      '🧪 pH Level',
                      '${recommendation.optimalPh}',
                    ),
                    _buildMetricRow(
                      context,
                      '📊 Growth Days',
                      '${recommendation.growthDaysEstimate.toInt()} days',
                    ),
                  ],
                )
              : GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildMetricCard(
                      context,
                      '🌡️',
                      'Temperature',
                      '${recommendation.optimalTemperature}°C',
                    ),
                    _buildMetricCard(
                      context,
                      '💧',
                      'Humidity',
                      '${recommendation.optimalHumidity}%',
                    ),
                    _buildMetricCard(
                      context,
                      '🧪',
                      'pH Level',
                      '${recommendation.optimalPh}',
                    ),
                    _buildMetricCard(
                      context,
                      '📊',
                      'Growth Time',
                      '${recommendation.growthDaysEstimate.toInt()} days',
                    ),
                  ],
                ),
          const SizedBox(height: 20),

          // Benefits and challenges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBenefitsCard(context, recommendation.benefits),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChallengesCard(context, recommendation.challenges),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build metric row for mobile
  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  /// Build metric card for desktop
  Widget _buildMetricCard(
    BuildContext context,
    String emoji,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  /// Build benefits card
  Widget _buildBenefitsCard(BuildContext context, List<String> benefits) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✅ Benefits',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          ...benefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $benefit',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build challenges card
  Widget _buildChallengesCard(BuildContext context, List<String> challenges) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚠️ Challenges',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 8),
          ...challenges.map((challenge) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $challenge',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build alternatives section
  Widget _buildAlternativesSection(
    BuildContext context,
    List<RecommendationModel> alternatives,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alternative Crops',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        isMobile
            ? Column(
                spacing: 12,
                children: alternatives
                    .map((alt) => _buildAlternativeCard(context, alt))
                    .toList(),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: alternatives.length,
                itemBuilder: (context, index) {
                  return _buildAlternativeCard(context, alternatives[index]);
                },
              ),
      ],
    );
  }

  /// Build single alternative card
  Widget _buildAlternativeCard(
    BuildContext context,
    RecommendationModel alternative,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alternative.recommendedCrop,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Growth: ${alternative.growthDaysEstimate.toInt()} days',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Difficulty: ${alternative.difficulty}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Build conditions comparison section
  Widget _buildComparisonSection(
    BuildContext context,
    RecommendationModel recommendation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimal Conditions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildConditionRow(
                context,
                'Temperature Range',
                '${(recommendation.optimalTemperature - 2).toStringAsFixed(1)} - ${(recommendation.optimalTemperature + 2).toStringAsFixed(1)}°C',
              ),
              const Divider(),
              _buildConditionRow(
                context,
                'Humidity Range',
                '${(recommendation.optimalHumidity - 10).toStringAsFixed(0)} - ${(recommendation.optimalHumidity + 10).toStringAsFixed(0)}%',
              ),
              const Divider(),
              _buildConditionRow(
                context,
                'pH Range',
                '${(recommendation.optimalPh - 0.5).toStringAsFixed(1)} - ${(recommendation.optimalPh + 0.5).toStringAsFixed(1)}',
              ),
              const Divider(),
              _buildConditionRow(
                context,
                'Water Level',
                '${(recommendation.optimalWaterLevel - 10).toStringAsFixed(0)} - ${(recommendation.optimalWaterLevel + 10).toStringAsFixed(0)}%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build condition row
  Widget _buildConditionRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  /// Get difficulty color
  Color _getDifficultyColor(String difficulty) {
    return switch (difficulty.toLowerCase()) {
      'easy' => Colors.green,
      'medium' => Colors.orange,
      'hard' => Colors.red,
      _ => Colors.grey,
    };
  }
}

/// Loading state widget
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(
            'Analyzing your conditions...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Error state widget
class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Recommendation Error',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

/// No recommendation available
class _NoRecommendationState extends StatelessWidget {
  const _NoRecommendationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Recommendations',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to generate recommendations',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

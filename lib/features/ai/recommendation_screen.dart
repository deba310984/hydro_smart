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

class _RecommendationScreenState extends ConsumerState<RecommendationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedState;
  String? _selectedCategory;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRecommendations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

        sensorAsync.then((sensorData) {
          Future.microtask(() {
            ref
                .read(recommendationControllerProvider.notifier)
                .fetchRecommendations(
                  temperature: sensorData['temperature'] ?? 25.0,
                  humidity: sensorData['humidity'] ?? 65.0,
                  ph: sensorData['ph'] ?? 6.5,
                  farmSize: selectedFarm.area,
                  alternativeCount: 10,
                  state: _selectedState,
                  category: _selectedCategory,
                  difficulty: _selectedDifficulty,
                );
          });
        }).catchError((e) {
          // Use default values if sensor data unavailable
          Future.microtask(() {
            ref
                .read(recommendationControllerProvider.notifier)
                .fetchRecommendations(
                  temperature: 25.0,
                  humidity: 65.0,
                  ph: 6.5,
                  farmSize: 50.0,
                  alternativeCount: 10,
                  state: _selectedState,
                  category: _selectedCategory,
                  difficulty: _selectedDifficulty,
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
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: const Text('🌱 Crop Recommendations'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF4A2C7C), // Royal purple
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFFFFD700), // Royal gold
          tabs: const [
            Tab(text: 'Best Match', icon: Icon(Icons.star, size: 18)),
            Tab(text: 'All Crops', icon: Icon(Icons.grid_view, size: 18)),
            Tab(text: 'Categories', icon: Icon(Icons.category, size: 18)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter section
          _buildFilterSection(context),

          // Content
          Expanded(
            child: recommendationState.isLoading
                ? const _LoadingState()
                : recommendationState.error != null
                    ? _ErrorState(
                        error: recommendationState.error!,
                        onRetry: _fetchRecommendations,
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // Best Match Tab
                          _buildBestMatchTab(
                            context,
                            recommendationState,
                            isMobile,
                          ),
                          // All Crops Tab
                          _buildAllCropsTab(
                            context,
                            recommendationState,
                            isMobile,
                          ),
                          // Categories Tab
                          _buildCategoriesTab(context, isMobile),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  /// Build filter section with state, category, and difficulty dropdowns
  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // State dropdown
            _buildFilterDropdown(
              context,
              label: '📍 State',
              value: _selectedState,
              items: indianStates,
              onChanged: (value) {
                setState(() => _selectedState = value);
                _fetchRecommendations();
              },
            ),
            const SizedBox(width: 12),

            // Category dropdown
            _buildCategoryDropdown(context),
            const SizedBox(width: 12),

            // Difficulty dropdown
            _buildDifficultyDropdown(context),
            const SizedBox(width: 12),

            // Refresh button
            ElevatedButton.icon(
              onPressed: _fetchRecommendations,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A2C7C),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(label),
          value: value,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All $label'),
            ),
            ...items.map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text('🌿 Category'),
          value: _selectedCategory,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Categories'),
            ),
            ...cropCategories.map((cat) => DropdownMenuItem(
                  value: cat['id'],
                  child: Text('${cat['emoji']} ${cat['name']}'),
                )),
          ],
          onChanged: (value) {
            setState(() => _selectedCategory = value);
            _fetchRecommendations();
          },
        ),
      ),
    );
  }

  Widget _buildDifficultyDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text('📊 Difficulty'),
          value: _selectedDifficulty,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Levels'),
            ),
            ...difficultyLevels.map((level) => DropdownMenuItem(
                  value: level['id'],
                  child: Text(level['name']!),
                )),
          ],
          onChanged: (value) {
            setState(() => _selectedDifficulty = value);
            _fetchRecommendations();
          },
        ),
      ),
    );
  }

  /// Build Best Match tab with primary recommendation
  Widget _buildBestMatchTab(
    BuildContext context,
    RecommendationState state,
    bool isMobile,
  ) {
    if (state.primaryRecommendation == null) {
      return const _NoRecommendationState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildPrimaryRecommendation(
            context,
            state.primaryRecommendation!,
            isMobile,
          ),
          const SizedBox(height: 32),
          if (state.alternativeRecommendations.isNotEmpty) ...[
            _buildAlternativesSection(
              context,
              state.alternativeRecommendations.take(5).toList(),
              isMobile,
            ),
          ],
        ],
      ),
    );
  }

  /// Build All Crops tab
  Widget _buildAllCropsTab(
    BuildContext context,
    RecommendationState state,
    bool isMobile,
  ) {
    final allCrops = [
      if (state.primaryRecommendation != null) state.primaryRecommendation!,
      ...state.alternativeRecommendations,
    ];

    if (allCrops.isEmpty) {
      return const _NoRecommendationState();
    }

    return GridView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.1 : 0.9,
      ),
      itemCount: allCrops.length,
      itemBuilder: (context, index) {
        return _buildComprehensiveCropCard(context, allCrops[index]);
      },
    );
  }

  /// Build Categories tab
  Widget _buildCategoriesTab(BuildContext context, bool isMobile) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cropCategories.length,
      itemBuilder: (context, index) {
        final category = cropCategories[index];
        return _buildCategoryCard(
          context,
          category['emoji']!,
          category['name']!,
          category['id']!,
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String emoji,
    String name,
    String categoryId,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() => _selectedCategory = categoryId);
          _tabController.animateTo(1); // Switch to All Crops tab
          _fetchRecommendations();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view crops in this category',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
            ],
          ),
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
                    _selectedState != null
                        ? 'Optimized for $_selectedState • ${_getCurrentSeason()}'
                        : 'AI-powered crop suggestions based on your conditions',
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

  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 11 || month <= 2) return 'Winter (Rabi)';
    if (month >= 3 && month <= 5) return 'Summer';
    if (month >= 6 && month <= 9) return 'Monsoon (Kharif)';
    return 'Fall';
  }

  /// Build primary recommendation card with comprehensive data
  Widget _buildPrimaryRecommendation(
    BuildContext context,
    RecommendationModel recommendation,
    bool isMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4A2C7C).withOpacity(0.15),
            const Color(0xFFFFD700).withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF4A2C7C).withOpacity(0.3), width: 2),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A2C7C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⭐ Best Match',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              _buildCompatibilityBadge(
                  context, recommendation.compatibilityScore),
              const SizedBox(width: 8),
              _buildDifficultyBadge(context, recommendation.difficultyLevel),
            ],
          ),
          const SizedBox(height: 16),

          // Crop name with emoji
          Row(
            children: [
              Text(
                recommendation.cropEmoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.recommendedCrop,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4A2C7C),
                              ),
                    ),
                    if (recommendation.scientificName.isNotEmpty)
                      Text(
                        recommendation.scientificName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          if (recommendation.description.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                recommendation.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
            ),
          const SizedBox(height: 20),

          // Quick stats row
          _buildQuickStats(context, recommendation),
          const SizedBox(height: 20),

          // Detailed metrics
          _buildDetailedMetrics(context, recommendation, isMobile),
          const SizedBox(height: 20),

          // Growing tips
          if (recommendation.tips.isNotEmpty)
            _buildTipsSection(context, recommendation.tips),
        ],
      ),
    );
  }

  Widget _buildCompatibilityBadge(BuildContext context, double score) {
    final color = score >= 80
        ? Colors.green
        : score >= 60
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${score.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(BuildContext context, String difficulty) {
    final color = _getDifficultyColor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, RecommendationModel rec) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, '📅', 'Harvest', '${rec.daysToHarvest} days'),
          _buildStatItem(context, '📈', 'Yield',
              '${rec.yieldPerSqm.toStringAsFixed(1)} kg/m²'),
          _buildStatItem(context, '💰', 'Profit',
              '${rec.profitMargin.toStringAsFixed(0)}%'),
          _buildStatItem(context, rec.waterIcon, 'Water', rec.waterConsumption),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildDetailedMetrics(
    BuildContext context,
    RecommendationModel rec,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimal Growing Conditions',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildMetricChip(
                context, '🌡️', 'Temperature', rec.temperatureRangeString),
            _buildMetricChip(
                context, '💧', 'Humidity', rec.humidityRangeString),
            _buildMetricChip(context, '🧪', 'pH', rec.phRangeString),
            _buildMetricChip(context, '⚡', 'EC', rec.ecRangeString),
            _buildMetricChip(context, '☀️', 'Light', '${rec.lightHours}h/day'),
            _buildMetricChip(
                context, '📦', 'Storage', '${rec.storageDays} days'),
          ],
        ),
        if (rec.bestHydroponicSystems.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Best Hydroponic Systems',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rec.bestHydroponicSystems.map((system) {
              return Chip(
                label: Text(system),
                backgroundColor: const Color(0xFFE8E0F0),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricChip(
    BuildContext context,
    String emoji,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context, List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Growing Tips',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tips.take(3).map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        tip,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Build comprehensive crop card for grid view
  Widget _buildComprehensiveCropCard(
    BuildContext context,
    RecommendationModel crop,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showCropDetails(context, crop),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Text(crop.cropEmoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.recommendedCrop,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          crop.category.replaceAll('_', ' ').toUpperCase(),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  _buildCompatibilityBadge(context, crop.compatibilityScore),
                ],
              ),
              const SizedBox(height: 12),

              // Quick info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat('📅', '${crop.daysToHarvest}d'),
                  _buildMiniStat(
                      '📈', '${crop.yieldPerSqm.toStringAsFixed(1)}kg'),
                  _buildMiniStat(
                      '💰', '${crop.profitMargin.toStringAsFixed(0)}%'),
                  _buildDifficultyBadge(context, crop.difficultyLevel),
                ],
              ),
              const SizedBox(height: 12),

              // Growing conditions
              Text(
                'Temp: ${crop.temperatureRangeString} | pH: ${crop.phRangeString}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),

              // Market demand
              Row(
                children: [
                  Text(crop.demandIndicator),
                  const SizedBox(width: 4),
                  Text(
                    'Market Demand: ${crop.marketDemand.replaceAll('_', ' ')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              const Spacer(),

              // View details button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showCropDetails(context, crop),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String emoji, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  void _showCropDetails(BuildContext context, RecommendationModel crop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Crop header
              Row(
                children: [
                  Text(crop.cropEmoji, style: const TextStyle(fontSize: 56)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.recommendedCrop,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (crop.scientificName.isNotEmpty)
                          Text(
                            crop.scientificName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildCompatibilityBadge(
                                context, crop.compatibilityScore),
                            const SizedBox(width: 8),
                            _buildDifficultyBadge(
                                context, crop.difficultyLevel),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (crop.description.isNotEmpty) ...[
                Text(
                  crop.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
              ],

              // Stats grid
              _buildQuickStats(context, crop),
              const SizedBox(height: 24),

              // Growing conditions
              _buildDetailedMetrics(context, crop, true),
              const SizedBox(height: 24),

              // Seasons
              if (crop.growingSeasons.isNotEmpty) ...[
                _buildInfoSection(
                  context,
                  '📆 Growing Seasons',
                  crop.growingSeasons,
                ),
                const SizedBox(height: 16),
              ],

              // Companion crops
              if (crop.companionCrops.isNotEmpty) ...[
                _buildInfoSection(
                  context,
                  '🌱 Companion Crops',
                  crop.companionCrops,
                ),
                const SizedBox(height: 16),
              ],

              // Common pests
              if (crop.commonPests.isNotEmpty) ...[
                _buildWarningSection(
                  context,
                  '🐛 Common Pests',
                  crop.commonPests,
                  Colors.orange,
                ),
                const SizedBox(height: 16),
              ],

              // Common diseases
              if (crop.commonDiseases.isNotEmpty) ...[
                _buildWarningSection(
                  context,
                  '🦠 Common Diseases',
                  crop.commonDiseases,
                  Colors.red,
                ),
                const SizedBox(height: 16),
              ],

              // Nutritional highlights
              if (crop.nutritionalHighlights.isNotEmpty) ...[
                _buildInfoSection(
                  context,
                  '🥗 Nutritional Highlights',
                  crop.nutritionalHighlights,
                ),
                const SizedBox(height: 16),
              ],

              // Growing tips
              if (crop.tips.isNotEmpty) _buildTipsSection(context, crop.tips),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((item) => Chip(
                    label: Text(item),
                    backgroundColor: const Color(0xFFE8E0F0),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildWarningSection(
    BuildContext context,
    String title,
    List<String> items,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $item',
                    style: Theme.of(context).textTheme.bodySmall),
              )),
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
          'Other Great Matches',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: alternatives.length,
            itemBuilder: (context, index) {
              return _buildAlternativeCard(context, alternatives[index]);
            },
          ),
        ),
      ],
    );
  }

  /// Build single alternative card
  Widget _buildAlternativeCard(
    BuildContext context,
    RecommendationModel crop,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () => _showCropDetails(context, crop),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(crop.cropEmoji, style: const TextStyle(fontSize: 28)),
                    const Spacer(),
                    _buildCompatibilityBadge(context, crop.compatibilityScore),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  crop.recommendedCrop,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  '${crop.daysToHarvest} days to harvest',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                _buildDifficultyBadge(context, crop.difficultyLevel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get difficulty color
  Color _getDifficultyColor(String difficulty) {
    return switch (difficulty.toLowerCase()) {
      'beginner' => Colors.green,
      'intermediate' => Colors.orange,
      'advanced' => Colors.red,
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
          CircularProgressIndicator(color: const Color(0xFF4A2C7C)),
          const SizedBox(height: 16),
          Text(
            'Analyzing conditions & finding best crops...',
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
  final VoidCallback? onRetry;

  const _ErrorState({required this.error, this.onRetry});

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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
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
          Icon(Icons.eco_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Recommendations Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your state and preferences to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}

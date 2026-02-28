import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/crop.dart';
import '../../data/repositories/crop_repository.dart';
import '../../domain/models/crop_filters.dart';
import '../../models/weather_model.dart';
import '../../providers/ml_prediction_provider.dart';
import '../../providers/weather_providers.dart';
import '../widgets/crop_card.dart';
import '../widgets/crop_filter_panel.dart';
import 'crop_detail_page.dart';

class CropRecommendationPage extends ConsumerStatefulWidget {
  const CropRecommendationPage({super.key});

  @override
  ConsumerState<CropRecommendationPage> createState() =>
      _CropRecommendationPageState();
}

class _CropRecommendationPageState
    extends ConsumerState<CropRecommendationPage> {
  late CropRepository cropRepository;

  List<Crop> allCrops = [];
  List<Crop> filteredCrops = [];
  CropFilters currentFilters = CropFilters();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    cropRepository = CropRepository();
    _loadCrops();

    // Initialize weather data on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherNotifier = ref.read(weatherProvider.notifier);
      if (!weatherNotifier.isInitialized) {
        weatherNotifier.initializeWeather();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCrops() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final crops = await cropRepository.getAllCrops();
      setState(() {
        allCrops = crops;
        filteredCrops = crops;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load crops: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _applyFilters(CropFilters filters) async {
    setState(() {
      isLoading = true;
    });

    try {
      final filtered = await cropRepository.filterCrops(filters);
      setState(() {
        currentFilters = filters;
        filteredCrops = filtered;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Filter error: $e';
        isLoading = false;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      filteredCrops = allCrops;
      currentFilters = CropFilters();
    });
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CropFilterPanel(
        currentFilters: currentFilters,
        onApply: (filters) {
          Navigator.pop(context);
          _applyFilters(filters);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Recommendations'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Current Conditions Card
            _buildCurrentConditionsCard(context),

            // AI Crop Prediction Card
            _buildAIPredictionCard(context),

            // Recommended Crops Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended Crops',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: _showFilterPanel,
                    child:
                        Icon(Icons.tune, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),

            // Search Bar
            _buildSearchBar(),

            // Crops List
            _buildCropsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentConditionsCard(BuildContext context) {
    final weatherDisplay = ref.watch(weatherDisplayProvider);
    final weatherAsync = ref.watch(weatherProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Conditions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
              weatherAsync.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : GestureDetector(
                      onTap: () =>
                          ref.read(weatherProvider.notifier).refreshWeather(),
                      child: Icon(Icons.refresh,
                          size: 18, color: Colors.grey[600]),
                    ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildConditionItem(context, 'Soil pH',
                  weatherDisplay['soilPh'] ?? '6.5', Icons.water_drop),
              _buildConditionItem(context, 'Temperature',
                  weatherDisplay['temperature'] ?? '--', Icons.thermostat),
              _buildConditionItem(context, 'Humidity',
                  weatherDisplay['humidity'] ?? '--', Icons.water),
            ],
          ),
          if (weatherDisplay['location'] != null &&
              weatherDisplay['location'] != 'Unknown Location')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '📍 ${weatherDisplay['location']} • ${weatherDisplay['lastUpdated']}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConditionItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ── AI Prediction Card ──────────────────────────
  Widget _buildAIPredictionCard(BuildContext context) {
    final mlState = ref.watch(mlPredictionProvider);
    final weather = ref.watch(currentWeatherProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.teal.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Crop Recommendation',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Show result or prompt
          if (mlState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(height: 8),
                    Text('Analyzing conditions...',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else if (mlState.error != null)
            _buildErrorState(context, mlState.error!)
          else if (mlState.hasPrediction)
            _buildPredictionResult(context, mlState)
          else
            _buildPredictionPrompt(context, weather),
        ],
      ),
    );
  }

  Widget _buildPredictionPrompt(
      BuildContext context, WeatherConditions? weather) {
    return Column(
      children: [
        Text(
          'Tap the button to get an AI-powered crop recommendation '
          'based on current weather conditions.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _runPrediction(weather),
            icon: const Icon(Icons.psychology, size: 18),
            label: const Text('Get AI Recommendation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Find a Crop from allCrops that matches the given crop name.
  Crop? _findCropByName(String name) {
    final lower = name.toLowerCase().trim();
    // Try exact match on cropName first
    for (final crop in allCrops) {
      if (crop.cropName.toLowerCase() == lower) return crop;
    }
    // Try partial/contains match on cropName
    for (final crop in allCrops) {
      if (crop.cropName.toLowerCase().contains(lower) ||
          lower.contains(crop.cropName.toLowerCase())) {
        return crop;
      }
    }
    // Try common names
    for (final crop in allCrops) {
      for (final common in crop.commonNames) {
        if (common.toLowerCase() == lower ||
            common.toLowerCase().contains(lower) ||
            lower.contains(common.toLowerCase())) {
          return crop;
        }
      }
    }
    return null;
  }

  /// Navigate to crop detail page for the given crop name
  void _openCropDetailByName(String cropName) {
    final crop = _findCropByName(cropName);
    if (crop != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropDetailPage(crop: crop),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Crop info for "$cropName" not found in database'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildPredictionResult(
      BuildContext context, MLPredictionState mlState) {
    final pred = mlState.prediction!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main prediction — tappable to open crop detail
        InkWell(
          onTap: () => _openCropDetailByName(pred.recommendedCrop),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.eco, color: Colors.green.shade700, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pred.recommendedCrop,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.green.shade400),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pred.confidence.toStringAsFixed(1)}% confidence • ${pred.locationUsed}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to view full details',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade600,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Confidence bar
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pred.confidence / 100,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(
              pred.confidence > 50
                  ? Colors.green
                  : pred.confidence > 25
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
        ),

        // Top alternatives
        if (mlState.topPredictions != null &&
            mlState.topPredictions!.length > 1) ...[
          const SizedBox(height: 12),
          Text(
            'Other suitable crops:',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: mlState.topPredictions!
                .skip(1) // skip the top one (already shown)
                .take(4)
                .map((tp) => GestureDetector(
                      onTap: () => _openCropDetailByName(tp.crop),
                      child: Chip(
                        label: Text(
                          '${tp.crop} ${tp.confidence.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 11),
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.green.shade50,
                        side: BorderSide(color: Colors.green.shade200),
                        avatar: Icon(Icons.open_in_new,
                            size: 12, color: Colors.green.shade400),
                      ),
                    ))
                .toList(),
          ),
        ],

        // Re-predict button
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(mlPredictionProvider.notifier).clear();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Predict Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green.shade700,
              side: BorderSide(color: Colors.green.shade300),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(mlPredictionProvider.notifier).clear();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  void _runPrediction(WeatherConditions? weather) {
    if (weather == null || weather.locationName == 'Unknown Location') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waiting for weather data. Please try again shortly.'),
        ),
      );
      return;
    }

    final location = _extractStateName(weather.locationName);
    ref.read(mlPredictionProvider.notifier).predictCrop(
          temperature: weather.temperature,
          humidity: weather.humidity,
          location: location,
          month: DateTime.now().month,
        );
  }

  String _extractStateName(String locationName) {
    final parts = locationName.split(',').map((s) => s.trim()).toList();
    if (parts.length >= 2) {
      final state = parts.length >= 3 ? parts[parts.length - 2] : parts.last;
      return state
          .replaceAll(RegExp(r'\s*(IN|India)\s*', caseSensitive: false), '')
          .trim();
    }
    return locationName;
  }
  // ── End AI Prediction Card ────────────────────

  // ── Search Bar ──────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search crops by name...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      filteredCrops = allCrops;
                    });
                  },
                  child:
                      Icon(Icons.clear, color: Colors.grey.shade500, size: 18),
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
          ),
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
            if (query.isEmpty) {
              filteredCrops = allCrops;
            } else {
              final lower = query.toLowerCase();
              filteredCrops = allCrops.where((crop) {
                return crop.cropName.toLowerCase().contains(lower) ||
                    crop.commonNames
                        .any((name) => name.toLowerCase().contains(lower));
              }).toList();
            }
          });
        },
      ),
    );
  }
  // ── End Search Bar ─────────────────────────────

  Widget _buildCropsList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCrops,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredCrops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No crops found matching your filters'),
            const SizedBox(height: 16),
            if (currentFilters.hasActiveFilters())
              ElevatedButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredCrops.length,
        itemBuilder: (context, index) {
          final crop = filteredCrops[index];
          return CropCard(
            crop: crop,
            onTap: () => _showCropDetails(crop),
          );
        },
      ),
    );
  }

  void _showCropDetails(Crop crop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropDetailPage(crop: crop),
      ),
    );
  }
}

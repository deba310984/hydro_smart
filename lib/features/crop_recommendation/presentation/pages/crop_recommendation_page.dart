import 'package:flutter/material.dart';
import '../../data/models/crop.dart';
import '../../data/repositories/crop_repository.dart';
import '../../domain/models/crop_filters.dart';
import '../widgets/crop_card.dart';
import '../widgets/crop_filter_panel.dart';

class CropRecommendationPage extends StatefulWidget {
  @override
  State<CropRecommendationPage> createState() => _CropRecommendationPageState();
}

class _CropRecommendationPageState extends State<CropRecommendationPage> {
  late CropRepository cropRepository;

  List<Crop> allCrops = [];
  List<Crop> filteredCrops = [];
  CropFilters currentFilters = CropFilters();

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    cropRepository = CropRepository();
    _loadCrops();
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
        title: Text('Crop Recommendations'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Current Conditions Card
            _buildCurrentConditionsCard(context),

            // Recommended Crops Header
            Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
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

            // Crops List
            _buildCropsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentConditionsCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
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
          Text(
            'Current Conditions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildConditionItem(context, 'Soil pH', '6.5', Icons.water_drop),
              _buildConditionItem(
                  context, 'Temperature', '22°C', Icons.thermostat),
              _buildConditionItem(context, 'Humidity', '65%', Icons.water),
            ],
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
        SizedBox(height: 4),
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

  Widget _buildCropsList() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(errorMessage!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCrops,
              child: Text('Retry'),
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
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No crops found matching your filters'),
            SizedBox(height: 16),
            if (currentFilters.hasActiveFilters())
              ElevatedButton(
                onPressed: _clearFilters,
                child: Text('Clear Filters'),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(crop.cropName),
        content: SingleChildScrollView(
          child: _buildCropDetailsContent(crop),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCropDetailsContent(Crop crop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image
        Image.network(
          crop.imageUrl,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 150,
              color: Colors.grey[300],
              child: Icon(Icons.image_not_supported),
            );
          },
        ),
        SizedBox(height: 16),

        // Description
        Text(crop.description),
        SizedBox(height: 16),

        // Compatible Techniques
        _detailRow('Compatible Techniques:',
            crop.getCompatibleTechniques().join(', ')),
        SizedBox(height: 8),

        // Growing Info
        _detailRow('Days to Harvest:', '${crop.seedToHarvestDays} days'),
        _detailRow('Expected Yield:', '${crop.yieldPerSqm} kg/m²'),
        _detailRow('Best Season:', crop.bestSeason),
        SizedBox(height: 8),

        // Growing Conditions
        _detailRow('pH Range:', crop.getPhRangeString()),
        _detailRow('Temperature Range:', crop.getTemperatureRangeString()),
        SizedBox(height: 8),

        // Market Info
        _detailRow('Profit Margin:', '${crop.profitMargin}%'),
        _detailRow('Market Demand:', crop.marketDemandLevel),
        _detailRow('Difficulty Level:', crop.difficultyLevel),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        SizedBox(width: 8),
        Flexible(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

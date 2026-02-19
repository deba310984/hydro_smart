import 'package:flutter/material.dart';
import '../../domain/models/crop_filters.dart';

class CropFilterPanel extends StatefulWidget {
  final CropFilters currentFilters;
  final Function(CropFilters) onApply;

  const CropFilterPanel({
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<CropFilterPanel> createState() => _CropFilterPanelState();
}

class _CropFilterPanelState extends State<CropFilterPanel> {
  late List<String> selectedTechniques;
  late List<String> selectedSeasons;
  late RangeValues growthDurationRange;
  late RangeValues profitMarginRange;
  late String? selectedDifficulty;
  late String? selectedMarketDemand;

  final techniques = ['NFT', 'DWC', 'Drip', 'Aeroponics'];
  final seasons = ['Spring', 'Summer', 'Autumn', 'Winter', 'Year-round'];
  final difficulties = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];
  final marketDemands = ['Low', 'Medium', 'High', 'Very-high'];

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    selectedTechniques =
        List.from(widget.currentFilters.hydroponicTechniques ?? []);
    selectedSeasons = List.from(widget.currentFilters.growingSeasons ?? []);
    growthDurationRange =
        widget.currentFilters.growthDurationRange ?? RangeValues(0, 180);
    profitMarginRange =
        widget.currentFilters.profitMarginRange ?? RangeValues(0, 100);
    selectedDifficulty = widget.currentFilters.difficultyLevel;
    selectedMarketDemand = widget.currentFilters.marketDemandLevel;
  }

  void _applyFilters() {
    final filters = CropFilters(
      hydroponicTechniques:
          selectedTechniques.isNotEmpty ? selectedTechniques : null,
      growingSeasons: selectedSeasons.isNotEmpty ? selectedSeasons : null,
      growthDurationRange: growthDurationRange,
      profitMarginRange: profitMarginRange,
      difficultyLevel: selectedDifficulty,
      marketDemandLevel: selectedMarketDemand,
    );

    widget.onApply(filters);
  }

  void _clearAllFilters() {
    setState(() {
      selectedTechniques.clear();
      selectedSeasons.clear();
      growthDurationRange = RangeValues(0, 180);
      profitMarginRange = RangeValues(0, 100);
      selectedDifficulty = null;
      selectedMarketDemand = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Crops',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Hydroponic Technique Filter
                  _buildFilterSection(
                    title: '🌱 Hydroponic Technique',
                    child: _buildCheckboxList(
                      techniques,
                      selectedTechniques,
                      (value, isSelected) {
                        setState(() {
                          if (isSelected) {
                            selectedTechniques.add(value);
                          } else {
                            selectedTechniques.remove(value);
                          }
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Growing Season Filter
                  _buildFilterSection(
                    title: '🌞 Growing Season',
                    child: _buildCheckboxList(
                      seasons,
                      selectedSeasons.map((s) => s.capitalize()).toList(),
                      (value, isSelected) {
                        setState(() {
                          if (isSelected) {
                            selectedSeasons.add(value.toLowerCase());
                          } else {
                            selectedSeasons.remove(value.toLowerCase());
                          }
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Growth Duration Filter
                  _buildFilterSection(
                    title: '📅 Growth Duration (Days)',
                    child: Column(
                      children: [
                        RangeSlider(
                          values: growthDurationRange,
                          min: 0,
                          max: 180,
                          divisions: 18,
                          labels: RangeLabels(
                            '${growthDurationRange.start.toStringAsFixed(0)} days',
                            '${growthDurationRange.end.toStringAsFixed(0)} days',
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              growthDurationRange = values;
                            });
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '${growthDurationRange.start.toStringAsFixed(0)} - ${growthDurationRange.end.toStringAsFixed(0)} days',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Profit Margin Filter
                  _buildFilterSection(
                    title: '💰 Profit Margin (%)',
                    child: Column(
                      children: [
                        RangeSlider(
                          values: profitMarginRange,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          labels: RangeLabels(
                            '${profitMarginRange.start.toStringAsFixed(0)}%',
                            '${profitMarginRange.end.toStringAsFixed(0)}%',
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              profitMarginRange = values;
                            });
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '${profitMarginRange.start.toStringAsFixed(0)}% - ${profitMarginRange.end.toStringAsFixed(0)}%',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Difficulty Level Filter
                  _buildFilterSection(
                    title: '⚙️ Difficulty Level',
                    child: _buildRadioList(
                      difficulties.map((d) => d.toLowerCase()).toList(),
                      selectedDifficulty,
                      (value) {
                        setState(() {
                          selectedDifficulty =
                              selectedDifficulty == value ? null : value;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Market Demand Filter
                  _buildFilterSection(
                    title: '📊 Market Demand',
                    child: _buildRadioList(
                      marketDemands.map((d) => d.toLowerCase()).toList(),
                      selectedMarketDemand,
                      (value) {
                        setState(() {
                          selectedMarketDemand =
                              selectedMarketDemand == value ? null : value;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _clearAllFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                          ),
                          child: Text('Clear All'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          child: Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildCheckboxList(
    List<String> items,
    List<String> selectedItems,
    Function(String, bool) onChanged,
  ) {
    return Column(
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return CheckboxListTile(
          title: Text(item),
          value: isSelected,
          onChanged: (bool? value) {
            onChanged(item.toLowerCase(), value ?? false);
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildRadioList(
    List<String> items,
    String? selectedItem,
    Function(String) onChanged,
  ) {
    return Column(
      children: items.map((item) {
        return ListTile(
          title: Text(item.capitalize()),
          leading: Radio<String>(
            value: item,
            groupValue: selectedItem,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
          contentPadding: EdgeInsets.zero,
          dense: true,
        );
      }).toList(),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

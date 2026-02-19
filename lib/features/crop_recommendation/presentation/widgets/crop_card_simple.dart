import 'package:flutter/material.dart';
import '../../data/models/crop.dart';

class CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback onTap;

  const CropCard({
    required this.crop,
    required this.onTap,
  });

  String _getRiskLevel() {
    final difficulty = crop.difficultyLevel.toLowerCase();
    if (difficulty == 'beginner') return 'Low';
    if (difficulty == 'intermediate') return 'Medium';
    if (difficulty == 'advanced') return 'High';
    return 'Extreme';
  }

  Color _getRiskColor() {
    final difficulty = crop.difficultyLevel.toLowerCase();
    if (difficulty == 'beginner') return Colors.green;
    if (difficulty == 'intermediate') return Colors.orange;
    if (difficulty == 'advanced') return Colors.red;
    return Colors.redAccent;
  }

  String _getWaterLevel() {
    final yield_ = crop.yieldPerSqm;
    if (yield_ < 15) return 'Low';
    if (yield_ < 25) return 'Medium';
    return 'High';
  }

  String _getCropEmoji() {
    final name = crop.cropName.toLowerCase();
    if (name.contains('tomato')) return '🍅';
    if (name.contains('lettuce')) return '🥬';
    if (name.contains('spinach')) return '🥬';
    if (name.contains('cucumber')) return '🥒';
    if (name.contains('basil')) return '🌿';
    if (name.contains('pepper')) return '🫑';
    return '🌱';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Icon, Name, Risk Level
              Row(
                children: [
                  // Crop Icon/Emoji
                  Text(
                    _getCropEmoji(),
                    style: TextStyle(fontSize: 32),
                  ),
                  SizedBox(width: 12),

                  // Crop Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.cropName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Risk Level: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Colors.grey[600], fontSize: 11),
                            ),
                            Text(
                              _getRiskLevel(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: _getRiskColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Stats Row: Duration, Profit, Water
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat(
                    context,
                    '${crop.seedToHarvestDays}',
                    'days',
                    'Duration',
                  ),
                  _buildStat(
                    context,
                    '${crop.profitMargin.toStringAsFixed(0)}%',
                    'Profit',
                    '',
                  ),
                  _buildStat(
                    context,
                    _getWaterLevel(),
                    'Water',
                    '',
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Select Crop Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    elevation: 0,
                  ),
                  child: Text(
                    'Select Crop',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String value,
    String label,
    String subLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
        ),
        if (subLabel.isNotEmpty)
          Text(
            subLabel,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600], fontSize: 11),
        ),
      ],
    );
  }
}

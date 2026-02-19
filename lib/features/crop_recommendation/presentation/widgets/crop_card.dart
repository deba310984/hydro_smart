import 'package:flutter/material.dart';
import '../../data/models/crop.dart';

class CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback onTap;

  const CropCard({
    required this.crop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final riskLevel = _getRiskLevel();
    final riskColor = _getRiskColor();

    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // Top row: Emoji + Name + Risk Level
            Row(
              children: [
                // Crop Emoji
                Text(
                  _getCropEmoji(),
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(width: 12),

                // Name + Risk Level
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Risk Level: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: riskColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              riskLevel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: riskColor,
                              ),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  context,
                  '📅',
                  '${crop.seedToHarvestDays}',
                  'Days',
                ),
                _buildStatItem(
                  context,
                  '💰',
                  '${crop.profitMargin.toStringAsFixed(0)}%',
                  'Profit',
                ),
                _buildStatItem(
                  context,
                  '💧',
                  _getWaterLevel(),
                  'Water',
                ),
              ],
            ),

            SizedBox(height: 12),

            // Select Button
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Select Crop',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String emoji,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 20)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getRiskLevel() {
    switch (crop.difficultyLevel.toLowerCase()) {
      case 'beginner':
        return 'Low';
      case 'intermediate':
        return 'Medium';
      case 'advanced':
        return 'High';
      case 'expert':
        return 'Extreme';
      default:
        return 'Unknown';
    }
  }

  Color _getRiskColor() {
    switch (crop.difficultyLevel.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getWaterLevel() {
    if (crop.yieldPerSqm < 15) {
      return 'Low';
    } else if (crop.yieldPerSqm < 25) {
      return 'Medium';
    } else {
      return 'High';
    }
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
    if (name.contains('leafy')) return '🥬';
    return '🌱';
  }
}

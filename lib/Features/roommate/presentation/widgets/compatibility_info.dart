// Presentation Layer - Compatibility Info Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/roommate_request_model.dart';

class CompatibilityInfoWidget extends StatelessWidget {
  final CompatibilityInfo compatibilityInfo;

  const CompatibilityInfoWidget({super.key, required this.compatibilityInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header with Compatibility Score
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Compatibility Info',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                if (compatibilityInfo.compatibilityScore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCompatibilityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${compatibilityInfo.compatibilityScore}% Match',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getCompatibilityColor(),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Sleep Schedule
            _buildCompatibilityItem(
              icon: Icons.bedtime_outlined,
              title: 'Sleep Schedule',
              value: compatibilityInfo.sleepScheduleText,
              color: Colors.indigo,
            ),
            const SizedBox(height: 12),

            // Lifestyle Preference
            _buildCompatibilityItem(
              icon: Icons.people_outline,
              title: 'Lifestyle',
              value: compatibilityInfo.lifestyleText,
              color: Colors.pink,
            ),
            const SizedBox(height: 12),

            // Smoking Preference
            _buildCompatibilityItem(
              icon: Icons.smoke_free_outlined,
              title: 'Smoking',
              value: compatibilityInfo.smokingText,
              color: Colors.green,
            ),
            const SizedBox(height: 12),

            // Drinking Preference
            _buildCompatibilityItem(
              icon: Icons.local_bar_outlined,
              title: 'Drinking',
              value: compatibilityInfo.drinkingText,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),

            // Sharing Style
            _buildCompatibilityItem(
              icon: Icons.share_outlined,
              title: 'Sharing Style',
              value: compatibilityInfo.sharingText,
              color: Colors.cyan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCompatibilityColor() {
    final score = compatibilityInfo.compatibilityScore ?? 0;
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

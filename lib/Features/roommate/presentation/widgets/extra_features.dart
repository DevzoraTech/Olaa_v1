// Presentation Layer - Extra Features Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ExtraFeatures extends StatelessWidget {
  final VoidCallback onBookmark;
  final VoidCallback onReport;
  final VoidCallback onShare;
  final bool isBookmarked;

  const ExtraFeatures({
    super.key,
    required this.onBookmark,
    required this.onReport,
    required this.onShare,
    required this.isBookmarked,
  });

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
            // Section Header
            Row(
              children: [
                Icon(
                  Icons.more_horiz_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'More Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Feature Buttons
            Row(
              children: [
                // Bookmark Button
                Expanded(
                  child: _buildFeatureButton(
                    icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    label: isBookmarked ? 'Bookmarked' : 'Bookmark',
                    color:
                        isBookmarked
                            ? AppTheme.primaryColor
                            : Colors.grey[600]!,
                    onPressed: onBookmark,
                  ),
                ),
                const SizedBox(width: 12),

                // Share Button
                Expanded(
                  child: _buildFeatureButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    color: Colors.blue,
                    onPressed: onShare,
                  ),
                ),
                const SizedBox(width: 12),

                // Report Button
                Expanded(
                  child: _buildFeatureButton(
                    icon: Icons.flag_outlined,
                    label: 'Report',
                    color: Colors.red,
                    onPressed: onReport,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Help Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bookmark to save for later, share with friends, or report if inappropriate.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

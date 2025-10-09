// Presentation Layer - Marketplace Posting Progress Widget
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/models/marketplace_steps.dart';

class MarketplacePostingProgress extends StatelessWidget {
  final int currentStepIndex;
  final Function(int)? onStepTap;
  final bool isStepClickable;

  const MarketplacePostingProgress({
    super.key,
    required this.currentStepIndex,
    this.onStepTap,
    this.isStepClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Column(
        children: [
          // Progress Bar
          _buildProgressBar(),
          const SizedBox(height: 16),
          // Step Indicators
          _buildStepIndicators(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (currentStepIndex + 1) / MarketplaceConstants.steps.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Marketplace Listing Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'Step ${currentStepIndex + 1} of ${MarketplaceConstants.steps.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicators() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            MarketplaceConstants.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isCompleted = index < currentStepIndex;
              final isCurrent = index == currentStepIndex;
              final isUpcoming = index > currentStepIndex;

              return Container(
                width: 60, // Fixed width to prevent overflow
                child: GestureDetector(
                  onTap:
                      isStepClickable && !isUpcoming
                          ? () => onStepTap?.call(index)
                          : null,
                  child: Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _getStepBackgroundColor(
                            isCompleted,
                            isCurrent,
                            isUpcoming,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getStepBorderColor(
                              isCompleted,
                              isCurrent,
                              isUpcoming,
                            ),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getStepIcon(
                            step.icon,
                            isCompleted,
                            isCurrent,
                            isUpcoming,
                          ),
                          size: 14,
                          color: _getStepIconColor(
                            isCompleted,
                            isCurrent,
                            isUpcoming,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getShortStepTitle(step.title),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: _getStepTextColor(
                            isCompleted,
                            isCurrent,
                            isUpcoming,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  String _getShortStepTitle(String title) {
    // Convert long titles to shorter versions
    switch (title) {
      case 'Item Info':
        return 'Info';
      case 'Item Details':
        return 'Details';
      case 'Pricing & Condition':
        return 'Price';
      case 'Photos & Contact':
        return 'Photos';
      case 'Review & Submit':
        return 'Review';
      default:
        return title;
    }
  }

  Color _getStepBackgroundColor(
    bool isCompleted,
    bool isCurrent,
    bool isUpcoming,
  ) {
    if (isCompleted) return AppTheme.primaryColor;
    if (isCurrent) return AppTheme.primaryColor.withOpacity(0.1);
    return Colors.grey[100]!;
  }

  Color _getStepBorderColor(bool isCompleted, bool isCurrent, bool isUpcoming) {
    if (isCompleted) return AppTheme.primaryColor;
    if (isCurrent) return AppTheme.primaryColor;
    return Colors.grey[300]!;
  }

  IconData _getStepIcon(
    IconData originalIcon,
    bool isCompleted,
    bool isCurrent,
    bool isUpcoming,
  ) {
    if (isCompleted) return Icons.check_rounded;
    return originalIcon;
  }

  Color _getStepIconColor(bool isCompleted, bool isCurrent, bool isUpcoming) {
    if (isCompleted) return Colors.white;
    if (isCurrent) return AppTheme.primaryColor;
    return Colors.grey[500]!;
  }

  Color _getStepTextColor(bool isCompleted, bool isCurrent, bool isUpcoming) {
    if (isCompleted) return AppTheme.primaryColor;
    if (isCurrent) return AppTheme.primaryColor;
    return Colors.grey[500]!;
  }
}

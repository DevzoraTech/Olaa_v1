// Presentation Layer - Hostel Posting Progress Indicator Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/hostel_steps.dart';

class HostelPostingProgressIndicator extends StatelessWidget {
  final List<HostelStepData> steps;
  final int currentStepIndex;
  final Function(int)? onStepTap;

  const HostelPostingProgressIndicator({
    super.key,
    required this.steps,
    required this.currentStepIndex,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
    final progress = currentStepIndex / (steps.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${currentStepIndex + 1} of ${steps.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${(progress * 100).round()}% Complete',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(3),
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
        children:
            steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isCompleted = index < currentStepIndex;
              final isActive = index == currentStepIndex;
              final isUpcoming = index > currentStepIndex;

              return GestureDetector(
                onTap:
                    onStepTap != null && (isCompleted || isActive)
                        ? () => onStepTap!(index)
                        : null,
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      // Step Icon
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _getStepColor(
                            isCompleted,
                            isActive,
                            isUpcoming,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getStepBorderColor(
                              isCompleted,
                              isActive,
                              isUpcoming,
                            ),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getStepIcon(isCompleted, isActive, isUpcoming),
                          size: 14,
                          color: _getStepIconColor(
                            isCompleted,
                            isActive,
                            isUpcoming,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Step Title
                      Text(
                        _getShortStepTitle(step.title),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: _getStepTextColor(
                            isCompleted,
                            isActive,
                            isUpcoming,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Color _getStepColor(bool isCompleted, bool isActive, bool isUpcoming) {
    if (isCompleted) return AppTheme.primaryColor;
    if (isActive) return AppTheme.primaryColor.withOpacity(0.2);
    return Colors.grey[200]!;
  }

  Color _getStepBorderColor(bool isCompleted, bool isActive, bool isUpcoming) {
    if (isCompleted) return AppTheme.primaryColor;
    if (isActive) return AppTheme.primaryColor;
    return Colors.grey[300]!;
  }

  IconData _getStepIcon(bool isCompleted, bool isActive, bool isUpcoming) {
    if (isCompleted) return Icons.check_rounded;
    if (isActive) return Icons.radio_button_checked_rounded;
    return Icons.radio_button_unchecked_rounded;
  }

  Color _getStepIconColor(bool isCompleted, bool isActive, bool isUpcoming) {
    if (isCompleted) return Colors.white;
    if (isActive) return AppTheme.primaryColor;
    return Colors.grey[400]!;
  }

  Color _getStepTextColor(bool isCompleted, bool isActive, bool isUpcoming) {
    if (isCompleted) return AppTheme.primaryColor;
    if (isActive) return AppTheme.primaryColor;
    return Colors.grey[500]!;
  }

  String _getShortStepTitle(String title) {
    switch (title) {
      case 'Basic Info':
        return 'Basic';
      case 'Room Details':
        return 'Room';
      case 'Pricing & Terms':
        return 'Price';
      case 'Amenities':
        return 'Amenities';
      case 'Rules & Policies':
        return 'Rules';
      case 'Photos & Media':
        return 'Photos';
      default:
        return title.length > 8 ? title.substring(0, 8) : title;
    }
  }
}

// Navigation Buttons Widget
class HostelStepNavigationButtons extends StatelessWidget {
  final bool canGoBack;
  final bool canGoForward;
  final bool isLoading;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextButtonText;
  final String backButtonText;

  const HostelStepNavigationButtons({
    super.key,
    required this.canGoBack,
    required this.canGoForward,
    required this.isLoading,
    this.onBack,
    this.onNext,
    this.nextButtonText = 'Next',
    this.backButtonText = 'Back',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back Button
            if (canGoBack)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onBack,
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                  label: Text(backButtonText),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

            if (canGoBack) const SizedBox(width: 16),

            // Next/Submit Button
            Expanded(
              flex: canGoBack ? 1 : 1,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onNext,
                icon:
                    isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(
                          nextButtonText == 'Submit Listing'
                              ? Icons.check_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: 16,
                        ),
                label: Text(isLoading ? 'Processing...' : nextButtonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

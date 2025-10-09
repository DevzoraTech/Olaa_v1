// Professional Progress Indicator Widget
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/models/roommate_request_steps.dart';

class RoommateRequestProgressIndicator extends StatelessWidget {
  final List<StepData> steps;
  final int currentStepIndex;
  final Function(int)? onStepTap;

  const RoommateRequestProgressIndicator({
    super.key,
    required this.steps,
    required this.currentStepIndex,
    this.onStepTap,
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
    final progress = (currentStepIndex + 1) / steps.length;

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
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = index < currentStepIndex;
            final isCurrent = index == currentStepIndex;
            final isUpcoming = index > currentStepIndex;

            return GestureDetector(
              onTap:
                  onStepTap != null && (isCompleted || isCurrent)
                      ? () => onStepTap!(index)
                      : null,
              child: _buildStepIndicator(
                step: step,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isUpcoming: isUpcoming,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildStepIndicator({
    required StepData step,
    required bool isCompleted,
    required bool isCurrent,
    required bool isUpcoming,
  }) {
    Color backgroundColor;
    Color iconColor;
    Color textColor;
    double scale = 1.0;

    if (isCompleted) {
      backgroundColor = AppTheme.primaryColor;
      iconColor = Colors.white;
      textColor = AppTheme.primaryColor;
    } else if (isCurrent) {
      backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
      iconColor = AppTheme.primaryColor;
      textColor = AppTheme.primaryColor;
      scale = 1.1;
    } else {
      backgroundColor = Colors.grey[200]!;
      iconColor = Colors.grey[400]!;
      textColor = Colors.grey[500]!;
    }

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border:
                  isCurrent
                      ? Border.all(color: AppTheme.primaryColor, width: 2)
                      : null,
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : step.icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              step.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class StepNavigationButtons extends StatelessWidget {
  final bool canGoBack;
  final bool canGoForward;
  final bool isLoading;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? nextButtonText;
  final String? backButtonText;

  const StepNavigationButtons({
    super.key,
    this.canGoBack = true,
    this.canGoForward = true,
    this.isLoading = false,
    this.onBack,
    this.onNext,
    this.nextButtonText,
    this.backButtonText,
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
      child: Row(
        children: [
          if (canGoBack) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  backButtonText ?? 'Back',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: canGoBack ? 1 : 1,
            child: ElevatedButton(
              onPressed: isLoading ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child:
                  isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        nextButtonText ?? 'Next',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

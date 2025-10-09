// Lifestyle Preferences Step Widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../domain/models/roommate_request_steps.dart';

class LifestylePreferencesStep extends StatefulWidget {
  final LifestyleData data;
  final ValueChanged<LifestyleData> onDataChanged;

  const LifestylePreferencesStep({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<LifestylePreferencesStep> createState() =>
      _LifestylePreferencesStepState();
}

class _LifestylePreferencesStepState extends State<LifestylePreferencesStep> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildSleepScheduleSection(),
          const SizedBox(height: 24),
          _buildLifestylePreferenceSection(),
          const SizedBox(height: 24),
          _buildSmokingPreferenceSection(),
          const SizedBox(height: 24),
          _buildDrinkingPreferenceSection(),
          const SizedBox(height: 24),
          _buildSharingStyleSection(),
          const SizedBox(height: 24),
          _buildInterestsSection(),
          const SizedBox(height: 32),
          _buildTipsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.self_improvement_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lifestyle Preferences',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tell us about your daily habits and lifestyle',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSleepScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sleep Schedule *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'When do you typically go to bed?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: widget.data.sleepSchedule,
          label: 'Select your sleep schedule',
          icon: Icons.bedtime_rounded,
          items: RoommateRequestConstants.sleepScheduleOptions,
          onChanged: (value) {
            widget.onDataChanged(
              widget.data.copyWith(sleepSchedule: value ?? ''),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLifestylePreferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lifestyle Preference *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How would you describe your lifestyle?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: widget.data.lifestylePreference,
          label: 'Select your lifestyle',
          icon: Icons.fitness_center_rounded,
          items: RoommateRequestConstants.lifestyleOptions,
          onChanged: (value) {
            widget.onDataChanged(
              widget.data.copyWith(lifestylePreference: value ?? ''),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSmokingPreferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smoking Preference *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What\'s your smoking preference?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: widget.data.smokingPreference,
          label: 'Select smoking preference',
          icon: Icons.smoking_rooms_rounded,
          items: RoommateRequestConstants.smokingOptions,
          onChanged: (value) {
            widget.onDataChanged(
              widget.data.copyWith(smokingPreference: value ?? ''),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrinkingPreferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Drinking Preference *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What\'s your drinking preference?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: widget.data.drinkingPreference,
          label: 'Select drinking preference',
          icon: Icons.local_bar_rounded,
          items: RoommateRequestConstants.drinkingOptions,
          onChanged: (value) {
            widget.onDataChanged(
              widget.data.copyWith(drinkingPreference: value ?? ''),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSharingStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sharing Style *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How social are you with roommates?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: widget.data.sharingStyle,
          label: 'Select sharing style',
          icon: Icons.people_rounded,
          items: RoommateRequestConstants.sharingStyleOptions,
          onChanged: (value) {
            widget.onDataChanged(
              widget.data.copyWith(sharingStyle: value ?? ''),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Interests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your interests to help find compatible roommates',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              RoommateRequestConstants.interestOptions.map((interest) {
                final isSelected = widget.data.interests.contains(interest);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      final interests = List<String>.from(
                        widget.data.interests,
                      );
                      if (isSelected) {
                        interests.remove(interest);
                      } else {
                        interests.add(interest);
                      }
                      widget.onDataChanged(
                        widget.data.copyWith(interests: interests),
                      );
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppTheme.primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, color: Colors.grey[600], size: 20),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: Be honest about your lifestyle preferences. This helps ensure compatibility with potential roommates!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

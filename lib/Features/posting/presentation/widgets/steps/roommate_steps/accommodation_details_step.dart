// Accommodation Details Step Widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/location_search_widget.dart';
import '../../../../../../core/widgets/multiple_location_selector.dart';
import '../../../../../../core/widgets/advanced_budget_range_selector.dart';
import '../../../../../../core/widgets/calendar_date_picker.dart';
import '../../../../domain/models/roommate_request_steps.dart';

class AccommodationDetailsStep extends StatefulWidget {
  final AccommodationData data;
  final ValueChanged<AccommodationData> onDataChanged;
  final List<Map<String, dynamic>> availableHostels;

  const AccommodationDetailsStep({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.availableHostels,
  });

  @override
  State<AccommodationDetailsStep> createState() =>
      _AccommodationDetailsStepState();
}

class _AccommodationDetailsStepState extends State<AccommodationDetailsStep> {
  late TextEditingController _preferredHostelController;

  @override
  void initState() {
    super.initState();
    _preferredHostelController = TextEditingController(
      text: widget.data.preferredHostel,
    );

    _addListeners();
  }

  void _addListeners() {
    _preferredHostelController.addListener(_updateData);
  }

  void _updateData() {
    widget.onDataChanged(
      widget.data.copyWith(
        preferredHostel: _preferredHostelController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _preferredHostelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          // Hostel Status Toggle - First and most prominent
          _buildHostelStatusToggle(),
          const SizedBox(height: 24),
          // Only show location section if NOT already in hostel
          if (!widget.data.isAlreadyInHostel) ...[
          _buildLocationSection(),
          const SizedBox(height: 24),
          ],
          // Only show budget section if NOT already in hostel
          if (!widget.data.isAlreadyInHostel) ...[
          _buildBudgetSection(),
          const SizedBox(height: 24),
          ],
          _buildHostelSection(),
          const SizedBox(height: 24),
          // Only show move-in date section if NOT already in hostel
          if (!widget.data.isAlreadyInHostel) ...[
          _buildMoveInDateSection(),
          const SizedBox(height: 24),
          ],
          _buildUrgencySection(),
          const SizedBox(height: 24),
          _buildLeaseDurationSection(),
          const SizedBox(height: 24),
          _buildAmenitiesSection(),
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
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.home_outlined,
                color: AppTheme.secondaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accommodation Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.data.isAlreadyInHostel
                        ? 'Tell us about your current hostel and roommate needs'
                        : 'Tell us about your housing preferences',
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

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Locations *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Which areas would you like to live in? You can select multiple locations.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        MultipleLocationSelector(
          selectedLocations: widget.data.preferredLocations,
          onLocationsChanged: (locations) {
            widget.onDataChanged(
              widget.data.copyWith(preferredLocations: locations),
            );
          },
          label: '',
          hintText:
              'Search for areas like Downtown, Near campus, Suburbs, etc.',
          icon: Icons.location_on_rounded,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return AdvancedBudgetRangeSelector(
      currentRange: RangeValues(widget.data.budgetMin, widget.data.budgetMax),
      onRangeChanged: (range) {
        widget.onDataChanged(
          widget.data.copyWith(budgetMin: range.start, budgetMax: range.end),
        );
      },
      label: 'Budget Range',
      currency: 'UGX',
      minValue: 0,
      maxValue: 5000000,
      divisions: 100,
      isRequired: true,
    );
  }

  Widget _buildHostelStatusToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hostel Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Are you already staying in a hostel or looking for one?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        _buildSegmentedControl(),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          // Already in Hostel Option
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!widget.data.isAlreadyInHostel) {
                  HapticFeedback.lightImpact();
                  widget.onDataChanged(
                    widget.data.copyWith(
                      isAlreadyInHostel: true,
                      currentHostel: widget.data.currentHostel,
                      // Clear fields that are no longer relevant
                      preferredLocations: [],
                      budgetMin: 0.0,
                      budgetMax: 1000000.0,
                      moveInDate: null,
                    ),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 56,
                decoration: BoxDecoration(
                  color:
                      widget.data.isAlreadyInHostel
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow:
                      widget.data.isAlreadyInHostel
                          ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.data.isAlreadyInHostel
                          ? Icons.home_rounded
                          : Icons.home_outlined,
                      color:
                          widget.data.isAlreadyInHostel
                              ? Colors.white
                              : Colors.grey[600],
                size: 20,
              ),
                    const SizedBox(width: 8),
                    Text(
                      'Already in Hostel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            widget.data.isAlreadyInHostel
                                ? Colors.white
                                : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Looking for Hostel Option
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.data.isAlreadyInHostel) {
                  HapticFeedback.lightImpact();
                  widget.onDataChanged(
                    widget.data.copyWith(
                      isAlreadyInHostel: false,
                      currentHostel: '',
                      // Restore fields that are now relevant
                      preferredLocations: widget.data.preferredLocations,
                      budgetMin: widget.data.budgetMin,
                      budgetMax: widget.data.budgetMax,
                      moveInDate: widget.data.moveInDate,
                    ),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 56,
                decoration: BoxDecoration(
                  color:
                      !widget.data.isAlreadyInHostel
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow:
                      !widget.data.isAlreadyInHostel
                          ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      !widget.data.isAlreadyInHostel
                          ? Icons.search_rounded
                          : Icons.search_outlined,
                      color:
                          !widget.data.isAlreadyInHostel
                              ? Colors.white
                              : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Looking for Hostel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            !widget.data.isAlreadyInHostel
                                ? Colors.white
                                : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildHostelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.data.isAlreadyInHostel
              ? 'Current Hostel'
              : 'Hostel Preference',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.data.isAlreadyInHostel
              ? 'Which hostel are you currently staying in?'
              : 'Do you have a specific hostel in mind?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        if (widget.data.isAlreadyInHostel) ...[
          _buildDropdownField(
            value: widget.data.currentHostel,
            label: 'Current Hostel *',
            icon: Icons.home_work_rounded,
            items:
                widget.availableHostels
                    .map((hostel) => hostel['title'] as String)
                    .toList(),
            onChanged: (value) {
              widget.onDataChanged(
                widget.data.copyWith(currentHostel: value ?? ''),
              );
            },
          ),
          const SizedBox(height: 16),
          LocationSearchWidget(
            initialValue: widget.data.hostelLocation,
            label: 'Hostel Location',
            hintText: 'Search for your hostel location',
            icon: Icons.location_on_rounded,
            isRequired: true,
            onLocationSelected: (locationData) {
              widget.onDataChanged(
                widget.data.copyWith(
                  hostelLocation: locationData.description,
                  hostelLatitude: locationData.latitude,
                  hostelLongitude: locationData.longitude,
                ),
              );
            },
          ),
        ] else ...[
          TextFormField(
            controller: _preferredHostelController,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Specific hostel name or area',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.home_work_rounded,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMoveInDateSection() {
    return CustomCalendarDatePicker(
      initialDate: widget.data.moveInDate,
      onDateSelected: (date) {
        widget.onDataChanged(widget.data.copyWith(moveInDate: date));
      },
      label: 'Move-in Date',
      hintText: 'Select your preferred move-in date',
      icon: Icons.calendar_today_rounded,
      isRequired: false,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  Widget _buildUrgencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Urgency *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How urgent is your need for accommodation?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: widget.data.urgency,
          label: 'Select urgency level',
          icon: Icons.priority_high_rounded,
          items: RoommateRequestConstants.urgencyOptions,
          onChanged: (value) {
            widget.onDataChanged(widget.data.copyWith(urgency: value ?? ''));
          },
        ),
      ],
    );
  }

  Widget _buildLeaseDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lease Duration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How long do you plan to stay?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: widget.data.leaseDuration,
          label: 'Select lease duration',
          icon: Icons.schedule_rounded,
          items: RoommateRequestConstants.leaseDurationOptions,
          onChanged: (value) {
            widget.onDataChanged(
              widget.data.copyWith(leaseDuration: value ?? ''),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Desired Amenities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What amenities are important to you?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              RoommateRequestConstants.amenityOptions.map((amenity) {
                final isSelected = widget.data.desiredAmenities.contains(
                  amenity,
                );
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      final amenities = List<String>.from(
                        widget.data.desiredAmenities,
                      );
                      if (isSelected) {
                        amenities.remove(amenity);
                      } else {
                        amenities.add(amenity);
                      }
                      widget.onDataChanged(
                        widget.data.copyWith(desiredAmenities: amenities),
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
                          isSelected
                              ? AppTheme.secondaryColor
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppTheme.secondaryColor
                                : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      amenity,
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
        color: AppTheme.secondaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppTheme.secondaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.data.isAlreadyInHostel
                  ? 'Tip: Be specific about your current hostel and what you\'re looking for in a roommate. This helps find compatible matches!'
                  : 'Tip: Be realistic about your budget and location preferences. This helps find suitable matches!',
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

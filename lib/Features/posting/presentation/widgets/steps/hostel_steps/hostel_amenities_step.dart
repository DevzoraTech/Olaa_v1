// Amenities & Features Step Widget for Hostel Posting
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../domain/models/hostel_steps.dart';

class HostelAmenitiesStep extends StatefulWidget {
  final HostelAmenitiesData data;
  final ValueChanged<HostelAmenitiesData> onDataChanged;

  const HostelAmenitiesStep({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<HostelAmenitiesStep> createState() => _HostelAmenitiesStepState();
}

class _HostelAmenitiesStepState extends State<HostelAmenitiesStep> {
  late TextEditingController _parkingController;
  late TextEditingController _securityController;
  late TextEditingController _internetController;
  late TextEditingController _laundryController;

  // Amenity Options
  final List<String> _amenityOptions = [
    'WiFi',
    'Air Conditioning',
    'Heating',
    'Laundry',
    'Kitchen',
    'Parking',
    'Security',
    'Gym',
    'Study Room',
    'Common Area',
    'Balcony',
    'Garden',
    'Swimming Pool',
    'Cafeteria',
    'Library',
    'Recreation Room',
    'Elevator',
    'Cable TV',
    'Hot Water',
    'Cleaning Service',
  ];

  // Nearby Facilities Options
  final List<String> _nearbyFacilitiesOptions = [
    'University Campus',
    'Shopping Mall',
    'Hospital',
    'Bank/ATM',
    'Restaurant',
    'Bus Stop',
    'Taxi Stand',
    'Grocery Store',
    'Pharmacy',
    'Gym/Fitness Center',
    'Library',
    'Post Office',
    'Police Station',
    'Fire Station',
    'Park',
  ];

  @override
  void initState() {
    super.initState();
    _parkingController = TextEditingController(text: widget.data.parkingInfo);
    _securityController = TextEditingController(
      text: widget.data.securityFeatures,
    );
    _internetController = TextEditingController(
      text: widget.data.internetSpeed,
    );
    _laundryController = TextEditingController(
      text: widget.data.laundryFacilities,
    );

    _addListeners();
  }

  void _addListeners() {
    _parkingController.addListener(_updateData);
    _securityController.addListener(_updateData);
    _internetController.addListener(_updateData);
    _laundryController.addListener(_updateData);
  }

  void _updateData() {
    widget.onDataChanged(
      widget.data.copyWith(
        parkingInfo: _parkingController.text.trim(),
        securityFeatures: _securityController.text.trim(),
        internetSpeed: _internetController.text.trim(),
        laundryFacilities: _laundryController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _parkingController.dispose();
    _securityController.dispose();
    _internetController.dispose();
    _laundryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildAmenitiesSection(),
          const SizedBox(height: 24),
          _buildNearbyFacilitiesSection(),
          const SizedBox(height: 24),
          _buildParkingSection(),
          const SizedBox(height: 24),
          _buildSecuritySection(),
          const SizedBox(height: 24),
          _buildInternetSection(),
          const SizedBox(height: 24),
          _buildLaundrySection(),
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
                Icons.home_work_outlined,
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
                    'Amenities & Features',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Highlight what makes your hostel special',
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

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Amenities *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all amenities available in your hostel',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _amenityOptions.map((amenity) {
                final isSelected = widget.data.amenities.contains(amenity);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      final amenities = List<String>.from(
                        widget.data.amenities,
                      );
                      if (isSelected) {
                        amenities.remove(amenity);
                      } else {
                        amenities.add(amenity);
                      }
                      widget.onDataChanged(
                        widget.data.copyWith(amenities: amenities),
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

  Widget _buildNearbyFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Facilities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What facilities are available nearby?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _nearbyFacilitiesOptions.map((facility) {
                final isSelected = widget.data.nearbyFacilities.contains(
                  facility,
                );
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      final facilities = List<String>.from(
                        widget.data.nearbyFacilities,
                      );
                      if (isSelected) {
                        facilities.remove(facility);
                      } else {
                        facilities.add(facility);
                      }
                      widget.onDataChanged(
                        widget.data.copyWith(nearbyFacilities: facilities),
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
                      facility,
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

  Widget _buildParkingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parking Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Describe parking availability and arrangements',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _parkingController,
          maxLines: 2,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText:
                'Free parking available for residents. Motorcycle parking included.',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.local_parking_rounded,
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
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What security measures are in place?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _securityController,
          maxLines: 2,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '24/7 security guard, CCTV cameras, secure entry system',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.security_rounded,
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
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildInternetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Internet Speed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What internet speed do you provide?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _internetController,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '50 Mbps WiFi',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.wifi_rounded,
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
    );
  }

  Widget _buildLaundrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Laundry Facilities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Describe laundry arrangements',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _laundryController,
          maxLines: 2,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText:
                'Shared laundry room with washing machines. Ironing facilities available.',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.local_laundry_service_rounded,
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
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
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
              'Tip: Highlight unique amenities that set your hostel apart. Students value convenience and comfort!',
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

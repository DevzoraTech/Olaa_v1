// Presentation Layer - Advanced Filters Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AdvancedFilters extends StatelessWidget {
  final String category;
  final VoidCallback onClose;

  const AdvancedFilters({
    super.key,
    required this.category,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        // TODO: Clear all filters
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildFilterContent(),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Apply filters
                  onClose();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    switch (category) {
      case 'Hostels':
        return _buildHostelFilters();
      case 'Roommates':
        return _buildRoommateFilters();
      case 'Events':
        return _buildEventFilters();
      case 'Clubs':
        return _buildClubFilters();
      case 'Marketplace':
        return _buildMarketplaceFilters();
      default:
        return _buildGeneralFilters();
    }
  }

  Widget _buildHostelFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(
          title: 'Price Range',
          child: Column(
            children: [
              RangeSlider(
                values: const RangeValues(200, 600),
                min: 100,
                max: 1000,
                divisions: 18,
                labels: const RangeLabels('\$200', '\$600'),
                onChanged: (values) {
                  // TODO: Handle price range change
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$200', style: TextStyle(color: Colors.grey[600])),
                  Text('\$600', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Distance from Campus',
          child: Column(
            children: [
              _buildCheckboxTile('Within 1 km', true),
              _buildCheckboxTile('1-2 km', false),
              _buildCheckboxTile('2-5 km', false),
              _buildCheckboxTile('5+ km', false),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Amenities',
          child: Column(
            children: [
              _buildCheckboxTile('Wi-Fi', true),
              _buildCheckboxTile('Meals Included', false),
              _buildCheckboxTile('Laundry', true),
              _buildCheckboxTile('Gym', false),
              _buildCheckboxTile('Study Room', true),
              _buildCheckboxTile('Parking', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoommateFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(
          title: 'Gender',
          child: Column(
            children: [
              _buildRadioTile('Any', true),
              _buildRadioTile('Male', false),
              _buildRadioTile('Female', false),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Faculty',
          child: Column(
            children: [
              _buildCheckboxTile('Computer Science', true),
              _buildCheckboxTile('Business', false),
              _buildCheckboxTile('Engineering', false),
              _buildCheckboxTile('Arts', false),
              _buildCheckboxTile('Science', false),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Budget Range',
          child: Column(
            children: [
              RangeSlider(
                values: const RangeValues(150, 300),
                min: 100,
                max: 500,
                divisions: 16,
                labels: const RangeLabels('\$150', '\$300'),
                onChanged: (values) {
                  // TODO: Handle budget range change
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$150', style: TextStyle(color: Colors.grey[600])),
                  Text('\$300', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Lifestyle',
          child: Column(
            children: [
              _buildCheckboxTile('Non-smoking', true),
              _buildCheckboxTile('Pet-friendly', false),
              _buildCheckboxTile('Night owl', false),
              _buildCheckboxTile('Early bird', true),
              _buildCheckboxTile('Social', false),
              _buildCheckboxTile('Quiet', true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(
          title: 'Event Type',
          child: Column(
            children: [
              _buildCheckboxTile('Free Events', true),
              _buildCheckboxTile('Paid Events', false),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Category',
          child: Column(
            children: [
              _buildCheckboxTile('Academic', true),
              _buildCheckboxTile('Social', false),
              _buildCheckboxTile('Sports', false),
              _buildCheckboxTile('Cultural', false),
              _buildCheckboxTile('Tech', true),
              _buildCheckboxTile('Career', false),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Time',
          child: Column(
            children: [
              _buildCheckboxTile('This Week', true),
              _buildCheckboxTile('This Month', false),
              _buildCheckboxTile('On Campus', true),
              _buildCheckboxTile('Off Campus', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClubFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(
          title: 'Club Type',
          child: Column(
            children: [
              _buildCheckboxTile('Academic', true),
              _buildCheckboxTile('Sports', false),
              _buildCheckboxTile('Cultural', false),
              _buildCheckboxTile('Technology', true),
              _buildCheckboxTile('Arts', false),
              _buildCheckboxTile('Community Service', false),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Size',
          child: Column(
            children: [
              _buildCheckboxTile('Small (1-20 members)', false),
              _buildCheckboxTile('Medium (21-50 members)', true),
              _buildCheckboxTile('Large (50+ members)', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarketplaceFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(
          title: 'Price Range',
          child: Column(
            children: [
              RangeSlider(
                values: const RangeValues(50, 500),
                min: 10,
                max: 2000,
                divisions: 39,
                labels: const RangeLabels('\$50', '\$500'),
                onChanged: (values) {
                  // TODO: Handle price range change
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$50', style: TextStyle(color: Colors.grey[600])),
                  Text('\$500', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Category',
          child: Column(
            children: [
              _buildCheckboxTile('Electronics', true),
              _buildCheckboxTile('Books', false),
              _buildCheckboxTile('Furniture', false),
              _buildCheckboxTile('Clothing', false),
              _buildCheckboxTile('Sports', false),
              _buildCheckboxTile('Other', false),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Condition',
          child: Column(
            children: [
              _buildCheckboxTile('New', false),
              _buildCheckboxTile('Like New', true),
              _buildCheckboxTile('Good', false),
              _buildCheckboxTile('Fair', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(
          title: 'Sort By',
          child: Column(
            children: [
              _buildRadioTile('Relevance', true),
              _buildRadioTile('Price: Low to High', false),
              _buildRadioTile('Price: High to Low', false),
              _buildRadioTile('Newest First', false),
              _buildRadioTile('Most Popular', false),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Location',
          child: Column(
            children: [
              _buildCheckboxTile('On Campus', true),
              _buildCheckboxTile('Near Campus', false),
              _buildCheckboxTile('Downtown', false),
              _buildCheckboxTile('Anywhere', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildCheckboxTile(String title, bool value) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      ),
      value: value,
      onChanged: (bool? newValue) {
        // TODO: Handle checkbox change
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildRadioTile(String title, bool value) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      ),
      value: title,
      groupValue: value ? title : null,
      onChanged: (String? newValue) {
        // TODO: Handle radio change
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}

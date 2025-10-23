// Multiple Location Selection Widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/location_search_widget.dart';

class MultipleLocationSelector extends StatefulWidget {
  final List<String> selectedLocations;
  final ValueChanged<List<String>> onLocationsChanged;
  final String label;
  final String hintText;
  final IconData icon;
  final bool isRequired;

  const MultipleLocationSelector({
    super.key,
    required this.selectedLocations,
    required this.onLocationsChanged,
    required this.label,
    required this.hintText,
    required this.icon,
    this.isRequired = false,
  });

  @override
  State<MultipleLocationSelector> createState() =>
      _MultipleLocationSelectorState();
}

class _MultipleLocationSelectorState extends State<MultipleLocationSelector> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addLocation(String location) {
    if (location.isNotEmpty && !widget.selectedLocations.contains(location)) {
      final updatedLocations = List<String>.from(widget.selectedLocations);
      updatedLocations.add(location);
      widget.onLocationsChanged(updatedLocations);
      HapticFeedback.lightImpact();
    }
  }

  void _removeLocation(String location) {
    final updatedLocations = List<String>.from(widget.selectedLocations);
    updatedLocations.remove(location);
    widget.onLocationsChanged(updatedLocations);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label + (widget.isRequired ? ' *' : ''),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),

        // Location Search Widget
        LocationSearchWidget(
          initialValue: '',
          label: '',
          hintText: widget.hintText,
          icon: widget.icon,
          isRequired: false,
          onLocationSelected: (locationData) {
            if (locationData.isValid) {
              _addLocation(locationData.description);
              _searchController.clear();
            }
          },
        ),

        const SizedBox(height: 12),

        // Selected Locations Display
        if (widget.selectedLocations.isNotEmpty) ...[
          Text(
            'Selected Locations (${widget.selectedLocations.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                widget.selectedLocations.map((location) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeLocation(location),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],

        // Helper Text
        if (widget.selectedLocations.isEmpty)
          Text(
            'Search and select your preferred locations',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}









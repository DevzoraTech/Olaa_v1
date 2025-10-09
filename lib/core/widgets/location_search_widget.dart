// Location Search Widget with Google Places Integration
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../theme/app_theme.dart';
import '../config/google_places_config.dart';

class LocationSearchWidget extends StatefulWidget {
  final String? initialValue;
  final String label;
  final String hintText;
  final IconData icon;
  final ValueChanged<LocationData> onLocationSelected;
  final bool isRequired;

  const LocationSearchWidget({
    super.key,
    this.initialValue,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.onLocationSelected,
    this.isRequired = false,
  });

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        GooglePlaceAutoCompleteTextField(
          textEditingController: _controller,
          googleAPIKey: GooglePlacesConfig.placesApiKey,
          inputDecoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(widget.icon, color: Colors.grey[600], size: 20),
            ),
            suffixIcon:
                _controller.text.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        _controller.clear();
                        widget.onLocationSelected(LocationData.empty());
                      },
                      icon: Icon(
                        Icons.clear_rounded,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    )
                    : null,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          debounceTime: 600,
          countries: const ["ug"], // Focus on Uganda
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            // Extract location data from prediction
            final locationData = LocationData(
              placeId: prediction.placeId ?? '',
              description: prediction.description ?? '',
              latitude:
                  prediction.lat != null
                      ? double.tryParse(prediction.lat!)
                      : null,
              longitude:
                  prediction.lng != null
                      ? double.tryParse(prediction.lng!)
                      : null,
            );

            // Provide haptic feedback
            HapticFeedback.lightImpact();

            // Call the callback
            widget.onLocationSelected(locationData);
          },
          itemClick: (Prediction prediction) {
            _controller.text = prediction.description ?? '';
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0),
            );
          },
          seperatedBuilder: const Divider(),
          containerHorizontalPadding: 10,
          itemBuilder: (context, index, prediction) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prediction.description ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (prediction.structuredFormatting?.secondaryText !=
                            null) ...[
                          const SizedBox(height: 2),
                          Text(
                            prediction.structuredFormatting!.secondaryText!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          isCrossBtnShown: true,
          textStyle: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class LocationData {
  final String placeId;
  final String description;
  final double? latitude;
  final double? longitude;

  const LocationData({
    required this.placeId,
    required this.description,
    this.latitude,
    this.longitude,
  });

  const LocationData.empty()
    : placeId = '',
      description = '',
      latitude = null,
      longitude = null;

  bool get isEmpty => placeId.isEmpty && description.isEmpty;
  bool get isValid => placeId.isNotEmpty && description.isNotEmpty;
}

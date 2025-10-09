// Review and Submit Step Widget for Hostel Posting
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../domain/models/hostel_steps.dart';

class HostelReviewAndSubmitStep extends StatelessWidget {
  final HostelFormData formData;
  final VoidCallback onSubmit;
  final bool isLoading;

  const HostelReviewAndSubmitStep({
    super.key,
    required this.formData,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildBasicInfoReview(),
          const SizedBox(height: 24),
          _buildRoomDetailsReview(),
          const SizedBox(height: 24),
          _buildPricingReview(),
          const SizedBox(height: 24),
          _buildAmenitiesReview(),
          const SizedBox(height: 24),
          _buildRulesReview(),
          const SizedBox(height: 24),
          _buildPhotosReview(),
          const SizedBox(height: 32),
          _buildSubmitSection(),
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
                Icons.check_circle_outline_rounded,
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
                    'Review & Submit',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your listing before publishing',
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

  Widget _buildBasicInfoReview() {
    return _buildReviewCard(
      title: 'Basic Information',
      icon: Icons.info_outline_rounded,
      children: [
        _buildReviewItem('Title', formData.basicInfo.title),
        _buildReviewItem('Description', formData.basicInfo.description),
        _buildReviewItem('Address', formData.basicInfo.address),
        _buildReviewItem('Contact', formData.basicInfo.contactInfo),
      ],
    );
  }

  Widget _buildRoomDetailsReview() {
    return _buildReviewCard(
      title: 'Room Details',
      icon: Icons.bed_rounded,
      children: [
        _buildReviewItem('Room Type', formData.roomDetails.roomType),
        _buildReviewItem(
          'Gender Preference',
          formData.roomDetails.genderPreference,
        ),
        _buildReviewItem('Furnishing', formData.roomDetails.furnishing),
        _buildReviewItem('Utilities', formData.roomDetails.utilities),
        _buildReviewItem(
          'Capacity',
          '${formData.roomDetails.capacity} person${formData.roomDetails.capacity > 1 ? 's' : ''}',
        ),
        if (formData.roomDetails.roomSize > 0)
          _buildReviewItem('Room Size', '${formData.roomDetails.roomSize} m²'),
      ],
    );
  }

  Widget _buildPricingReview() {
    return _buildReviewCard(
      title: 'Pricing & Terms',
      icon: Icons.attach_money_rounded,
      children: [
        _buildReviewItem(
          'Monthly Rent',
          '${formData.pricing.currency} ${formData.pricing.monthlyRent.toStringAsFixed(0)}',
        ),
        if (formData.pricing.securityDeposit > 0)
          _buildReviewItem(
            'Security Deposit',
            '${formData.pricing.currency} ${formData.pricing.securityDeposit.toStringAsFixed(0)}',
          ),
        _buildReviewItem('Payment Schedule', formData.pricing.paymentSchedule),
        _buildReviewItem('Lease Duration', formData.pricing.leaseDuration),
        _buildReviewItem(
          'Utilities',
          formData.pricing.utilitiesIncluded ? 'Included in rent' : 'Separate',
        ),
        if (!formData.pricing.utilitiesIncluded &&
            formData.pricing.utilitiesCost > 0)
          _buildReviewItem(
            'Utilities Cost',
            '${formData.pricing.currency} ${formData.pricing.utilitiesCost.toStringAsFixed(0)}/month',
          ),
        if (formData.pricing.moveInDate.isNotEmpty)
          _buildReviewItem('Move-in Date', formData.pricing.moveInDate),
      ],
    );
  }

  Widget _buildAmenitiesReview() {
    return _buildReviewCard(
      title: 'Amenities & Features',
      icon: Icons.home_work_outlined,
      children: [
        if (formData.amenities.amenities.isNotEmpty)
          _buildReviewItem(
            'Amenities',
            formData.amenities.amenities.join(', '),
          ),
        if (formData.amenities.nearbyFacilities.isNotEmpty)
          _buildReviewItem(
            'Nearby Facilities',
            formData.amenities.nearbyFacilities.join(', '),
          ),
        if (formData.amenities.parkingInfo.isNotEmpty)
          _buildReviewItem('Parking', formData.amenities.parkingInfo),
        if (formData.amenities.securityFeatures.isNotEmpty)
          _buildReviewItem('Security', formData.amenities.securityFeatures),
        if (formData.amenities.internetSpeed.isNotEmpty)
          _buildReviewItem('Internet', formData.amenities.internetSpeed),
        if (formData.amenities.laundryFacilities.isNotEmpty)
          _buildReviewItem('Laundry', formData.amenities.laundryFacilities),
      ],
    );
  }

  Widget _buildRulesReview() {
    return _buildReviewCard(
      title: 'Rules & Policies',
      icon: Icons.rule_rounded,
      children: [
        if (formData.rules.houseRules.isNotEmpty)
          _buildReviewItem('House Rules', formData.rules.houseRules.join(', ')),
        if (formData.rules.visitorPolicy.isNotEmpty)
          _buildReviewItem('Visitor Policy', formData.rules.visitorPolicy),
        if (formData.rules.smokingPolicy.isNotEmpty)
          _buildReviewItem('Smoking Policy', formData.rules.smokingPolicy),
        if (formData.rules.petPolicy.isNotEmpty)
          _buildReviewItem('Pet Policy', formData.rules.petPolicy),
        if (formData.rules.noisePolicy.isNotEmpty)
          _buildReviewItem('Noise Policy', formData.rules.noisePolicy),
        if (formData.rules.cleaningPolicy.isNotEmpty)
          _buildReviewItem('Cleaning Policy', formData.rules.cleaningPolicy),
        if (formData.rules.additionalRules.isNotEmpty)
          _buildReviewItem('Additional Rules', formData.rules.additionalRules),
      ],
    );
  }

  Widget _buildPhotosReview() {
    return _buildReviewCard(
      title: 'Photos & Media',
      icon: Icons.photo_camera_rounded,
      children: [
        _buildReviewItem(
          'Photos',
          '${formData.photos.photos.length} photo${formData.photos.photos.length != 1 ? 's' : ''}',
        ),
        if (formData.photos.virtualTour.isNotEmpty)
          _buildReviewItem('Virtual Tour', 'Link provided'),
        if (formData.photos.floorPlan.isNotEmpty)
          _buildReviewItem('Floor Plan', 'Link provided'),
        if (formData.photos.neighborhoodMap.isNotEmpty)
          _buildReviewItem('Neighborhood Map', 'Link provided'),
      ],
    );
  }

  Widget _buildReviewCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.publish_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Ready to Publish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your hostel listing is ready to be published. Students will be able to see and contact you about your accommodation.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onSubmit,
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
                      : const Icon(Icons.publish_rounded, size: 18),
              label: Text(
                isLoading ? 'Publishing...' : 'Publish Hostel Listing',
              ),
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
    );
  }
}

// Roommate Review and Submit Step Widget
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../domain/models/roommate_request_steps.dart';

class RoommateReviewAndSubmitStep extends StatelessWidget {
  final RoommateRequestFormData formData;
  final VoidCallback onSubmit;
  final bool isLoading;

  const RoommateReviewAndSubmitStep({
    super.key,
    required this.formData,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildReviewSections(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
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
                    'Review your roommate request before submitting',
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

  Widget _buildReviewSections() {
    return Column(
      children: [
        _buildPersonalInfoReview(),
        const SizedBox(height: 16),
        _buildAccommodationReview(),
        const SizedBox(height: 16),
        _buildLifestyleReview(),
        const SizedBox(height: 16),
        _buildRoommatePreferencesReview(),
        const SizedBox(height: 16),
        _buildContactReview(),
      ],
    );
  }

  Widget _buildPersonalInfoReview() {
    return _buildReviewCard(
      title: 'Personal Information',
      icon: Icons.person_outline_rounded,
      children: [
        _buildReviewItem('Bio', formData.personalInfo.bio),
        if (formData.personalInfo.nickname.isNotEmpty)
          _buildReviewItem('Nickname', formData.personalInfo.nickname),
        if (formData.personalInfo.profilePictureUrl != null)
          _buildReviewItem('Profile Picture', 'Added'),
      ],
    );
  }

  Widget _buildAccommodationReview() {
    return _buildReviewCard(
      title: 'Accommodation Details',
      icon: Icons.home_outlined,
      children: [
        _buildReviewItem(
          'Preferred Locations',
          formData.accommodation.preferredLocations.isEmpty
              ? 'None selected'
              : formData.accommodation.preferredLocations.join(', '),
        ),
        _buildReviewItem(
          'Budget Range',
          '${_formatCurrency(formData.accommodation.budgetMin)} - ${_formatCurrency(formData.accommodation.budgetMax)} UGX',
        ),
        if (formData.accommodation.preferredHostel.isNotEmpty)
          _buildReviewItem(
            'Preferred Hostel',
            formData.accommodation.preferredHostel,
          ),
        if (formData.accommodation.moveInDate != null)
          _buildReviewItem(
            'Move-in Date',
            _formatDate(formData.accommodation.moveInDate!),
          ),
        _buildReviewItem('Urgency', formData.accommodation.urgency),
        _buildReviewItem(
          'Lease Duration',
          formData.accommodation.leaseDuration,
        ),
      ],
    );
  }

  Widget _buildLifestyleReview() {
    return _buildReviewCard(
      title: 'Lifestyle Preferences',
      icon: Icons.schedule_outlined,
      children: [
        _buildReviewItem('Sleep Schedule', formData.lifestyle.sleepSchedule),
        _buildReviewItem(
          'Lifestyle Preference',
          formData.lifestyle.lifestylePreference,
        ),
        _buildReviewItem(
          'Smoking Preference',
          formData.lifestyle.smokingPreference,
        ),
        _buildReviewItem(
          'Drinking Preference',
          formData.lifestyle.drinkingPreference,
        ),
        _buildReviewItem('Sharing Style', formData.lifestyle.sharingStyle),
      ],
    );
  }

  Widget _buildRoommatePreferencesReview() {
    return _buildReviewCard(
      title: 'Roommate Preferences',
      icon: Icons.people_outline_rounded,
      children: [
        if (formData.roommatePreferences.preferredAgeRange.isNotEmpty)
          _buildReviewItem(
            'Age Range',
            formData.roommatePreferences.preferredAgeRange,
          ),
        if (formData.roommatePreferences.petPreference.isNotEmpty)
          _buildReviewItem(
            'Pet Preference',
            formData.roommatePreferences.petPreference,
          ),
        if (formData.roommatePreferences.otherPreferences.isNotEmpty)
          _buildReviewItem(
            'Other Preferences',
            formData.roommatePreferences.otherPreferences,
          ),
      ],
    );
  }

  Widget _buildContactReview() {
    return _buildReviewCard(
      title: 'Contact & Photos',
      icon: Icons.contact_phone_outlined,
      children: [
        _buildReviewItem(
          'Photos',
          '${formData.contactAndPhotos.photos.length} photos',
        ),
        if (formData.contactAndPhotos.phoneNumber.isNotEmpty)
          _buildReviewItem(
            'Phone',
            formData.contactAndPhotos.isPhoneShared
                ? formData.contactAndPhotos.phoneNumber
                : 'Private',
          ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                  fontSize: 18,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double value) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child:
            isLoading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Submitting...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Submit Roommate Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

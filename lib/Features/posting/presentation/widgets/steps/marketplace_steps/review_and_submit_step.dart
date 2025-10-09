// Review and Submit Step Widget
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../domain/models/marketplace_steps.dart';

class ReviewAndSubmitStep extends StatelessWidget {
  final MarketplaceFormData formData;
  final VoidCallback onSubmit;
  final bool isLoading;

  const ReviewAndSubmitStep({
    super.key,
    required this.formData,
    required this.onSubmit,
    this.isLoading = false,
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
                    'Review your listing before submitting',
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
        _buildItemInfoReview(),
        const SizedBox(height: 16),
        _buildItemDetailsReview(),
        const SizedBox(height: 16),
        _buildPricingReview(),
        const SizedBox(height: 16),
        _buildContactReview(),
      ],
    );
  }

  Widget _buildItemInfoReview() {
    return _buildReviewCard(
      title: 'Item Information',
      icon: Icons.info_outline_rounded,
      children: [
        _buildReviewItem('Title', formData.itemInfo.title),
        _buildReviewItem('Description', formData.itemInfo.description),
        _buildReviewItem('Category', formData.itemInfo.category),
      ],
    );
  }

  Widget _buildItemDetailsReview() {
    return _buildReviewCard(
      title: 'Item Details',
      icon: Icons.details_outlined,
      children: [
        if (formData.itemDetails.brand.isNotEmpty)
          _buildReviewItem('Brand', formData.itemDetails.brand),
        if (formData.itemDetails.model.isNotEmpty)
          _buildReviewItem('Model', formData.itemDetails.model),
        if (formData.itemDetails.specifications.isNotEmpty)
          _buildReviewItem(
            'Specifications',
            formData.itemDetails.specifications,
          ),
        if (formData.itemDetails.tags.isNotEmpty)
          _buildReviewItem('Tags', formData.itemDetails.tags.join(', ')),
      ],
    );
  }

  Widget _buildPricingReview() {
    return _buildReviewCard(
      title: 'Pricing & Condition',
      icon: Icons.attach_money_rounded,
      children: [
        _buildReviewItem(
          'Price',
          '${formData.pricingAndCondition.price.toStringAsFixed(0)} ${formData.pricingAndCondition.currency}',
        ),
        _buildReviewItem('Condition', formData.pricingAndCondition.condition),
        _buildReviewItem(
          'Payment Method',
          formData.pricingAndCondition.paymentMethod,
        ),
        _buildReviewItem(
          'Negotiable',
          formData.pricingAndCondition.isNegotiable ? 'Yes' : 'No',
        ),
      ],
    );
  }

  Widget _buildContactReview() {
    return _buildReviewCard(
      title: 'Photos & Contact',
      icon: Icons.photo_camera_rounded,
      children: [
        _buildReviewItem(
          'Photos',
          '${formData.photosAndContact.photos.length} photos',
        ),
        if (formData.photosAndContact.contactPhone.isNotEmpty)
          _buildReviewItem(
            'Phone',
            formData.photosAndContact.isPhoneShared
                ? formData.photosAndContact.contactPhone
                : 'Private',
          ),
        if (formData.photosAndContact.contactEmail.isNotEmpty)
          _buildReviewItem(
            'Email',
            formData.photosAndContact.isEmailShared
                ? formData.photosAndContact.contactEmail
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

  Widget _buildReviewItem(String label, String value) {
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
                    Icon(Icons.storefront_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Post to Marketplace',
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

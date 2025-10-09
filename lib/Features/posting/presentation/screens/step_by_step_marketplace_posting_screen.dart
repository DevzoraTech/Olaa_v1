// Presentation Layer - Step-by-Step Marketplace Posting Screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../core/services/roommate_posting_service.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../domain/models/marketplace_steps.dart';
import '../widgets/marketplace_posting_progress.dart';
import '../widgets/steps/marketplace_steps/item_info_step.dart';
import '../widgets/steps/marketplace_steps/item_details_step.dart';
import '../widgets/steps/marketplace_steps/pricing_and_condition_step.dart';
import '../widgets/steps/marketplace_steps/photos_and_contact_step.dart';
import '../widgets/steps/marketplace_steps/review_and_submit_step.dart';

class StepByStepMarketplacePostingScreen extends StatefulWidget {
  const StepByStepMarketplacePostingScreen({super.key});

  @override
  State<StepByStepMarketplacePostingScreen> createState() =>
      _StepByStepMarketplacePostingScreenState();
}

class _StepByStepMarketplacePostingScreenState
    extends State<StepByStepMarketplacePostingScreen> {
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  final SupabaseDatabaseService _databaseService =
      SupabaseDatabaseService.instance;
  final PageController _pageController = PageController();

  int _currentStepIndex = 0;
  bool _isLoading = false;

  // Form data
  late MarketplaceFormData _formData;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    _formData = const MarketplaceFormData(
      itemInfo: ItemInfoData(),
      itemDetails: ItemDetailsData(),
      pricingAndCondition: PricingAndConditionData(),
      photosAndContact: PhotosAndContactData(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            MarketplacePostingProgress(
              currentStepIndex: _currentStepIndex,
              onStepTap: _onStepTap,
              isStepClickable: true,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  ItemInfoStep(
                    data: _formData.itemInfo,
                    onDataChanged: _updateItemInfo,
                  ),
                  ItemDetailsStep(
                    data: _formData.itemDetails,
                    onDataChanged: _updateItemDetails,
                  ),
                  PricingAndConditionStep(
                    data: _formData.pricingAndCondition,
                    onDataChanged: _updatePricingAndCondition,
                  ),
                  PhotosAndContactStep(
                    data: _formData.photosAndContact,
                    onDataChanged: _updatePhotosAndContact,
                  ),
                  ReviewAndSubmitStep(
                    formData: _formData,
                    onSubmit: _submitMarketplaceItem,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.grey[800],
            size: 20,
          ),
          onPressed: () => _onBackPressed(),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Post to Marketplace',
            style: TextStyle(
              color: Colors.grey[900],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Step ${_currentStepIndex + 1} of ${MarketplaceConstants.steps.length}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        if (_currentStepIndex < MarketplaceConstants.steps.length - 1)
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _onSkipPressed,
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[100],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final isLastStep =
        _currentStepIndex == MarketplaceConstants.steps.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStepIndex > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _onPreviousPressed,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_currentStepIndex > 0) const SizedBox(width: 12),
            Expanded(
              flex: _currentStepIndex == 0 ? 1 : 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient:
                      _canProceed()
                          ? LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : null,
                  boxShadow:
                      _canProceed()
                          ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : [],
                ),
                child: ElevatedButton(
                  onPressed: _canProceed() ? _onNextPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.grey[300],
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLastStep)
                        Icon(Icons.check_circle_rounded, size: 20),
                      if (isLastStep) const SizedBox(width: 8),
                      Text(
                        isLastStep ? 'Submit Listing' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (!isLastStep) const SizedBox(width: 8),
                      if (!isLastStep)
                        Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStepTap(int stepIndex) {
    if (stepIndex <= _currentStepIndex) {
      _pageController.animateToPage(
        stepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentStepIndex = index;
    });
  }

  void _onPreviousPressed() {
    if (_currentStepIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onNextPressed() {
    if (_currentStepIndex < MarketplaceConstants.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSkipPressed() {
    if (_currentStepIndex < MarketplaceConstants.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onBackPressed() {
    if (_currentStepIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  bool _canProceed() {
    switch (_currentStepIndex) {
      case 0:
        return _formData.itemInfo.isValid;
      case 1:
        return _formData.itemDetails.isValid;
      case 2:
        return _formData.pricingAndCondition.isValid;
      case 3:
        return _formData.photosAndContact.isValid;
      case 4:
        return _formData.isValid;
      default:
        return false;
    }
  }

  // Data update methods
  void _updateItemInfo(ItemInfoData data) {
    setState(() {
      _formData = _formData.copyWith(itemInfo: data);
    });
  }

  void _updateItemDetails(ItemDetailsData data) {
    setState(() {
      _formData = _formData.copyWith(itemDetails: data);
    });
  }

  void _updatePricingAndCondition(PricingAndConditionData data) {
    setState(() {
      _formData = _formData.copyWith(pricingAndCondition: data);
    });
  }

  void _updatePhotosAndContact(PhotosAndContactData data) {
    setState(() {
      _formData = _formData.copyWith(photosAndContact: data);
    });
  }

  Future<void> _submitMarketplaceItem() async {
    if (!_formData.isValid) {
      AppUtils.showErrorSnackBar(
        context,
        'Please complete all required fields.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Upload photos if any
      List<String> uploadedPhotoUrls = [];
      if (_formData.photosAndContact.photos.isNotEmpty) {
        uploadedPhotoUrls = await RoommatePostingService.uploadPhotos(
          photoPaths: _formData.photosAndContact.photos,
          userId: user.id,
        );
      }

      // Prepare posting data (only include fields that exist in the database schema)
      final postingData = <String, dynamic>{
        'seller_id': user.id,
        'title': _formData.itemInfo.title,
        'description': _formData.itemInfo.description,
        'category': _formData.itemInfo.category,
        'price': _formData.pricingAndCondition.price,
        'currency': _formData.pricingAndCondition.currency,
        'condition': _formData.pricingAndCondition.condition,
        'images': uploadedPhotoUrls,
        'contact_phone': _formData.photosAndContact.contactPhone,
        'contact_email': _formData.photosAndContact.contactEmail,
        'is_available': true,
      };

      // Save to marketplace_items table
      print('DEBUG: Posting marketplace item: $postingData');

      final result = await _databaseService.createMarketplaceItem(postingData);

      if (result == null) {
        throw Exception('Failed to create marketplace item');
      }

      print('DEBUG: Marketplace item created successfully: $result');

      if (mounted) {
        // Show success with haptic feedback
        HapticFeedback.heavyImpact();

        AppUtils.showSuccessSnackBar(
          context,
          'Item posted to marketplace successfully! 🎉',
        );

        // Navigate back with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        AppUtils.showErrorSnackBar(
          context,
          'Failed to post item. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Main Step-by-Step Hostel Posting Screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../domain/models/hostel_steps.dart';
import '../widgets/hostel_posting_progress.dart';
import '../widgets/steps/hostel_steps/hostel_basic_info_step.dart';
import '../widgets/steps/hostel_steps/hostel_room_details_step.dart';
import '../widgets/steps/hostel_steps/hostel_pricing_step.dart';
import '../widgets/steps/hostel_steps/hostel_amenities_step.dart';
import '../widgets/steps/hostel_steps/hostel_rules_step.dart';
import '../widgets/steps/hostel_steps/hostel_photos_step.dart';
import '../widgets/steps/hostel_steps/hostel_review_and_submit_step.dart';

class StepByStepHostelPostingScreen extends StatefulWidget {
  const StepByStepHostelPostingScreen({super.key});

  @override
  State<StepByStepHostelPostingScreen> createState() =>
      _StepByStepHostelPostingScreenState();
}

class _StepByStepHostelPostingScreenState
    extends State<StepByStepHostelPostingScreen>
    with TickerProviderStateMixin {
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  final SupabaseDatabaseService _databaseService =
      SupabaseDatabaseService.instance;
  final PageController _pageController = PageController();

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form Data
  late HostelFormData _formData;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // Current step tracking
  int _currentStepIndex = 0;
  List<HostelStepData> _steps = [];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _initializeSteps();
    _initializeAnimations();
  }

  void _initializeFormData() {
    _formData = const HostelFormData(
      basicInfo: HostelBasicInfoData(),
      roomDetails: HostelRoomDetailsData(),
      pricing: HostelPricingData(),
      amenities: HostelAmenitiesData(),
      rules: HostelRulesData(),
      photos: HostelPhotosData(),
    );
  }

  void _initializeSteps() {
    _steps =
        HostelConstants.steps.map((step) {
          return step.copyWith(
            isActive:
                step.step == HostelConstants.steps[_currentStepIndex].step,
          );
        }).toList();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          return await _showUnsavedChangesDialog();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        extendBodyBehindAppBar: true,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildAppBar(),
              _buildProgressIndicator(),
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      HostelBasicInfoStep(
                        data: _formData.basicInfo,
                        onDataChanged: _updateBasicInfo,
                      ),
                      HostelRoomDetailsStep(
                        data: _formData.roomDetails,
                        onDataChanged: _updateRoomDetails,
                      ),
                      HostelPricingStep(
                        data: _formData.pricing,
                        onDataChanged: _updatePricing,
                      ),
                      HostelAmenitiesStep(
                        data: _formData.amenities,
                        onDataChanged: _updateAmenities,
                      ),
                      HostelRulesStep(
                        data: _formData.rules,
                        onDataChanged: _updateRules,
                      ),
                      HostelPhotosStep(
                        data: _formData.photos,
                        onDataChanged: _updatePhotos,
                      ),
                      HostelReviewAndSubmitStep(
                        formData: _formData,
                        onSubmit: _submitHostelListing,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () async {
            if (_hasUnsavedChanges) {
              final shouldLeave = await _showUnsavedChangesDialog();
              if (shouldLeave) Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.grey[800],
            size: 20,
          ),
        ),
      ),
      title: Text(
        'List Your Hostel',
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressIndicator() {
    return HostelPostingProgressIndicator(
      steps: _steps,
      currentStepIndex: _currentStepIndex,
      onStepTap: _canNavigateToStep ? _navigateToStep : null,
    );
  }

  Widget _buildNavigationButtons() {
    final currentStep = HostelConstants.steps[_currentStepIndex];
    final isLastStep = _currentStepIndex == HostelConstants.steps.length - 1;
    final canGoNext = _formData.isStepValid(currentStep.step);

    return HostelStepNavigationButtons(
      canGoBack: _currentStepIndex > 0,
      canGoForward: true,
      isLoading: _isLoading,
      onBack: _currentStepIndex > 0 ? _goToPreviousStep : null,
      onNext:
          canGoNext
              ? (isLastStep ? _submitHostelListing : _goToNextStep)
              : null,
      nextButtonText: isLastStep ? 'Submit Listing' : 'Next',
      backButtonText: 'Back',
    );
  }

  void _updateBasicInfo(HostelBasicInfoData data) {
    setState(() {
      _formData = _formData.copyWith(basicInfo: data);
      _hasUnsavedChanges = true;
      _updateStepCompletion();
    });
  }

  void _updateRoomDetails(HostelRoomDetailsData data) {
    setState(() {
      _formData = _formData.copyWith(roomDetails: data);
      _hasUnsavedChanges = true;
      _updateStepCompletion();
    });
  }

  void _updatePricing(HostelPricingData data) {
    setState(() {
      _formData = _formData.copyWith(pricing: data);
      _hasUnsavedChanges = true;
      _updateStepCompletion();
    });
  }

  void _updateAmenities(HostelAmenitiesData data) {
    setState(() {
      _formData = _formData.copyWith(amenities: data);
      _hasUnsavedChanges = true;
      _updateStepCompletion();
    });
  }

  void _updateRules(HostelRulesData data) {
    setState(() {
      _formData = _formData.copyWith(rules: data);
      _hasUnsavedChanges = true;
      _updateStepCompletion();
    });
  }

  void _updatePhotos(HostelPhotosData data) {
    setState(() {
      _formData = _formData.copyWith(photos: data);
      _hasUnsavedChanges = true;
      _updateStepCompletion();
    });
  }

  void _updateStepCompletion() {
    _steps =
        _steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isCompleted = _formData.isStepValid(step.step);
          final isActive = index == _currentStepIndex;

          return step.copyWith(isCompleted: isCompleted, isActive: isActive);
        }).toList();
  }

  void _goToNextStep() {
    if (_currentStepIndex < HostelConstants.steps.length - 1) {
      _navigateToStep(_currentStepIndex + 1);
    }
  }

  void _goToPreviousStep() {
    if (_currentStepIndex > 0) {
      _navigateToStep(_currentStepIndex - 1);
    }
  }

  void _navigateToStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < HostelConstants.steps.length) {
      setState(() {
        _currentStepIndex = stepIndex;
        _updateStepCompletion();
      });

      _pageController.animateToPage(
        stepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool get _canNavigateToStep {
    // Allow navigation to completed steps or current step
    return true;
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Unsaved Changes'),
                  ],
                ),
                content: const Text(
                  'You have unsaved changes. Are you sure you want to leave without saving?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Stay',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Leave'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<Map<String, dynamic>> _uploadHostelMedia() async {
    final uploadedUrls = <String, dynamic>{};

    try {
      print('DEBUG: Starting media upload process...');

      // Collect all file paths
      final allFilePaths = <String>[];
      final fileTypes = <String>[];

      // Add photos
      for (final photoPath in _formData.photos.photos) {
        if (photoPath.isNotEmpty && photoPath.startsWith('/')) {
          allFilePaths.add(photoPath);
          fileTypes.add('photo');
          print('DEBUG: Added photo: $photoPath');
        }
      }

      // Add virtual tour video
      if (_formData.photos.virtualTour.isNotEmpty &&
          _formData.photos.virtualTour.startsWith('/')) {
        allFilePaths.add(_formData.photos.virtualTour);
        fileTypes.add('virtual_tour');
        print('DEBUG: Added video: ${_formData.photos.virtualTour}');
      }

      // Add floor plan
      if (_formData.photos.floorPlan.isNotEmpty &&
          _formData.photos.floorPlan.startsWith('/')) {
        allFilePaths.add(_formData.photos.floorPlan);
        fileTypes.add('floor_plan');
        print('DEBUG: Added floor plan: ${_formData.photos.floorPlan}');
      }

      // Add neighborhood map
      if (_formData.photos.neighborhoodMap.isNotEmpty &&
          _formData.photos.neighborhoodMap.startsWith('/')) {
        allFilePaths.add(_formData.photos.neighborhoodMap);
        fileTypes.add('neighborhood_map');
        print(
          'DEBUG: Added neighborhood map: ${_formData.photos.neighborhoodMap}',
        );
      }

      if (allFilePaths.isEmpty) {
        print('DEBUG: No files to upload');
        return {};
      }

      print('DEBUG: Total files to upload: ${allFilePaths.length}');
      print('DEBUG: File paths: $allFilePaths');

      // Upload all files
      final user = _authService.currentUser;
      if (user == null) {
        print('DEBUG: No user found');
        return {};
      }

      print('DEBUG: Uploading files for user: ${user.id}');
      final uploadedUrls = await _databaseService.uploadHostelMedia(
        filePaths: allFilePaths,
        userId: user.id,
        hostelId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('DEBUG: Uploaded URLs: $uploadedUrls');

      // Organize URLs by type
      final result = <String, dynamic>{};
      int photoIndex = 0;
      int urlIndex = 0;

      for (final type in fileTypes) {
        if (type == 'photo') {
          if (!result.containsKey('photos')) {
            result['photos'] = <String>[];
          }
          (result['photos'] as List<String>).add(uploadedUrls[urlIndex]);
          photoIndex++;
        } else {
          // Map the type to the correct database field name
          String fieldName = type;
          if (type == 'virtual_tour') {
            fieldName = 'virtual_tour';
          } else if (type == 'floor_plan') {
            fieldName = 'floor_plan';
          } else if (type == 'neighborhood_map') {
            fieldName = 'neighborhood_map';
          }
          result[fieldName] = uploadedUrls[urlIndex];
        }
        urlIndex++;
      }

      print('DEBUG: Final organized URLs: $result');
      return result;
    } catch (e) {
      print('ERROR: Failed to upload hostel media: $e');
      print('ERROR: Stack trace: ${StackTrace.current}');
      return {}; // Return empty map if upload fails
    }
  }

  Future<void> _submitHostelListing() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get user profile data
      final userProfile = await _authService.getUserProfile(user.id);
      final providerName =
          '${userProfile?['first_name'] ?? ''} ${userProfile?['last_name'] ?? ''}'
              .trim();

      // Upload media files first
      final uploadedMedia = await _uploadHostelMedia();
      print('DEBUG: Uploaded media result: $uploadedMedia');

      // Check if we have any media files that should have been uploaded
      final hasMediaFiles =
          _formData.photos.photos.isNotEmpty ||
          _formData.photos.virtualTour.isNotEmpty ||
          _formData.photos.floorPlan.isNotEmpty ||
          _formData.photos.neighborhoodMap.isNotEmpty;

      // If we have media files but upload failed, show error
      if (hasMediaFiles && uploadedMedia.isEmpty) {
        throw Exception('Failed to upload media files. Please try again.');
      }

      // Prepare posting data with uploaded media URLs
      final postingData = <String, dynamic>{
        'provider_id': user.id,
        'provider_name': providerName,
        'type': 'hostel_listing',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        ..._formData.toPostingData(includeMedia: false), // Exclude media fields
        ...uploadedMedia, // Add only uploaded URLs
      };

      print('DEBUG: Final posting data: $postingData');

      // Save to database
      await _databaseService.createHostelListing(postingData);

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
        });

        // Show success with haptic feedback
        HapticFeedback.heavyImpact();

        AppUtils.showSuccessSnackBar(
          context,
          'Hostel listing published successfully! 🎉',
        );

        // Navigate back with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error creating hostel listing: $e');
      if (mounted) {
        HapticFeedback.heavyImpact();
        AppUtils.showErrorSnackBar(
          context,
          'Failed to publish hostel listing: ${e.toString()}',
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

// Main Step-by-Step Roommate Request Screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../core/services/roommate_posting_service.dart';
import '../../domain/models/roommate_request_steps.dart';
import '../widgets/roommate_request_progress.dart';
import '../widgets/steps/roommate_steps/personal_info_step.dart';
import '../widgets/steps/roommate_steps/accommodation_details_step.dart';
import '../widgets/steps/roommate_steps/lifestyle_preferences_step.dart';
import '../widgets/steps/roommate_steps/roommate_preferences_step.dart';
import '../widgets/steps/roommate_steps/contact_and_photos_step.dart';
import '../widgets/steps/roommate_steps/roommate_review_and_submit_step.dart';

class StepByStepRoommateRequestScreen extends StatefulWidget {
  const StepByStepRoommateRequestScreen({super.key});

  @override
  State<StepByStepRoommateRequestScreen> createState() =>
      _StepByStepRoommateRequestScreenState();
}

class _StepByStepRoommateRequestScreenState
    extends State<StepByStepRoommateRequestScreen>
    with TickerProviderStateMixin {
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  final PageController _pageController = PageController();

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form Data
  late RoommateRequestFormData _formData;
  List<Map<String, dynamic>> _availableHostels = [];
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // Current step tracking
  int _currentStepIndex = 0;
  List<StepData> _steps = [];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _initializeSteps();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeFormData() {
    _formData = const RoommateRequestFormData(
      personalInfo: PersonalInfoData(),
      accommodation: AccommodationData(),
      lifestyle: LifestyleData(),
      roommatePreferences: RoommatePreferencesData(),
      contactAndPhotos: ContactAndPhotosData(),
    );
  }

  void _initializeSteps() {
    _steps =
        RoommateRequestConstants.steps.map((step) {
          return step.copyWith(
            isActive:
                step.step ==
                RoommateRequestConstants.steps[_currentStepIndex].step,
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

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        // Load available hostels
        final hostels = await RoommatePostingService.getAvailableHostels();
        setState(() {
          _availableHostels = hostels;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
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
                      PersonalInfoStep(
                        data: _formData.personalInfo,
                        onDataChanged: _updatePersonalInfo,
                      ),
                      AccommodationDetailsStep(
                        data: _formData.accommodation,
                        onDataChanged: _updateAccommodation,
                        availableHostels: _availableHostels,
                      ),
                      LifestylePreferencesStep(
                        data: _formData.lifestyle,
                        onDataChanged: _updateLifestyle,
                      ),
                      RoommatePreferencesStep(
                        data: _formData.roommatePreferences,
                        onDataChanged: _updateRoommatePreferences,
                      ),
                      ContactAndPhotosStep(
                        data: _formData.contactAndPhotos,
                        onDataChanged: _updateContactAndPhotos,
                      ),
                      RoommateReviewAndSubmitStep(
                        formData: _formData,
                        onSubmit: _submitRequest,
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
        'Find a Roommate',
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
    return RoommateRequestProgressIndicator(
      steps: _steps,
      currentStepIndex: _currentStepIndex,
      onStepTap: _canNavigateToStep ? _navigateToStep : null,
    );
  }

  Widget _buildNavigationButtons() {
    final currentStep = RoommateRequestConstants.steps[_currentStepIndex];
    final isLastStep =
        _currentStepIndex == RoommateRequestConstants.steps.length - 1;
    final canGoNext = _formData.isStepValid(currentStep.step);

    return StepNavigationButtons(
      canGoBack: _currentStepIndex > 0,
      canGoForward: true,
      isLoading: _isLoading,
      onBack: _currentStepIndex > 0 ? _goToPreviousStep : null,
      onNext: canGoNext ? (isLastStep ? _submitRequest : _goToNextStep) : null,
      nextButtonText: isLastStep ? 'Submit Request' : 'Next',
      backButtonText: 'Back',
    );
  }

  void _updatePersonalInfo(PersonalInfoData data) {
    setState(() {
      _formData = _formData.copyWith(personalInfo: data);
      _hasUnsavedChanges = true;
      _updateStepCompletion();
    });
  }

  void _updateAccommodation(AccommodationData data) {
    setState(() {
      _formData = _formData.copyWith(accommodation: data);
      _hasUnsavedChanges = true;
      _updateStepCompletion();
    });
  }

  void _updateLifestyle(LifestyleData data) {
    setState(() {
      _formData = _formData.copyWith(lifestyle: data);
      _hasUnsavedChanges = true;
      _updateStepCompletion();
    });
  }

  void _updateRoommatePreferences(RoommatePreferencesData data) {
    setState(() {
      _formData = _formData.copyWith(roommatePreferences: data);
      _hasUnsavedChanges = true;
      _updateStepCompletion();
    });
  }

  void _updateContactAndPhotos(ContactAndPhotosData data) {
    setState(() {
      _formData = _formData.copyWith(contactAndPhotos: data);
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
    if (_currentStepIndex < RoommateRequestConstants.steps.length - 1) {
      _navigateToStep(_currentStepIndex + 1);
    }
  }

  void _goToPreviousStep() {
    if (_currentStepIndex > 0) {
      _navigateToStep(_currentStepIndex - 1);
    }
  }

  void _navigateToStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < RoommateRequestConstants.steps.length) {
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

  Future<void> _submitRequest() async {
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
      final userName =
          '${userProfile?['first_name'] ?? ''} ${userProfile?['last_name'] ?? ''}'
              .trim();
      final nickname = userProfile?['nickname'] ?? '';
      final campus = userProfile?['campus'] ?? '';
      final yearOfStudy = userProfile?['year_of_study'] ?? '';

      // Upload photos if any
      List<String> uploadedPhotoUrls = [];
      if (_formData.contactAndPhotos.photos.isNotEmpty) {
        uploadedPhotoUrls = await RoommatePostingService.uploadPhotos(
          photoPaths: _formData.contactAndPhotos.photos,
          userId: user.id,
        );
      }

      // Upload profile picture if provided
      String? profilePictureUrl = _formData.personalInfo.profilePictureUrl;
      print('DEBUG: Original profile picture URL: $profilePictureUrl');

      if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
        // If it's a local file path, upload it
        if (profilePictureUrl.startsWith('/') ||
            profilePictureUrl.startsWith('file://')) {
          final fileName =
              'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          print(
            'DEBUG: Uploading profile picture: $profilePictureUrl to $fileName',
          );

          profilePictureUrl = await _authService.uploadProfileImage(
            imagePath: profilePictureUrl.replaceFirst('file://', ''),
            fileName: fileName,
          );

          print('DEBUG: Uploaded profile picture URL: $profilePictureUrl');
        }
      }

      // Prepare posting data
      final postingData = <String, dynamic>{
        'student_id': user.id,
        'student_name': userName,
        'nickname': nickname,
        'campus': campus,
        'year_of_study': yearOfStudy,
        ..._formData.toPostingData(),
        'profile_picture_url': profilePictureUrl,
        'photos': uploadedPhotoUrls, // Use uploaded URLs instead of local paths
        'status': 'Active',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Create roommate request
      await RoommatePostingService.createRoommateRequest(
        requestData: postingData,
      );

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
        });

        // Show success with haptic feedback
        HapticFeedback.heavyImpact();

        AppUtils.showSuccessSnackBar(
          context,
          'Roommate request posted successfully! 🎉',
        );

        // Navigate back with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        AppUtils.showErrorSnackBar(
          context,
          'Failed to post roommate request. Please try again.',
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

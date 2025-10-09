// Presentation Layer - Unified Sign Up Screen with Progress Tracking
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_auth_service.dart';
import 'login_screen.dart';

class UnifiedSignUpScreen extends StatefulWidget {
  const UnifiedSignUpScreen({super.key});

  @override
  State<UnifiedSignUpScreen> createState() => _UnifiedSignUpScreenState();
}

class _UnifiedSignUpScreenState extends State<UnifiedSignUpScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  // Current step tracking
  int _currentStep = 0;
  String _selectedUserType = '';

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Student fields
  final _campusController = TextEditingController();
  final _yearController = TextEditingController();
  final _courseController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  List<String> _selectedInterests = [];

  // Hostel provider fields
  final _businessNameController = TextEditingController();
  final _primaryPhoneController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _addressController = TextEditingController();

  // Event organizer fields
  final _organizationNameController = TextEditingController();
  final _organizationTypeController = TextEditingController();
  final _organizationDescriptionController = TextEditingController();
  final _organizationWebsiteController = TextEditingController();
  final _organizationPhoneController = TextEditingController();

  // Promoter fields
  final _agencyNameController = TextEditingController();
  final _agencyTypeController = TextEditingController();
  final _agencyDescriptionController = TextEditingController();
  final _agencyWebsiteController = TextEditingController();
  final _agencyPhoneController = TextEditingController();

  // Profile picture
  File? _selectedImage;
  String? _profileImageUrl;
  bool _isUploadingImage = false;

  // Loading state
  bool _isLoading = false;

  // Auth service
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Step definitions
  final List<SignUpStep> _steps = [
    SignUpStep(
      title: 'Basic Information',
      subtitle: 'Tell us about yourself',
      stepNumber: 1,
    ),
    SignUpStep(
      title: 'Account Type',
      subtitle: 'Choose your role',
      stepNumber: 2,
    ),
    SignUpStep(
      title: 'Role Details',
      subtitle: 'Complete your profile',
      stepNumber: 3,
    ),
    SignUpStep(
      title: 'Profile Picture',
      subtitle: 'Add your photo',
      stepNumber: 4,
    ),
    SignUpStep(title: 'Complete', subtitle: 'Review and finish', stepNumber: 5),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _campusController.dispose();
    _yearController.dispose();
    _courseController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _primaryPhoneController.dispose();
    _secondaryPhoneController.dispose();
    _locationNameController.dispose();
    _addressController.dispose();
    _organizationNameController.dispose();
    _organizationTypeController.dispose();
    _organizationDescriptionController.dispose();
    _organizationWebsiteController.dispose();
    _organizationPhoneController.dispose();
    _agencyNameController.dispose();
    _agencyTypeController.dispose();
    _agencyDescriptionController.dispose();
    _agencyWebsiteController.dispose();
    _agencyPhoneController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleCompleteSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.completeSignUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        userType: _selectedUserType,
        // Student fields
        campus:
            _campusController.text.isNotEmpty ? _campusController.text : null,
        yearOfStudy:
            _yearController.text.isNotEmpty ? _yearController.text : null,
        course:
            _courseController.text.isNotEmpty ? _courseController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        gender: _selectedGender,
        interests: _selectedInterests.isNotEmpty ? _selectedInterests : null,
        // Hostel provider fields
        businessName:
            _businessNameController.text.isNotEmpty
                ? _businessNameController.text
                : null,
        primaryPhone:
            _primaryPhoneController.text.isNotEmpty
                ? _primaryPhoneController.text
                : null,
        secondaryPhone:
            _secondaryPhoneController.text.isNotEmpty
                ? _secondaryPhoneController.text
                : null,
        locationName:
            _locationNameController.text.isNotEmpty
                ? _locationNameController.text
                : null,
        address:
            _addressController.text.isNotEmpty ? _addressController.text : null,
        // Event organizer fields
        organizationName:
            _organizationNameController.text.isNotEmpty
                ? _organizationNameController.text
                : null,
        organizationType:
            _organizationTypeController.text.isNotEmpty
                ? _organizationTypeController.text
                : null,
        organizationDescription:
            _organizationDescriptionController.text.isNotEmpty
                ? _organizationDescriptionController.text
                : null,
        organizationWebsite:
            _organizationWebsiteController.text.isNotEmpty
                ? _organizationWebsiteController.text
                : null,
        organizationPhone:
            _organizationPhoneController.text.isNotEmpty
                ? _organizationPhoneController.text
                : null,
        // Promoter fields
        agencyName:
            _agencyNameController.text.isNotEmpty
                ? _agencyNameController.text
                : null,
        agencyType:
            _agencyTypeController.text.isNotEmpty
                ? _agencyTypeController.text
                : null,
        agencyDescription:
            _agencyDescriptionController.text.isNotEmpty
                ? _agencyDescriptionController.text
                : null,
        agencyWebsite:
            _agencyWebsiteController.text.isNotEmpty
                ? _agencyWebsiteController.text
                : null,
        agencyPhone:
            _agencyPhoneController.text.isNotEmpty
                ? _agencyPhoneController.text
                : null,
        // Profile image
        profileImageUrl: _profileImageUrl,
        imagePath: _selectedImage?.path,
      );

      if (mounted) {
        AppUtils.showSuccessSnackBar(context, 'Account created successfully!');
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showErrorSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Account',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfoStep(),
                  _buildUserTypeStep(),
                  _buildRoleDetailsStep(),
                  _buildProfilePictureStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Step indicators
          Row(
            children:
                _steps.asMap().entries.map((entry) {
                  int index = entry.key;
                  SignUpStep step = entry.value;
                  bool isActive = index <= _currentStep;
                  bool isCompleted = index < _currentStep;

                  return Expanded(
                    child: Row(
                      children: [
                        // Step circle
                        GestureDetector(
                          onTap: () => _goToStep(index),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  isCompleted
                                      ? AppTheme.primaryColor
                                      : isActive
                                      ? AppTheme.primaryColor.withOpacity(0.2)
                                      : Colors.grey[300],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isActive
                                        ? AppTheme.primaryColor
                                        : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child:
                                  isCompleted
                                      ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                      : Text(
                                        '${step.stepNumber}',
                                        style: TextStyle(
                                          color:
                                              isActive
                                                  ? AppTheme.primaryColor
                                                  : Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                            ),
                          ),
                        ),

                        // Connector line
                        if (index < _steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color:
                                  isCompleted
                                      ? AppTheme.primaryColor
                                      : Colors.grey[300],
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 16),

          // Current step title
          Text(
            _steps[_currentStep].title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _steps[_currentStep].subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a password',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Role',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the role that best describes you',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          _buildUserTypeCard(
            title: 'Student',
            subtitle:
                'I\'m a student looking for housing, events, and campus connections',
            icon: Icons.school_outlined,
            userType: 'student',
          ),

          const SizedBox(height: 16),

          _buildUserTypeCard(
            title: 'Hostel Provider',
            subtitle: 'I own or manage hostels and want to list them',
            icon: Icons.home_outlined,
            userType: 'hostel_provider',
          ),

          const SizedBox(height: 16),

          _buildUserTypeCard(
            title: 'Event Organizer',
            subtitle: 'I organize campus events, clubs, and activities',
            icon: Icons.event_outlined,
            userType: 'event_organizer',
          ),

          const SizedBox(height: 16),

          _buildUserTypeCard(
            title: 'Promoter',
            subtitle: 'I promote concerts, parties, and off-campus events',
            icon: Icons.music_note_outlined,
            userType: 'promoter',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Your Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us more about yourself',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          if (_selectedUserType == 'student') _buildStudentFields(),
          if (_selectedUserType == 'hostel_provider')
            _buildHostelProviderFields(),
          if (_selectedUserType == 'event_organizer')
            _buildEventOrganizerFields(),
          if (_selectedUserType == 'promoter') _buildPromoterFields(),
        ],
      ),
    );
  }

  Widget _buildProfilePictureStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Picture',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a photo to help others recognize you (Optional)',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                // Profile picture preview
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 3,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (_selectedImage != null)
                          ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        if (_isUploadingImage)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  _isUploadingImage
                      ? 'Uploading...'
                      : _selectedImage != null
                      ? 'Tap to change photo'
                      : 'Tap to add photo',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your information before creating your account',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          _buildReviewCard(
            title: 'Basic Information',
            items: {
              'Name': _nameController.text,
              'Email': _emailController.text,
              'Role': _getRoleDisplayName(_selectedUserType),
            },
          ),

          const SizedBox(height: 16),

          if (_selectedUserType == 'student') _buildStudentReviewCard(),
          if (_selectedUserType == 'hostel_provider')
            _buildHostelProviderReviewCard(),
          if (_selectedUserType == 'event_organizer')
            _buildEventOrganizerReviewCard(),
          if (_selectedUserType == 'promoter') _buildPromoterReviewCard(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          Expanded(
            child: ElevatedButton(
              onPressed:
                  _currentStep == _steps.length - 1
                      ? _handleCompleteSignUp
                      : _canProceedToNextStep()
                      ? _nextStep
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        _currentStep == _steps.length - 1
                            ? 'Create Account'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0: // Basic info
        return _nameController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty;
      case 1: // User type
        return _selectedUserType.isNotEmpty;
      case 2: // Role details
        return _validateRoleDetails();
      case 3: // Profile picture
        return true; // Optional step
      case 4: // Review
        return true;
      default:
        return false;
    }
  }

  bool _validateRoleDetails() {
    switch (_selectedUserType) {
      case 'student':
        return _campusController.text.isNotEmpty &&
            _yearController.text.isNotEmpty &&
            _courseController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty &&
            _selectedGender != null;
      case 'hostel_provider':
        return _businessNameController.text.isNotEmpty &&
            _primaryPhoneController.text.isNotEmpty &&
            _locationNameController.text.isNotEmpty &&
            _addressController.text.isNotEmpty;
      case 'event_organizer':
        return _organizationNameController.text.isNotEmpty &&
            _organizationTypeController.text.isNotEmpty &&
            _organizationDescriptionController.text.isNotEmpty;
      case 'promoter':
        return _agencyNameController.text.isNotEmpty &&
            _agencyTypeController.text.isNotEmpty &&
            _agencyDescriptionController.text.isNotEmpty;
      default:
        return false;
    }
  }

  // Helper methods for building form fields and cards
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String userType,
  }) {
    final isSelected = _selectedUserType == userType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = userType;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? AppTheme.primaryColor : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 24),
          ],
        ),
      ),
    );
  }

  // Role-specific field builders
  Widget _buildStudentFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _campusController,
          label: 'Campus/University',
          hint: 'Enter your campus',
          icon: Icons.school_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your campus';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _yearController,
          label: 'Year of Study',
          hint: 'e.g., Year 1, Year 2',
          icon: Icons.calendar_today_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your year of study';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _courseController,
          label: 'Course/Program',
          hint: 'Enter your course',
          icon: Icons.menu_book_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your course';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: 'Enter your phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Gender selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children:
                  ['Male', 'Female', 'Other'].map((gender) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGender = gender;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedGender == gender
                                    ? AppTheme.primaryColor.withOpacity(0.1)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  _selectedGender == gender
                                      ? AppTheme.primaryColor
                                      : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            gender,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  _selectedGender == gender
                                      ? AppTheme.primaryColor
                                      : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Interests selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interests (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    'Technology',
                    'Sports',
                    'Music',
                    'Art',
                    'Gaming',
                    'Reading',
                    'Travel',
                    'Food',
                    'Fashion',
                    'Photography',
                  ].map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests.remove(interest);
                          } else {
                            _selectedInterests.add(interest);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppTheme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHostelProviderFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _businessNameController,
          label: 'Business Name',
          hint: 'Enter your business name',
          icon: Icons.business_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your business name';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _primaryPhoneController,
          label: 'Primary Phone',
          hint: 'Enter your primary phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your primary phone';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _secondaryPhoneController,
          label: 'Secondary Phone (Optional)',
          hint: 'Enter secondary phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _locationNameController,
          label: 'Location Name',
          hint: 'e.g., Near Campus, Downtown',
          icon: Icons.location_on_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter location name';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _addressController,
          label: 'Address',
          hint: 'Enter full address',
          icon: Icons.home_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEventOrganizerFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _organizationNameController,
          label: 'Organization Name',
          hint: 'Enter organization name',
          icon: Icons.business_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter organization name';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _organizationTypeController,
          label: 'Organization Type',
          hint: 'e.g., Student Club, University Department',
          icon: Icons.category_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter organization type';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _organizationDescriptionController,
          label: 'Description',
          hint: 'Describe your organization',
          icon: Icons.description_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter organization description';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _organizationWebsiteController,
          label: 'Website (Optional)',
          hint: 'Enter website URL',
          icon: Icons.language_outlined,
          keyboardType: TextInputType.url,
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _organizationPhoneController,
          label: 'Phone (Optional)',
          hint: 'Enter contact phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildPromoterFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _agencyNameController,
          label: 'Agency/Promoter Name',
          hint: 'Enter agency name',
          icon: Icons.business_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter agency name';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _agencyTypeController,
          label: 'Agency Type',
          hint: 'e.g., Event Promotion, Music Agency',
          icon: Icons.category_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter agency type';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _agencyDescriptionController,
          label: 'Description',
          hint: 'Describe your agency',
          icon: Icons.description_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter agency description';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _agencyWebsiteController,
          label: 'Website (Optional)',
          hint: 'Enter website URL',
          icon: Icons.language_outlined,
          keyboardType: TextInputType.url,
        ),

        const SizedBox(height: 20),

        _buildTextField(
          controller: _agencyPhoneController,
          label: 'Phone (Optional)',
          hint: 'Enter contact phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  // Review card builders
  Widget _buildReviewCard({
    required String title,
    required Map<String, String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          ...items.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      '${entry.key}:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStudentReviewCard() {
    return _buildReviewCard(
      title: 'Student Information',
      items: {
        'Campus': _campusController.text,
        'Year': _yearController.text,
        'Course': _courseController.text,
        'Phone': _phoneController.text,
        'Gender': _selectedGender ?? 'Not specified',
        'Interests':
            _selectedInterests.isEmpty ? 'None' : _selectedInterests.join(', '),
      },
    );
  }

  Widget _buildHostelProviderReviewCard() {
    return _buildReviewCard(
      title: 'Business Information',
      items: {
        'Business Name': _businessNameController.text,
        'Primary Phone': _primaryPhoneController.text,
        'Secondary Phone':
            _secondaryPhoneController.text.isEmpty
                ? 'Not provided'
                : _secondaryPhoneController.text,
        'Location': _locationNameController.text,
        'Address': _addressController.text,
      },
    );
  }

  Widget _buildEventOrganizerReviewCard() {
    return _buildReviewCard(
      title: 'Organization Information',
      items: {
        'Organization': _organizationNameController.text,
        'Type': _organizationTypeController.text,
        'Description': _organizationDescriptionController.text,
        'Website':
            _organizationWebsiteController.text.isEmpty
                ? 'Not provided'
                : _organizationWebsiteController.text,
        'Phone':
            _organizationPhoneController.text.isEmpty
                ? 'Not provided'
                : _organizationPhoneController.text,
      },
    );
  }

  Widget _buildPromoterReviewCard() {
    return _buildReviewCard(
      title: 'Agency Information',
      items: {
        'Agency Name': _agencyNameController.text,
        'Type': _agencyTypeController.text,
        'Description': _agencyDescriptionController.text,
        'Website':
            _agencyWebsiteController.text.isEmpty
                ? 'Not provided'
                : _agencyWebsiteController.text,
        'Phone':
            _agencyPhoneController.text.isEmpty
                ? 'Not provided'
                : _agencyPhoneController.text,
      },
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImage != null)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Remove Photo'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                        _profileImageUrl = null;
                      });
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions
      if (await _requestPermissions(source)) {
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
            _isUploadingImage = false; // Don't upload immediately
          });

          print('DEBUG: Image selected: ${image.path}');
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        AppUtils.showErrorSnackBar(context, 'Failed to pick image: $e');
      }
    }
  }

  Future<bool> _requestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        _showPermissionDeniedDialog(
          'Camera permission is required to take photos.',
        );
        return false;
      }
      return status.isGranted;
    } else {
      // For gallery
      if (Platform.isAndroid) {
        // Try photos permission first (Android 13+)
        var photosStatus = await Permission.photos.status;
        if (photosStatus.isDenied) {
          photosStatus = await Permission.photos.request();
        }

        // Fallback to storage permission for older Android versions
        if (photosStatus.isDenied) {
          var storageStatus = await Permission.storage.status;
          if (storageStatus.isDenied) {
            storageStatus = await Permission.storage.request();
          }
          if (storageStatus.isDenied) {
            _showPermissionDeniedDialog(
              'Storage permission is required to access photos.',
            );
            return false;
          }
        }
        return photosStatus.isGranted ||
            (await Permission.storage.status).isGranted;
      } else {
        // iOS
        final status = await Permission.photos.request();
        if (status.isDenied) {
          _showPermissionDeniedDialog(
            'Photos permission is required to access your photo library.',
          );
          return false;
        }
        return status.isGranted;
      }
    }
  }

  void _showPermissionDeniedDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  String _getRoleDisplayName(String userType) {
    switch (userType) {
      case 'student':
        return 'Student';
      case 'hostel_provider':
        return 'Hostel Provider';
      case 'event_organizer':
        return 'Event Organizer';
      case 'promoter':
        return 'Promoter';
      default:
        return 'Unknown';
    }
  }
}

class SignUpStep {
  final String title;
  final String subtitle;
  final int stepNumber;

  SignUpStep({
    required this.title,
    required this.subtitle,
    required this.stepNumber,
  });
}

// Enterprise-Level Edit Profile Screen - Premium UI/UX
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/services/supabase_auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? currentProfile;
  final String userRole;

  const EditProfileScreen({
    super.key,
    required this.currentProfile,
    required this.userRole,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _profilePictureController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _profilePictureAnimation;

  // State Variables
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  File? _selectedProfileImage;
  int _currentSection = 0;

  // Form Focus Nodes
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _universityFocus = FocusNode();
  final _bioFocus = FocusNode();

  // Controllers for form fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _universityController;
  late TextEditingController _yearController;
  late TextEditingController _bioController;
  late TextEditingController _instagramController;
  late TextEditingController _linkedinController;
  late TextEditingController _websiteController;

  // Business-specific controllers
  late TextEditingController _businessNameController;
  late TextEditingController _organizationNameController;
  late TextEditingController _agencyNameController;
  late TextEditingController _locationNameController;
  late TextEditingController _organizationTypeController;
  late TextEditingController _agencyTypeController;

  // Privacy & Social Settings
  bool _isPhonePublic = true;
  bool _isEmailPublic = true;
  bool _showOnlineStatus = true;
  bool _allowMessages = true;
  bool _showActivityStatus = true;
  String _selectedGender = '';
  String _selectedYear = '';
  List<String> _selectedInterests = [];
  List<String> _selectedLanguages = [];

  // Data Lists
  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _yearOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Graduate',
    'Post Graduate',
    'PhD',
  ];

  final List<String> _interestOptions = [
    'Technology',
    'Sports',
    'Music',
    'Art',
    'Photography',
    'Gaming',
    'Cooking',
    'Travel',
    'Fitness',
    'Movies',
    'Reading',
    'Dancing',
    'Theater',
    'Science',
    'Business',
    'Volunteering',
    'Fashion',
    'Nature',
    'Politics',
    'History',
    'Languages',
    'Astronomy',
    'Psychology',
    'Philosophy',
    'Economics',
  ];

  final List<String> _languageOptions = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Portuguese',
    'Russian',
    'Italian',
    'Dutch',
    'Hindi',
    'Turkish',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeControllers();
    _addFocusListeners();
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

    _profilePictureController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    _profilePictureAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _profilePictureController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _profilePictureController.forward();
  }

  void _initializeControllers() {
    final profile = widget.currentProfile ?? {};

    _firstNameController = TextEditingController(
      text: profile['first_name'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: profile['last_name'] ?? '',
    );
    _emailController = TextEditingController(text: profile['email'] ?? '');
    _phoneController = TextEditingController(
      text: profile['phone_number'] ?? '',
    );
    _universityController = TextEditingController(
      text: profile['campus'] ?? '',
    );
    _yearController = TextEditingController(
      text: profile['year_of_study'] ?? '',
    );
    _bioController = TextEditingController(text: profile['bio'] ?? '');
    _instagramController = TextEditingController(
      text: profile['instagram'] ?? '',
    );
    _linkedinController = TextEditingController(
      text: profile['linkedin'] ?? '',
    );
    _websiteController = TextEditingController(text: profile['website'] ?? '');

    // Initialize business-specific controllers
    _businessNameController = TextEditingController(
      text: profile['business_name'] ?? '',
    );
    _organizationNameController = TextEditingController(
      text: profile['organization_name'] ?? '',
    );
    _agencyNameController = TextEditingController(
      text: profile['agency_name'] ?? '',
    );
    _locationNameController = TextEditingController(
      text: profile['location_name'] ?? '',
    );
    _organizationTypeController = TextEditingController(
      text: profile['organization_type'] ?? '',
    );
    _agencyTypeController = TextEditingController(
      text: profile['agency_type'] ?? '',
    );

    // Initialize settings
    _isPhonePublic = profile['phone_public'] ?? true;
    _isEmailPublic = profile['email_public'] ?? true;
    _showOnlineStatus = profile['show_online_status'] ?? true;
    _allowMessages = profile['allow_messages'] ?? true;
    _showActivityStatus = profile['show_activity_status'] ?? true;
    _selectedGender = profile['gender'] ?? '';
    _selectedYear = profile['year_of_study'] ?? '';

    // Handle arrays
    final interests = profile['interests'] as List<dynamic>? ?? [];
    _selectedInterests = interests.cast<String>();

    final languages = profile['languages'] as List<dynamic>? ?? [];
    _selectedLanguages = languages.cast<String>();
  }

  void _addFocusListeners() {
    final controllers = [
      _firstNameController,
      _lastNameController,
      _emailController,
      _phoneController,
      _universityController,
      _bioController,
      _instagramController,
      _linkedinController,
      _websiteController,
      _businessNameController,
      _organizationNameController,
      _agencyNameController,
      _locationNameController,
      _organizationTypeController,
      _agencyTypeController,
    ];

    for (var controller in controllers) {
      controller.addListener(() {
        if (!_hasUnsavedChanges) {
          setState(() {
            _hasUnsavedChanges = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _profilePictureController.dispose();
    _scrollController.dispose();

    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _yearController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();

    _businessNameController.dispose();
    _organizationNameController.dispose();
    _agencyNameController.dispose();
    _locationNameController.dispose();
    _organizationTypeController.dispose();
    _agencyTypeController.dispose();

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _universityFocus.dispose();
    _bioFocus.dispose();

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
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
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
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                _hasUnsavedChanges
                    ? AppTheme.primaryColor
                    : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child:
                _isLoading
                    ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _hasUnsavedChanges
                              ? Colors.white
                              : AppTheme.primaryColor,
                        ),
                      ),
                    )
                    : Text(
                      'Save',
                      style: TextStyle(
                        color:
                            _hasUnsavedChanges
                                ? Colors.white
                                : AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.primaryColor.withOpacity(0.6),
                AppTheme.secondaryColor.withOpacity(0.4),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                _buildProfilePictureSection(),
                const SizedBox(height: 16),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make your profile shine 👌',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return ScaleTransition(
      scale: _profilePictureAnimation,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _buildProfilePicture(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _showImagePickerOptions();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    if (_selectedProfileImage != null) {
      return ClipOval(
        child: Image.file(
          _selectedProfileImage!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    final profileImageUrl = widget.currentProfile?['profile_image_url'];
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          profileImageUrl,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultProfilePicture();
          },
        ),
      );
    }

    return _buildDefaultProfilePicture();
  }

  Widget _buildDefaultProfilePicture() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 60,
        color: AppTheme.primaryColor.withOpacity(0.7),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildSectionNavigator(),
            const SizedBox(height: 20),
            _buildCurrentSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionNavigator() {
    final sections = [
      {'title': 'Basic', 'icon': Icons.person_outline_rounded},
      {'title': 'Academic', 'icon': Icons.school_rounded},
      {'title': 'Social', 'icon': Icons.share_rounded},
      {'title': 'Business', 'icon': Icons.business_rounded},
      {'title': 'Privacy', 'icon': Icons.security_rounded},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children:
            sections.asMap().entries.map((entry) {
              final index = entry.key;
              final section = entry.value;
              final isSelected = _currentSection == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _currentSection = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          section['icon'] as IconData,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section['title'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentSection) {
      case 0:
        return _buildBasicInfoSection();
      case 1:
        return _buildAcademicSection();
      case 2:
        return _buildSocialSection();
      case 3:
        return _buildBusinessSection();
      case 4:
        return _buildPrivacySection();
      default:
        return _buildBasicInfoSection();
    }
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Personal Information',
          icon: Icons.person_outline_rounded,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildPremiumTextField(
                    controller: _firstNameController,
                    focusNode: _firstNameFocus,
                    label: 'First Name',
                    prefixIcon: Icons.badge_outlined,
                    validator:
                        (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPremiumTextField(
                    controller: _lastNameController,
                    focusNode: _lastNameFocus,
                    label: 'Last Name',
                    prefixIcon: Icons.badge_outlined,
                    validator:
                        (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPremiumTextField(
              controller: _emailController,
              focusNode: _emailFocus,
              label: 'Email Address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty == true) return 'Email is required';
                if (!AppUtils.isValidEmail(value!))
                  return 'Invalid email format';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildPremiumTextField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              label: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              value: _selectedGender,
              label: 'Gender',
              icon: Icons.person_outline_rounded,
              items: _genderOptions,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value ?? '';
                  _hasUnsavedChanges = true;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'About Me',
          icon: Icons.info_outline_rounded,
          children: [
            _buildPremiumTextField(
              controller: _bioController,
              focusNode: _bioFocus,
              label: 'Bio',
              prefixIcon: Icons.edit_note_rounded,
              hintText: _getBioHint(),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 20),
            _buildInterestsSelector(),
            const SizedBox(height: 20),
            _buildLanguagesSelector(),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicSection() {
    if (widget.userRole != 'Student') {
      return _buildEmptySection(
        'Academic Information',
        'Academic details are only available for students.',
        Icons.school_outlined,
      );
    }

    return _buildSectionCard(
      title: 'Academic Information',
      icon: Icons.school_rounded,
      children: [
        _buildPremiumTextField(
          controller: _universityController,
          focusNode: _universityFocus,
          label: 'University/College',
          prefixIcon: Icons.account_balance_rounded,
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          value: _selectedYear,
          label: 'Year of Study',
          icon: Icons.calendar_today_rounded,
          items: _yearOptions,
          onChanged: (value) {
            setState(() {
              _selectedYear = value ?? '';
              _hasUnsavedChanges = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    return _buildSectionCard(
      title: 'Social Media & Links',
      icon: Icons.share_rounded,
      children: [
        _buildPremiumTextField(
          controller: _instagramController,
          label: 'Instagram Username',
          prefixIcon: Icons.camera_alt_rounded,
          hintText: '@username',
          prefixText: 'instagram.com/',
        ),
        const SizedBox(height: 20),
        _buildPremiumTextField(
          controller: _linkedinController,
          label: 'LinkedIn Profile',
          prefixIcon: Icons.work_outline_rounded,
          hintText: 'your-profile',
          prefixText: 'linkedin.com/in/',
        ),
        const SizedBox(height: 20),
        _buildPremiumTextField(
          controller: _websiteController,
          label: 'Website/Portfolio',
          prefixIcon: Icons.link_rounded,
          hintText: 'https://yourwebsite.com',
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildBusinessSection() {
    if (widget.userRole == 'Student') {
      return _buildEmptySection(
        'Business Information',
        'Business details are only available for business providers.',
        Icons.business_outlined,
      );
    }

    return Column(
      children: [
        _buildSectionCard(
          title: 'Business Information',
          icon: Icons.business_rounded,
          children: [
            if (widget.userRole == 'Hostel Provider') ...[
              _buildPremiumTextField(
                controller: _businessNameController,
                label: 'Business/Hostel Name',
                prefixIcon: Icons.home_rounded,
                validator:
                    (value) =>
                        value?.isEmpty == true
                            ? 'Business name is required'
                            : null,
              ),
              const SizedBox(height: 20),
              _buildPremiumTextField(
                controller: _locationNameController,
                label: 'Location/Address',
                prefixIcon: Icons.location_on_rounded,
                hintText: 'Enter your hostel location',
              ),
            ],
            if (widget.userRole == 'Event Organizer') ...[
              _buildPremiumTextField(
                controller: _organizationNameController,
                label: 'Organization Name',
                prefixIcon: Icons.account_balance_rounded,
                validator:
                    (value) =>
                        value?.isEmpty == true
                            ? 'Organization name is required'
                            : null,
              ),
              const SizedBox(height: 20),
              _buildPremiumTextField(
                controller: _organizationTypeController,
                label: 'Organization Type',
                prefixIcon: Icons.category_rounded,
                hintText: 'e.g., Student Club, NGO, Company',
              ),
            ],
            if (widget.userRole == 'Promoter') ...[
              _buildPremiumTextField(
                controller: _agencyNameController,
                label: 'Agency Name',
                prefixIcon: Icons.music_note_rounded,
                validator:
                    (value) =>
                        value?.isEmpty == true
                            ? 'Agency name is required'
                            : null,
              ),
              const SizedBox(height: 20),
              _buildPremiumTextField(
                controller: _agencyTypeController,
                label: 'Agency Type',
                prefixIcon: Icons.category_rounded,
                hintText: 'e.g., Event Promotion, Marketing Agency',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSectionCard(
      title: 'Privacy & Visibility Settings',
      icon: Icons.security_rounded,
      children: [
        _buildPrivacyToggle(
          title: 'Show Phone Number',
          subtitle: 'Allow others to see your phone number',
          value: _isPhonePublic,
          onChanged: (value) {
            setState(() {
              _isPhonePublic = value;
              _hasUnsavedChanges = true;
            });
          },
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: 16),
        _buildPrivacyToggle(
          title: 'Show Email Address',
          subtitle: 'Allow others to see your email',
          value: _isEmailPublic,
          onChanged: (value) {
            setState(() {
              _isEmailPublic = value;
              _hasUnsavedChanges = true;
            });
          },
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _buildPrivacyToggle(
          title: 'Online Status',
          subtitle: 'Show when you\'re online',
          value: _showOnlineStatus,
          onChanged: (value) {
            setState(() {
              _showOnlineStatus = value;
              _hasUnsavedChanges = true;
            });
          },
          icon: Icons.circle,
        ),
        const SizedBox(height: 16),
        _buildPrivacyToggle(
          title: 'Allow Messages',
          subtitle: 'Let people send you direct messages',
          value: _allowMessages,
          onChanged: (value) {
            setState(() {
              _allowMessages = value;
              _hasUnsavedChanges = true;
            });
          },
          icon: Icons.message_outlined,
        ),
        const SizedBox(height: 16),
        _buildPrivacyToggle(
          title: 'Activity Status',
          subtitle: 'Show your recent activity',
          value: _showActivityStatus,
          onChanged: (value) {
            setState(() {
              _showActivityStatus = value;
              _hasUnsavedChanges = true;
            });
          },
          icon: Icons.access_time_rounded,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    String? hintText,
    IconData? prefixIcon,
    String? prefixText,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[800],
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixText: prefixText,
        prefixIcon:
            prefixIcon != null
                ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(prefixIcon, color: Colors.grey[600], size: 20),
                )
                : null,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
        counterStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
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
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, color: Colors.grey[600], size: 20),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInterestsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.favorite_outline_rounded,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Interests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _interestOptions.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (isSelected) {
                        _selectedInterests.remove(interest);
                      } else {
                        _selectedInterests.add(interest);
                      }
                      _hasUnsavedChanges = true;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppTheme.primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguagesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.language_rounded, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Languages',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _languageOptions.map((language) {
                final isSelected = _selectedLanguages.contains(language);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (isSelected) {
                        _selectedLanguages.remove(language);
                      } else {
                        _selectedLanguages.add(language);
                      }
                      _hasUnsavedChanges = true;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.secondaryColor
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppTheme.secondaryColor
                                : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      language,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacyToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  value
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? AppTheme.primaryColor : Colors.grey[500],
              size: 18,
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
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeColor: AppTheme.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey[400], size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Change Profile Picture',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildImageOption(
                    icon: Icons.camera_alt_rounded,
                    title: 'Take Photo',
                    subtitle: 'Use camera to take a new photo',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library_rounded,
                    title: 'Choose from Gallery',
                    subtitle: 'Select an existing photo',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  if (_selectedProfileImage != null ||
                      widget.currentProfile?['profile_image_url'] != null)
                    _buildImageOption(
                      icon: Icons.delete_outline_rounded,
                      title: 'Remove Photo',
                      subtitle: 'Use default profile picture',
                      onTap: _removeProfilePicture,
                      isDestructive: true,
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isDestructive
                  ? Colors.red.withOpacity(0.1)
                  : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppTheme.primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedProfileImage = File(pickedFile.path);
          _hasUnsavedChanges = true;
        });

        // Animate profile picture update
        _profilePictureController.reset();
        _profilePictureController.forward();

        AppUtils.showSuccessSnackBar(
          context,
          'Profile picture updated! Don\'t forget to save.',
        );
      }
    } catch (e) {
      AppUtils.showErrorSnackBar(
        context,
        'Failed to pick image. Please try again.',
      );
    }
  }

  void _removeProfilePicture() {
    setState(() {
      _selectedProfileImage = null;
      _hasUnsavedChanges = true;
    });

    AppUtils.showSuccessSnackBar(
      context,
      'Profile picture removed! Don\'t forget to save.',
    );
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

  String _getBioHint() {
    switch (widget.userRole) {
      case 'Student':
        return 'Tell others about yourself, your interests, and what you\'re looking for in campus life.';
      case 'Hostel Provider':
        return 'Describe your accommodation, amenities, and what makes your place special.';
      case 'Event Organizer':
        return 'Share information about your organization and the events you create.';
      case 'Promoter':
        return 'Tell people about your agency and the events you promote.';
      default:
        return 'Write something interesting about yourself...';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      AppUtils.showErrorSnackBar(
        context,
        'Please fill in all required fields correctly.',
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

      // Prepare update data
      final updateData = <String, dynamic>{
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'gender': _selectedGender,
        'interests': _selectedInterests,
        'languages': _selectedLanguages,
        'instagram': _instagramController.text.trim(),
        'linkedin': _linkedinController.text.trim(),
        'website': _websiteController.text.trim(),
        'phone_public': _isPhonePublic,
        'email_public': _isEmailPublic,
        'show_online_status': _showOnlineStatus,
        'allow_messages': _allowMessages,
        'show_activity_status': _showActivityStatus,
      };

      // Add role-specific fields
      if (widget.userRole == 'Student') {
        updateData['campus'] = _universityController.text.trim();
        updateData['year_of_study'] = _selectedYear;
      } else if (widget.userRole == 'Hostel Provider') {
        updateData['business_name'] = _businessNameController.text.trim();
        updateData['location_name'] = _locationNameController.text.trim();
      } else if (widget.userRole == 'Event Organizer') {
        updateData['organization_name'] =
            _organizationNameController.text.trim();
        updateData['organization_type'] =
            _organizationTypeController.text.trim();
      } else if (widget.userRole == 'Promoter') {
        updateData['agency_name'] = _agencyNameController.text.trim();
        updateData['agency_type'] = _agencyTypeController.text.trim();
      }

      // TODO: Handle profile image upload to Supabase storage
      if (_selectedProfileImage != null) {
        // This would upload the image and get the URL
        // updateData['profile_image_url'] = uploadedImageUrl;
      }

      // Update profile
      await _authService.updateUserProfile(user.id, updateData);

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
        });

        // Show success with haptic feedback
        HapticFeedback.heavyImpact();

        AppUtils.showSuccessSnackBar(
          context,
          'Profile updated successfully! 🎉',
        );

        // Navigate back with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        AppUtils.showErrorSnackBar(
          context,
          'Failed to update profile. Please try again.',
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

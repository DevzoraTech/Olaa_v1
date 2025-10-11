// Presentation Layer - Profile Header Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../core/services/verification_service.dart';
import 'package:pulse_campus/Features/verification/domain/models/verification_models.dart';
import 'package:pulse_campus/Features/verification/presentation/screens/verification_submission_screen.dart';
import '../screens/edit_bio_screen.dart';
import '../screens/edit_profile_screen.dart';

class ProfileHeader extends StatefulWidget {
  final String userRole;

  const ProfileHeader({super.key, required this.userRole});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  final VerificationService _verificationService = VerificationService.instance;
  Map<String, dynamic>? _userProfile;
  VerificationSubmission? _verificationSubmission;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _authService.currentUser;
      print('DEBUG: Loading profile for user: ${user?.id}');

      if (user != null) {
        // Load profile and verification data in parallel
        final futures = await Future.wait([
          _authService.getUserProfile(user.id),
          _verificationService.getUserVerificationSubmission(user.id),
        ]);

        final profile = futures[0] as Map<String, dynamic>?;
        final verificationSubmission = futures[1] as VerificationSubmission?;

        print('DEBUG: Profile loaded: $profile');
        print('DEBUG: Verification submission: $verificationSubmission');

        if (mounted) {
          setState(() {
            _userProfile = profile;
            _verificationSubmission = verificationSubmission;
            _isLoading = false;
          });
        }
      } else {
        print('DEBUG: No current user found');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
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
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          // Profile Picture and Basic Info
          Row(
            children: [
              // Profile Picture
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryColor, width: 3),
                ),
                child: _getProfilePicture(),
              ),
              const SizedBox(width: 16),

              // Basic Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getProfileName(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getProfileSubtitle(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: _getVerificationColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getVerificationStatus(),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getVerificationColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_shouldShowVerificationButton()) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _navigateToVerification,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getVerificationButtonText(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Edit Button
              GestureDetector(
                onTap: () {
                  _navigateToEditProfile();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bio/Description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getProfileBio(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _navigateToEditBio();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getProfilePicture() {
    final imageUrl = _userProfile?['profile_image_url'];
    print('DEBUG: Profile image URL: $imageUrl');

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('DEBUG: Image failed to load: $error');
            return Icon(
              _getProfileIcon(),
              color: AppTheme.primaryColor,
              size: 40,
            );
          },
        ),
      );
    }
    return Icon(_getProfileIcon(), color: AppTheme.primaryColor, size: 40);
  }

  IconData _getProfileIcon() {
    final role = _userProfile?['primary_role'] ?? widget.userRole;
    switch (role) {
      case 'Student':
        return Icons.person;
      case 'Hostel Provider':
        return Icons.home;
      case 'Event Organizer':
        return Icons.event;
      case 'Promoter':
        return Icons.music_note;
      default:
        return Icons.person;
    }
  }

  String _getProfileName() {
    if (_userProfile == null) return 'Loading...';

    final role = _userProfile!['primary_role'] ?? widget.userRole;
    print('DEBUG: Getting profile name for role: $role');

    switch (role) {
      case 'Student':
        final firstName = _userProfile!['first_name'] ?? '';
        final lastName = _userProfile!['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        print('DEBUG: Student name: $fullName');
        return fullName.isNotEmpty ? fullName : 'Student';
      case 'Hostel Provider':
        final firstName = _userProfile!['first_name'] ?? '';
        final lastName = _userProfile!['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final businessName = _userProfile!['business_name'] ?? '';

        if (fullName.isNotEmpty && businessName.isNotEmpty) {
          return '$fullName ($businessName)';
        } else if (fullName.isNotEmpty) {
          return fullName;
        } else if (businessName.isNotEmpty) {
          return businessName;
        }
        return 'Hostel Provider';
      case 'Event Organizer':
        final firstName = _userProfile!['first_name'] ?? '';
        final lastName = _userProfile!['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final orgName = _userProfile!['organization_name'] ?? '';

        if (fullName.isNotEmpty && orgName.isNotEmpty) {
          return '$fullName ($orgName)';
        } else if (fullName.isNotEmpty) {
          return fullName;
        } else if (orgName.isNotEmpty) {
          return orgName;
        }
        return 'Event Organizer';
      case 'Promoter':
        final firstName = _userProfile!['first_name'] ?? '';
        final lastName = _userProfile!['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final agencyName = _userProfile!['agency_name'] ?? '';

        if (fullName.isNotEmpty && agencyName.isNotEmpty) {
          return '$fullName ($agencyName)';
        } else if (fullName.isNotEmpty) {
          return fullName;
        } else if (agencyName.isNotEmpty) {
          return agencyName;
        }
        return 'Promoter';
      default:
        final firstName = _userProfile!['first_name'] ?? '';
        final lastName = _userProfile!['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        return fullName.isNotEmpty ? fullName : 'User';
    }
  }

  String _getProfileSubtitle() {
    if (_userProfile == null) return 'Loading...';

    final role = _userProfile!['primary_role'] ?? widget.userRole;
    print('DEBUG: Getting profile subtitle for role: $role');

    switch (role) {
      case 'Student':
        final course = _userProfile!['course'] ?? '';
        final year = _userProfile!['year_of_study'] ?? '';
        final campus = _userProfile!['campus'] ?? '';

        List<String> parts = [];
        if (course.isNotEmpty) parts.add(course);
        if (year.isNotEmpty) parts.add('Year $year');
        if (campus.isNotEmpty) parts.add(campus);

        final subtitle = parts.join(' • ');
        print('DEBUG: Student subtitle: $subtitle');
        return subtitle.isNotEmpty ? subtitle : 'Student';
      case 'Hostel Provider':
        final location = _userProfile!['location_name'] ?? '';
        final phone = _userProfile!['phone_number'] ?? '';
        final email = _userProfile!['email'] ?? '';

        List<String> parts = ['Hostel Provider'];
        if (location.isNotEmpty) parts.add(location);
        if (phone.isNotEmpty) parts.add('📞 $phone');
        if (email.isNotEmpty) parts.add('✉️ $email');

        final subtitle = parts.join(' • ');
        print('DEBUG: Hostel Provider subtitle: $subtitle');
        return subtitle;
      case 'Event Organizer':
        final orgType = _userProfile!['organization_type'] ?? '';
        final phone = _userProfile!['phone_number'] ?? '';
        final email = _userProfile!['email'] ?? '';

        List<String> parts = ['Event Organizer'];
        if (orgType.isNotEmpty) parts.add(orgType);
        if (phone.isNotEmpty) parts.add('📞 $phone');
        if (email.isNotEmpty) parts.add('✉️ $email');

        final subtitle = parts.join(' • ');
        print('DEBUG: Event Organizer subtitle: $subtitle');
        return subtitle;
      case 'Promoter':
        final agencyType = _userProfile!['agency_type'] ?? '';
        final phone = _userProfile!['phone_number'] ?? '';
        final email = _userProfile!['email'] ?? '';

        List<String> parts = ['Promoter'];
        if (agencyType.isNotEmpty) parts.add(agencyType);
        if (phone.isNotEmpty) parts.add('📞 $phone');
        if (email.isNotEmpty) parts.add('✉️ $email');

        final subtitle = parts.join(' • ');
        print('DEBUG: Promoter subtitle: $subtitle');
        return subtitle;
      default:
        return role;
    }
  }

  String _getVerificationStatus() {
    if (_userProfile == null) return 'Loading...';

    // Check if user is verified in profile
    final isVerified = _userProfile!['is_verified'] ?? false;
    if (isVerified) {
      return 'Verified';
    }

    // Check verification submission status
    if (_verificationSubmission != null) {
      switch (_verificationSubmission!.status) {
        case VerificationStatus.pending:
          return 'Pending Review';
        case VerificationStatus.underReview:
          return 'Under Review';
        case VerificationStatus.approved:
          return 'Verified';
        case VerificationStatus.rejected:
          return 'Rejected';
      }
    }

    return 'Not Verified';
  }

  String _getProfileBio() {
    if (_userProfile == null) return 'Loading...';

    final bio = _userProfile!['bio'];
    if (bio != null && bio.isNotEmpty) {
      return bio;
    }

    // Fallback bio based on role
    final role = _userProfile!['primary_role'] ?? widget.userRole;
    switch (role) {
      case 'Student':
        return 'Tell us about yourself, your interests, and what you\'re looking for in a roommate.';
      case 'Hostel Provider':
        return 'Describe your hostel, amenities, and what makes your accommodation special.';
      case 'Event Organizer':
        return 'Share information about your organization and the events you organize.';
      case 'Promoter':
        return 'Tell us about your agency and the events you promote.';
      default:
        return 'Add a bio to tell others about yourself.';
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfileScreen(
              currentProfile: _userProfile,
              userRole: widget.userRole,
            ),
      ),
    );

    // Reload profile if changes were made
    if (result == true) {
      _loadUserProfile();
    }
  }

  void _navigateToEditBio() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditBioScreen(
              currentBio: _getProfileBio(),
              userRole: _userProfile?['primary_role'] ?? widget.userRole,
            ),
      ),
    );

    if (result != null) {
      // Refresh the profile data
      await _loadUserProfile();
    }
  }

  // Public method to refresh profile data
  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  Color _getVerificationColor() {
    if (_userProfile == null) return Colors.grey;

    // Check if user is verified in profile
    final isVerified = _userProfile!['is_verified'] ?? false;
    if (isVerified) {
      return Colors.green;
    }

    // Check verification submission status
    if (_verificationSubmission != null) {
      switch (_verificationSubmission!.status) {
        case VerificationStatus.pending:
          return Colors.orange;
        case VerificationStatus.underReview:
          return Colors.blue;
        case VerificationStatus.approved:
          return Colors.green;
        case VerificationStatus.rejected:
          return Colors.red;
      }
    }

    return Colors.grey;
  }

  bool _shouldShowVerificationButton() {
    if (_userProfile == null) return false;

    // Don't show if already verified
    final isVerified = _userProfile!['is_verified'] ?? false;
    if (isVerified) return false;

    // Show if no submission or submission is rejected/expired
    if (_verificationSubmission == null) return true;
    if (_verificationSubmission!.isRejected ||
        _verificationSubmission!.isExpired) {
      return true;
    }

    return false;
  }

  String _getVerificationButtonText() {
    final role = _userProfile?['primary_role'] ?? widget.userRole;
    if (role == 'Student') {
      return 'Verify for Marketplace';
    }
    return 'Verify';
  }

  void _navigateToVerification() async {
    final user = _authService.currentUser;
    if (user == null) return;

    // Check if user can submit verification
    final canSubmit = await _verificationService.canSubmitVerification(user.id);
    if (!canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already have a pending verification submission'),
        ),
      );
      return;
    }

    // Get submission type from user role
    final role = _userProfile?['primary_role'] ?? widget.userRole;
    VerificationSubmissionType submissionType;
    switch (role) {
      case 'Student':
        submissionType = VerificationSubmissionType.student;
        break;
      case 'Hostel Provider':
        submissionType = VerificationSubmissionType.hostelProvider;
        break;
      case 'Event Organizer':
        submissionType = VerificationSubmissionType.eventOrganizer;
        break;
      case 'Promoter':
        submissionType = VerificationSubmissionType.promoter;
        break;
      default:
        submissionType = VerificationSubmissionType.student;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                VerificationSubmissionScreen(submissionType: submissionType),
      ),
    );

    if (result == true) {
      // Refresh the profile data
      await _loadUserProfile();
    }
  }
}

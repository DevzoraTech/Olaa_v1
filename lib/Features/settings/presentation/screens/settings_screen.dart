// Presentation Layer - Settings Screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/role_management_section.dart';
import '../widgets/account_section.dart';
import '../widgets/notifications_section.dart';
import '../widgets/privacy_section.dart';
import '../widgets/app_preferences_section.dart';
import '../widgets/support_section.dart';
import '../widgets/legal_section.dart';
import '../widgets/about_section.dart';
import '/Features/profile/presentation/screens/edit_profile_screen.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/theme/app_theme.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userRole = 'Student'; // This would come from user data
  bool _isDarkMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _twoFactorAuth = false;
  bool _doNotDisturb = false;
  bool _wifiOnlyDownloads = true;

  final SupabaseAuthService _authService = SupabaseAuthService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey[700],
            size: 20,
          ),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Account Section
            AccountSection(
              userRole: _userRole,
              onEditProfile: () async {
                await _navigateToEditProfile();
              },
              onChangeEmail: () {
                // TODO: Navigate to change email
              },
              onChangePassword: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
              onDeactivateAccount: () {
                _showDeactivateDialog();
              },
            ),

            // Role & Access Section
            RoleManagementSection(
              currentRole: _userRole,
              onRoleChanged: (newRole) {
                setState(() {
                  _userRole = newRole;
                });
              },
              onVerificationPressed: () {
                // TODO: Navigate to verification
              },
            ),

            // Notifications Section
            NotificationsSection(
              pushNotifications: _pushNotifications,
              emailNotifications: _emailNotifications,
              onPushNotificationsChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
              onEmailNotificationsChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),

            // Privacy & Security Section
            PrivacySection(
              twoFactorAuth: _twoFactorAuth,
              doNotDisturb: _doNotDisturb,
              onTwoFactorAuthChanged: (value) {
                setState(() {
                  _twoFactorAuth = value;
                });
              },
              onDoNotDisturbChanged: (value) {
                setState(() {
                  _doNotDisturb = value;
                });
              },
              onBlockedUsersPressed: () {
                // TODO: Navigate to blocked users
              },
            ),

            // App Preferences Section
            AppPreferencesSection(
              isDarkMode: _isDarkMode,
              wifiOnlyDownloads: _wifiOnlyDownloads,
              onThemeChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
              onWifiOnlyChanged: (value) {
                setState(() {
                  _wifiOnlyDownloads = value;
                });
              },
              onLanguagePressed: () {
                // TODO: Navigate to language selection
              },
            ),

            // Support Section
            SupportSection(
              onHelpCenterPressed: () {
                // TODO: Navigate to help center
              },
              onContactSupportPressed: () {
                // TODO: Navigate to contact support
              },
              onFeedbackPressed: () {
                // TODO: Navigate to feedback
              },
              onReportBugPressed: () {
                // TODO: Navigate to report bug
              },
            ),

            // Legal Section
            LegalSection(
              onTermsPressed: () {
                // TODO: Navigate to terms
              },
              onPrivacyPressed: () {
                // TODO: Navigate to privacy policy
              },
              onGuidelinesPressed: () {
                // TODO: Navigate to community guidelines
              },
            ),

            // About Section
            AboutSection(
              onRateAppPressed: () {
                // TODO: Rate app
              },
              onShareAppPressed: () {
                // TODO: Share app
              },
            ),

            // Logout Section
            _buildLogoutSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Deactivate Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            content: Text(
              'Are you sure you want to deactivate your account? This action can be reversed by logging in again.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement deactivate account
                },
                child: Text(
                  'Deactivate',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _navigateToEditProfile() async {
    try {
      // Get current user profile data
      final user = _authService.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to edit your profile'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get user profile data
      final profileData = await _authService.getUserProfile(user.id);

      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => EditProfileScreen(
                  currentProfile: profileData,
                  userRole: _userRole,
                ),
          ),
        );

        // If profile was updated successfully, refresh the settings screen
        if (result == true) {
          setState(() {
            // Refresh any profile-dependent data here if needed
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildLogoutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your account session and security',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),

            // Sign Out Button
            _buildLogoutButton(),

            const SizedBox(height: 12),

            // Session Info
            FutureBuilder<Map<String, String?>>(
              future: SessionManager.instance.getUserInfo(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final lastLogin = snapshot.data?['lastLogin'];
                  if (lastLogin != null) {
                    final loginTime = DateTime.parse(lastLogin);
                    final timeAgo = _getTimeAgo(loginTime);

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Last login: $timeAgo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.red[200]!, width: 1.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20, color: Colors.red[700]),
            const SizedBox(width: 12),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            contentPadding: const EdgeInsets.all(28),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.orange[600],
                    size: 36,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  'Are you sure you want to sign out? You\'ll need to enter your credentials again to access your account.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Logout Button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _handleLogout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Close dialog first
      Navigator.pop(context);

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Signing out...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );

      // Perform logout
      await SessionManager.instance.logout();

      // Haptic feedback
      HapticFeedback.mediumImpact();

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Navigate to login screen and clear all routes
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text(
                  'Successfully signed out',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to sign out: ${e.toString()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

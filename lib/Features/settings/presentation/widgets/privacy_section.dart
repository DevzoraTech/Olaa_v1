// Presentation Layer - Privacy Section Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'settings_section.dart';
import 'settings_item.dart';
import 'settings_toggle_item.dart';

class PrivacySection extends StatelessWidget {
  final bool twoFactorAuth;
  final bool doNotDisturb;
  final Function(bool) onTwoFactorAuthChanged;
  final Function(bool) onDoNotDisturbChanged;
  final VoidCallback onBlockedUsersPressed;

  const PrivacySection({
    super.key,
    required this.twoFactorAuth,
    required this.doNotDisturb,
    required this.onTwoFactorAuthChanged,
    required this.onDoNotDisturbChanged,
    required this.onBlockedUsersPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Privacy & Security',
      icon: Icons.security_outlined,
      children: [
        SettingsItem(
          icon: Icons.visibility_outlined,
          title: 'Profile Visibility',
          subtitle: 'Control who can see your profile',
          onTap: () => _showProfileVisibilityDialog(context),
        ),
        SettingsItem(
          icon: Icons.block_outlined,
          title: 'Blocked / Reported Users',
          subtitle: 'Manage blocked and reported users',
          onTap: onBlockedUsersPressed,
        ),
        SettingsToggleItem(
          icon: Icons.security_outlined,
          title: 'Two-Factor Authentication',
          subtitle: 'Add an extra layer of security to your account',
          value: twoFactorAuth,
          onChanged: onTwoFactorAuthChanged,
        ),
        SettingsToggleItem(
          icon: Icons.do_not_disturb_outlined,
          title: 'Do Not Disturb',
          subtitle: 'Silence notifications during night hours',
          value: doNotDisturb,
          onChanged: onDoNotDisturbChanged,
        ),
      ],
    );
  }

  void _showProfileVisibilityDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Profile Visibility',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                // Visibility Options
                _buildVisibilityOption(
                  context,
                  'Public',
                  'Anyone can see your profile',
                  Icons.public_outlined,
                  Colors.green[600]!,
                ),
                _buildVisibilityOption(
                  context,
                  'Campus Only',
                  'Only students from your campus can see your profile',
                  Icons.school_outlined,
                  Colors.blue[600]!,
                ),
                _buildVisibilityOption(
                  context,
                  'Private',
                  'Only people you approve can see your profile',
                  Icons.lock_outlined,
                  Colors.orange[600]!,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildVisibilityOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing:
            title ==
                    'Campus Only' // Default selection
                ? Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 20,
                )
                : null,
        onTap: () {
          Navigator.pop(context);
          // TODO: Update profile visibility
        },
      ),
    );
  }
}

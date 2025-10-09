// Presentation Layer - Account Section Widget
import 'package:flutter/material.dart';
import 'settings_section.dart';
import 'settings_item.dart';

class AccountSection extends StatelessWidget {
  final String userRole;
  final VoidCallback onEditProfile;
  final VoidCallback onChangeEmail;
  final VoidCallback onChangePassword;
  final VoidCallback onDeactivateAccount;

  const AccountSection({
    super.key,
    required this.userRole,
    required this.onEditProfile,
    required this.onChangeEmail,
    required this.onChangePassword,
    required this.onDeactivateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Account',
      icon: Icons.person_outline,
      children: [
        SettingsItem(
          icon: Icons.edit_outlined,
          title: 'Edit Profile',
          subtitle: 'Update your name, picture, bio, and campus info',
          onTap: onEditProfile,
        ),
        // Hide Change Email/Phone for students
        if (userRole != 'Student')
          SettingsItem(
            icon: Icons.email_outlined,
            title: 'Change Email / Phone',
            subtitle: 'Update your contact information',
            onTap: onChangeEmail,
          ),
        SettingsItem(
          icon: Icons.lock_outline,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: onChangePassword,
        ),
        SettingsItem(
          icon: Icons.delete_outline,
          title: 'Deactivate / Delete Account',
          subtitle: 'Permanently remove your account',
          onTap: onDeactivateAccount,
          isDestructive: true,
        ),
      ],
    );
  }
}

// Presentation Layer - Notifications Section Widget
import 'package:flutter/material.dart';
import 'settings_section.dart';
import 'settings_item.dart';
import 'settings_toggle_item.dart';

class NotificationsSection extends StatelessWidget {
  final bool pushNotifications;
  final bool emailNotifications;
  final Function(bool) onPushNotificationsChanged;
  final Function(bool) onEmailNotificationsChanged;

  const NotificationsSection({
    super.key,
    required this.pushNotifications,
    required this.emailNotifications,
    required this.onPushNotificationsChanged,
    required this.onEmailNotificationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      children: [
        SettingsToggleItem(
          icon: Icons.notifications_active_outlined,
          title: 'Push Notifications',
          subtitle: 'Get notified about roommate updates, events, and messages',
          value: pushNotifications,
          onChanged: onPushNotificationsChanged,
        ),
        SettingsToggleItem(
          icon: Icons.email_outlined,
          title: 'Email Notifications',
          subtitle: 'Receive email updates about important activities',
          value: emailNotifications,
          onChanged: onEmailNotificationsChanged,
        ),
        SettingsItem(
          icon: Icons.settings_outlined,
          title: 'Notification Preferences',
          subtitle: 'Customize notification types and timing',
          onTap: () {
            // TODO: Navigate to detailed notification settings
          },
        ),
      ],
    );
  }
}

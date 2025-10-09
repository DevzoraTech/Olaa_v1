// Presentation Layer - Support Section Widget
import 'package:flutter/material.dart';
import 'settings_section.dart';
import 'settings_item.dart';

class SupportSection extends StatelessWidget {
  final VoidCallback onHelpCenterPressed;
  final VoidCallback onContactSupportPressed;
  final VoidCallback onFeedbackPressed;
  final VoidCallback onReportBugPressed;

  const SupportSection({
    super.key,
    required this.onHelpCenterPressed,
    required this.onContactSupportPressed,
    required this.onFeedbackPressed,
    required this.onReportBugPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Support',
      icon: Icons.help_outline,
      children: [
        SettingsItem(
          icon: Icons.help_center_outlined,
          title: 'Help Center',
          subtitle: 'FAQs and troubleshooting guides',
          onTap: onHelpCenterPressed,
        ),
        SettingsItem(
          icon: Icons.support_agent_outlined,
          title: 'Contact Support',
          subtitle: 'Chat or email our support team',
          onTap: onContactSupportPressed,
        ),
        SettingsItem(
          icon: Icons.feedback_outlined,
          title: 'Feedback & Suggestions',
          subtitle: 'Share your ideas to improve PulseCampus',
          onTap: onFeedbackPressed,
        ),
        SettingsItem(
          icon: Icons.bug_report_outlined,
          title: 'Report a Bug',
          subtitle: 'Help us fix issues you encounter',
          onTap: onReportBugPressed,
        ),
      ],
    );
  }
}

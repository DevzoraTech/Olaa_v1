// Presentation Layer - Legal Section Widget
import 'package:flutter/material.dart';
import 'settings_section.dart';
import 'settings_item.dart';

class LegalSection extends StatelessWidget {
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;
  final VoidCallback onGuidelinesPressed;

  const LegalSection({
    super.key,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    required this.onGuidelinesPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Legal',
      icon: Icons.gavel_outlined,
      children: [
        SettingsItem(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          onTap: onTermsPressed,
        ),
        SettingsItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'Learn how we protect your data',
          onTap: onPrivacyPressed,
        ),
        SettingsItem(
          icon: Icons.rule_outlined,
          title: 'Community Guidelines',
          subtitle: 'Understand our community standards',
          onTap: onGuidelinesPressed,
        ),
      ],
    );
  }
}

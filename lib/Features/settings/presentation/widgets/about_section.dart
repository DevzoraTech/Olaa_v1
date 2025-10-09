// Presentation Layer - About Section Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'settings_section.dart';
import 'settings_item.dart';

class AboutSection extends StatelessWidget {
  final VoidCallback onRateAppPressed;
  final VoidCallback onShareAppPressed;

  const AboutSection({
    super.key,
    required this.onRateAppPressed,
    required this.onShareAppPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'About',
      icon: Icons.info_outline,
      children: [
        // App Version Info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/olaa-logo.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'O',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olaa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Version 2.0.1',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Made with ❤️ for students',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SettingsItem(
          icon: Icons.star_outline,
          title: 'Rate Us',
          subtitle: 'Help us improve by rating the app',
          onTap: onRateAppPressed,
        ),
        SettingsItem(
          icon: Icons.share_outlined,
          title: 'Share App with Friends',
          subtitle: 'Invite friends to join PulseCampus',
          onTap: onShareAppPressed,
        ),
        SettingsItem(
          icon: Icons.code_outlined,
          title: 'Developer Info',
          subtitle: 'DevZora Technologies',
          onTap: () {
            // TODO: Show developer info
          },
        ),
      ],
    );
  }
}

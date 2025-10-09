// Presentation Layer - App Preferences Section Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'settings_section.dart';
import 'settings_item.dart';
import 'settings_toggle_item.dart';

class AppPreferencesSection extends StatelessWidget {
  final bool isDarkMode;
  final bool wifiOnlyDownloads;
  final Function(bool) onThemeChanged;
  final Function(bool) onWifiOnlyChanged;
  final VoidCallback onLanguagePressed;

  const AppPreferencesSection({
    super.key,
    required this.isDarkMode,
    required this.wifiOnlyDownloads,
    required this.onThemeChanged,
    required this.onWifiOnlyChanged,
    required this.onLanguagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'App Preferences',
      icon: Icons.tune_outlined,
      children: [
        SettingsItem(
          icon: Icons.palette_outlined,
          title: 'Theme',
          subtitle: isDarkMode ? 'Dark Mode' : 'Light Mode',
          onTap: () => _showThemeDialog(context),
        ),
        SettingsItem(
          icon: Icons.language_outlined,
          title: 'Language',
          subtitle: 'English',
          onTap: onLanguagePressed,
        ),
        SettingsToggleItem(
          icon: Icons.wifi_outlined,
          title: 'Wi-Fi Only Downloads',
          subtitle: 'Download images and videos only on Wi-Fi',
          value: wifiOnlyDownloads,
          onChanged: onWifiOnlyChanged,
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context) {
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
                  'Choose Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                // Theme Options
                _buildThemeOption(
                  context,
                  'Light Mode',
                  'Clean and bright interface',
                  Icons.light_mode_outlined,
                  Colors.orange[600]!,
                  false,
                ),
                _buildThemeOption(
                  context,
                  'Dark Mode',
                  'Easy on the eyes in low light',
                  Icons.dark_mode_outlined,
                  Colors.indigo[600]!,
                  true,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    final isSelected = isDarkMode == isDark;

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
            isSelected
                ? Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 20,
                )
                : null,
        onTap: () {
          onThemeChanged(isDark);
          Navigator.pop(context);
        },
      ),
    );
  }
}

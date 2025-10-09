// Presentation Layer - Bottom Navigation Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Detect current theme
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0B1014) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                index: 0,
                isActive: currentIndex == 0,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                icon: Icons.search,
                label: 'Search',
                index: 1,
                isActive: currentIndex == 1,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                icon: Icons.chat,
                label: 'Chat',
                index: 2,
                isActive: currentIndex == 2,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                icon: Icons.store,
                label: 'Market',
                index: 3,
                isActive: currentIndex == 3,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                icon: Icons.event,
                label: 'Events',
                index: 4,
                isActive: currentIndex == 4,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isActive
                      ? AppTheme.primaryColor
                      : isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color:
                    isActive
                        ? AppTheme.primaryColor
                        : isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Presentation Layer - Home Header Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFocused = false;
  bool _isDarkMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProfileDropdown(BuildContext context) {
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

                // Profile option
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'View and edit your profile',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),

                // Settings option
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Account settings and preferences',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect current theme
    final brightness = Theme.of(context).brightness;
    _isDarkMode = brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              _isDarkMode
                  ? [const Color(0xFF0B1014), const Color(0xFF1A1F2E)]
                  : [Colors.white, Colors.grey[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: _isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Top row with app name and icons
          Row(
            children: [
              // App Name Only
              Text(
                'Olaa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.grey[900],
                  letterSpacing: -0.5,
                ),
              ),

              const Spacer(),

              // Notification Bell
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Colors.grey[800] : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          _isDarkMode ? Colors.grey[600]! : Colors.grey[200]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color:
                              _isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          size: 22,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Profile Icon
              GestureDetector(
                onTap: () => _showProfileDropdown(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.15),
                        AppTheme.primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Enhanced Search Bar
          GestureDetector(
            onTap: () {
              // Navigate to search screen
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      _isFocused
                          ? AppTheme.primaryColor
                          : _isDarkMode
                          ? Colors.grey[600]!
                          : Colors.grey[300]!,
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        _isFocused
                            ? AppTheme.primaryColor.withOpacity(0.15)
                            : Colors.black.withOpacity(0.06),
                    blurRadius: _isFocused ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onTap: () => setState(() => _isFocused = true),
                      onSubmitted: (_) => setState(() => _isFocused = false),
                      decoration: InputDecoration(
                        hintText: 'Search hostels, events, items...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 36,
                    width: 1,
                    color: _isDarkMode ? Colors.grey[600] : Colors.grey[300],
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // TODO: Show filter options
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Filter',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

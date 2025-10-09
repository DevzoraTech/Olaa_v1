// Management App Bar Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ManagementAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String role;
  final VoidCallback onAddNew;

  const ManagementAppBar({
    super.key,
    required this.role,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.grey[800],
          size: 22,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Listings',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _getRoleDisplayName(role),
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: ElevatedButton.icon(
            onPressed: onAddNew,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return 'Student Dashboard';
      case 'hostel provider':
        return 'Hostel Provider Panel';
      case 'event organizer':
        return 'Event Organizer Panel';
      case 'promoter':
        return 'Promoter Panel';
      default:
        return 'Dashboard';
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}




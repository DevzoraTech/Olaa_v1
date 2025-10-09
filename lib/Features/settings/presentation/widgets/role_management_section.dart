// Presentation Layer - Role Management Section Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'settings_section.dart';
import 'settings_item.dart';

class RoleManagementSection extends StatelessWidget {
  final String currentRole;
  final Function(String) onRoleChanged;
  final VoidCallback onVerificationPressed;

  const RoleManagementSection({
    super.key,
    required this.currentRole,
    required this.onRoleChanged,
    required this.onVerificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Role & Access',
      icon: Icons.admin_panel_settings_outlined,
      children: [
        // Current Role Display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getRoleIcon(currentRole),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Role',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentRole,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Role Management Options
        SettingsItem(
          icon: Icons.swap_horiz_outlined,
          title: 'Switch / Add Roles',
          subtitle: 'Manage multiple roles (Student, Organizer, etc.)',
          onTap: () => _showRoleManagementDialog(context),
        ),
        SettingsItem(
          icon: Icons.verified_user_outlined,
          title: 'Verification',
          subtitle: _getVerificationSubtitle(),
          onTap: onVerificationPressed,
        ),
      ],
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Student':
        return Icons.school_outlined;
      case 'Hostel Provider':
        return Icons.home_outlined;
      case 'Event Organizer':
        return Icons.event_outlined;
      case 'Promoter':
        return Icons.music_note_outlined;
      default:
        return Icons.person_outlined;
    }
  }

  String _getVerificationSubtitle() {
    switch (currentRole) {
      case 'Student':
        return 'Upload student ID for verification';
      case 'Hostel Provider':
        return 'Upload business license/hostel proof';
      case 'Event Organizer':
        return 'Get organizer verification badge';
      case 'Promoter':
        return 'Get promoter verification badge';
      default:
        return 'Complete verification process';
    }
  }

  void _showRoleManagementDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                const SizedBox(height: 8),

                Text(
                  'Manage Roles',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  'You can have multiple roles on PulseCampus. Each role gives you access to different features.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Available Roles
                ...[
                  'Student',
                  'Hostel Provider',
                  'Event Organizer',
                  'Promoter',
                ].map((role) => _buildRoleOption(context, role)).toList(),
              ],
            ),
          ),
    );
  }

  Widget _buildRoleOption(BuildContext context, String role) {
    final isCurrentRole = currentRole == role;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        leading: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCurrentRole ? AppTheme.primaryColor : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getRoleIcon(role),
            color: isCurrentRole ? Colors.white : Colors.grey[600],
            size: 14,
          ),
        ),
        title: Text(
          role,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isCurrentRole ? AppTheme.primaryColor : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          _getRoleDescription(role),
          style: TextStyle(fontSize: 9, color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            isCurrentRole
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                )
                : Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primaryColor,
                  size: 14,
                ),
        onTap:
            isCurrentRole
                ? null
                : () {
                  onRoleChanged(role);
                  Navigator.pop(context);
                },
      ),
    );
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case 'Student':
        return 'Access housing, events, marketplace, and connect with roommates';
      case 'Hostel Provider':
        return 'List properties, manage bookings, and connect with students';
      case 'Event Organizer':
        return 'Create events, manage RSVPs, and engage with campus community';
      case 'Promoter':
        return 'Promote concerts, parties, and off-campus events to students';
      default:
        return 'Role description';
    }
  }
}

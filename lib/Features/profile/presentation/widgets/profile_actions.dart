// Presentation Layer - Profile Actions Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileActions extends StatelessWidget {
  final String userRole;

  const ProfileActions({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Actions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          ..._getActionsForRole(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _getActionsForRole() {
    switch (userRole) {
      case 'Student':
        return [
          _buildActionItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Update budget, interests, preferences',
            onTap: () {
              // TODO: Navigate to edit profile
            },
          ),
          _buildActionItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Notifications, privacy, logout',
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
          _buildActionItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            subtitle: 'Payments, deposits, transactions',
            onTap: () {
              // TODO: Navigate to wallet
            },
          ),
        ];
      case 'Hostel Provider':
        return [
          _buildActionItem(
            icon: Icons.add_home_outlined,
            title: 'Add New Listing',
            subtitle: 'Create a new hostel listing',
            onTap: () {
              // TODO: Navigate to add listing
            },
          ),
          _buildActionItem(
            icon: Icons.edit_outlined,
            title: 'Update Listings',
            subtitle: 'Edit or delete existing listings',
            onTap: () {
              // TODO: Navigate to manage listings
            },
          ),
          _buildActionItem(
            icon: Icons.analytics_outlined,
            title: 'View Reports',
            subtitle: 'Analytics and performance metrics',
            onTap: () {
              // TODO: Navigate to reports
            },
          ),
          _buildActionItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Account management and preferences',
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
        ];
      case 'Event Organizer':
        return [
          _buildActionItem(
            icon: Icons.add_outlined,
            title: 'Create New Event',
            subtitle: 'Organize a new campus event',
            onTap: () {
              // TODO: Navigate to create event
            },
          ),
          _buildActionItem(
            icon: Icons.share_outlined,
            title: 'Share Event',
            subtitle: 'Promote and share your events',
            onTap: () {
              // TODO: Navigate to share event
            },
          ),
          _buildActionItem(
            icon: Icons.message_outlined,
            title: 'Message Attendees',
            subtitle: 'Communicate with event participants',
            onTap: () {
              // TODO: Navigate to messages
            },
          ),
          _buildActionItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Account management and preferences',
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
        ];
      case 'Promoter':
        return [
          _buildActionItem(
            icon: Icons.add_outlined,
            title: 'Create Event',
            subtitle: 'Create concert, party, or social event',
            onTap: () {
              // TODO: Navigate to create event
            },
          ),
          _buildActionItem(
            icon: Icons.trending_up_outlined,
            title: 'Boost Event',
            subtitle: 'Promote event with paid advertising',
            onTap: () {
              // TODO: Navigate to boost event
            },
          ),
          _buildActionItem(
            icon: Icons.qr_code_outlined,
            title: 'Share Links',
            subtitle: 'Generate QR codes and share links',
            onTap: () {
              // TODO: Navigate to share links
            },
          ),
          _buildActionItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            subtitle: 'Ticket sales and revenue management',
            onTap: () {
              // TODO: Navigate to wallet
            },
          ),
          _buildActionItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Account management and preferences',
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

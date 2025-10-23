// Management Summary Bar Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ManagementSummaryBar extends StatelessWidget {
  final String role;
  final String filter;

  const ManagementSummaryBar({
    super.key,
    required this.role,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getRoleIcon(role),
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSummaryTitle(role),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSummarySubtitle(role, filter),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusBadge(filter),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return Icons.shopping_bag_outlined;
      case 'hostel provider':
        return Icons.home_work_outlined;
      case 'event organizer':
        return Icons.event_outlined;
      case 'promoter':
        return Icons.campaign_outlined;
      default:
        return Icons.dashboard_outlined;
    }
  }

  String _getSummaryTitle(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return 'My Products';
      case 'hostel provider':
        return 'My Hostels';
      case 'event organizer':
        return 'My Events';
      case 'promoter':
        return 'My Campaigns';
      default:
        return 'My Listings';
    }
  }

  String _getSummarySubtitle(String role, String filter) {
    final baseText = _getBaseSubtitle(role);
    if (filter == 'All') {
      return baseText;
    }
    return '$baseText • Showing $filter';
  }

  String _getBaseSubtitle(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return 'Manage your marketplace listings';
      case 'hostel provider':
        return 'Manage your hostel properties';
      case 'event organizer':
        return 'Manage your events and bookings';
      case 'promoter':
        return 'Manage your promotional campaigns';
      default:
        return 'Manage your content';
    }
  }

  String _getStatusBadge(String filter) {
    switch (filter.toLowerCase()) {
      case 'active':
        return 'ACTIVE';
      case 'hidden':
        return 'HIDDEN';
      case 'completed':
        return 'COMPLETED';
      default:
        return 'ALL';
    }
  }
}








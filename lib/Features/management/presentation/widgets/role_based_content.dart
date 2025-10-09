// Role Based Content Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'managers/products_manager.dart';
import 'managers/hostels_manager.dart';
import 'managers/events_manager.dart';
import 'managers/promotions_manager.dart';
import 'managers/roommate_requests_manager.dart';

class RoleBasedContent extends StatelessWidget {
  final String role;
  final String filter;
  final TabController tabController;

  const RoleBasedContent({
    super.key,
    required this.role,
    required this.filter,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: _buildRoleBasedContent(role),
    );
  }

  Widget _buildRoleBasedContent(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return TabBarView(
          controller: tabController,
          children: [
            ProductsManager(filter: filter),
            RoommateRequestsManager(filter: filter),
          ],
        );
      case 'hostel provider':
        return HostelsManager(filter: filter);
      case 'event organizer':
        return EventsManager(filter: filter);
      case 'promoter':
        return PromotionsManager(filter: filter);
      default:
        return TabBarView(
          controller: tabController,
          children: [
            ProductsManager(filter: filter),
            RoommateRequestsManager(filter: filter),
          ],
        );
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

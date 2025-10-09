// Presentation Layer - Notifications Tabs Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/notification_model.dart';

class NotificationsTabs extends StatelessWidget {
  final NotificationCategory selectedCategory;
  final Function(NotificationCategory) onCategoryChanged;

  const NotificationsTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTab(
            category: NotificationCategory.all,
            icon: Icons.notifications_outlined,
            label: 'All',
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          _buildTab(
            category: NotificationCategory.chats,
            icon: Icons.chat_bubble_outline,
            label: 'Chats',
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildTab(
            category: NotificationCategory.events,
            icon: Icons.event_outlined,
            label: 'Events',
            color: Colors.purple,
          ),
          const SizedBox(width: 8),
          _buildTab(
            category: NotificationCategory.housing,
            icon: Icons.home_outlined,
            label: 'Housing',
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _buildTab(
            category: NotificationCategory.marketplace,
            icon: Icons.shopping_bag_outlined,
            label: 'Marketplace',
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildTab(
            category: NotificationCategory.campusPulse,
            icon: Icons.trending_up_outlined,
            label: 'Campus Pulse',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required NotificationCategory category,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () => onCategoryChanged(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[600], size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

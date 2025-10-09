// Presentation Layer - Chat Header Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quick Actions Row
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.person_add_rounded,
                  title: 'New Chat',
                  subtitle: 'Start conversation',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    // TODO: Implement new chat functionality
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.group_add_rounded,
                  title: 'New Group',
                  subtitle: 'Create group',
                  color: Colors.green[600]!,
                  onTap: () {
                    // TODO: Implement new group functionality
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              _buildStatItem(
                icon: Icons.chat_bubble_outline,
                count: '12',
                label: 'Active Chats',
                color: Colors.blue[600]!,
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                icon: Icons.group_outlined,
                count: '5',
                label: 'Groups',
                color: Colors.purple[600]!,
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                icon: Icons.notifications_active_outlined,
                count: '3',
                label: 'Unread',
                color: Colors.orange[600]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}

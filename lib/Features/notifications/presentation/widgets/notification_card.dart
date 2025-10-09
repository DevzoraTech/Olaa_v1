// Presentation Layer - Notification Card Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              notification.isRead
                  ? Colors.grey[200]!
                  : notification.typeColor.withOpacity(0.3),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Unread Indicator
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: notification.typeColor,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 20),

                // Icon/Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: notification.typeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      notification.avatarUrl != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              notification.avatarUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  notification.type.typeIcon,
                                  color: notification.typeColor,
                                  size: 20,
                                );
                              },
                            ),
                          )
                          : Icon(
                            notification.type.typeIcon,
                            color: notification.typeColor,
                            size: 20,
                          ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                          color:
                              notification.isRead
                                  ? Colors.grey[600]
                                  : Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Message
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              notification.isRead
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Time and Action
                      Row(
                        children: [
                          // Time
                          Text(
                            notification.timeAgo,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                          const Spacer(),

                          // Action Button
                          if (notification.isActionable &&
                              notification.actionText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: notification.typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                notification.actionText!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: notification.typeColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Priority Indicator (for high/urgent notifications)
                if (notification.priority == NotificationPriority.high ||
                    notification.priority == NotificationPriority.urgent)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: notification.priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

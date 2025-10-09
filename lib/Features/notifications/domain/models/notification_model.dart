// Domain Layer - Notification Models
import 'package:flutter/material.dart';

enum NotificationType {
  chat,
  event,
  housing,
  marketplace,
  campusPulse,
  reminder,
  system,
}

extension NotificationTypeExtension on NotificationType {
  IconData get typeIcon {
    switch (this) {
      case NotificationType.chat:
        return Icons.chat_bubble_outline;
      case NotificationType.event:
        return Icons.event_outlined;
      case NotificationType.housing:
        return Icons.home_outlined;
      case NotificationType.marketplace:
        return Icons.shopping_bag_outlined;
      case NotificationType.campusPulse:
        return Icons.trending_up_outlined;
      case NotificationType.reminder:
        return Icons.schedule_outlined;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }
}

enum NotificationCategory {
  all,
  chats,
  events,
  housing,
  marketplace,
  campusPulse,
}

enum NotificationPriority { low, medium, high, urgent }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationCategory category;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final bool isActionable;
  final String? actionText;
  final String? actionRoute;
  final String? iconUrl;
  final String? avatarUrl;
  final Map<String, dynamic>? metadata;
  final String? userId;
  final String? relatedId; // ID of related item (event, hostel, chat, etc.)

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
    this.isActionable = false,
    this.actionText,
    this.actionRoute,
    this.iconUrl,
    this.avatarUrl,
    this.metadata,
    this.userId,
    this.relatedId,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationCategory? category,
    NotificationPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    bool? isActionable,
    String? actionText,
    String? actionRoute,
    String? iconUrl,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
    String? userId,
    String? relatedId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isActionable: isActionable ?? this.isActionable,
      actionText: actionText ?? this.actionText,
      actionRoute: actionRoute ?? this.actionRoute,
      iconUrl: iconUrl ?? this.iconUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      metadata: metadata ?? this.metadata,
      userId: userId ?? this.userId,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color get typeColor {
    switch (type) {
      case NotificationType.chat:
        return Colors.blue;
      case NotificationType.event:
        return Colors.purple;
      case NotificationType.housing:
        return Colors.green;
      case NotificationType.marketplace:
        return Colors.orange;
      case NotificationType.campusPulse:
        return Colors.red;
      case NotificationType.reminder:
        return Colors.amber;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }
}

class UpcomingReminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final NotificationType type;
  final String? actionRoute;
  final bool isCompleted;

  const UpcomingReminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    required this.type,
    this.actionRoute,
    this.isCompleted = false,
  });

  String get timeUntil {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Due now';
    }
  }
}

class TrendingNotification {
  final String id;
  final String title;
  final String description;
  final int engagementCount;
  final NotificationType type;
  final String? actionRoute;

  const TrendingNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.engagementCount,
    required this.type,
    this.actionRoute,
  });
}

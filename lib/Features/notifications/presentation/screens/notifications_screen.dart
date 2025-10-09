// Presentation Layer - Notifications Screen
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/notifications_header.dart';
import '../widgets/notifications_tabs.dart';
import '../widgets/upcoming_reminders.dart';
import '../widgets/trending_notifications.dart';
import '../widgets/notifications_list.dart';
import '../../domain/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationCategory _selectedCategory = NotificationCategory.all;
  bool _showUpcomingReminders = true;
  bool _showTrendingNotifications = true;

  // Mock data - in real app, this would come from a service
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      title: 'Freshers Bash starts in 2 hours',
      message: 'Don\'t forget to bring your student ID!',
      type: NotificationType.event,
      category: NotificationCategory.events,
      priority: NotificationPriority.high,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isActionable: true,
      actionText: 'View Event',
      actionRoute: '/event/123',
    ),
    NotificationModel(
      id: '2',
      title: 'New hostel matches your budget',
      message: '3 hostels near campus under \$500/month',
      type: NotificationType.housing,
      category: NotificationCategory.housing,
      priority: NotificationPriority.medium,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isActionable: true,
      actionText: 'View Listings',
      actionRoute: '/housing',
    ),
    NotificationModel(
      id: '3',
      title: 'John accepted your roommate request',
      message: 'You can now chat with John about living together',
      type: NotificationType.chat,
      category: NotificationCategory.chats,
      priority: NotificationPriority.medium,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isActionable: true,
      actionText: 'Start Chat',
      actionRoute: '/chat/456',
    ),
    NotificationModel(
      id: '4',
      title: '32 new RSVPs for Tech Fest',
      message: 'Your event is gaining popularity!',
      type: NotificationType.event,
      category: NotificationCategory.events,
      priority: NotificationPriority.low,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isActionable: true,
      actionText: 'View RSVPs',
      actionRoute: '/event/789/rsvps',
    ),
    NotificationModel(
      id: '5',
      title: 'Campus Poll: Best Cafeteria Food',
      message: 'Vote for your favorite cafeteria dish',
      type: NotificationType.campusPulse,
      category: NotificationCategory.campusPulse,
      priority: NotificationPriority.low,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isActionable: true,
      actionText: 'Vote Now',
      actionRoute: '/poll/101',
    ),
  ];

  final List<UpcomingReminder> _upcomingReminders = [
    UpcomingReminder(
      id: '1',
      title: 'Roommate Meeting',
      description: 'Meet with potential roommate at 3 PM',
      scheduledTime: DateTime.now().add(const Duration(hours: 2)),
      type: NotificationType.housing,
      actionRoute: '/chat/456',
    ),
    UpcomingReminder(
      id: '2',
      title: 'Payment Due',
      description: 'Hostel rent payment due tomorrow',
      scheduledTime: DateTime.now().add(const Duration(days: 1)),
      type: NotificationType.housing,
      actionRoute: '/payments',
    ),
  ];

  final List<TrendingNotification> _trendingNotifications = [
    TrendingNotification(
      id: '1',
      title: '50+ students RSVP\'d to the Freshers Party',
      description: 'This event is trending on campus!',
      engagementCount: 50,
      type: NotificationType.event,
      actionRoute: '/event/123',
    ),
    TrendingNotification(
      id: '2',
      title: 'New hostel listing matches your budget',
      description: 'Based on your interests, you may like this listing',
      engagementCount: 12,
      type: NotificationType.housing,
      actionRoute: '/housing/456',
    ),
  ];

  void _onCategoryChanged(NotificationCategory category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        if (!notification.isRead) {
          // In real app, this would update the notification in the database
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _onNotificationTap(NotificationModel notification) {
    // Mark as read
    setState(() {
      // In real app, this would update the notification in the database
    });

    // Navigate to relevant page
    if (notification.actionRoute != null) {
      Navigator.pushNamed(context, notification.actionRoute!);
    }
  }

  void _onNotificationDismiss(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notificationId);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notification dismissed')));
  }

  List<NotificationModel> get _filteredNotifications {
    if (_selectedCategory == NotificationCategory.all) {
      return _notifications;
    }
    return _notifications
        .where((n) => n.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey[700],
            size: 20,
          ),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Open notification preferences
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification preferences')),
              );
            },
            icon: Icon(
              Icons.filter_list_outlined,
              color: Colors.grey[600],
              size: 22,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Notifications Header
            NotificationsHeader(
              unreadCount: _notifications.where((n) => !n.isRead).length,
              onMarkAllRead: _markAllAsRead,
            ),

            // Notifications Tabs
            NotificationsTabs(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),

            const SizedBox(height: 16),

            // Upcoming Reminders (if enabled and has data)
            if (_showUpcomingReminders && _upcomingReminders.isNotEmpty)
              UpcomingReminders(
                reminders: _upcomingReminders,
                onReminderTap: (reminder) {
                  if (reminder.actionRoute != null) {
                    Navigator.pushNamed(context, reminder.actionRoute!);
                  }
                },
              ),

            // Trending Notifications (if enabled and has data)
            if (_showTrendingNotifications && _trendingNotifications.isNotEmpty)
              TrendingNotifications(
                trendingNotifications: _trendingNotifications,
                onTrendingTap: (trending) {
                  if (trending.actionRoute != null) {
                    Navigator.pushNamed(context, trending.actionRoute!);
                  }
                },
              ),

            // Notifications List
            NotificationsList(
              notifications: _filteredNotifications,
              onNotificationTap: _onNotificationTap,
              onNotificationDismiss: _onNotificationDismiss,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Core Layer - DateTime Utilities
import 'package:intl/intl.dart';

/// Utility class for handling DateTime operations with timezone conversions
///
/// Supabase stores all timestamps in UTC, so we need to convert to local time
/// for display throughout the app.
class DateTimeUtils {
  /// Parse a DateTime from Supabase (always stored in UTC) and convert to local timezone
  ///
  /// Example:
  /// ```dart
  /// final timestamp = DateTimeUtils.parseSupabaseTimestamp('2024-01-15T10:30:00Z');
  /// print(timestamp); // 2024-01-15 05:30:00.000 (if user is in EST)
  /// ```
  static DateTime parseSupabaseTimestamp(String timestamp) {
    try {
      return DateTime.parse(timestamp).toLocal();
    } catch (e) {
      print('ERROR: Failed to parse timestamp "$timestamp": $e');
      // Return current time as fallback to prevent crashes
      return DateTime.now();
    }
  }

  /// Format a DateTime for display in messages
  ///
  /// Rules:
  /// - Today: Show time only (10:30 AM)
  /// - Yesterday: Show "Yesterday"
  /// - This week: Show day name (Monday, Tuesday)
  /// - Older: Show date (Jan 15, 2024)
  ///
  /// Example:
  /// ```dart
  /// final formatted = DateTimeUtils.formatMessageTime(message.createdAt);
  /// print(formatted); // "10:30 AM" or "Yesterday" or "Jan 15"
  /// ```
  static String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final localTime = timestamp.toLocal();
    final difference = now.difference(localTime);

    // Handle future timestamps (shouldn't happen, but be defensive)
    if (localTime.isAfter(now)) {
      return formatTime(now);
    }

    // Today - show time only
    if (difference.inDays == 0 && now.day == localTime.day) {
      return formatTime(localTime);
    }

    // Yesterday
    if (difference.inDays == 1 ||
        (difference.inDays == 0 && now.day != localTime.day)) {
      return 'Yesterday';
    }

    // This week - show day name
    if (difference.inDays < 7) {
      return _getDayName(localTime.weekday);
    }

    // This year - show month and day
    if (now.year == localTime.year) {
      return DateFormat('MMM d').format(localTime); // Jan 15
    }

    // Older - show full date
    return DateFormat('MMM d, yyyy').format(localTime); // Jan 15, 2024
  }

  /// Format just the time portion (10:30 AM)
  static String formatTime(DateTime timestamp) {
    final localTime = timestamp.toLocal();
    return DateFormat('h:mm a').format(localTime); // 10:30 AM
  }

  /// Format full date and time (Jan 15, 2024 at 10:30 AM)
  static String formatFullDateTime(DateTime timestamp) {
    final localTime = timestamp.toLocal();
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(localTime);
  }

  /// Format date for chat list (shows when last message was sent)
  ///
  /// Rules:
  /// - Today: Show time (10:30 AM)
  /// - This week: Show day (Mon, Tue)
  /// - Older: Show date (Jan 15)
  static String formatChatListTime(DateTime timestamp) {
    final now = DateTime.now();
    final localTime = timestamp.toLocal();
    final difference = now.difference(localTime);

    // Handle future timestamps
    if (localTime.isAfter(now)) {
      return formatTime(now);
    }

    // Today - show time
    if (difference.inDays == 0 && now.day == localTime.day) {
      return formatTime(localTime);
    }

    // This week - show short day name
    if (difference.inDays < 7) {
      return _getShortDayName(localTime.weekday);
    }

    // This year - show month and day
    if (now.year == localTime.year) {
      return DateFormat('MMM d').format(localTime);
    }

    // Older - show date with year
    return DateFormat('MM/dd/yy').format(localTime);
  }

  /// Get full day name (Monday, Tuesday, etc.)
  static String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  /// Get short day name (Mon, Tue, etc.)
  static String _getShortDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Check if two DateTime objects are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    final local1 = date1.toLocal();
    final local2 = date2.toLocal();
    return local1.year == local2.year &&
        local1.month == local2.month &&
        local1.day == local2.day;
  }

  /// Check if a timestamp is today
  static bool isToday(DateTime timestamp) {
    return isSameDay(timestamp, DateTime.now());
  }

  /// Check if a timestamp is yesterday
  static bool isYesterday(DateTime timestamp) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(timestamp, yesterday);
  }

  /// Format a time difference (5 minutes ago, 2 hours ago)
  static String formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final localTime = timestamp.toLocal();
    final difference = now.difference(localTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return formatMessageTime(timestamp);
    }
  }

  /// Convert local DateTime to UTC ISO8601 string for Supabase
  ///
  /// Use this when sending timestamps to Supabase
  static String toSupabaseTimestamp(DateTime localTime) {
    return localTime.toUtc().toIso8601String();
  }
}

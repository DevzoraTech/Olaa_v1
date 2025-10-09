import 'package:flutter/material.dart';

class AppUtils {
  // Screen Size Helpers
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return getScreenWidth(context) >= 1024;
  }

  // Responsive Helpers
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return getScreenWidth(context) * (percentage / 100);
  }

  static double getResponsiveHeight(BuildContext context, double percentage) {
    return getScreenHeight(context) * (percentage / 100);
  }

  // Padding Helpers
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  // Animation Helpers
  static Duration getAnimationDuration(BuildContext context) {
    return const Duration(milliseconds: 300);
  }

  static Curve getAnimationCurve() {
    return Curves.easeInOut;
  }

  // Validation Helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8 && password.length <= 50;
  }

  // String Helpers
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Date Helpers
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  // Navigation Helpers
  static void navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  static void navigateAndReplace(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => page));
  }

  static void navigateAndClear(BuildContext context, Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  // Snackbar Helpers
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green[600]);
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.red[600]);
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.blue[600]);
  }

  // Loading Helpers
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Image Helpers
  static String getImageUrl(String? imageUrl, {String? placeholder}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return placeholder ?? 'https://via.placeholder.com/300x200';
    }
    return imageUrl;
  }

  // Debounce Helper
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    Future.delayed(delay, callback);
  }
}


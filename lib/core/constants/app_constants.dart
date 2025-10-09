class AppConstants {
  // App Information
  static const String appName = 'Olaa';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your Campus. Your People.';

  // API Configuration
  static const String baseUrl = 'https://api.pulsecampus.com';
  static const int apiTimeout = 30000; // 30 seconds

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String selectedUniversityKey = 'selected_university';
  static const String userTypeKey = 'user_type';
  static const String isFirstLaunchKey = 'is_first_launch';

  // User Types
  static const String studentUserType = 'student';
  static const String hostelProviderUserType = 'hostel_provider';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Debounce Duration
  static const Duration searchDebounce = Duration(milliseconds: 500);
}

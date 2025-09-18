/// Application constants for Stack Logistics
class AppConstants {
  // App Information
  static const String appName = 'Stack Logistics';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Your mobile app to control shipping containers';

  // API Configuration
  static const String baseUrl = 'https://api.stacklogistics.com'; // Placeholder
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Local Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String isOnboardingCompletedKey = 'is_onboarding_completed';
  static const String isLoggedInKey = 'is_logged_in';
  static const String isPremiumUserKey = 'is_premium_user';

  // Hive Box Names
  static const String userBoxName = 'users';
  static const String containerBoxName = 'containers';
  static const String inventoryBoxName = 'inventory';
  static const String notificationBoxName = 'notifications';
  static const String settingsBoxName = 'settings';
  static const String cacheBoxName = 'cache';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String containersCollection = 'containers';
  static const String inventoryCollection = 'inventory';
  static const String notificationsCollection = 'notifications';
  static const String analyticsCollection = 'analytics';

  // Error Messages
  static const String networkErrorMessage =
      'Network connection failed. Please check your internet connection and try again.';
  static const String serverErrorMessage =
      'Server error occurred. Please try again later.';
  static const String unknownErrorMessage =
      'An unexpected error occurred. Please try again.';
  static const String authErrorMessage =
      'Authentication failed. Please log in again.';
  static const String permissionDeniedMessage =
      'Permission denied. You don\'t have access to this resource.';
  static const String invalidDataMessage =
      'Invalid data format. Please check your input.';
  static const String dataNotFoundMessage = 'Requested data not found.';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Container Status Constants
  static const String containerStatusLoading = 'loading';
  static const String containerStatusInTransit = 'in_transit';
  static const String containerStatusDelivered = 'delivered';
  static const String containerStatusDelayed = 'delayed';
  static const String containerStatusDamaged = 'damaged';
  static const String containerStatusLost = 'lost';

  // Priority Levels
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
  static const String priorityCritical = 'critical';

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'HH:mm';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Regular Expressions
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  static const String containerNumberRegex = r'^[A-Z]{4}[0-9]{7}$';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableBarcodeScanning = true;
  static const bool enableMapIntegration = true;

  // Premium Features
  static const List<String> premiumFeatures = [
    'unlimited_containers',
    'advanced_analytics',
    'export_data',
    'priority_support',
    'team_collaboration',
    'real_time_tracking',
    'custom_notifications',
    'offline_sync',
  ];

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'es', 'fr'];
  static const String defaultLanguage = 'en';

  // Deep Link Patterns
  static const String containerDeepLink = '/container/{containerId}';
  static const String inventoryDeepLink = '/inventory/{inventoryId}';
  static const String trackingDeepLink = '/tracking/{trackingId}';
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';

/// Repository interface for notification operations
abstract class NotificationRepository {
  /// Get all notifications for the current user
  Future<Either<Failure, List<AppNotification>>> getAllNotifications();

  /// Get unread notifications count
  Future<Either<Failure, int>> getUnreadNotificationsCount();

  /// Get notifications by type
  Future<Either<Failure, List<AppNotification>>> getNotificationsByType(
    NotificationType type,
  );

  /// Get notifications by priority
  Future<Either<Failure, List<AppNotification>>> getNotificationsByPriority(
    NotificationPriority priority,
  );

  /// Get notifications for a specific container
  Future<Either<Failure, List<AppNotification>>> getNotificationsByContainer(
    String containerId,
  );

  /// Mark a notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Delete all notifications
  Future<Either<Failure, void>> deleteAllNotifications();

  /// Create a new notification (for testing or manual creation)
  Future<Either<Failure, AppNotification>> createNotification(
    AppNotification notification,
  );

  /// Initialize FCM and get device token
  Future<Either<Failure, String?>> initializeFCM();

  /// Subscribe to FCM topic
  Future<Either<Failure, void>> subscribeToTopic(String topic);

  /// Unsubscribe from FCM topic
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic);

  /// Update FCM token in the server
  Future<Either<Failure, void>> updateFCMToken(String token);

  /// Get stored FCM token
  Future<Either<Failure, String?>> getFCMToken();

  /// Stream of incoming notifications
  Stream<Either<Failure, AppNotification>> get notificationStream;

  /// Clear all local notification data
  Future<Either<Failure, void>> clearLocalNotifications();

  /// Sync notifications with remote server
  Future<Either<Failure, List<AppNotification>>> syncNotifications();

  /// Get notification settings/preferences
  Future<Either<Failure, NotificationSettings>> getNotificationSettings();

  /// Update notification settings/preferences
  Future<Either<Failure, void>> updateNotificationSettings(
    NotificationSettings settings,
  );
}

/// Notification settings entity
class NotificationSettings {
  const NotificationSettings({
    this.enablePushNotifications = true,
    this.enableContainerUpdates = true,
    this.enableDeliveryNotifications = true,
    this.enableDelayAlerts = true,
    this.enableSystemAnnouncements = true,
    this.enableSecurityAlerts = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.ledEnabled = true,
    this.priority = NotificationPriority.medium,
  });

  /// Whether push notifications are enabled
  final bool enablePushNotifications;

  /// Whether container status update notifications are enabled
  final bool enableContainerUpdates;

  /// Whether delivery notifications are enabled
  final bool enableDeliveryNotifications;

  /// Whether delay alert notifications are enabled
  final bool enableDelayAlerts;

  /// Whether system announcement notifications are enabled
  final bool enableSystemAnnouncements;

  /// Whether security alert notifications are enabled
  final bool enableSecurityAlerts;

  /// Whether quiet hours are enabled
  final bool quietHoursEnabled;

  /// Start time for quiet hours (24-hour format)
  final String? quietHoursStart;

  /// End time for quiet hours (24-hour format)
  final String? quietHoursEnd;

  /// Whether notification sound is enabled
  final bool soundEnabled;

  /// Whether notification vibration is enabled
  final bool vibrationEnabled;

  /// Whether notification LED is enabled
  final bool ledEnabled;

  /// Default notification priority
  final NotificationPriority priority;

  /// Create a copy with updated fields
  NotificationSettings copyWith({
    bool? enablePushNotifications,
    bool? enableContainerUpdates,
    bool? enableDeliveryNotifications,
    bool? enableDelayAlerts,
    bool? enableSystemAnnouncements,
    bool? enableSecurityAlerts,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? ledEnabled,
    NotificationPriority? priority,
  }) {
    return NotificationSettings(
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      enableContainerUpdates:
          enableContainerUpdates ?? this.enableContainerUpdates,
      enableDeliveryNotifications:
          enableDeliveryNotifications ?? this.enableDeliveryNotifications,
      enableDelayAlerts: enableDelayAlerts ?? this.enableDelayAlerts,
      enableSystemAnnouncements:
          enableSystemAnnouncements ?? this.enableSystemAnnouncements,
      enableSecurityAlerts: enableSecurityAlerts ?? this.enableSecurityAlerts,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      ledEnabled: ledEnabled ?? this.ledEnabled,
      priority: priority ?? this.priority,
    );
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'enablePushNotifications': enablePushNotifications,
      'enableContainerUpdates': enableContainerUpdates,
      'enableDeliveryNotifications': enableDeliveryNotifications,
      'enableDelayAlerts': enableDelayAlerts,
      'enableSystemAnnouncements': enableSystemAnnouncements,
      'enableSecurityAlerts': enableSecurityAlerts,
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'ledEnabled': ledEnabled,
      'priority': priority.toString(),
    };
  }

  /// Create from map
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      enablePushNotifications: map['enablePushNotifications'] ?? true,
      enableContainerUpdates: map['enableContainerUpdates'] ?? true,
      enableDeliveryNotifications: map['enableDeliveryNotifications'] ?? true,
      enableDelayAlerts: map['enableDelayAlerts'] ?? true,
      enableSystemAnnouncements: map['enableSystemAnnouncements'] ?? true,
      enableSecurityAlerts: map['enableSecurityAlerts'] ?? true,
      quietHoursEnabled: map['quietHoursEnabled'] ?? false,
      quietHoursStart: map['quietHoursStart'],
      quietHoursEnd: map['quietHoursEnd'],
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      ledEnabled: map['ledEnabled'] ?? true,
      priority: _parsePriority(map['priority']),
    );
  }

  static NotificationPriority _parsePriority(String? priorityString) {
    if (priorityString == null) return NotificationPriority.medium;

    switch (priorityString) {
      case 'NotificationPriority.low':
        return NotificationPriority.low;
      case 'NotificationPriority.medium':
        return NotificationPriority.medium;
      case 'NotificationPriority.high':
        return NotificationPriority.high;
      case 'NotificationPriority.critical':
        return NotificationPriority.critical;
      default:
        return NotificationPriority.medium;
    }
  }
}

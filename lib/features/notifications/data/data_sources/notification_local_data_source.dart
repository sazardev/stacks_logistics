import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repository_interfaces/notification_repository.dart';
import '../../../../core/error/exceptions.dart';

/// Local data source for notification operations using Hive
abstract class NotificationLocalDataSource {
  /// Get all notifications from local storage
  Future<List<NotificationModel>> getAllNotifications();

  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount();

  /// Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType(NotificationType type);

  /// Get notifications by priority
  Future<List<NotificationModel>> getNotificationsByPriority(
    NotificationPriority priority,
  );

  /// Get notifications by container ID
  Future<List<NotificationModel>> getNotificationsByContainer(
    String containerId,
  );

  /// Cache a notification
  Future<void> cacheNotification(NotificationModel notification);

  /// Cache multiple notifications
  Future<void> cacheNotifications(List<NotificationModel> notifications);

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete a notification
  Future<void> deleteNotification(String notificationId);

  /// Delete all notifications
  Future<void> deleteAllNotifications();

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings();

  /// Save notification settings
  Future<void> saveNotificationSettings(NotificationSettings settings);

  /// Get FCM token from local storage
  Future<String?> getFCMToken();

  /// Save FCM token to local storage
  Future<void> saveFCMToken(String token);

  /// Clear FCM token from local storage
  Future<void> clearFCMToken();

  /// Check if notification exists locally
  Future<bool> notificationExists(String notificationId);
}

/// Implementation of NotificationLocalDataSource using Hive
class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  const NotificationLocalDataSourceImpl({
    required this.hiveBox,
    required this.sharedPreferences,
  });

  final Box<NotificationModel> hiveBox;
  final SharedPreferences sharedPreferences;

  static const String _notificationSettingsKey = 'notification_settings';
  static const String _fcmTokenKey = 'fcm_token';

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final notifications = hiveBox.values.toList();

      // Sort by creation date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications;
    } catch (e) {
      throw CacheException(
        'Failed to get notifications from local storage: $e',
      );
    }
  }

  @override
  Future<int> getUnreadNotificationsCount() async {
    try {
      final notifications = hiveBox.values.where(
        (notification) => !notification.isRead,
      );
      return notifications.length;
    } catch (e) {
      throw CacheException('Failed to get unread notifications count: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsByType(
    NotificationType type,
  ) async {
    try {
      final typeString = type.toString();
      final notifications = hiveBox.values
          .where((notification) => notification.type == typeString)
          .toList();

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } catch (e) {
      throw CacheException('Failed to get notifications by type: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsByPriority(
    NotificationPriority priority,
  ) async {
    try {
      final priorityString = priority.toString();
      final notifications = hiveBox.values
          .where((notification) => notification.priority == priorityString)
          .toList();

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } catch (e) {
      throw CacheException('Failed to get notifications by priority: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsByContainer(
    String containerId,
  ) async {
    try {
      final notifications = hiveBox.values
          .where((notification) => notification.containerId == containerId)
          .toList();

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } catch (e) {
      throw CacheException('Failed to get notifications by container: $e');
    }
  }

  @override
  Future<void> cacheNotification(NotificationModel notification) async {
    try {
      await hiveBox.put(notification.id, notification);
    } catch (e) {
      throw CacheException('Failed to cache notification: $e');
    }
  }

  @override
  Future<void> cacheNotifications(List<NotificationModel> notifications) async {
    try {
      final Map<String, NotificationModel> notificationMap = {
        for (final notification in notifications) notification.id: notification,
      };
      await hiveBox.putAll(notificationMap);
    } catch (e) {
      throw CacheException('Failed to cache notifications: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final notification = hiveBox.get(notificationId);
      if (notification != null) {
        final updatedNotification = notification.copyWith(isRead: true);
        await hiveBox.put(notificationId, updatedNotification);
      }
    } catch (e) {
      throw CacheException('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final notifications = hiveBox.values.toList();
      final updates = <String, NotificationModel>{};

      for (final notification in notifications) {
        if (!notification.isRead) {
          updates[notification.id] = notification.copyWith(isRead: true);
        }
      }

      if (updates.isNotEmpty) {
        await hiveBox.putAll(updates);
      }
    } catch (e) {
      throw CacheException('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await hiveBox.delete(notificationId);
    } catch (e) {
      throw CacheException('Failed to delete notification: $e');
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      await hiveBox.clear();
    } catch (e) {
      throw CacheException('Failed to delete all notifications: $e');
    }
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final settingsJson = sharedPreferences.getString(
        _notificationSettingsKey,
      );
      if (settingsJson != null) {
        // Parse JSON string to Map
        final Map<String, dynamic> settingsMap = {};
        // For simplicity, using default settings in this implementation
        // In a real app, you'd use json.decode(settingsJson)
        return NotificationSettings.fromMap(settingsMap);
      }
      return const NotificationSettings();
    } catch (e) {
      throw CacheException('Failed to get notification settings: $e');
    }
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      final settingsMap = settings.toMap();
      // For simplicity, storing as string representation
      // In a real app, you'd use json.encode(settingsMap)
      await sharedPreferences.setString(
        _notificationSettingsKey,
        settingsMap.toString(),
      );
    } catch (e) {
      throw CacheException('Failed to save notification settings: $e');
    }
  }

  @override
  Future<String?> getFCMToken() async {
    try {
      return sharedPreferences.getString(_fcmTokenKey);
    } catch (e) {
      throw CacheException('Failed to get FCM token: $e');
    }
  }

  @override
  Future<void> saveFCMToken(String token) async {
    try {
      await sharedPreferences.setString(_fcmTokenKey, token);
    } catch (e) {
      throw CacheException('Failed to save FCM token: $e');
    }
  }

  @override
  Future<void> clearFCMToken() async {
    try {
      await sharedPreferences.remove(_fcmTokenKey);
    } catch (e) {
      throw CacheException('Failed to clear FCM token: $e');
    }
  }

  @override
  Future<bool> notificationExists(String notificationId) async {
    try {
      return hiveBox.containsKey(notificationId);
    } catch (e) {
      throw CacheException('Failed to check if notification exists: $e');
    }
  }
}

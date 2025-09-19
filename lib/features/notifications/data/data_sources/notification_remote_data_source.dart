import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';
import '../../domain/entities/app_notification.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/fcm_config.dart';

/// Remote data source for notification operations using Firebase
abstract class NotificationRemoteDataSource {
  /// Get all notifications for the current user
  Future<List<NotificationModel>> getAllNotifications();

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

  /// Mark notification as read on the server
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read on the server
  Future<void> markAllAsRead();

  /// Delete notification on the server
  Future<void> deleteNotification(String notificationId);

  /// Create a new notification on the server
  Future<NotificationModel> createNotification(NotificationModel notification);

  /// Initialize FCM and get device token
  Future<String?> initializeFCM();

  /// Subscribe to FCM topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Update FCM token on the server
  Future<void> updateFCMToken(String token);

  /// Stream of incoming FCM messages
  Stream<NotificationModel> get fcmMessageStream;

  /// Sync notifications with server
  Future<List<NotificationModel>> syncNotifications(DateTime? lastSyncTime);
}

/// Implementation of NotificationRemoteDataSource using Firebase
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.firebaseMessaging,
  });

  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseMessaging firebaseMessaging;

  static const String _notificationsCollection = 'notifications';
  static const String _usersCollection = 'users';
  static const String _tokensCollection = 'fcm_tokens';

  /// Get current user's notifications collection reference
  CollectionReference<Map<String, dynamic>> _getUserNotificationsRef() {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      throw const AuthException('User not authenticated');
    }
    return firestore
        .collection(_usersCollection)
        .doc(currentUser.uid)
        .collection(_notificationsCollection);
  }

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final notificationsRef = _getUserNotificationsRef();
      final querySnapshot = await notificationsRef
          .orderBy('createdAt', descending: true)
          .limit(50) // Limit to prevent excessive data transfer
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(
        message: 'Failed to get notifications from server: $e',
      );
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsByType(
    NotificationType type,
  ) async {
    try {
      final notificationsRef = _getUserNotificationsRef();
      final querySnapshot = await notificationsRef
          .where('type', isEqualTo: type.toString())
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to get notifications by type: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsByPriority(
    NotificationPriority priority,
  ) async {
    try {
      final notificationsRef = _getUserNotificationsRef();
      final querySnapshot = await notificationsRef
          .where('priority', isEqualTo: priority.toString())
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(
        message: 'Failed to get notifications by priority: $e',
      );
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsByContainer(
    String containerId,
  ) async {
    try {
      final notificationsRef = _getUserNotificationsRef();
      final querySnapshot = await notificationsRef
          .where('containerId', isEqualTo: containerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(
        message: 'Failed to get notifications by container: $e',
      );
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final notificationsRef = _getUserNotificationsRef();
      await notificationsRef.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final notificationsRef = _getUserNotificationsRef();
      final batch = firestore.batch();

      final unreadNotifications = await notificationsRef
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(
        message: 'Failed to mark all notifications as read: $e',
      );
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notificationsRef = _getUserNotificationsRef();
      await notificationsRef.doc(notificationId).delete();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to delete notification: $e');
    }
  }

  @override
  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    try {
      final notificationsRef = _getUserNotificationsRef();
      final docRef = await notificationsRef.add(notification.toFirestore());

      final doc = await docRef.get();
      return NotificationModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to create notification: $e');
    }
  }

  @override
  Future<String?> initializeFCM() async {
    try {
      await FCMConfig.initialize();
      final token = await FCMConfig.getToken();

      if (token != null) {
        await updateFCMToken(token);
      }

      return token;
    } catch (e) {
      throw ServerException(message: 'Failed to initialize FCM: $e');
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FCMConfig.subscribeToTopic(topic);
    } catch (e) {
      throw ServerException(message: 'Failed to subscribe to topic: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FCMConfig.unsubscribeFromTopic(topic);
    } catch (e) {
      throw ServerException(message: 'Failed to unsubscribe from topic: $e');
    }
  }

  @override
  Future<void> updateFCMToken(String token) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const AuthException('User not authenticated');
      }

      await firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .collection(_tokensCollection)
          .doc('current')
          .set({
            'token': token,
            'updatedAt': FieldValue.serverTimestamp(),
            'platform': _getCurrentPlatform(),
          }, SetOptions(merge: true));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to update FCM token: $e');
    }
  }

  @override
  Stream<NotificationModel> get fcmMessageStream {
    return FirebaseMessaging.onMessage.map((message) {
      final data = message.data;
      data['title'] = message.notification?.title ?? '';
      data['body'] = message.notification?.body ?? '';
      return NotificationModel.fromFCMData(data);
    });
  }

  @override
  Future<List<NotificationModel>> syncNotifications(
    DateTime? lastSyncTime,
  ) async {
    try {
      final notificationsRef = _getUserNotificationsRef();
      Query<Map<String, dynamic>> query = notificationsRef.orderBy(
        'createdAt',
        descending: true,
      );

      if (lastSyncTime != null) {
        query = query.where(
          'createdAt',
          isGreaterThan: Timestamp.fromDate(lastSyncTime),
        );
      }

      final querySnapshot = await query.limit(100).get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to sync notifications: $e');
    }
  }

  /// Get current platform identifier
  String _getCurrentPlatform() {
    // This would typically be more sophisticated
    return 'flutter';
  }
}

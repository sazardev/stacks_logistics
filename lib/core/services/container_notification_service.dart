import 'package:flutter/foundation.dart';
import '../../features/notifications/domain/entities/app_notification.dart';
import '../../features/notifications/domain/repository_interfaces/notification_repository.dart';
import '../../features/container_tracking/domain/entities/container.dart';

/// Service to integrate notifications with container events
class ContainerNotificationService {
  ContainerNotificationService({required this.notificationRepository});

  final NotificationRepository notificationRepository;

  /// Create notification when container status changes
  Future<void> onContainerStatusChanged({
    required Container container,
    required ContainerStatus oldStatus,
    required ContainerStatus newStatus,
  }) async {
    try {
      final notification = AppNotification.containerStatusUpdate(
        id: '${container.id}_status_${DateTime.now().millisecondsSinceEpoch}',
        containerId: container.id,
        containerNumber: container.containerNumber,
        oldStatus: _statusToString(oldStatus),
        newStatus: _statusToString(newStatus),
        createdAt: DateTime.now(),
        additionalData: {
          'container_id': container.id,
          'old_status': oldStatus.toString(),
          'new_status': newStatus.toString(),
          'current_location': container.currentLocation.fullAddress,
        },
      );

      final result = await notificationRepository.createNotification(
        notification,
      );
      result.fold(
        (failure) {
          if (kDebugMode) {
            print(
              'Failed to create status change notification: ${failure.message}',
            );
          }
        },
        (notification) {
          if (kDebugMode) {
            print('Status change notification created: ${notification.title}');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating status change notification: $e');
      }
    }
  }

  /// Create notification when container is delivered
  Future<void> onContainerDelivered({required Container container}) async {
    try {
      final notification = AppNotification.containerDelivery(
        id: '${container.id}_delivered_${DateTime.now().millisecondsSinceEpoch}',
        containerId: container.id,
        containerNumber: container.containerNumber,
        location: container.currentLocation.fullAddress,
        createdAt: DateTime.now(),
        additionalData: {
          'container_id': container.id,
          'delivery_location': container.currentLocation.fullAddress,
          'delivered_at': DateTime.now().toIso8601String(),
        },
      );

      final result = await notificationRepository.createNotification(
        notification,
      );
      result.fold(
        (failure) {
          if (kDebugMode) {
            print('Failed to create delivery notification: ${failure.message}');
          }
        },
        (notification) {
          if (kDebugMode) {
            print('Delivery notification created: ${notification.title}');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating delivery notification: $e');
      }
    }
  }

  /// Create notification when container is delayed
  Future<void> onContainerDelayed({
    required Container container,
    required String reason,
    required DateTime expectedDelivery,
  }) async {
    try {
      final notification = AppNotification.containerDelay(
        id: '${container.id}_delayed_${DateTime.now().millisecondsSinceEpoch}',
        containerId: container.id,
        containerNumber: container.containerNumber,
        reason: reason,
        expectedDelivery: expectedDelivery,
        createdAt: DateTime.now(),
        additionalData: {
          'container_id': container.id,
          'delay_reason': reason,
          'original_expected': expectedDelivery.toIso8601String(),
          'current_location': container.currentLocation.fullAddress,
        },
      );

      final result = await notificationRepository.createNotification(
        notification,
      );
      result.fold(
        (failure) {
          if (kDebugMode) {
            print('Failed to create delay notification: ${failure.message}');
          }
        },
        (notification) {
          if (kDebugMode) {
            print('Delay notification created: ${notification.title}');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating delay notification: $e');
      }
    }
  }

  /// Create notification when container location is updated
  Future<void> onContainerLocationUpdated({
    required Container container,
    required String previousLocation,
  }) async {
    try {
      final notification = AppNotification(
        id: '${container.id}_location_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Container Location Updated',
        body:
            'Container ${container.containerNumber} moved from $previousLocation to ${container.currentLocation.fullAddress}',
        type: NotificationType.containerLocationUpdate,
        priority: NotificationPriority.low,
        createdAt: DateTime.now(),
        containerId: container.id,
        data: {
          'container_id': container.id,
          'container_number': container.containerNumber,
          'previous_location': previousLocation,
          'current_location': container.currentLocation.fullAddress,
          'latitude': container.currentLocation.latitude,
          'longitude': container.currentLocation.longitude,
        },
        actionUrl: '/container/${container.id}',
      );

      final result = await notificationRepository.createNotification(
        notification,
      );
      result.fold(
        (failure) {
          if (kDebugMode) {
            print(
              'Failed to create location update notification: ${failure.message}',
            );
          }
        },
        (notification) {
          if (kDebugMode) {
            print(
              'Location update notification created: ${notification.title}',
            );
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating location update notification: $e');
      }
    }
  }

  /// Create notification for container damage
  Future<void> onContainerDamaged({
    required Container container,
    required String damageDescription,
  }) async {
    try {
      final notification = AppNotification(
        id: '${container.id}_damage_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Container Damage Reported',
        body:
            'Container ${container.containerNumber} has been damaged: $damageDescription',
        type: NotificationType.containerDamage,
        priority: NotificationPriority.critical,
        createdAt: DateTime.now(),
        containerId: container.id,
        data: {
          'container_id': container.id,
          'container_number': container.containerNumber,
          'damage_description': damageDescription,
          'location': container.currentLocation.fullAddress,
          'reported_at': DateTime.now().toIso8601String(),
        },
        actionUrl: '/container/${container.id}',
      );

      final result = await notificationRepository.createNotification(
        notification,
      );
      result.fold(
        (failure) {
          if (kDebugMode) {
            print('Failed to create damage notification: ${failure.message}');
          }
        },
        (notification) {
          if (kDebugMode) {
            print('Damage notification created: ${notification.title}');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating damage notification: $e');
      }
    }
  }

  /// Subscribe to container-specific topics for FCM
  Future<void> subscribeToContainerUpdates(String containerId) async {
    try {
      await notificationRepository.subscribeToTopic('container_$containerId');

      if (kDebugMode) {
        print('Subscribed to container updates for: $containerId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to container updates: $e');
      }
    }
  }

  /// Unsubscribe from container-specific topics
  Future<void> unsubscribeFromContainerUpdates(String containerId) async {
    try {
      await notificationRepository.unsubscribeFromTopic(
        'container_$containerId',
      );

      if (kDebugMode) {
        print('Unsubscribed from container updates for: $containerId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from container updates: $e');
      }
    }
  }

  /// Subscribe to general logistics updates
  Future<void> subscribeToGeneralUpdates() async {
    try {
      await notificationRepository.subscribeToTopic('logistics_updates');
      await notificationRepository.subscribeToTopic('system_announcements');

      if (kDebugMode) {
        print('Subscribed to general logistics updates');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to general updates: $e');
      }
    }
  }

  /// Create system announcement notification
  Future<void> createSystemAnnouncement({
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.medium,
    String? imageUrl,
    DateTime? expiresAt,
  }) async {
    try {
      final notification = AppNotification.systemAnnouncement(
        id: 'system_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        createdAt: DateTime.now(),
        priority: priority,
        imageUrl: imageUrl,
        expiresAt: expiresAt,
        additionalData: {
          'type': 'system_announcement',
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      final result = await notificationRepository.createNotification(
        notification,
      );
      result.fold(
        (failure) {
          if (kDebugMode) {
            print('Failed to create system announcement: ${failure.message}');
          }
        },
        (notification) {
          if (kDebugMode) {
            print('System announcement created: ${notification.title}');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating system announcement: $e');
      }
    }
  }

  /// Convert container status to readable string
  String _statusToString(ContainerStatus status) {
    switch (status) {
      case ContainerStatus.loading:
        return 'Loading';
      case ContainerStatus.inTransit:
        return 'In Transit';
      case ContainerStatus.delivered:
        return 'Delivered';
      case ContainerStatus.delayed:
        return 'Delayed';
      case ContainerStatus.damaged:
        return 'Damaged';
      case ContainerStatus.lost:
        return 'Lost';
    }
  }
}

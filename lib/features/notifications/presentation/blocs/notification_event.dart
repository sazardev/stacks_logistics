import 'package:equatable/equatable.dart';
import '../../domain/entities/app_notification.dart';

/// Events for notification BLoC
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all notifications
class LoadAllNotifications extends NotificationEvent {
  const LoadAllNotifications();
}

/// Event to load notifications by type
class LoadNotificationsByType extends NotificationEvent {
  const LoadNotificationsByType({required this.type});

  final NotificationType type;

  @override
  List<Object?> get props => [type];
}

/// Event to load notifications by priority
class LoadNotificationsByPriority extends NotificationEvent {
  const LoadNotificationsByPriority({required this.priority});

  final NotificationPriority priority;

  @override
  List<Object?> get props => [priority];
}

/// Event to load notifications for a specific container
class LoadNotificationsByContainer extends NotificationEvent {
  const LoadNotificationsByContainer({required this.containerId});

  final String containerId;

  @override
  List<Object?> get props => [containerId];
}

/// Event to mark a notification as read
class MarkNotificationAsRead extends NotificationEvent {
  const MarkNotificationAsRead({required this.notificationId});

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

/// Event to mark all notifications as read
class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

/// Event to delete a notification
class DeleteNotification extends NotificationEvent {
  const DeleteNotification({required this.notificationId});

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

/// Event to delete all notifications
class DeleteAllNotifications extends NotificationEvent {
  const DeleteAllNotifications();
}

/// Event to initialize FCM
class InitializeFCM extends NotificationEvent {
  const InitializeFCM();
}

/// Event to subscribe to a topic
class SubscribeToTopic extends NotificationEvent {
  const SubscribeToTopic({required this.topic});

  final String topic;

  @override
  List<Object?> get props => [topic];
}

/// Event to unsubscribe from a topic
class UnsubscribeFromTopic extends NotificationEvent {
  const UnsubscribeFromTopic({required this.topic});

  final String topic;

  @override
  List<Object?> get props => [topic];
}

/// Event to refresh notifications (sync with server)
class RefreshNotifications extends NotificationEvent {
  const RefreshNotifications();
}

/// Event when a new notification is received
class NotificationReceived extends NotificationEvent {
  const NotificationReceived({required this.notification});

  final AppNotification notification;

  @override
  List<Object?> get props => [notification];
}

/// Event to get unread notifications count
class GetUnreadNotificationsCount extends NotificationEvent {
  const GetUnreadNotificationsCount();
}

/// Event to filter notifications
class FilterNotifications extends NotificationEvent {
  const FilterNotifications({
    this.type,
    this.priority,
    this.showOnlyUnread = false,
    this.containerId,
  });

  final NotificationType? type;
  final NotificationPriority? priority;
  final bool showOnlyUnread;
  final String? containerId;

  @override
  List<Object?> get props => [type, priority, showOnlyUnread, containerId];
}

/// Event to clear notification filters
class ClearNotificationFilters extends NotificationEvent {
  const ClearNotificationFilters();
}

/// Event to create a test notification (for development)
class CreateTestNotification extends NotificationEvent {
  const CreateTestNotification({required this.notification});

  final AppNotification notification;

  @override
  List<Object?> get props => [notification];
}

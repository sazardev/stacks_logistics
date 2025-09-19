import 'package:equatable/equatable.dart';
import '../../domain/entities/app_notification.dart';

/// States for notification BLoC
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Loaded state with notifications
class NotificationLoaded extends NotificationState {
  const NotificationLoaded({
    required this.notifications,
    this.unreadCount = 0,
    this.filteredNotifications,
    this.activeFilters = const NotificationFilters(),
    this.fcmToken,
    this.isRefreshing = false,
  });

  final List<AppNotification> notifications;
  final int unreadCount;
  final List<AppNotification>? filteredNotifications;
  final NotificationFilters activeFilters;
  final String? fcmToken;
  final bool isRefreshing;

  /// Get the notifications to display (filtered or all)
  List<AppNotification> get displayNotifications {
    if (filteredNotifications != null) {
      return filteredNotifications!;
    }
    return notifications;
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return activeFilters.type != null ||
        activeFilters.priority != null ||
        activeFilters.showOnlyUnread ||
        activeFilters.containerId != null;
  }

  /// Create a copy with updated fields
  NotificationLoaded copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    List<AppNotification>? filteredNotifications,
    NotificationFilters? activeFilters,
    String? fcmToken,
    bool? isRefreshing,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      filteredNotifications:
          filteredNotifications ?? this.filteredNotifications,
      activeFilters: activeFilters ?? this.activeFilters,
      fcmToken: fcmToken ?? this.fcmToken,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  /// Create a copy with cleared filters
  NotificationLoaded copyWithClearedFilters() {
    return NotificationLoaded(
      notifications: notifications,
      unreadCount: unreadCount,
      filteredNotifications: null,
      activeFilters: const NotificationFilters(),
      fcmToken: fcmToken,
      isRefreshing: isRefreshing,
    );
  }

  /// Create a copy with a new notification added
  NotificationLoaded copyWithNewNotification(AppNotification notification) {
    final updatedNotifications = [notification, ...notifications];
    final updatedUnreadCount = notification.isRead
        ? unreadCount
        : unreadCount + 1;

    // Update filtered notifications if filters are active
    List<AppNotification>? updatedFilteredNotifications;
    if (filteredNotifications != null) {
      if (_notificationMatchesFilters(notification, activeFilters)) {
        updatedFilteredNotifications = [
          notification,
          ...filteredNotifications!,
        ];
      } else {
        updatedFilteredNotifications = filteredNotifications;
      }
    }

    return NotificationLoaded(
      notifications: updatedNotifications,
      unreadCount: updatedUnreadCount,
      filteredNotifications: updatedFilteredNotifications,
      activeFilters: activeFilters,
      fcmToken: fcmToken,
      isRefreshing: isRefreshing,
    );
  }

  /// Create a copy with a notification marked as read
  NotificationLoaded copyWithNotificationRead(String notificationId) {
    final updatedNotifications = notifications.map((notification) {
      if (notification.id == notificationId && !notification.isRead) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    final updatedFilteredNotifications = filteredNotifications?.map((
      notification,
    ) {
      if (notification.id == notificationId && !notification.isRead) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    // Decrease unread count if notification was unread
    final targetNotification = notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => AppNotification(
        id: '',
        title: '',
        body: '',
        type: NotificationType.general,
        priority: NotificationPriority.low,
        createdAt: DateTime.now(),
        isRead: true,
      ),
    );

    final updatedUnreadCount = !targetNotification.isRead
        ? unreadCount - 1
        : unreadCount;

    return NotificationLoaded(
      notifications: updatedNotifications,
      unreadCount: updatedUnreadCount,
      filteredNotifications: updatedFilteredNotifications,
      activeFilters: activeFilters,
      fcmToken: fcmToken,
      isRefreshing: isRefreshing,
    );
  }

  /// Create a copy with all notifications marked as read
  NotificationLoaded copyWithAllNotificationsRead() {
    final updatedNotifications = notifications.map((notification) {
      return notification.copyWith(isRead: true);
    }).toList();

    final updatedFilteredNotifications = filteredNotifications?.map((
      notification,
    ) {
      return notification.copyWith(isRead: true);
    }).toList();

    return NotificationLoaded(
      notifications: updatedNotifications,
      unreadCount: 0,
      filteredNotifications: updatedFilteredNotifications,
      activeFilters: activeFilters,
      fcmToken: fcmToken,
      isRefreshing: isRefreshing,
    );
  }

  /// Create a copy with a notification removed
  NotificationLoaded copyWithNotificationRemoved(String notificationId) {
    final targetNotification = notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => AppNotification(
        id: '',
        title: '',
        body: '',
        type: NotificationType.general,
        priority: NotificationPriority.low,
        createdAt: DateTime.now(),
        isRead: true,
      ),
    );

    final updatedNotifications = notifications
        .where((n) => n.id != notificationId)
        .toList();
    final updatedFilteredNotifications = filteredNotifications
        ?.where((n) => n.id != notificationId)
        .toList();
    final updatedUnreadCount = !targetNotification.isRead
        ? unreadCount - 1
        : unreadCount;

    return NotificationLoaded(
      notifications: updatedNotifications,
      unreadCount: updatedUnreadCount,
      filteredNotifications: updatedFilteredNotifications,
      activeFilters: activeFilters,
      fcmToken: fcmToken,
      isRefreshing: isRefreshing,
    );
  }

  /// Apply filters to notifications
  NotificationLoaded copyWithFilters(NotificationFilters filters) {
    List<AppNotification> filtered = notifications;

    // Apply type filter
    if (filters.type != null) {
      filtered = filtered.where((n) => n.type == filters.type).toList();
    }

    // Apply priority filter
    if (filters.priority != null) {
      filtered = filtered.where((n) => n.priority == filters.priority).toList();
    }

    // Apply unread filter
    if (filters.showOnlyUnread) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    // Apply container filter
    if (filters.containerId != null) {
      filtered = filtered
          .where((n) => n.containerId == filters.containerId)
          .toList();
    }

    return NotificationLoaded(
      notifications: notifications,
      unreadCount: unreadCount,
      filteredNotifications: filtered,
      activeFilters: filters,
      fcmToken: fcmToken,
      isRefreshing: isRefreshing,
    );
  }

  /// Check if a notification matches the current filters
  bool _notificationMatchesFilters(
    AppNotification notification,
    NotificationFilters filters,
  ) {
    if (filters.type != null && notification.type != filters.type) {
      return false;
    }

    if (filters.priority != null && notification.priority != filters.priority) {
      return false;
    }

    if (filters.showOnlyUnread && notification.isRead) {
      return false;
    }

    if (filters.containerId != null &&
        notification.containerId != filters.containerId) {
      return false;
    }

    return true;
  }

  @override
  List<Object?> get props => [
    notifications,
    unreadCount,
    filteredNotifications,
    activeFilters,
    fcmToken,
    isRefreshing,
  ];
}

/// Error state
class NotificationError extends NotificationState {
  const NotificationError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// FCM initialization success state
class FCMInitialized extends NotificationState {
  const FCMInitialized({required this.token});

  final String token;

  @override
  List<Object?> get props => [token];
}

/// Notification action success state
class NotificationActionSuccess extends NotificationState {
  const NotificationActionSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Filter configuration class
class NotificationFilters extends Equatable {
  const NotificationFilters({
    this.type,
    this.priority,
    this.showOnlyUnread = false,
    this.containerId,
  });

  final NotificationType? type;
  final NotificationPriority? priority;
  final bool showOnlyUnread;
  final String? containerId;

  /// Create a copy with updated fields
  NotificationFilters copyWith({
    NotificationType? type,
    NotificationPriority? priority,
    bool? showOnlyUnread,
    String? containerId,
  }) {
    return NotificationFilters(
      type: type ?? this.type,
      priority: priority ?? this.priority,
      showOnlyUnread: showOnlyUnread ?? this.showOnlyUnread,
      containerId: containerId ?? this.containerId,
    );
  }

  @override
  List<Object?> get props => [type, priority, showOnlyUnread, containerId];
}

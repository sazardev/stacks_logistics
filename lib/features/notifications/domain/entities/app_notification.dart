import 'package:equatable/equatable.dart';

/// Notification entity representing a push notification in the domain layer
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.containerId,
    this.data = const {},
    this.isRead = false,
    this.imageUrl,
    this.actionUrl,
    this.expiresAt,
  });

  /// Unique identifier for the notification
  final String id;

  /// Notification title
  final String title;

  /// Notification body/message
  final String body;

  /// Type of notification
  final NotificationType type;

  /// Priority level of the notification
  final NotificationPriority priority;

  /// When the notification was created
  final DateTime createdAt;

  /// Associated container ID (if applicable)
  final String? containerId;

  /// Additional data payload
  final Map<String, dynamic> data;

  /// Whether the notification has been read
  final bool isRead;

  /// Image URL for rich notifications
  final String? imageUrl;

  /// Action URL to navigate when notification is tapped
  final String? actionUrl;

  /// When the notification expires (if applicable)
  final DateTime? expiresAt;

  /// Create a copy with updated fields
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    String? containerId,
    Map<String, dynamic>? data,
    bool? isRead,
    String? imageUrl,
    String? actionUrl,
    DateTime? expiresAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      containerId: containerId ?? this.containerId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Check if notification has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if notification is related to a container
  bool get isContainerNotification => containerId != null;

  /// Factory constructor for container status update
  factory AppNotification.containerStatusUpdate({
    required String id,
    required String containerId,
    required String containerNumber,
    required String oldStatus,
    required String newStatus,
    required DateTime createdAt,
    Map<String, dynamic> additionalData = const {},
  }) {
    return AppNotification(
      id: id,
      title: 'Container Status Update',
      body:
          'Container $containerNumber status changed from $oldStatus to $newStatus',
      type: NotificationType.containerStatusUpdate,
      priority: NotificationPriority.medium,
      createdAt: createdAt,
      containerId: containerId,
      data: {
        'container_number': containerNumber,
        'old_status': oldStatus,
        'new_status': newStatus,
        ...additionalData,
      },
      actionUrl: '/container/$containerId',
    );
  }

  /// Factory constructor for container delivery
  factory AppNotification.containerDelivery({
    required String id,
    required String containerId,
    required String containerNumber,
    required String location,
    required DateTime createdAt,
    Map<String, dynamic> additionalData = const {},
  }) {
    return AppNotification(
      id: id,
      title: 'Container Delivered',
      body: 'Container $containerNumber has been delivered to $location',
      type: NotificationType.containerDelivery,
      priority: NotificationPriority.high,
      createdAt: createdAt,
      containerId: containerId,
      data: {
        'container_number': containerNumber,
        'delivery_location': location,
        ...additionalData,
      },
      actionUrl: '/container/$containerId',
    );
  }

  /// Factory constructor for container delay
  factory AppNotification.containerDelay({
    required String id,
    required String containerId,
    required String containerNumber,
    required String reason,
    required DateTime expectedDelivery,
    required DateTime createdAt,
    Map<String, dynamic> additionalData = const {},
  }) {
    return AppNotification(
      id: id,
      title: 'Container Delayed',
      body: 'Container $containerNumber has been delayed. Reason: $reason',
      type: NotificationType.containerDelay,
      priority: NotificationPriority.high,
      createdAt: createdAt,
      containerId: containerId,
      data: {
        'container_number': containerNumber,
        'delay_reason': reason,
        'expected_delivery': expectedDelivery.toIso8601String(),
        ...additionalData,
      },
      actionUrl: '/container/$containerId',
    );
  }

  /// Factory constructor for system announcements
  factory AppNotification.systemAnnouncement({
    required String id,
    required String title,
    required String body,
    required DateTime createdAt,
    NotificationPriority priority = NotificationPriority.low,
    String? imageUrl,
    DateTime? expiresAt,
    Map<String, dynamic> additionalData = const {},
  }) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.systemAnnouncement,
      priority: priority,
      createdAt: createdAt,
      data: additionalData,
      imageUrl: imageUrl,
      expiresAt: expiresAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    priority,
    createdAt,
    containerId,
    data,
    isRead,
    imageUrl,
    actionUrl,
    expiresAt,
  ];

  @override
  String toString() {
    return 'AppNotification('
        'id: $id, '
        'title: $title, '
        'type: $type, '
        'priority: $priority, '
        'containerId: $containerId, '
        'isRead: $isRead'
        ')';
  }
}

/// Types of notifications in the application
enum NotificationType {
  /// Container status has been updated
  containerStatusUpdate,

  /// Container has been delivered
  containerDelivery,

  /// Container is delayed
  containerDelay,

  /// Container location has been updated
  containerLocationUpdate,

  /// Container has been damaged
  containerDamage,

  /// System maintenance or announcements
  systemAnnouncement,

  /// Security alerts
  securityAlert,

  /// Account-related notifications
  accountUpdate,

  /// General information
  general,
}

/// Priority levels for notifications
enum NotificationPriority {
  /// Low priority - informational
  low,

  /// Medium priority - normal updates
  medium,

  /// High priority - important updates
  high,

  /// Critical priority - urgent alerts
  critical,
}

/// Extension to get display values for notification types
extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.containerStatusUpdate:
        return 'Container Status Update';
      case NotificationType.containerDelivery:
        return 'Container Delivery';
      case NotificationType.containerDelay:
        return 'Container Delay';
      case NotificationType.containerLocationUpdate:
        return 'Location Update';
      case NotificationType.containerDamage:
        return 'Container Damage';
      case NotificationType.systemAnnouncement:
        return 'System Announcement';
      case NotificationType.securityAlert:
        return 'Security Alert';
      case NotificationType.accountUpdate:
        return 'Account Update';
      case NotificationType.general:
        return 'General';
    }
  }

  String get iconName {
    switch (this) {
      case NotificationType.containerStatusUpdate:
        return 'update';
      case NotificationType.containerDelivery:
        return 'local_shipping';
      case NotificationType.containerDelay:
        return 'schedule';
      case NotificationType.containerLocationUpdate:
        return 'location_on';
      case NotificationType.containerDamage:
        return 'warning';
      case NotificationType.systemAnnouncement:
        return 'announcement';
      case NotificationType.securityAlert:
        return 'security';
      case NotificationType.accountUpdate:
        return 'account_circle';
      case NotificationType.general:
        return 'info';
    }
  }
}

/// Extension to get display values for notification priorities
extension NotificationPriorityExtension on NotificationPriority {
  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.medium:
        return 'Medium';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.critical:
        return 'Critical';
    }
  }

  int get numericValue {
    switch (this) {
      case NotificationPriority.low:
        return 1;
      case NotificationPriority.medium:
        return 2;
      case NotificationPriority.high:
        return 3;
      case NotificationPriority.critical:
        return 4;
    }
  }
}

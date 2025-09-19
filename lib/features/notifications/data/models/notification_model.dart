import 'package:hive/hive.dart';
import '../../domain/entities/app_notification.dart';

part 'notification_model.g.dart';

/// Notification model for data layer (Hive and Firebase)
@HiveType(typeId: 3)
class NotificationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final String priority;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String? containerId;

  @HiveField(7)
  final Map<String, dynamic> data;

  @HiveField(8)
  final bool isRead;

  @HiveField(9)
  final String? imageUrl;

  @HiveField(10)
  final String? actionUrl;

  @HiveField(11)
  final DateTime? expiresAt;

  const NotificationModel({
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

  /// Convert from domain entity
  factory NotificationModel.fromEntity(AppNotification notification) {
    return NotificationModel(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      type: notification.type.toString(),
      priority: notification.priority.toString(),
      createdAt: notification.createdAt,
      containerId: notification.containerId,
      data: notification.data,
      isRead: notification.isRead,
      imageUrl: notification.imageUrl,
      actionUrl: notification.actionUrl,
      expiresAt: notification.expiresAt,
    );
  }

  /// Convert to domain entity
  AppNotification toEntity() {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: _parseNotificationType(type),
      priority: _parseNotificationPriority(priority),
      createdAt: createdAt,
      containerId: containerId,
      data: data,
      isRead: isRead,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      expiresAt: expiresAt,
    );
  }

  /// Create from Firebase document
  factory NotificationModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'general',
      priority: data['priority'] ?? 'medium',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      containerId: data['containerId'],
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isRead: data['isRead'] ?? false,
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
      expiresAt: data['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['expiresAt'])
          : null,
    );
  }

  /// Convert to Firebase document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'priority': priority,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'containerId': containerId,
      'data': data,
      'isRead': isRead,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
    };
  }

  /// Create from FCM message data
  factory NotificationModel.fromFCMData(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'general',
      priority: data['priority'] ?? 'medium',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(data['createdAt']))
          : DateTime.now(),
      containerId: data['containerId'],
      data: Map<String, dynamic>.from(data),
      isRead: false, // New notifications are unread
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
      expiresAt: data['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(data['expiresAt']))
          : null,
    );
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? priority,
    DateTime? createdAt,
    String? containerId,
    Map<String, dynamic>? data,
    bool? isRead,
    String? imageUrl,
    String? actionUrl,
    DateTime? expiresAt,
  }) {
    return NotificationModel(
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

  @override
  String toString() {
    return 'NotificationModel('
        'id: $id, '
        'title: $title, '
        'type: $type, '
        'priority: $priority, '
        'isRead: $isRead'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Parse notification type from string
  static NotificationType _parseNotificationType(String typeString) {
    switch (typeString) {
      case 'NotificationType.containerStatusUpdate':
        return NotificationType.containerStatusUpdate;
      case 'NotificationType.containerDelivery':
        return NotificationType.containerDelivery;
      case 'NotificationType.containerDelay':
        return NotificationType.containerDelay;
      case 'NotificationType.containerLocationUpdate':
        return NotificationType.containerLocationUpdate;
      case 'NotificationType.containerDamage':
        return NotificationType.containerDamage;
      case 'NotificationType.systemAnnouncement':
        return NotificationType.systemAnnouncement;
      case 'NotificationType.securityAlert':
        return NotificationType.securityAlert;
      case 'NotificationType.accountUpdate':
        return NotificationType.accountUpdate;
      case 'NotificationType.general':
      default:
        return NotificationType.general;
    }
  }

  /// Parse notification priority from string
  static NotificationPriority _parseNotificationPriority(
    String priorityString,
  ) {
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

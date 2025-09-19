import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:stacks_logistics/core/services/container_notification_service.dart';
import 'package:stacks_logistics/features/notifications/domain/repository_interfaces/notification_repository.dart';
import 'package:stacks_logistics/features/notifications/domain/entities/app_notification.dart';
import 'package:stacks_logistics/features/container_tracking/domain/entities/container.dart';
import 'package:stacks_logistics/core/error/failures.dart';

@GenerateMocks([NotificationRepository])
import 'container_notification_service_test.mocks.dart';

void main() {
  late ContainerNotificationService service;
  late MockNotificationRepository mockRepository;
  late Container testContainer;

  setUp(() {
    mockRepository = MockNotificationRepository();
    service = ContainerNotificationService(
      notificationRepository: mockRepository,
    );

    testContainer = Container(
      id: 'test-container-id',
      containerNumber: 'TCLU1234567',
      status: ContainerStatus.inTransit,
      origin: const Location(
        name: 'Port of Los Angeles',
        address: '1234 Port Blvd',
        city: 'Los Angeles',
        country: 'USA',
        latitude: 33.7366,
        longitude: -118.2648,
      ),
      destination: const Location(
        name: 'Port of Long Beach',
        address: '5678 Harbor Dr',
        city: 'Long Beach',
        country: 'USA',
        latitude: 33.7666,
        longitude: -118.1895,
      ),
      currentLocation: const Location(
        name: 'Port of Los Angeles',
        address: '1234 Port Blvd',
        city: 'Los Angeles',
        country: 'USA',
        latitude: 33.7366,
        longitude: -118.2648,
      ),
      contents: 'Test cargo',
      weight: 25000.0,
      priority: Priority.medium,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  group('ContainerNotificationService', () {
    group('onContainerStatusChanged', () {
      test('should create status change notification successfully', () async {
        // Arrange
        final testNotification = AppNotification(
          id: 'test-id',
          title: 'Container Status Updated',
          body:
              'Container TCLU1234567 status changed from In Transit to Delivered',
          type: NotificationType.containerStatusUpdate,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
        );

        when(
          mockRepository.createNotification(any),
        ).thenAnswer((_) async => Right(testNotification));

        // Act
        await service.onContainerStatusChanged(
          container: testContainer,
          oldStatus: ContainerStatus.inTransit,
          newStatus: ContainerStatus.delivered,
        );

        // Assert
        verify(mockRepository.createNotification(any)).called(1);
      });

      test('should handle notification creation failure gracefully', () async {
        // Arrange
        when(
          mockRepository.createNotification(any),
        ).thenAnswer((_) async => Left(ServerFailure(message: 'Server error')));

        // Act & Assert - Should not throw
        await service.onContainerStatusChanged(
          container: testContainer,
          oldStatus: ContainerStatus.inTransit,
          newStatus: ContainerStatus.delivered,
        );

        verify(mockRepository.createNotification(any)).called(1);
      });
    });

    group('onContainerDelivered', () {
      test('should create delivery notification successfully', () async {
        // Arrange
        final testNotification = AppNotification(
          id: 'test-id',
          title: 'Container Delivered',
          body: 'Container TCLU1234567 has been delivered',
          type: NotificationType.containerDelivery,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
        );

        when(
          mockRepository.createNotification(any),
        ).thenAnswer((_) async => Right(testNotification));

        // Act
        await service.onContainerDelivered(container: testContainer);

        // Assert
        verify(mockRepository.createNotification(any)).called(1);
      });
    });

    group('onContainerDelayed', () {
      test('should create delay notification successfully', () async {
        // Arrange
        final expectedDelivery = DateTime.now().add(const Duration(days: 7));
        final testNotification = AppNotification(
          id: 'test-id',
          title: 'Container Delayed',
          body: 'Container TCLU1234567 is delayed',
          type: NotificationType.containerDelay,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
        );

        when(
          mockRepository.createNotification(any),
        ).thenAnswer((_) async => Right(testNotification));

        // Act
        await service.onContainerDelayed(
          container: testContainer,
          reason: 'Weather conditions',
          expectedDelivery: expectedDelivery,
        );

        // Assert
        verify(mockRepository.createNotification(any)).called(1);
      });
    });

    group('onContainerLocationUpdated', () {
      test('should create location update notification successfully', () async {
        // Arrange
        final testNotification = AppNotification(
          id: 'test-id',
          title: 'Container Location Updated',
          body: 'Container TCLU1234567 location updated',
          type: NotificationType.containerLocationUpdate,
          priority: NotificationPriority.low,
          createdAt: DateTime.now(),
        );

        when(
          mockRepository.createNotification(any),
        ).thenAnswer((_) async => Right(testNotification));

        // Act
        await service.onContainerLocationUpdated(
          container: testContainer,
          previousLocation: 'Previous Location',
        );

        // Assert
        verify(mockRepository.createNotification(any)).called(1);
      });
    });

    group('onContainerDamaged', () {
      test('should create damage notification successfully', () async {
        // Arrange
        final testNotification = AppNotification(
          id: 'test-id',
          title: 'Container Damage Reported',
          body: 'Container TCLU1234567 has been damaged',
          type: NotificationType.containerDamage,
          priority: NotificationPriority.critical,
          createdAt: DateTime.now(),
        );

        when(
          mockRepository.createNotification(any),
        ).thenAnswer((_) async => Right(testNotification));

        // Act
        await service.onContainerDamaged(
          container: testContainer,
          damageDescription: 'Dent in side panel',
        );

        // Assert
        verify(mockRepository.createNotification(any)).called(1);
      });
    });

    group('Topic Subscriptions', () {
      test('should subscribe to container updates successfully', () async {
        // Arrange
        when(
          mockRepository.subscribeToTopic(any),
        ).thenAnswer((_) async => const Right(null));

        // Act
        await service.subscribeToContainerUpdates('test-container-id');

        // Assert
        verify(
          mockRepository.subscribeToTopic('container_test-container-id'),
        ).called(1);
      });

      test('should unsubscribe from container updates successfully', () async {
        // Arrange
        when(
          mockRepository.unsubscribeFromTopic(any),
        ).thenAnswer((_) async => const Right(null));

        // Act
        await service.unsubscribeFromContainerUpdates('test-container-id');

        // Assert
        verify(
          mockRepository.unsubscribeFromTopic('container_test-container-id'),
        ).called(1);
      });

      test('should subscribe to general updates successfully', () async {
        // Arrange
        when(
          mockRepository.subscribeToTopic(any),
        ).thenAnswer((_) async => const Right(null));

        // Act
        await service.subscribeToGeneralUpdates();

        // Assert
        verify(mockRepository.subscribeToTopic('logistics_updates')).called(1);
        verify(
          mockRepository.subscribeToTopic('system_announcements'),
        ).called(1);
      });
    });

    group('createSystemAnnouncement', () {
      test('should create system announcement successfully', () async {
        // Arrange
        final testNotification = AppNotification(
          id: 'test-id',
          title: 'System Maintenance',
          body: 'System will be down for maintenance',
          type: NotificationType.systemAnnouncement,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
        );

        when(
          mockRepository.createNotification(any),
        ).thenAnswer((_) async => Right(testNotification));

        // Act
        await service.createSystemAnnouncement(
          title: 'System Maintenance',
          body: 'System will be down for maintenance',
        );

        // Assert
        verify(mockRepository.createNotification(any)).called(1);
      });

      test('should create system announcement with custom priority', () async {
        // Arrange
        final testNotification = AppNotification(
          id: 'test-id',
          title: 'Critical Update',
          body: 'Important system update',
          type: NotificationType.systemAnnouncement,
          priority: NotificationPriority.critical,
          createdAt: DateTime.now(),
        );

        when(
          mockRepository.createNotification(any),
        ).thenAnswer((_) async => Right(testNotification));

        // Act
        await service.createSystemAnnouncement(
          title: 'Critical Update',
          body: 'Important system update',
          priority: NotificationPriority.critical,
        );

        // Assert
        verify(mockRepository.createNotification(any)).called(1);
      });
    });
  });
}

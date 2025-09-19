import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:stacks_logistics/features/container_tracking/data/repositories/container_repository_impl.dart';
import 'package:stacks_logistics/features/container_tracking/data/data_sources/container_local_data_source.dart';
import 'package:stacks_logistics/features/container_tracking/data/data_sources/container_remote_data_source.dart';
import 'package:stacks_logistics/features/container_tracking/data/models/container_model.dart';
import 'package:stacks_logistics/features/container_tracking/domain/entities/container.dart';
import 'package:stacks_logistics/core/services/container_notification_service.dart';
import 'package:stacks_logistics/features/notifications/domain/repository_interfaces/notification_repository.dart';

@GenerateMocks([
  ContainerLocalDataSource,
  ContainerRemoteDataSource,
  Connectivity,
  ContainerNotificationService,
  NotificationRepository,
])
import 'container_tracking_integration_test.mocks.dart';

void main() {
  late ContainerRepositoryImpl repository;
  late MockContainerLocalDataSource mockLocalDataSource;
  late MockContainerRemoteDataSource mockRemoteDataSource;
  late MockConnectivity mockConnectivity;
  late MockContainerNotificationService mockNotificationService;
  late Container testContainer;
  late Container updatedContainer;

  setUp(() {
    mockLocalDataSource = MockContainerLocalDataSource();
    mockRemoteDataSource = MockContainerRemoteDataSource();
    mockConnectivity = MockConnectivity();
    mockNotificationService = MockContainerNotificationService();

    repository = ContainerRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      connectivity: mockConnectivity,
      notificationService: mockNotificationService,
    );

    testContainer = Container(
      id: 'test-container-1',
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
      contents: 'Electronics',
      weight: 15000.0,
      priority: Priority.high,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    );

    updatedContainer = testContainer.copyWith(
      status: ContainerStatus.delivered,
      currentLocation: testContainer.destination,
      updatedAt: DateTime.now(),
    );
  });

  group('Container Tracking Integration Tests', () {
    test(
      'should send status change notification when container is updated',
      () async {
        // Arrange
        final previousModel = ContainerModel.fromEntity(testContainer);
        final updatedModel = ContainerModel.fromEntity(updatedContainer);

        when(
          mockLocalDataSource.getContainerById('test-container-1'),
        ).thenAnswer((_) async => previousModel);
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);
        when(
          mockLocalDataSource.cacheContainer(any),
        ).thenAnswer((_) async => {});
        when(
          mockRemoteDataSource.updateContainer(any),
        ).thenAnswer((_) async => updatedModel);
        when(
          mockLocalDataSource.setLastSyncTime(any),
        ).thenAnswer((_) async => {});
        when(
          mockNotificationService.onContainerStatusChanged(
            container: anyNamed('container'),
            oldStatus: anyNamed('oldStatus'),
            newStatus: anyNamed('newStatus'),
          ),
        ).thenAnswer((_) async => {});
        when(
          mockNotificationService.onContainerDelivered(
            container: anyNamed('container'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.updateContainer(updatedContainer);

        // Assert
        expect(result.isRight(), true);

        // Verify status change notification was called
        verify(
          mockNotificationService.onContainerStatusChanged(
            container: updatedContainer,
            oldStatus: ContainerStatus.inTransit,
            newStatus: ContainerStatus.delivered,
          ),
        ).called(1);

        // Verify delivery notification was called
        verify(
          mockNotificationService.onContainerDelivered(
            container: updatedContainer,
          ),
        ).called(1);
      },
    );

    test(
      'should send location update notification when container location changes',
      () async {
        // Arrange
        final newLocation = const Location(
          name: 'Warehouse A',
          address: '9999 Storage St',
          city: 'Los Angeles',
          country: 'USA',
          latitude: 33.7500,
          longitude: -118.2500,
        );

        final locationUpdatedContainer = testContainer.copyWith(
          currentLocation: newLocation,
          updatedAt: DateTime.now(),
        );

        final previousModel = ContainerModel.fromEntity(testContainer);
        final updatedModel = ContainerModel.fromEntity(
          locationUpdatedContainer,
        );

        when(
          mockLocalDataSource.getContainerById('test-container-1'),
        ).thenAnswer((_) async => previousModel);
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);
        when(
          mockLocalDataSource.cacheContainer(any),
        ).thenAnswer((_) async => {});
        when(
          mockRemoteDataSource.updateContainer(any),
        ).thenAnswer((_) async => updatedModel);
        when(
          mockLocalDataSource.setLastSyncTime(any),
        ).thenAnswer((_) async => {});
        when(
          mockNotificationService.onContainerLocationUpdated(
            container: anyNamed('container'),
            previousLocation: anyNamed('previousLocation'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.updateContainer(
          locationUpdatedContainer,
        );

        // Assert
        expect(result.isRight(), true);

        // Verify location update notification was called
        verify(
          mockNotificationService.onContainerLocationUpdated(
            container: locationUpdatedContainer,
            previousLocation: testContainer.currentLocation.fullAddress,
          ),
        ).called(1);
      },
    );

    test(
      'should send damage notification when container status changes to damaged',
      () async {
        // Arrange
        final damagedContainer = testContainer.copyWith(
          status: ContainerStatus.damaged,
          updatedAt: DateTime.now(),
        );

        final previousModel = ContainerModel.fromEntity(testContainer);
        final updatedModel = ContainerModel.fromEntity(damagedContainer);

        when(
          mockLocalDataSource.getContainerById('test-container-1'),
        ).thenAnswer((_) async => previousModel);
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);
        when(
          mockLocalDataSource.cacheContainer(any),
        ).thenAnswer((_) async => {});
        when(
          mockRemoteDataSource.updateContainer(any),
        ).thenAnswer((_) async => updatedModel);
        when(
          mockLocalDataSource.setLastSyncTime(any),
        ).thenAnswer((_) async => {});
        when(
          mockNotificationService.onContainerStatusChanged(
            container: anyNamed('container'),
            oldStatus: anyNamed('oldStatus'),
            newStatus: anyNamed('newStatus'),
          ),
        ).thenAnswer((_) async => {});
        when(
          mockNotificationService.onContainerDamaged(
            container: anyNamed('container'),
            damageDescription: anyNamed('damageDescription'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.updateContainer(damagedContainer);

        // Assert
        expect(result.isRight(), true);

        // Verify status change notification was called
        verify(
          mockNotificationService.onContainerStatusChanged(
            container: damagedContainer,
            oldStatus: ContainerStatus.inTransit,
            newStatus: ContainerStatus.damaged,
          ),
        ).called(1);

        // Verify damage notification was called
        verify(
          mockNotificationService.onContainerDamaged(
            container: damagedContainer,
            damageDescription: 'Container damage detected',
          ),
        ).called(1);
      },
    );

    test(
      'should handle notification errors gracefully without failing container update',
      () async {
        // Arrange
        final previousModel = ContainerModel.fromEntity(testContainer);
        final updatedModel = ContainerModel.fromEntity(updatedContainer);

        when(
          mockLocalDataSource.getContainerById('test-container-1'),
        ).thenAnswer((_) async => previousModel);
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);
        when(
          mockLocalDataSource.cacheContainer(any),
        ).thenAnswer((_) async => {});
        when(
          mockRemoteDataSource.updateContainer(any),
        ).thenAnswer((_) async => updatedModel);
        when(
          mockLocalDataSource.setLastSyncTime(any),
        ).thenAnswer((_) async => {});

        // Make notification service throw an error
        when(
          mockNotificationService.onContainerStatusChanged(
            container: anyNamed('container'),
            oldStatus: anyNamed('oldStatus'),
            newStatus: anyNamed('newStatus'),
          ),
        ).thenThrow(Exception('Notification service error'));

        // Act
        final result = await repository.updateContainer(updatedContainer);

        // Assert
        expect(result.isRight(), true);

        // Verify container update still succeeded despite notification error
        verify(mockLocalDataSource.cacheContainer(any)).called(1);
        verify(mockRemoteDataSource.updateContainer(any)).called(1);
      },
    );

    test(
      'should not send notifications when notification service is null',
      () async {
        // Arrange
        final repositoryWithoutNotifications = ContainerRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: mockRemoteDataSource,
          connectivity: mockConnectivity,
          notificationService: null, // No notification service
        );

        final previousModel = ContainerModel.fromEntity(testContainer);
        final updatedModel = ContainerModel.fromEntity(updatedContainer);

        when(
          mockLocalDataSource.getContainerById('test-container-1'),
        ).thenAnswer((_) async => previousModel);
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.wifi);
        when(
          mockLocalDataSource.cacheContainer(any),
        ).thenAnswer((_) async => {});
        when(
          mockRemoteDataSource.updateContainer(any),
        ).thenAnswer((_) async => updatedModel);
        when(
          mockLocalDataSource.setLastSyncTime(any),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repositoryWithoutNotifications.updateContainer(
          updatedContainer,
        );

        // Assert
        expect(result.isRight(), true);

        // Verify no notification methods were called
        verifyNever(
          mockNotificationService.onContainerStatusChanged(
            container: anyNamed('container'),
            oldStatus: anyNamed('oldStatus'),
            newStatus: anyNamed('newStatus'),
          ),
        );
        verifyNever(
          mockNotificationService.onContainerDelivered(
            container: anyNamed('container'),
          ),
        );
      },
    );
  });
}

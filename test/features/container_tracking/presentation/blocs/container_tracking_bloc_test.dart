import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stacks_logistics/features/container_tracking/domain/entities/container.dart';
import 'package:stacks_logistics/features/container_tracking/presentation/blocs/container_tracking_bloc.dart';
import 'package:stacks_logistics/features/container_tracking/presentation/blocs/container_tracking_event.dart';
import 'package:stacks_logistics/features/container_tracking/presentation/blocs/container_tracking_state.dart';

import 'container_tracking_bloc_test.mocks.dart';

@GenerateMocks([ContainerTrackingBloc])
void main() {
  group('ContainerTrackingBloc Tests', () {
    late MockContainerTrackingBloc mockBloc;

    setUp(() {
      mockBloc = MockContainerTrackingBloc();
    });

    test('should have ContainerTrackingInitial as initial state', () {
      // Arrange
      when(mockBloc.state).thenReturn(const ContainerTrackingInitial());

      // Assert
      expect(mockBloc.state, const ContainerTrackingInitial());
    });

    test(
      'should emit loading and loaded states when LoadContainers is successful',
      () {
        // Arrange
        final testContainers = [
          Container(
            id: 'test_1',
            containerNumber: 'TEST1234567',
            status: ContainerStatus.inTransit,
            currentLocation: const Location(
              name: 'Test Port',
              address: 'Test Address',
              city: 'Test City',
              country: 'Test Country',
              latitude: 0.0,
              longitude: 0.0,
            ),
            destination: const Location(
              name: 'Test Destination',
              address: 'Test Destination Address',
              city: 'Test Destination City',
              country: 'Test Destination Country',
              latitude: 1.0,
              longitude: 1.0,
            ),
            origin: const Location(
              name: 'Test Origin',
              address: 'Test Origin Address',
              city: 'Test Origin City',
              country: 'Test Origin Country',
              latitude: -1.0,
              longitude: -1.0,
            ),
            contents: 'Test contents',
            weight: 1000.0,
            priority: Priority.medium,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ];

        when(mockBloc.stream).thenAnswer(
          (_) => Stream.fromIterable([
            const ContainerTrackingLoading(),
            ContainerTrackingLoaded(containers: testContainers),
          ]),
        );

        // Act & Assert
        expectLater(
          mockBloc.stream,
          emitsInOrder([
            const ContainerTrackingLoading(),
            ContainerTrackingLoaded(containers: testContainers),
          ]),
        );
      },
    );

    test('should emit error state when LoadContainers fails', () {
      // Arrange
      const errorMessage = 'Failed to load containers';
      when(mockBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const ContainerTrackingLoading(),
          const ContainerTrackingError(errorMessage),
        ]),
      );

      // Act & Assert
      expectLater(
        mockBloc.stream,
        emitsInOrder([
          const ContainerTrackingLoading(),
          const ContainerTrackingError(errorMessage),
        ]),
      );
    });

    test(
      'should verify that add method is called with LoadAllContainers event',
      () {
        // Arrange
        const event = LoadAllContainers();

        // Act
        mockBloc.add(event);

        // Assert
        verify(mockBloc.add(event)).called(1);
      },
    );
  });
}

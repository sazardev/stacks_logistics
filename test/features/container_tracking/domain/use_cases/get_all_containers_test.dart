import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stacks_logistics/core/error/failures.dart';
import 'package:stacks_logistics/features/container_tracking/domain/entities/container.dart';
import 'package:stacks_logistics/features/container_tracking/domain/repository_interfaces/container_repository.dart';
import 'package:stacks_logistics/features/container_tracking/domain/use_cases/get_all_containers.dart';

import 'get_all_containers_test.mocks.dart';

@GenerateMocks([ContainerRepository])
void main() {
  late GetAllContainers usecase;
  late MockContainerRepository mockRepository;

  setUp(() {
    mockRepository = MockContainerRepository();
    usecase = GetAllContainers(mockRepository);
  });

  group('GetAllContainers', () {
    final tContainers = [
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

    test('should get containers from the repository', () async {
      // Arrange
      when(
        mockRepository.getAllContainers(),
      ).thenAnswer((_) async => Right(tContainers));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(tContainers));
      verify(mockRepository.getAllContainers());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository throws exception', () async {
      // Arrange
      const tFailure = NetworkFailure(message: 'Network error');
      when(
        mockRepository.getAllContainers(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.getAllContainers());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no containers exist', () async {
      // Arrange
      const List<Container> emptyList = [];
      when(
        mockRepository.getAllContainers(),
      ).thenAnswer((_) async => const Right(emptyList));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(emptyList));
      verify(mockRepository.getAllContainers());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}

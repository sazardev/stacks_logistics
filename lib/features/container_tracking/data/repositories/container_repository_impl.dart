import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/container.dart';
import '../../domain/repository_interfaces/container_repository.dart';
import '../data_sources/container_local_data_source.dart';
import '../data_sources/container_remote_data_source.dart';
import '../models/container_model.dart';
// import '../models/location_model.dart';
// import '../models/tracking_entry_model.dart';
import '../exceptions/container_exceptions.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/data_seeding_service.dart';

/// Implementation of ContainerRepository that supports both local and remote data sources
/// with automatic synchronization logic
class ContainerRepositoryImpl implements ContainerRepository {
  ContainerRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  final ContainerLocalDataSource localDataSource;
  final ContainerRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  /// Check if the device has internet connectivity
  Future<bool> get _hasConnection async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet;
  }

  @override
  Future<Either<Failure, List<Container>>> getAllContainers() async {
    try {
      // Try to get containers from local cache first
      final localContainers = await localDataSource.getAllContainers();
      final localEntities = localContainers
          .map((model) => model.toEntity())
          .toList();

      // If local cache is empty, seed with sample data for demo purposes
      if (localEntities.isEmpty) {
        final sampleContainers = DataSeedingService.generateSampleContainers();
        final sampleModels = sampleContainers
            .map((container) => ContainerModel.fromEntity(container))
            .toList();
        await localDataSource.cacheContainers(sampleModels);
        return Right(sampleContainers);
      }

      // If we have network connectivity, try to sync with remote
      if (await _hasConnection) {
        try {
          final remoteContainers = await remoteDataSource.getAllContainers();
          final remoteEntities = remoteContainers
              .map((model) => model.toEntity())
              .toList();

          // Cache the remote data locally
          await localDataSource.cacheContainers(remoteContainers);
          await localDataSource.setLastSyncTime(DateTime.now());

          return Right(remoteEntities);
        } catch (e) {
          // If remote fails but we have local data, return local data
          if (localEntities.isNotEmpty) {
            return Right(localEntities);
          }
          return Left(_mapExceptionToFailure(e));
        }
      }

      // Return local data if no connectivity or remote failed
      return Right(localEntities);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Container>> getContainerById(String id) async {
    try {
      // Try local first for faster response
      final localContainer = await localDataSource.getContainerById(id);
      if (localContainer != null) {
        // If we have connectivity, also try to get fresh data from remote
        if (await _hasConnection) {
          try {
            final remoteContainer = await remoteDataSource.getContainerById(id);
            await localDataSource.cacheContainer(remoteContainer);
            return Right(remoteContainer.toEntity());
          } catch (e) {
            // Return local data if remote fails
            return Right(localContainer.toEntity());
          }
        }
        return Right(localContainer.toEntity());
      }

      // If not in local cache and we have connectivity, try remote
      if (await _hasConnection) {
        final remoteContainer = await remoteDataSource.getContainerById(id);
        await localDataSource.cacheContainer(remoteContainer);
        return Right(remoteContainer.toEntity());
      }

      return const Left(NotFoundFailure(message: 'Container not found'));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Container>>> searchContainers(
    String query,
  ) async {
    try {
      // Search in local cache first
      final localResults = await localDataSource.searchContainers(query);
      final localEntities = localResults
          .map((model) => model.toEntity())
          .toList();

      // If we have connectivity, also search remote and merge results
      if (await _hasConnection) {
        try {
          final remoteResults = await remoteDataSource.searchContainers(query);
          final remoteEntities = remoteResults
              .map((model) => model.toEntity())
              .toList();

          // Cache the remote results
          await localDataSource.cacheContainers(remoteResults);

          // Merge and deduplicate results (prefer remote data)
          final Map<String, Container> mergedResults = {};
          for (final container in localEntities) {
            mergedResults[container.id] = container;
          }
          for (final container in remoteEntities) {
            mergedResults[container.id] = container;
          }

          return Right(mergedResults.values.toList());
        } catch (e) {
          // Return local results if remote search fails
          return Right(localEntities);
        }
      }

      return Right(localEntities);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Container>> createContainer(
    Container container,
  ) async {
    try {
      // Always cache locally first for offline capability
      final model = ContainerModel.fromEntity(container);
      await localDataSource.cacheContainer(model);

      // If we have connectivity, sync to remote
      if (await _hasConnection) {
        try {
          final remoteId = await remoteDataSource.createContainer(model);
          // Update local cache with the remote ID
          final updatedModel = ContainerModel.fromEntity(
            container.copyWith(id: remoteId),
          );
          await localDataSource.cacheContainer(updatedModel);
          return Right(updatedModel.toEntity());
        } catch (e) {
          // Return the locally cached version if remote creation fails
          return Right(container);
        }
      }

      return Right(container);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Container>> updateContainer(
    Container container,
  ) async {
    try {
      // Update local cache first
      final model = ContainerModel.fromEntity(container);
      await localDataSource.cacheContainer(model);

      // If we have connectivity, sync to remote
      if (await _hasConnection) {
        try {
          await remoteDataSource.updateContainer(model);
          await localDataSource.setLastSyncTime(DateTime.now());
        } catch (e) {
          // Log the sync failure but return success since local update succeeded
          // TODO: Implement sync queue for failed operations
        }
      }

      return Right(container);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContainer(String id) async {
    try {
      // Delete from local cache first
      await localDataSource.deleteContainer(id);

      // If we have connectivity, delete from remote
      if (await _hasConnection) {
        try {
          await remoteDataSource.deleteContainer(id);
        } catch (e) {
          // Log the sync failure but return success since local deletion succeeded
          // TODO: Implement sync queue for failed operations
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Container>>> getContainersByStatus(
    ContainerStatus status,
  ) async {
    try {
      // Get from local cache
      final localContainers = await localDataSource.getContainersByStatus(
        status.name,
      );
      final localEntities = localContainers
          .map((model) => model.toEntity())
          .toList();

      // If we have connectivity, try to get fresh data from remote
      if (await _hasConnection) {
        try {
          final remoteContainers = await remoteDataSource.getContainersByStatus(
            status.name,
          );
          final remoteEntities = remoteContainers
              .map((model) => model.toEntity())
              .toList();

          // Cache the remote data locally
          await localDataSource.cacheContainers(remoteContainers);

          return Right(remoteEntities);
        } catch (e) {
          // Return local data if remote fails
          return Right(localEntities);
        }
      }

      return Right(localEntities);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Container>>> getContainersByPriority(
    Priority priority,
  ) async {
    try {
      // Get from local cache
      final localContainers = await localDataSource.getContainersByPriority(
        priority.name,
      );
      final localEntities = localContainers
          .map((model) => model.toEntity())
          .toList();

      // If we have connectivity, try to get fresh data from remote
      if (await _hasConnection) {
        try {
          final remoteContainers = await remoteDataSource
              .getContainersByPriority(priority.name);
          final remoteEntities = remoteContainers
              .map((model) => model.toEntity())
              .toList();

          // Cache the remote data locally
          await localDataSource.cacheContainers(remoteContainers);

          return Right(remoteEntities);
        } catch (e) {
          // Return local data if remote fails
          return Right(localEntities);
        }
      }

      return Right(localEntities);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Add missing repository methods with basic implementations

  @override
  Future<Either<Failure, void>> addTrackingEntry(
    String containerId,
    TrackingEntry entry,
  ) async {
    // TODO: Implement adding tracking entry
    return const Left(UnknownFailure(message: 'Not implemented yet'));
  }

  @override
  Future<Either<Failure, List<TrackingEntry>>> getTrackingHistory(
    String containerId,
  ) async {
    // TODO: Implement getting tracking history
    return const Left(UnknownFailure(message: 'Not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> syncData() async {
    // TODO: Implement full data synchronization
    return const Left(UnknownFailure(message: 'Not implemented yet'));
  }

  @override
  Future<Either<Failure, List<Container>>> getOverdueContainers() async {
    // TODO: Implement getting overdue containers
    return const Left(UnknownFailure(message: 'Not implemented yet'));
  }

  @override
  Future<Either<Failure, List<Container>>> bulkUpdateContainers(
    List<Container> containers,
  ) async {
    // TODO: Implement bulk update
    return const Left(UnknownFailure(message: 'Not implemented yet'));
  }

  @override
  Future<Either<Failure, List<Container>>> getContainersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // TODO: Implement date range filtering
    return const Left(UnknownFailure(message: 'Not implemented yet'));
  }

  @override
  Future<Either<Failure, String>> exportContainerData(
    List<String> containerIds,
  ) async {
    // TODO: Implement data export
    return const Left(UnknownFailure(message: 'Not implemented yet'));
  }

  /// Map exceptions to appropriate failure types
  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception is ContainerNotFoundException) {
      return NotFoundFailure(message: exception.message);
    } else if (exception is UserNotAuthenticatedException) {
      return const AuthFailure(message: 'User not authenticated');
    } else if (exception is ContainerValidationException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is ContainerSyncException) {
      return SyncFailure(message: exception.message);
    } else if (exception is ContainerPermissionException) {
      return PermissionFailure(message: exception.message);
    } else if (exception is ServerException) {
      return ServerFailure(message: exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(message: exception.message);
    } else if (exception is LocalStorageException) {
      return LocalStorageFailure(message: exception.message);
    } else {
      return UnknownFailure(
        message: 'An unexpected error occurred: $exception',
      );
    }
  }
}

/// Extension to convert Container entity to its model representation
// extension ContainerToModel on Container {
//   /// Convert Container entity to ContainerModel for data layer
//   ///
//   /// This method creates a ContainerModel instance from the domain entity,
//   /// which can then be used for local storage or remote API operations.
//   ContainerModel toModel() {
//     return ContainerModel(
//       id: id,
//       containerNumber: containerNumber,
//       status: status.name,
//       currentLocation: LocationModel.fromEntity(currentLocation),
//       destination: LocationModel.fromEntity(destination),
//       origin: LocationModel.fromEntity(origin),
//       contents: contents,
//       weight: weight,
//       priority: priority.name,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//       estimatedArrival: estimatedArrival,
//       actualArrival: actualArrival,
//       notes: notes,
//       trackingHistory: trackingHistory
//           .map((entry) => TrackingEntryModel.fromEntity(entry))
//           .toList(),
//     );
//   }
// }

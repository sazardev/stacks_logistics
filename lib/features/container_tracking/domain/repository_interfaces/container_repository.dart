import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/container.dart';

/// Repository interface for container tracking operations
abstract class ContainerRepository {
  /// Retrieves all containers
  Future<Either<Failure, List<Container>>> getAllContainers();

  /// Retrieves a specific container by ID
  Future<Either<Failure, Container>> getContainerById(String id);

  /// Retrieves containers by status
  Future<Either<Failure, List<Container>>> getContainersByStatus(
    ContainerStatus status,
  );

  /// Searches containers by container number or contents
  Future<Either<Failure, List<Container>>> searchContainers(String query);

  /// Creates a new container
  Future<Either<Failure, Container>> createContainer(Container container);

  /// Updates an existing container
  Future<Either<Failure, Container>> updateContainer(Container container);

  /// Deletes a container
  Future<Either<Failure, void>> deleteContainer(String id);

  /// Adds a tracking entry to a container
  Future<Either<Failure, void>> addTrackingEntry(
    String containerId,
    TrackingEntry entry,
  );

  /// Retrieves tracking history for a container
  Future<Either<Failure, List<TrackingEntry>>> getTrackingHistory(
    String containerId,
  );

  /// Synchronizes local data with remote data
  Future<Either<Failure, void>> syncData();

  /// Retrieves containers that are overdue
  Future<Either<Failure, List<Container>>> getOverdueContainers();

  /// Retrieves containers by priority
  Future<Either<Failure, List<Container>>> getContainersByPriority(
    Priority priority,
  );

  /// Bulk updates multiple containers
  Future<Either<Failure, List<Container>>> bulkUpdateContainers(
    List<Container> containers,
  );

  /// Retrieves containers within a date range
  Future<Either<Failure, List<Container>>> getContainersByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Exports container data
  Future<Either<Failure, String>> exportContainerData(
    List<String> containerIds,
  );
}

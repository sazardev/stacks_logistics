import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/container.dart';
import '../repository_interfaces/container_repository.dart';

/// Use case for updating an existing container
class UpdateContainer {
  const UpdateContainer(this.repository);

  final ContainerRepository repository;

  Future<Either<Failure, Container>> call(Container container) {
    // Validate container data
    final validation = _validateContainer(container);
    if (validation != null) {
      return Future.value(Left(validation));
    }

    return repository.updateContainer(container);
  }

  ValidationFailure? _validateContainer(Container container) {
    if (container.id.isEmpty) {
      return const ValidationFailure(message: 'Container ID cannot be empty');
    }

    if (container.containerNumber.isEmpty) {
      return const ValidationFailure(
        message: 'Container number cannot be empty',
      );
    }

    if (container.contents.isEmpty) {
      return const ValidationFailure(
        message: 'Container contents cannot be empty',
      );
    }

    if (container.weight <= 0) {
      return const ValidationFailure(
        message: 'Container weight must be greater than 0',
      );
    }

    // Validate container number format (4 letters + 7 digits)
    final containerNumberRegex = RegExp(r'^[A-Z]{4}[0-9]{7}$');
    if (!containerNumberRegex.hasMatch(container.containerNumber)) {
      return const ValidationFailure(
        message:
            'Invalid container number format. Expected format: ABCD1234567',
      );
    }

    // Validate dates - updatedAt should be after createdAt
    if (container.updatedAt.isBefore(container.createdAt)) {
      return const ValidationFailure(
        message: 'Updated date cannot be before created date',
      );
    }

    // Validate estimated arrival if provided
    if (container.estimatedArrival != null &&
        container.estimatedArrival!.isBefore(container.createdAt)) {
      return const ValidationFailure(
        message: 'Estimated arrival cannot be before container creation date',
      );
    }

    // Validate actual arrival if provided
    if (container.actualArrival != null &&
        container.actualArrival!.isBefore(container.createdAt)) {
      return const ValidationFailure(
        message: 'Actual arrival cannot be before container creation date',
      );
    }

    return null;
  }
}

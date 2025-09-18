import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repository_interfaces/container_repository.dart';

/// Use case for deleting a container
class DeleteContainer {
  const DeleteContainer(this.repository);

  final ContainerRepository repository;

  Future<Either<Failure, void>> call(String id) {
    if (id.isEmpty) {
      return Future.value(
        const Left(ValidationFailure(message: 'Container ID cannot be empty')),
      );
    }

    return repository.deleteContainer(id);
  }
}

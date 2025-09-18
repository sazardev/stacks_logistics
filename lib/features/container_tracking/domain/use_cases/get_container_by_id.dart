import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/container.dart';
import '../repository_interfaces/container_repository.dart';

/// Use case for retrieving a container by ID
class GetContainerById {
  const GetContainerById(this.repository);

  final ContainerRepository repository;

  Future<Either<Failure, Container>> call(String id) {
    if (id.isEmpty) {
      return Future.value(
        const Left(ValidationFailure(message: 'Container ID cannot be empty')),
      );
    }

    return repository.getContainerById(id);
  }
}

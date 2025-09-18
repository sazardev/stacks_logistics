import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/container.dart';
import '../repository_interfaces/container_repository.dart';

/// Use case for retrieving all containers
class GetAllContainers {
  const GetAllContainers(this.repository);

  final ContainerRepository repository;

  Future<Either<Failure, List<Container>>> call() {
    return repository.getAllContainers();
  }
}

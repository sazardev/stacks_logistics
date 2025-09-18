import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/container.dart';
import '../repository_interfaces/container_repository.dart';

/// Use case for retrieving containers by priority
class GetContainersByPriority {
  const GetContainersByPriority(this.repository);

  final ContainerRepository repository;

  Future<Either<Failure, List<Container>>> call(Priority priority) {
    return repository.getContainersByPriority(priority);
  }
}

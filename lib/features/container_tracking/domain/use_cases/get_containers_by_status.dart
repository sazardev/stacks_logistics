import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/container.dart';
import '../repository_interfaces/container_repository.dart';

/// Use case for retrieving containers by status
class GetContainersByStatus {
  const GetContainersByStatus(this.repository);

  final ContainerRepository repository;

  Future<Either<Failure, List<Container>>> call(ContainerStatus status) {
    return repository.getContainersByStatus(status);
  }
}

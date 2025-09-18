import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/container.dart';
import '../repository_interfaces/container_repository.dart';

/// Use case for searching containers
class SearchContainers {
  const SearchContainers(this.repository);

  final ContainerRepository repository;

  Future<Either<Failure, List<Container>>> call(String query) {
    if (query.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure(message: 'Search query cannot be empty')),
      );
    }

    if (query.trim().length < 2) {
      return Future.value(
        const Left(
          ValidationFailure(
            message: 'Search query must be at least 2 characters long',
          ),
        ),
      );
    }

    return repository.searchContainers(query.trim());
  }
}

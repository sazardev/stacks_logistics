import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for use cases in the application
abstract class UseCase<Type, Params> {
  /// Execute the use case
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case that doesn't require parameters
abstract class UseCaseNoParams<Type> {
  /// Execute the use case
  Future<Either<Failure, Type>> call();
}

/// Use case that returns a stream
abstract class StreamUseCase<Type, Params> {
  /// Execute the use case
  Stream<Either<Failure, Type>> call(Params params);
}

/// Use case that returns a stream and doesn't require parameters
abstract class StreamUseCaseNoParams<Type> {
  /// Execute the use case
  Stream<Either<Failure, Type>> call();
}

/// No parameters class for use cases that don't need parameters
class NoParams {
  const NoParams();
}

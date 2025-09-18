import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repository_interfaces/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';

/// Use case for listening to authentication state changes
class AuthStateChangesUseCase implements StreamUseCaseNoParams<User?> {
  const AuthStateChangesUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Stream<Either<Failure, User?>> call() {
    return repository.authStateChanges;
  }
}

import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repository_interfaces/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';

/// Use case for signing in with email and password
class SignInUseCase implements UseCase<User, SignInParams> {
  const SignInUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters for sign in use case
class SignInParams {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;
}

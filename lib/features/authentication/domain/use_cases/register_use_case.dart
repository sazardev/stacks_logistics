import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repository_interfaces/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';

/// Use case for registering with email and password
class RegisterUseCase implements UseCase<User, RegisterParams> {
  const RegisterUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.registerWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
      companyName: params.companyName,
    );
  }
}

/// Parameters for register use case
class RegisterParams {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    this.companyName,
  });

  final String email;
  final String password;
  final String name;
  final String? companyName;
}

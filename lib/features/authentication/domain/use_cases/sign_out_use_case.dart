import 'package:dartz/dartz.dart';
import '../repository_interfaces/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';

/// Use case for signing out
class SignOutUseCase implements UseCaseNoParams<void> {
  const SignOutUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}

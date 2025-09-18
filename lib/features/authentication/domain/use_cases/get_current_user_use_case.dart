import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repository_interfaces/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';

/// Use case for getting current user
class GetCurrentUserUseCase implements UseCaseNoParams<User?> {
  const GetCurrentUserUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, User?>> call() async {
    return await repository.getCurrentUser();
  }
}

import 'package:dartz/dartz.dart';
import '../repository_interfaces/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';

/// Use case for sending password reset email
class SendPasswordResetEmailUseCase
    implements UseCase<void, SendPasswordResetEmailParams> {
  const SendPasswordResetEmailUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(
    SendPasswordResetEmailParams params,
  ) async {
    return await repository.sendPasswordResetEmail(params.email);
  }
}

/// Parameters for send password reset email use case
class SendPasswordResetEmailParams {
  const SendPasswordResetEmailParams({required this.email});

  final String email;
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repository_interfaces/notification_repository.dart';

/// Use case for initializing FCM and getting device token
class InitializeFCMUseCase implements UseCaseNoParams<String?> {
  const InitializeFCMUseCase({required this.repository});

  final NotificationRepository repository;

  @override
  Future<Either<Failure, String?>> call() async {
    return await repository.initializeFCM();
  }
}

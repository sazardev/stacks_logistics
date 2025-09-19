import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/app_notification.dart';
import '../repository_interfaces/notification_repository.dart';

/// Use case for getting notifications by container ID
class GetNotificationsByContainerUseCase
    implements
        UseCase<List<AppNotification>, GetNotificationsByContainerParams> {
  const GetNotificationsByContainerUseCase({required this.repository});

  final NotificationRepository repository;

  @override
  Future<Either<Failure, List<AppNotification>>> call(
    GetNotificationsByContainerParams params,
  ) async {
    if (params.containerId.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Container ID cannot be empty'),
      );
    }

    return await repository.getNotificationsByContainer(params.containerId);
  }
}

/// Parameters for getting notifications by container
class GetNotificationsByContainerParams {
  const GetNotificationsByContainerParams({required this.containerId});

  final String containerId;
}

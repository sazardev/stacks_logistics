import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repository_interfaces/notification_repository.dart';

/// Use case for marking a notification as read
class MarkNotificationAsReadUseCase
    implements UseCase<void, MarkNotificationAsReadParams> {
  const MarkNotificationAsReadUseCase({required this.repository});

  final NotificationRepository repository;

  @override
  Future<Either<Failure, void>> call(
    MarkNotificationAsReadParams params,
  ) async {
    if (params.notificationId.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Notification ID cannot be empty'),
      );
    }

    return await repository.markAsRead(params.notificationId);
  }
}

/// Parameters for marking notification as read
class MarkNotificationAsReadParams {
  const MarkNotificationAsReadParams({required this.notificationId});

  final String notificationId;
}

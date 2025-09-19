import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/app_notification.dart';
import '../repository_interfaces/notification_repository.dart';

/// Use case for getting all notifications
class GetAllNotificationsUseCase
    implements UseCaseNoParams<List<AppNotification>> {
  const GetAllNotificationsUseCase({required this.repository});

  final NotificationRepository repository;

  @override
  Future<Either<Failure, List<AppNotification>>> call() async {
    return await repository.getAllNotifications();
  }
}

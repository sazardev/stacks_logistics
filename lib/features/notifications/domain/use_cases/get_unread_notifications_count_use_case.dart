import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repository_interfaces/notification_repository.dart';

/// Use case for getting unread notifications count
class GetUnreadNotificationsCountUseCase implements UseCaseNoParams<int> {
  const GetUnreadNotificationsCountUseCase({required this.repository});

  final NotificationRepository repository;

  @override
  Future<Either<Failure, int>> call() async {
    return await repository.getUnreadNotificationsCount();
  }
}

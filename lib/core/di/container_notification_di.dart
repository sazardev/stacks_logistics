import 'package:get_it/get_it.dart';
import '../services/container_notification_service.dart';

class ContainerNotificationDI {
  ContainerNotificationDI._();

  static void init() {
    GetIt.instance.registerLazySingleton<ContainerNotificationService>(
      () => ContainerNotificationService(
        notificationRepository: GetIt.instance(),
      ),
    );
  }
}

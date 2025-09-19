import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'data/data_sources/notification_local_data_source.dart';
import 'data/data_sources/notification_remote_data_source.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'data/models/notification_model.dart';
import 'domain/repository_interfaces/notification_repository.dart';
import 'domain/use_cases/get_all_notifications_use_case.dart';
import 'domain/use_cases/get_unread_notifications_count_use_case.dart';
import 'domain/use_cases/mark_notification_as_read_use_case.dart';
import 'domain/use_cases/initialize_fcm_use_case.dart';
import 'domain/use_cases/get_notifications_by_container_use_case.dart';
import 'presentation/blocs/notification_bloc.dart';
import '../../core/network/network_info.dart';

/// Notification feature dependency injection configuration
class NotificationDI {
  static Future<void> init(GetIt getIt) async {
    // Initialize Hive box for notifications
    await _initHive();

    // Data sources
    getIt.registerLazySingleton<NotificationLocalDataSource>(
      () => NotificationLocalDataSourceImpl(
        hiveBox: Hive.box<NotificationModel>('notifications'),
        sharedPreferences: getIt<SharedPreferences>(),
      ),
    );

    getIt.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(
        firestore: getIt<FirebaseFirestore>(),
        firebaseAuth: getIt<FirebaseAuth>(),
        firebaseMessaging: getIt<FirebaseMessaging>(),
      ),
    );

    // Repository
    getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        remoteDataSource: getIt<NotificationRemoteDataSource>(),
        localDataSource: getIt<NotificationLocalDataSource>(),
        networkInfo: getIt<NetworkInfo>(),
      ),
    );

    // Use cases
    getIt.registerLazySingleton<GetAllNotificationsUseCase>(
      () => GetAllNotificationsUseCase(
        repository: getIt<NotificationRepository>(),
      ),
    );

    getIt.registerLazySingleton<GetUnreadNotificationsCountUseCase>(
      () => GetUnreadNotificationsCountUseCase(
        repository: getIt<NotificationRepository>(),
      ),
    );

    getIt.registerLazySingleton<MarkNotificationAsReadUseCase>(
      () => MarkNotificationAsReadUseCase(
        repository: getIt<NotificationRepository>(),
      ),
    );

    getIt.registerLazySingleton<InitializeFCMUseCase>(
      () => InitializeFCMUseCase(repository: getIt<NotificationRepository>()),
    );

    getIt.registerLazySingleton<GetNotificationsByContainerUseCase>(
      () => GetNotificationsByContainerUseCase(
        repository: getIt<NotificationRepository>(),
      ),
    );

    // BLoC
    getIt.registerFactory<NotificationBloc>(
      () => NotificationBloc(
        getAllNotificationsUseCase: getIt<GetAllNotificationsUseCase>(),
        getUnreadNotificationsCountUseCase:
            getIt<GetUnreadNotificationsCountUseCase>(),
        markNotificationAsReadUseCase: getIt<MarkNotificationAsReadUseCase>(),
        initializeFCMUseCase: getIt<InitializeFCMUseCase>(),
        getNotificationsByContainerUseCase:
            getIt<GetNotificationsByContainerUseCase>(),
        notificationRepository: getIt<NotificationRepository>(),
      ),
    );

    // Register Firebase Messaging if not already registered
    if (!getIt.isRegistered<FirebaseMessaging>()) {
      getIt.registerLazySingleton<FirebaseMessaging>(
        () => FirebaseMessaging.instance,
      );
    }
  }

  /// Initialize Hive box for notifications
  static Future<void> _initHive() async {
    if (!Hive.isBoxOpen('notifications')) {
      await Hive.openBox<NotificationModel>('notifications');
    }
  }

  /// Close Hive boxes when app closes
  static Future<void> dispose() async {
    if (Hive.isBoxOpen('notifications')) {
      await Hive.box<NotificationModel>('notifications').close();
    }
  }
}

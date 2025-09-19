import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repository_interfaces/notification_repository.dart';
import '../data_sources/notification_local_data_source.dart';
import '../data_sources/notification_remote_data_source.dart';
import '../models/notification_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';

/// Implementation of NotificationRepository
class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final NotificationRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<AppNotification>>> getAllNotifications() async {
    try {
      // Always try to get from remote first if connected
      if (await networkInfo.isConnected) {
        try {
          final remoteNotifications = await remoteDataSource
              .getAllNotifications();

          // Cache the notifications locally
          await localDataSource.cacheNotifications(remoteNotifications);

          return Right(
            remoteNotifications.map((model) => model.toEntity()).toList(),
          );
        } catch (e) {
          // If remote fails, fall back to local
          final localNotifications = await localDataSource
              .getAllNotifications();
          return Right(
            localNotifications.map((model) => model.toEntity()).toList(),
          );
        }
      } else {
        // No network, get from local storage
        final localNotifications = await localDataSource.getAllNotifications();
        return Right(
          localNotifications.map((model) => model.toEntity()).toList(),
        );
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadNotificationsCount() async {
    try {
      // Always check local cache for speed
      final count = await localDataSource.getUnreadNotificationsCount();
      return Right(count);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get unread count: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AppNotification>>> getNotificationsByType(
    NotificationType type,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteNotifications = await remoteDataSource
              .getNotificationsByType(type);
          await localDataSource.cacheNotifications(remoteNotifications);
          return Right(
            remoteNotifications.map((model) => model.toEntity()).toList(),
          );
        } catch (e) {
          final localNotifications = await localDataSource
              .getNotificationsByType(type);
          return Right(
            localNotifications.map((model) => model.toEntity()).toList(),
          );
        }
      } else {
        final localNotifications = await localDataSource.getNotificationsByType(
          type,
        );
        return Right(
          localNotifications.map((model) => model.toEntity()).toList(),
        );
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AppNotification>>> getNotificationsByPriority(
    NotificationPriority priority,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteNotifications = await remoteDataSource
              .getNotificationsByPriority(priority);
          await localDataSource.cacheNotifications(remoteNotifications);
          return Right(
            remoteNotifications.map((model) => model.toEntity()).toList(),
          );
        } catch (e) {
          final localNotifications = await localDataSource
              .getNotificationsByPriority(priority);
          return Right(
            localNotifications.map((model) => model.toEntity()).toList(),
          );
        }
      } else {
        final localNotifications = await localDataSource
            .getNotificationsByPriority(priority);
        return Right(
          localNotifications.map((model) => model.toEntity()).toList(),
        );
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AppNotification>>> getNotificationsByContainer(
    String containerId,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteNotifications = await remoteDataSource
              .getNotificationsByContainer(containerId);
          await localDataSource.cacheNotifications(remoteNotifications);
          return Right(
            remoteNotifications.map((model) => model.toEntity()).toList(),
          );
        } catch (e) {
          final localNotifications = await localDataSource
              .getNotificationsByContainer(containerId);
          return Right(
            localNotifications.map((model) => model.toEntity()).toList(),
          );
        }
      } else {
        final localNotifications = await localDataSource
            .getNotificationsByContainer(containerId);
        return Right(
          localNotifications.map((model) => model.toEntity()).toList(),
        );
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      // Always update local immediately for UI responsiveness
      await localDataSource.markAsRead(notificationId);

      // Update remote if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.markAsRead(notificationId);
        } catch (e) {
          // Remote update failed, but local is updated
          // This will be synced later
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to mark notification as read: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      // Always update local immediately
      await localDataSource.markAllAsRead();

      // Update remote if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.markAllAsRead();
        } catch (e) {
          // Remote update failed, but local is updated
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to mark all notifications as read: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    try {
      // Delete locally first
      await localDataSource.deleteNotification(notificationId);

      // Delete from remote if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteNotification(notificationId);
        } catch (e) {
          // Remote delete failed, but local is deleted
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications() async {
    try {
      // Delete locally first
      await localDataSource.deleteAllNotifications();

      // Note: We don't delete all from remote server for safety
      // This would typically be a soft delete or archive operation

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to delete all notifications: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AppNotification>> createNotification(
    AppNotification notification,
  ) async {
    try {
      final notificationModel = NotificationModel.fromEntity(notification);

      // Cache locally first
      await localDataSource.cacheNotification(notificationModel);

      // Create on remote if connected
      if (await networkInfo.isConnected) {
        try {
          final remoteNotification = await remoteDataSource.createNotification(
            notificationModel,
          );
          // Update local with remote version (might have server-generated fields)
          await localDataSource.cacheNotification(remoteNotification);
          return Right(remoteNotification.toEntity());
        } catch (e) {
          // Remote creation failed, but local is cached
          return Right(notificationModel.toEntity());
        }
      }

      return Right(notificationModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create notification: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> initializeFCM() async {
    try {
      final token = await remoteDataSource.initializeFCM();

      if (token != null) {
        await localDataSource.saveFCMToken(token);
      }

      return Right(token);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to initialize FCM: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> subscribeToTopic(String topic) async {
    try {
      await remoteDataSource.subscribeToTopic(topic);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to subscribe to topic: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic) async {
    try {
      await remoteDataSource.unsubscribeFromTopic(topic);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to unsubscribe from topic: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateFCMToken(String token) async {
    try {
      await localDataSource.saveFCMToken(token);

      if (await networkInfo.isConnected) {
        await remoteDataSource.updateFCMToken(token);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update FCM token: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getFCMToken() async {
    try {
      final token = await localDataSource.getFCMToken();
      return Right(token);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get FCM token: $e'));
    }
  }

  @override
  Stream<Either<Failure, AppNotification>> get notificationStream {
    return remoteDataSource.fcmMessageStream
        .map<Either<Failure, AppNotification>>((notificationModel) {
          // Cache incoming notifications locally
          localDataSource.cacheNotification(notificationModel);
          return Right(notificationModel.toEntity());
        })
        .handleError((error) {
          return Left(ServerFailure(message: 'FCM stream error: $error'));
        });
  }

  @override
  Future<Either<Failure, void>> clearLocalNotifications() async {
    try {
      await localDataSource.deleteAllNotifications();
      await localDataSource.clearFCMToken();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to clear local notifications: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<AppNotification>>> syncNotifications() async {
    try {
      if (!(await networkInfo.isConnected)) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      // Get last sync time (simplified - in real app would store this)
      final lastSyncTime = DateTime.now().subtract(const Duration(days: 7));

      final remoteNotifications = await remoteDataSource.syncNotifications(
        lastSyncTime,
      );
      await localDataSource.cacheNotifications(remoteNotifications);

      return Right(
        remoteNotifications.map((model) => model.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sync notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationSettings>>
  getNotificationSettings() async {
    try {
      final settings = await localDataSource.getNotificationSettings();
      return Right(settings);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to get notification settings: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateNotificationSettings(
    NotificationSettings settings,
  ) async {
    try {
      await localDataSource.saveNotificationSettings(settings);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to update notification settings: $e'),
      );
    }
  }
}

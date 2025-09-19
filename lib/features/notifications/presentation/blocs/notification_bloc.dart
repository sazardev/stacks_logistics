import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_all_notifications_use_case.dart';
import '../../domain/use_cases/get_unread_notifications_count_use_case.dart';
import '../../domain/use_cases/mark_notification_as_read_use_case.dart';
import '../../domain/use_cases/initialize_fcm_use_case.dart';
import '../../domain/use_cases/get_notifications_by_container_use_case.dart';
import '../../domain/repository_interfaces/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC for managing notification state and operations
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    required this.getAllNotificationsUseCase,
    required this.getUnreadNotificationsCountUseCase,
    required this.markNotificationAsReadUseCase,
    required this.initializeFCMUseCase,
    required this.getNotificationsByContainerUseCase,
    required this.notificationRepository,
  }) : super(const NotificationInitial()) {
    on<LoadAllNotifications>(_onLoadAllNotifications);
    on<LoadNotificationsByType>(_onLoadNotificationsByType);
    on<LoadNotificationsByPriority>(_onLoadNotificationsByPriority);
    on<LoadNotificationsByContainer>(_onLoadNotificationsByContainer);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<DeleteAllNotifications>(_onDeleteAllNotifications);
    on<InitializeFCM>(_onInitializeFCM);
    on<SubscribeToTopic>(_onSubscribeToTopic);
    on<UnsubscribeFromTopic>(_onUnsubscribeFromTopic);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<NotificationReceived>(_onNotificationReceived);
    on<GetUnreadNotificationsCount>(_onGetUnreadNotificationsCount);
    on<FilterNotifications>(_onFilterNotifications);
    on<ClearNotificationFilters>(_onClearNotificationFilters);
    on<CreateTestNotification>(_onCreateTestNotification);

    // Listen to incoming notifications
    _notificationStreamSubscription = notificationRepository.notificationStream
        .listen((result) {
          result.fold(
            (failure) {
              // Handle stream error
            },
            (notification) {
              add(NotificationReceived(notification: notification));
            },
          );
        });
  }

  final GetAllNotificationsUseCase getAllNotificationsUseCase;
  final GetUnreadNotificationsCountUseCase getUnreadNotificationsCountUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final InitializeFCMUseCase initializeFCMUseCase;
  final GetNotificationsByContainerUseCase getNotificationsByContainerUseCase;
  final NotificationRepository notificationRepository;

  StreamSubscription? _notificationStreamSubscription;

  @override
  Future<void> close() {
    _notificationStreamSubscription?.cancel();
    return super.close();
  }

  /// Load all notifications
  Future<void> _onLoadAllNotifications(
    LoadAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await getAllNotificationsUseCase();
    final countResult = await getUnreadNotificationsCountUseCase();

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) {
        final unreadCount = countResult.fold((failure) => 0, (count) => count);

        emit(
          NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ),
        );
      },
    );
  }

  /// Load notifications by type
  Future<void> _onLoadNotificationsByType(
    LoadNotificationsByType event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await notificationRepository.getNotificationsByType(
      event.type,
    );
    final countResult = await getUnreadNotificationsCountUseCase();

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) {
        final unreadCount = countResult.fold((failure) => 0, (count) => count);

        emit(
          NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ),
        );
      },
    );
  }

  /// Load notifications by priority
  Future<void> _onLoadNotificationsByPriority(
    LoadNotificationsByPriority event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await notificationRepository.getNotificationsByPriority(
      event.priority,
    );
    final countResult = await getUnreadNotificationsCountUseCase();

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) {
        final unreadCount = countResult.fold((failure) => 0, (count) => count);

        emit(
          NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ),
        );
      },
    );
  }

  /// Load notifications by container
  Future<void> _onLoadNotificationsByContainer(
    LoadNotificationsByContainer event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final params = GetNotificationsByContainerParams(
      containerId: event.containerId,
    );
    final result = await getNotificationsByContainerUseCase(params);
    final countResult = await getUnreadNotificationsCountUseCase();

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) {
        final unreadCount = countResult.fold((failure) => 0, (count) => count);

        emit(
          NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ),
        );
      },
    );
  }

  /// Mark notification as read
  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      final params = MarkNotificationAsReadParams(
        notificationId: event.notificationId,
      );
      final result = await markNotificationAsReadUseCase(params);

      result.fold(
        (failure) => emit(NotificationError(message: failure.message)),
        (_) {
          emit(currentState.copyWithNotificationRead(event.notificationId));
        },
      );
    }
  }

  /// Mark all notifications as read
  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      final result = await notificationRepository.markAllAsRead();

      result.fold(
        (failure) => emit(NotificationError(message: failure.message)),
        (_) {
          emit(currentState.copyWithAllNotificationsRead());
        },
      );
    }
  }

  /// Delete notification
  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      final result = await notificationRepository.deleteNotification(
        event.notificationId,
      );

      result.fold(
        (failure) => emit(NotificationError(message: failure.message)),
        (_) {
          emit(currentState.copyWithNotificationRemoved(event.notificationId));
        },
      );
    }
  }

  /// Delete all notifications
  Future<void> _onDeleteAllNotifications(
    DeleteAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await notificationRepository.deleteAllNotifications();

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) {
        emit(const NotificationLoaded(notifications: [], unreadCount: 0));
      },
    );
  }

  /// Initialize FCM
  Future<void> _onInitializeFCM(
    InitializeFCM event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await initializeFCMUseCase();

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (token) {
        if (token != null) {
          emit(FCMInitialized(token: token));
        }
      },
    );
  }

  /// Subscribe to topic
  Future<void> _onSubscribeToTopic(
    SubscribeToTopic event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await notificationRepository.subscribeToTopic(event.topic);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) {
        emit(
          NotificationActionSuccess(message: 'Subscribed to ${event.topic}'),
        );
      },
    );
  }

  /// Unsubscribe from topic
  Future<void> _onUnsubscribeFromTopic(
    UnsubscribeFromTopic event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await notificationRepository.unsubscribeFromTopic(
      event.topic,
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) {
        emit(
          NotificationActionSuccess(
            message: 'Unsubscribed from ${event.topic}',
          ),
        );
      },
    );
  }

  /// Refresh notifications
  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const NotificationLoading());
    }

    final result = await notificationRepository.syncNotifications();
    final countResult = await getUnreadNotificationsCountUseCase();

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) {
        final unreadCount = countResult.fold((failure) => 0, (count) => count);

        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          emit(
            currentState.copyWith(
              notifications: notifications,
              unreadCount: unreadCount,
              isRefreshing: false,
            ),
          );
        } else {
          emit(
            NotificationLoaded(
              notifications: notifications,
              unreadCount: unreadCount,
            ),
          );
        }
      },
    );
  }

  /// Handle received notification
  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(currentState.copyWithNewNotification(event.notification));
    }
  }

  /// Get unread notifications count
  Future<void> _onGetUnreadNotificationsCount(
    GetUnreadNotificationsCount event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await getUnreadNotificationsCountUseCase();

    result.fold(
      (failure) {
        // Don't emit error for count failure, just keep current state
      },
      (count) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          emit(currentState.copyWith(unreadCount: count));
        }
      },
    );
  }

  /// Filter notifications
  void _onFilterNotifications(
    FilterNotifications event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final filters = NotificationFilters(
        type: event.type,
        priority: event.priority,
        showOnlyUnread: event.showOnlyUnread,
        containerId: event.containerId,
      );

      emit(currentState.copyWithFilters(filters));
    }
  }

  /// Clear notification filters
  void _onClearNotificationFilters(
    ClearNotificationFilters event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(currentState.copyWithClearedFilters());
    }
  }

  /// Create test notification
  Future<void> _onCreateTestNotification(
    CreateTestNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await notificationRepository.createNotification(
      event.notification,
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notification) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          emit(currentState.copyWithNewNotification(notification));
        }
      },
    );
  }
}

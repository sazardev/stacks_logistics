import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/use_cases/get_all_containers.dart';
import '../../domain/use_cases/get_container_by_id.dart';
import '../../domain/use_cases/search_containers.dart' as search_use_case;
import '../../domain/use_cases/get_containers_by_status.dart';
import '../../domain/use_cases/get_containers_by_priority.dart';
import '../../domain/use_cases/create_container.dart' as create_use_case;
import '../../domain/use_cases/update_container.dart' as update_use_case;
import '../../domain/use_cases/delete_container.dart' as delete_use_case;
import 'container_tracking_event.dart';
import 'container_tracking_state.dart';

/// BLoC for container tracking operations
class ContainerTrackingBloc
    extends Bloc<ContainerTrackingEvent, ContainerTrackingState> {
  ContainerTrackingBloc({
    required this.getAllContainers,
    required this.getContainerById,
    required this.searchContainers,
    required this.getContainersByStatus,
    required this.getContainersByPriority,
    required this.createContainer,
    required this.updateContainer,
    required this.deleteContainer,
  }) : super(const ContainerTrackingInitial()) {
    on<LoadAllContainers>(_onLoadAllContainers);
    on<LoadContainerById>(_onLoadContainerById);
    on<SearchContainers>(_onSearchContainers);
    on<FilterContainersByStatus>(_onFilterContainersByStatus);
    on<FilterContainersByPriority>(_onFilterContainersByPriority);
    on<CreateContainer>(_onCreateContainer);
    on<UpdateContainer>(_onUpdateContainer);
    on<DeleteContainer>(_onDeleteContainer);
    on<RefreshContainers>(_onRefreshContainers);
    on<ClearSearch>(_onClearSearch);
    on<ClearFilters>(_onClearFilters);
  }

  final GetAllContainers getAllContainers;
  final GetContainerById getContainerById;
  final search_use_case.SearchContainers searchContainers;
  final GetContainersByStatus getContainersByStatus;
  final GetContainersByPriority getContainersByPriority;
  final create_use_case.CreateContainer createContainer;
  final update_use_case.UpdateContainer updateContainer;
  final delete_use_case.DeleteContainer deleteContainer;

  Future<void> _onLoadAllContainers(
    LoadAllContainers event,
    Emitter<ContainerTrackingState> emit,
  ) async {
    emit(const ContainerTrackingLoading());

    final result = await getAllContainers();

    result.fold(
      (failure) => emit(ContainerTrackingError(_mapFailureToMessage(failure))),
      (containers) => emit(ContainerTrackingLoaded(containers: containers)),
    );
  }

  Future<void> _onLoadContainerById(
    LoadContainerById event,
    Emitter<ContainerTrackingState> emit,
  ) async {
    emit(const ContainerTrackingLoading());

    final result = await getContainerById(event.id);

    result.fold(
      (failure) => emit(ContainerTrackingError(_mapFailureToMessage(failure))),
      (container) {
        if (state is ContainerTrackingLoaded) {
          final currentState = state as ContainerTrackingLoaded;
          emit(currentState.copyWith(selectedContainer: container));
        } else {
          emit(
            ContainerTrackingLoaded(
              containers: [container],
              selectedContainer: container,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSearchContainers(
    SearchContainers event,
    Emitter<ContainerTrackingState> emit,
  ) async {
    emit(const ContainerTrackingLoading());

    final result = await searchContainers(event.query);

    result.fold(
      (failure) => emit(ContainerTrackingError(_mapFailureToMessage(failure))),
      (containers) =>
          emit(ContainerSearchResults(results: containers, query: event.query)),
    );
  }

  Future<void> _onFilterContainersByStatus(
    FilterContainersByStatus event,
    Emitter<ContainerTrackingState> emit,
  ) async {
    emit(const ContainerTrackingLoading());

    final result = await getContainersByStatus(event.status);

    result.fold(
      (failure) => emit(ContainerTrackingError(_mapFailureToMessage(failure))),
      (containers) {
        if (state is ContainerTrackingLoaded) {
          final currentState = state as ContainerTrackingLoaded;
          emit(
            currentState.copyWith(
              containers: containers,
              statusFilter: event.status,
            ),
          );
        } else {
          emit(
            ContainerTrackingLoaded(
              containers: containers,
              statusFilter: event.status,
            ),
          );
        }
      },
    );
  }

  Future<void> _onFilterContainersByPriority(
    FilterContainersByPriority event,
    Emitter<ContainerTrackingState> emit,
  ) async {
    emit(const ContainerTrackingLoading());

    final result = await getContainersByPriority(event.priority);

    result.fold(
      (failure) => emit(ContainerTrackingError(_mapFailureToMessage(failure))),
      (containers) {
        if (state is ContainerTrackingLoaded) {
          final currentState = state as ContainerTrackingLoaded;
          emit(
            currentState.copyWith(
              containers: containers,
              priorityFilter: event.priority,
            ),
          );
        } else {
          emit(
            ContainerTrackingLoaded(
              containers: containers,
              priorityFilter: event.priority,
            ),
          );
        }
      },
    );
  }

  Future<void> _onCreateContainer(
    CreateContainer event,
    Emitter<ContainerTrackingState> emit,
  ) async {
    emit(const ContainerTrackingLoading());

    final result = await createContainer(event.container);

    result.fold(
      (failure) => emit(ContainerTrackingError(_mapFailureToMessage(failure))),
      (container) {
        emit(ContainerCreated(container));
        // Refresh the container list
        add(const LoadAllContainers());
      },
    );
  }

  Future<void> _onUpdateContainer(
    UpdateContainer event,
    Emitter<ContainerTrackingState> emit,
  ) async {
    emit(const ContainerTrackingLoading());

    final result = await updateContainer(event.container);

    result.fold(
      (failure) => emit(ContainerTrackingError(_mapFailureToMessage(failure))),
      (container) {
        emit(ContainerUpdated(container));
        // Refresh the container list
        add(const LoadAllContainers());
      },
    );
  }

  Future<void> _onDeleteContainer(
    DeleteContainer event,
    Emitter<ContainerTrackingState> emit,
  ) async {
    emit(const ContainerTrackingLoading());

    final result = await deleteContainer(event.id);

    result.fold(
      (failure) => emit(ContainerTrackingError(_mapFailureToMessage(failure))),
      (_) {
        emit(ContainerDeleted(event.id));
        // Refresh the container list
        add(const LoadAllContainers());
      },
    );
  }

  Future<void> _onRefreshContainers(
    RefreshContainers event,
    Emitter<ContainerTrackingState> emit,
  ) async {
    add(const LoadAllContainers());
  }

  void _onClearSearch(ClearSearch event, Emitter<ContainerTrackingState> emit) {
    if (state is ContainerTrackingLoaded) {
      final currentState = state as ContainerTrackingLoaded;
      emit(currentState.copyWith(clearSearchQuery: true));
    } else if (state is ContainerSearchResults) {
      add(const LoadAllContainers());
    }
  }

  void _onClearFilters(
    ClearFilters event,
    Emitter<ContainerTrackingState> emit,
  ) {
    if (state is ContainerTrackingLoaded) {
      final currentState = state as ContainerTrackingLoaded;
      emit(
        currentState.copyWith(
          clearStatusFilter: true,
          clearPriorityFilter: true,
        ),
      );
      // Reload all containers without filters
      add(const LoadAllContainers());
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Network connection failed. Please check your internet connection.';
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case ValidationFailure:
        return failure.message;
      case NotFoundFailure:
        return 'Container not found.';
      case LocalStorageFailure:
        return 'Local storage error occurred.';
      case AuthFailure:
        return 'Authentication failed. Please login again.';
      case AuthorizationFailure:
        return 'You do not have permission to perform this action.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/container.dart';

/// States for container tracking BLoC
abstract class ContainerTrackingState extends Equatable {
  const ContainerTrackingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ContainerTrackingInitial extends ContainerTrackingState {
  const ContainerTrackingInitial();
}

/// Loading state
class ContainerTrackingLoading extends ContainerTrackingState {
  const ContainerTrackingLoading();
}

/// Loaded state with containers
class ContainerTrackingLoaded extends ContainerTrackingState {
  const ContainerTrackingLoaded({
    required this.containers,
    this.selectedContainer,
    this.searchQuery,
    this.statusFilter,
    this.priorityFilter,
  });

  final List<Container> containers;
  final Container? selectedContainer;
  final String? searchQuery;
  final ContainerStatus? statusFilter;
  final Priority? priorityFilter;

  @override
  List<Object?> get props => [
    containers,
    selectedContainer,
    searchQuery,
    statusFilter,
    priorityFilter,
  ];

  /// Copy with method for state updates
  ContainerTrackingLoaded copyWith({
    List<Container>? containers,
    Container? selectedContainer,
    String? searchQuery,
    ContainerStatus? statusFilter,
    Priority? priorityFilter,
    bool clearSelectedContainer = false,
    bool clearSearchQuery = false,
    bool clearStatusFilter = false,
    bool clearPriorityFilter = false,
  }) {
    return ContainerTrackingLoaded(
      containers: containers ?? this.containers,
      selectedContainer: clearSelectedContainer
          ? null
          : selectedContainer ?? this.selectedContainer,
      searchQuery: clearSearchQuery ? null : searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter
          ? null
          : statusFilter ?? this.statusFilter,
      priorityFilter: clearPriorityFilter
          ? null
          : priorityFilter ?? this.priorityFilter,
    );
  }
}

/// Error state
class ContainerTrackingError extends ContainerTrackingState {
  const ContainerTrackingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Container created successfully state
class ContainerCreated extends ContainerTrackingState {
  const ContainerCreated(this.container);

  final Container container;

  @override
  List<Object?> get props => [container];
}

/// Container updated successfully state
class ContainerUpdated extends ContainerTrackingState {
  const ContainerUpdated(this.container);

  final Container container;

  @override
  List<Object?> get props => [container];
}

/// Container deleted successfully state
class ContainerDeleted extends ContainerTrackingState {
  const ContainerDeleted(this.containerId);

  final String containerId;

  @override
  List<Object?> get props => [containerId];
}

/// Search results state
class ContainerSearchResults extends ContainerTrackingState {
  const ContainerSearchResults({required this.results, required this.query});

  final List<Container> results;
  final String query;

  @override
  List<Object?> get props => [results, query];
}

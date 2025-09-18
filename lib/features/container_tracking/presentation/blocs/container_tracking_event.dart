import 'package:equatable/equatable.dart';
import '../../domain/entities/container.dart';

/// Events for container tracking BLoC
abstract class ContainerTrackingEvent extends Equatable {
  const ContainerTrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all containers
class LoadAllContainers extends ContainerTrackingEvent {
  const LoadAllContainers();
}

/// Event to load a specific container by ID
class LoadContainerById extends ContainerTrackingEvent {
  const LoadContainerById(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Event to search containers
class SearchContainers extends ContainerTrackingEvent {
  const SearchContainers(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to filter containers by status
class FilterContainersByStatus extends ContainerTrackingEvent {
  const FilterContainersByStatus(this.status);

  final ContainerStatus status;

  @override
  List<Object?> get props => [status];
}

/// Event to filter containers by priority
class FilterContainersByPriority extends ContainerTrackingEvent {
  const FilterContainersByPriority(this.priority);

  final Priority priority;

  @override
  List<Object?> get props => [priority];
}

/// Event to create a new container
class CreateContainer extends ContainerTrackingEvent {
  const CreateContainer(this.container);

  final Container container;

  @override
  List<Object?> get props => [container];
}

/// Event to update an existing container
class UpdateContainer extends ContainerTrackingEvent {
  const UpdateContainer(this.container);

  final Container container;

  @override
  List<Object?> get props => [container];
}

/// Event to delete a container
class DeleteContainer extends ContainerTrackingEvent {
  const DeleteContainer(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Event to refresh the container list
class RefreshContainers extends ContainerTrackingEvent {
  const RefreshContainers();
}

/// Event to clear search results
class ClearSearch extends ContainerTrackingEvent {
  const ClearSearch();
}

/// Event to clear all filters
class ClearFilters extends ContainerTrackingEvent {
  const ClearFilters();
}

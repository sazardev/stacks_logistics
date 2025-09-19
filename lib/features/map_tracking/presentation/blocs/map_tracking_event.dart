import 'package:equatable/equatable.dart';
import '../../../container_tracking/domain/entities/container.dart';

/// Events for map tracking BLoC
abstract class MapTrackingEvent extends Equatable {
  const MapTrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all container markers
class LoadContainerMarkers extends MapTrackingEvent {
  const LoadContainerMarkers();
}

/// Event to select a marker on the map
class SelectMarker extends MapTrackingEvent {
  const SelectMarker({required this.markerId});

  final String markerId;

  @override
  List<Object?> get props => [markerId];
}

/// Event to deselect current marker
class DeselectMarker extends MapTrackingEvent {
  const DeselectMarker();
}

/// Event to update map camera position
class UpdateCameraPosition extends MapTrackingEvent {
  const UpdateCameraPosition({
    required this.latitude,
    required this.longitude,
    this.zoom,
  });

  final double latitude;
  final double longitude;
  final double? zoom;

  @override
  List<Object?> get props => [latitude, longitude, zoom];
}

/// Event to get current user location
class GetCurrentLocation extends MapTrackingEvent {
  const GetCurrentLocation();
}

/// Event to filter markers by container status
class FilterMarkersByStatus extends MapTrackingEvent {
  const FilterMarkersByStatus({required this.statuses});

  final List<ContainerStatus> statuses;

  @override
  List<Object?> get props => [statuses];
}

/// Event to search for location
class SearchLocation extends MapTrackingEvent {
  const SearchLocation({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to toggle route visibility
class ToggleRouteVisibility extends MapTrackingEvent {
  const ToggleRouteVisibility({required this.containerId});

  final String containerId;

  @override
  List<Object?> get props => [containerId];
}

/// Event to center map on container
class CenterOnContainer extends MapTrackingEvent {
  const CenterOnContainer({required this.containerId});

  final String containerId;

  @override
  List<Object?> get props => [containerId];
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/map_marker.dart';
import '../../../container_tracking/domain/entities/container.dart';

/// States for map tracking BLoC
abstract class MapTrackingState extends Equatable {
  const MapTrackingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MapTrackingInitial extends MapTrackingState {
  const MapTrackingInitial();
}

/// Loading state
class MapTrackingLoading extends MapTrackingState {
  const MapTrackingLoading();
}

/// Loaded state with markers and routes
class MapTrackingLoaded extends MapTrackingState {
  const MapTrackingLoaded({
    required this.markers,
    this.routes = const [],
    this.selectedMarkerId,
    this.currentUserLocation,
    this.filteredStatuses = const [],
    this.searchResults = const [],
    this.cameraLatitude,
    this.cameraLongitude,
    this.cameraZoom = 10.0,
  });

  /// All markers on the map
  final List<MapMarker> markers;

  /// All routes on the map
  final List<MapRoute> routes;

  /// Currently selected marker ID
  final String? selectedMarkerId;

  /// User's current location
  final MapWaypoint? currentUserLocation;

  /// Status filters applied to markers
  final List<ContainerStatus> filteredStatuses;

  /// Location search results
  final List<MapWaypoint> searchResults;

  /// Current camera position
  final double? cameraLatitude;
  final double? cameraLongitude;
  final double cameraZoom;

  /// Get filtered markers based on status filters
  List<MapMarker> get filteredMarkers {
    if (filteredStatuses.isEmpty) return markers;

    return markers.where((marker) {
      if (marker.container == null) return true;
      return filteredStatuses.contains(marker.container!.status);
    }).toList();
  }

  /// Get currently selected marker
  MapMarker? get selectedMarker {
    if (selectedMarkerId == null) return null;
    return markers.firstWhere(
      (marker) => marker.id == selectedMarkerId,
      orElse: () => markers.first,
    );
  }

  /// Create a copy of this state with updated values
  MapTrackingLoaded copyWith({
    List<MapMarker>? markers,
    List<MapRoute>? routes,
    String? selectedMarkerId,
    bool clearSelectedMarkerId = false,
    MapWaypoint? currentUserLocation,
    List<ContainerStatus>? filteredStatuses,
    List<MapWaypoint>? searchResults,
    double? cameraLatitude,
    double? cameraLongitude,
    double? cameraZoom,
  }) {
    return MapTrackingLoaded(
      markers: markers ?? this.markers,
      routes: routes ?? this.routes,
      selectedMarkerId: clearSelectedMarkerId
          ? null
          : (selectedMarkerId ?? this.selectedMarkerId),
      currentUserLocation: currentUserLocation ?? this.currentUserLocation,
      filteredStatuses: filteredStatuses ?? this.filteredStatuses,
      searchResults: searchResults ?? this.searchResults,
      cameraLatitude: cameraLatitude ?? this.cameraLatitude,
      cameraLongitude: cameraLongitude ?? this.cameraLongitude,
      cameraZoom: cameraZoom ?? this.cameraZoom,
    );
  }

  @override
  List<Object?> get props => [
    markers,
    routes,
    selectedMarkerId,
    currentUserLocation,
    filteredStatuses,
    searchResults,
    cameraLatitude,
    cameraLongitude,
    cameraZoom,
  ];
}

/// Error state
class MapTrackingError extends MapTrackingState {
  const MapTrackingError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Location permission denied state
class MapTrackingLocationPermissionDenied extends MapTrackingState {
  const MapTrackingLocationPermissionDenied();
}

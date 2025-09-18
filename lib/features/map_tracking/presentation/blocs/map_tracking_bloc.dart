import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/map_marker.dart';
import '../../domain/use_cases/get_container_markers_use_case.dart';
import '../../domain/use_cases/get_current_location_use_case.dart';
import '../../domain/use_cases/get_container_route_use_case.dart';
import 'map_tracking_event.dart';
import 'map_tracking_state.dart';

/// BLoC for managing map tracking state and operations
class MapTrackingBloc extends Bloc<MapTrackingEvent, MapTrackingState> {
  MapTrackingBloc({
    required this.getContainerMarkersUseCase,
    required this.getCurrentLocationUseCase,
    required this.getContainerRouteUseCase,
  }) : super(const MapTrackingInitial()) {
    on<LoadContainerMarkers>(_onLoadContainerMarkers);
    on<SelectMarker>(_onSelectMarker);
    on<DeselectMarker>(_onDeselectMarker);
    on<UpdateCameraPosition>(_onUpdateCameraPosition);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<FilterMarkersByStatus>(_onFilterMarkersByStatus);
    on<SearchLocation>(_onSearchLocation);
    on<ToggleRouteVisibility>(_onToggleRouteVisibility);
    on<CenterOnContainer>(_onCenterOnContainer);
  }

  final GetContainerMarkersUseCase getContainerMarkersUseCase;
  final GetCurrentLocationUseCase getCurrentLocationUseCase;
  final GetContainerRouteUseCase getContainerRouteUseCase;

  /// Load all container markers
  Future<void> _onLoadContainerMarkers(
    LoadContainerMarkers event,
    Emitter<MapTrackingState> emit,
  ) async {
    emit(const MapTrackingLoading());

    final result = await getContainerMarkersUseCase();

    result.fold(
      (failure) => emit(MapTrackingError(message: failure.message)),
      (markers) => emit(MapTrackingLoaded(markers: markers)),
    );
  }

  /// Select a marker on the map
  void _onSelectMarker(SelectMarker event, Emitter<MapTrackingState> emit) {
    if (state is MapTrackingLoaded) {
      final currentState = state as MapTrackingLoaded;
      emit(currentState.copyWith(selectedMarkerId: event.markerId));
    }
  }

  /// Deselect current marker
  void _onDeselectMarker(DeselectMarker event, Emitter<MapTrackingState> emit) {
    if (state is MapTrackingLoaded) {
      final currentState = state as MapTrackingLoaded;
      emit(currentState.copyWith(clearSelectedMarkerId: true));
    }
  }

  /// Update camera position
  void _onUpdateCameraPosition(
    UpdateCameraPosition event,
    Emitter<MapTrackingState> emit,
  ) {
    if (state is MapTrackingLoaded) {
      final currentState = state as MapTrackingLoaded;
      emit(
        currentState.copyWith(
          cameraLatitude: event.latitude,
          cameraLongitude: event.longitude,
          cameraZoom: event.zoom,
        ),
      );
    }
  }

  /// Get current user location
  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<MapTrackingState> emit,
  ) async {
    if (state is MapTrackingLoaded) {
      final currentState = state as MapTrackingLoaded;

      final result = await getCurrentLocationUseCase();

      result.fold(
        (failure) => emit(MapTrackingError(message: failure.message)),
        (location) => emit(
          currentState.copyWith(
            currentUserLocation: location,
            cameraLatitude: location.latitude,
            cameraLongitude: location.longitude,
            cameraZoom: 15.0,
          ),
        ),
      );
    }
  }

  /// Filter markers by container status
  void _onFilterMarkersByStatus(
    FilterMarkersByStatus event,
    Emitter<MapTrackingState> emit,
  ) {
    if (state is MapTrackingLoaded) {
      final currentState = state as MapTrackingLoaded;
      emit(currentState.copyWith(filteredStatuses: event.statuses));
    }
  }

  /// Search for location (placeholder implementation)
  Future<void> _onSearchLocation(
    SearchLocation event,
    Emitter<MapTrackingState> emit,
  ) async {
    // TODO: Implement location search using geocoding
    if (state is MapTrackingLoaded) {
      final currentState = state as MapTrackingLoaded;
      // For now, just clear search results
      emit(currentState.copyWith(searchResults: []));
    }
  }

  /// Toggle route visibility for a container
  void _onToggleRouteVisibility(
    ToggleRouteVisibility event,
    Emitter<MapTrackingState> emit,
  ) {
    if (state is MapTrackingLoaded) {
      final currentState = state as MapTrackingLoaded;

      // Toggle route visibility in the routes list
      final updatedRoutes = currentState.routes.map((route) {
        if (route.containerId == event.containerId) {
          return MapRoute(
            id: route.id,
            containerId: route.containerId,
            waypoints: route.waypoints,
            routeType: route.routeType,
            isVisible: !route.isVisible,
            color: route.color,
          );
        }
        return route;
      }).toList();

      emit(currentState.copyWith(routes: updatedRoutes));
    }
  }

  /// Center map on a specific container
  void _onCenterOnContainer(
    CenterOnContainer event,
    Emitter<MapTrackingState> emit,
  ) {
    if (state is MapTrackingLoaded) {
      final currentState = state as MapTrackingLoaded;

      // Find the container marker
      final containerMarker = currentState.markers.firstWhere(
        (marker) =>
            marker.containerId == event.containerId &&
            marker.markerType == MapMarkerType.container,
        orElse: () => currentState.markers.first,
      );

      emit(
        currentState.copyWith(
          cameraLatitude: containerMarker.latitude,
          cameraLongitude: containerMarker.longitude,
          cameraZoom: 15.0,
          selectedMarkerId: containerMarker.id,
        ),
      );
    }
  }
}

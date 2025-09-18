import 'package:equatable/equatable.dart';
import '../../../container_tracking/domain/entities/container.dart';

/// Map marker entity representing a container location on the map
class MapMarker extends Equatable {
  const MapMarker({
    required this.id,
    required this.containerId,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
    required this.markerType,
    this.container,
    this.isSelected = false,
  });

  /// Unique identifier for the marker
  final String id;

  /// Container ID this marker represents
  final String containerId;

  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// Title displayed on the marker
  final String title;

  /// Description displayed when marker is tapped
  final String description;

  /// Type of marker (container, origin, destination, current)
  final MapMarkerType markerType;

  /// Associated container data
  final Container? container;

  /// Whether this marker is currently selected
  final bool isSelected;

  /// Creates a copy of this marker with the given fields replaced
  MapMarker copyWith({
    String? id,
    String? containerId,
    double? latitude,
    double? longitude,
    String? title,
    String? description,
    MapMarkerType? markerType,
    Container? container,
    bool? isSelected,
  }) {
    return MapMarker(
      id: id ?? this.id,
      containerId: containerId ?? this.containerId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      title: title ?? this.title,
      description: description ?? this.description,
      markerType: markerType ?? this.markerType,
      container: container ?? this.container,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Creates a marker from a container entity
  factory MapMarker.fromContainer(Container container) {
    return MapMarker(
      id: 'container_${container.id}',
      containerId: container.id,
      latitude: container.currentLocation.latitude,
      longitude: container.currentLocation.longitude,
      title: container.containerNumber,
      description: '${container.status.name} - ${container.contents}',
      markerType: MapMarkerType.container,
      container: container,
    );
  }

  /// Creates an origin marker from a container
  factory MapMarker.fromOrigin(Container container) {
    return MapMarker(
      id: 'origin_${container.id}',
      containerId: container.id,
      latitude: container.origin.latitude,
      longitude: container.origin.longitude,
      title: 'Origin - ${container.containerNumber}',
      description: 'Starting point: ${container.origin.address}',
      markerType: MapMarkerType.origin,
      container: container,
    );
  }

  /// Creates a destination marker from a container
  factory MapMarker.fromDestination(Container container) {
    return MapMarker(
      id: 'destination_${container.id}',
      containerId: container.id,
      latitude: container.destination.latitude,
      longitude: container.destination.longitude,
      title: 'Destination - ${container.containerNumber}',
      description: 'Target location: ${container.destination.address}',
      markerType: MapMarkerType.destination,
      container: container,
    );
  }

  @override
  List<Object?> get props => [
    id,
    containerId,
    latitude,
    longitude,
    title,
    description,
    markerType,
    container,
    isSelected,
  ];
}

/// Types of map markers
enum MapMarkerType {
  /// Current container location
  container,

  /// Container origin point
  origin,

  /// Container destination point
  destination,

  /// User's current location
  userLocation,
}

/// Map route entity representing a route between locations
class MapRoute extends Equatable {
  const MapRoute({
    required this.id,
    required this.containerId,
    required this.waypoints,
    required this.routeType,
    this.isVisible = true,
    this.color,
  });

  /// Unique identifier for the route
  final String id;

  /// Container ID this route represents
  final String containerId;

  /// List of waypoints (lat, lng pairs)
  final List<MapWaypoint> waypoints;

  /// Type of route
  final MapRouteType routeType;

  /// Whether the route is visible on the map
  final bool isVisible;

  /// Route color (optional, defaults to container status color)
  final int? color;

  @override
  List<Object?> get props => [
    id,
    containerId,
    waypoints,
    routeType,
    isVisible,
    color,
  ];
}

/// Map waypoint representing a point along a route
class MapWaypoint extends Equatable {
  const MapWaypoint({
    required this.latitude,
    required this.longitude,
    this.timestamp,
    this.description,
  });

  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// When this waypoint was recorded
  final DateTime? timestamp;

  /// Optional description of this waypoint
  final String? description;

  @override
  List<Object?> get props => [latitude, longitude, timestamp, description];
}

/// Types of map routes
enum MapRouteType {
  /// Planned route from origin to destination
  planned,

  /// Actual route taken (historical tracking)
  actual,

  /// Current tracking route
  current,
}

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/error/failures.dart';
import '../../../container_tracking/domain/entities/container.dart';
import '../../../container_tracking/domain/repository_interfaces/container_repository.dart';
import '../../domain/entities/map_marker.dart';
import '../../domain/repository_interfaces/map_tracking_repository.dart';

/// Implementation of map tracking repository
class MapTrackingRepositoryImpl implements MapTrackingRepository {
  MapTrackingRepositoryImpl({required this.containerRepository});

  final ContainerRepository containerRepository;

  @override
  Future<Either<Failure, List<MapMarker>>> getContainerMarkers() async {
    try {
      final containersResult = await containerRepository.getAllContainers();

      return containersResult.fold((failure) => Left(failure), (containers) {
        final markers = <MapMarker>[];

        for (final container in containers) {
          // Add container current location marker
          markers.add(MapMarker.fromContainer(container));

          // Add origin marker if different from current location
          if (container.origin != container.currentLocation) {
            markers.add(MapMarker.fromOrigin(container));
          }

          // Add destination marker if different from current location
          if (container.destination != container.currentLocation) {
            markers.add(MapMarker.fromDestination(container));
          }
        }

        return Right(markers);
      });
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to load container markers: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<MapMarker>>> getContainerMarkersById(
    String containerId,
  ) async {
    try {
      final containerResult = await containerRepository.getContainerById(
        containerId,
      );

      return containerResult.fold((failure) => Left(failure), (container) {
        final markers = <MapMarker>[
          MapMarker.fromContainer(container),
          MapMarker.fromOrigin(container),
          MapMarker.fromDestination(container),
        ];

        return Right(markers);
      });
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to get container markers: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, MapRoute?>> getContainerRoute(
    String containerId,
  ) async {
    try {
      final containerResult = await containerRepository.getContainerById(
        containerId,
      );

      return containerResult.fold((failure) => Left(failure), (container) {
        // Create a simple route from origin to current to destination
        final waypoints = <MapWaypoint>[
          MapWaypoint(
            latitude: container.origin.latitude,
            longitude: container.origin.longitude,
            description: 'Origin: ${container.origin.address}',
          ),
          MapWaypoint(
            latitude: container.currentLocation.latitude,
            longitude: container.currentLocation.longitude,
            description: 'Current location',
            timestamp: DateTime.now(),
          ),
          MapWaypoint(
            latitude: container.destination.latitude,
            longitude: container.destination.longitude,
            description: 'Destination: ${container.destination.address}',
          ),
        ];

        final route = MapRoute(
          id: 'route_$containerId',
          containerId: containerId,
          waypoints: waypoints,
          routeType: MapRouteType.planned,
          isVisible: true,
          color: _getRouteColorByStatus(container.status),
        );

        return Right(route);
      });
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get container route: $e'));
    }
  }

  @override
  Future<Either<Failure, MapWaypoint>> getCurrentLocation() async {
    try {
      // Check permissions
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        return Left(PermissionFailure(message: 'Location permission denied'));
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final waypoint = MapWaypoint(
        latitude: position.latitude,
        longitude: position.longitude,
        description: 'Current location',
        timestamp: DateTime.now(),
      );

      return Right(waypoint);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get current location: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasLocationPermission() async {
    try {
      final hasPermission = await _handleLocationPermission();
      return Right(hasPermission);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to check location permissions: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> requestLocationPermission() async {
    try {
      final hasPermission = await _handleLocationPermission();
      return Right(hasPermission);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to request location permissions: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<MapWaypoint>>> searchLocations(
    String query,
  ) async {
    try {
      final locations = await locationFromAddress(query);

      final results = <MapWaypoint>[];
      for (final location in locations) {
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        final placemark = placemarks.isNotEmpty ? placemarks.first : null;
        final address = placemark != null
            ? '${placemark.street}, ${placemark.locality}, ${placemark.country}'
            : 'Unknown location';

        results.add(
          MapWaypoint(
            latitude: location.latitude,
            longitude: location.longitude,
            description: address,
            timestamp: DateTime.now(),
          ),
        );
      }

      return Right(results);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search locations: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address =
            '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        return Right(address);
      } else {
        return const Right('Unknown location');
      }
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to get address from coordinates: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, MapWaypoint>> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        final waypoint = MapWaypoint(
          latitude: location.latitude,
          longitude: location.longitude,
          description: address,
          timestamp: DateTime.now(),
        );
        return Right(waypoint);
      } else {
        return Left(ValidationFailure(message: 'Address not found: $address'));
      }
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to get coordinates from address: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateContainerLocation({
    required String containerId,
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  }) async {
    try {
      // TODO: Implement container location update
      // This would typically involve updating the container's current location
      // and potentially adding a new tracking entry
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to update container location: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Container>>> getContainersInArea({
    required double northeastLat,
    required double northeastLng,
    required double southwestLat,
    required double southwestLng,
  }) async {
    try {
      final containersResult = await containerRepository.getAllContainers();

      return containersResult.fold((failure) => Left(failure), (containers) {
        // Filter containers within the specified area
        final containersInArea = containers.where((container) {
          final lat = container.currentLocation.latitude;
          final lng = container.currentLocation.longitude;

          return lat <= northeastLat &&
              lat >= southwestLat &&
              lng <= northeastLng &&
              lng >= southwestLng;
        }).toList();

        return Right(containersInArea);
      });
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to get containers in area: $e'),
      );
    }
  }

  /// Handle location permissions
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get route color based on container status
  int _getRouteColorByStatus(ContainerStatus status) {
    switch (status) {
      case ContainerStatus.loading:
        return 0xFFFFCA28; // Yellow
      case ContainerStatus.inTransit:
        return 0xFF42A5F5; // Blue
      case ContainerStatus.delivered:
        return 0xFF388E3C; // Green
      case ContainerStatus.delayed:
        return 0xFFFF6F00; // Orange
      case ContainerStatus.lost:
        return 0xFFD32F2F; // Red
      default:
        return 0xFF42A5F5; // Default blue
    }
  }
}

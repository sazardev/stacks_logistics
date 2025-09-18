import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/map_marker.dart';
import '../../../container_tracking/domain/entities/container.dart';

/// Repository interface for map tracking operations
abstract class MapTrackingRepository {
  /// Get markers for all containers
  Future<Either<Failure, List<MapMarker>>> getContainerMarkers();

  /// Get markers for a specific container (origin, current, destination)
  Future<Either<Failure, List<MapMarker>>> getContainerMarkersById(
    String containerId,
  );

  /// Get route for a specific container
  Future<Either<Failure, MapRoute?>> getContainerRoute(String containerId);

  /// Get user's current location
  Future<Either<Failure, MapWaypoint>> getCurrentLocation();

  /// Update container location (for real-time tracking)
  Future<Either<Failure, void>> updateContainerLocation({
    required String containerId,
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  });

  /// Get containers within a geographic area
  Future<Either<Failure, List<Container>>> getContainersInArea({
    required double northeastLat,
    required double northeastLng,
    required double southwestLat,
    required double southwestLng,
  });

  /// Search for locations by address
  Future<Either<Failure, List<MapWaypoint>>> searchLocations(String query);

  /// Get address from coordinates (reverse geocoding)
  Future<Either<Failure, String>> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  });

  /// Get coordinates from address (forward geocoding)
  Future<Either<Failure, MapWaypoint>> getCoordinatesFromAddress(
    String address,
  );

  /// Check if location permissions are granted
  Future<Either<Failure, bool>> hasLocationPermission();

  /// Request location permissions
  Future<Either<Failure, bool>> requestLocationPermission();
}

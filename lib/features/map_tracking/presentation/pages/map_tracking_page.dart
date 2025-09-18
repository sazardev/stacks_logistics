import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/map_marker.dart';
import '../blocs/map_tracking_bloc.dart';
import '../blocs/map_tracking_event.dart';
import '../blocs/map_tracking_state.dart';

/// Main map tracking page
class MapTrackingPage extends StatefulWidget {
  const MapTrackingPage({Key? key}) : super(key: key);

  @override
  State<MapTrackingPage> createState() => _MapTrackingPageState();
}

class _MapTrackingPageState extends State<MapTrackingPage> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Container Map'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              context.read<MapTrackingBloc>().add(GetCurrentLocation());
            },
            tooltip: 'My Location',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MapTrackingBloc>().add(LoadContainerMarkers());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<MapTrackingBloc, MapTrackingState>(
        builder: (context, state) {
          if (state is MapTrackingInitial) {
            // Trigger initial load
            context.read<MapTrackingBloc>().add(LoadContainerMarkers());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MapTrackingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MapTrackingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading map',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MapTrackingBloc>().add(
                        LoadContainerMarkers(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is MapTrackingLoaded) {
            return _buildMapView(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMapView(BuildContext context, MapTrackingLoaded state) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(
              state.cameraLatitude ?? 37.7749,
              state.cameraLongitude ?? -122.4194,
            ),
            zoom: state.cameraZoom,
          ),
          markers: _buildMarkers(state),
          polylines: _buildPolylines(state),
          onCameraMove: (CameraPosition position) {
            context.read<MapTrackingBloc>().add(
              UpdateCameraPosition(
                latitude: position.target.latitude,
                longitude: position.target.longitude,
                zoom: position.zoom,
              ),
            );
          },
          onTap: (LatLng position) {
            // Deselect marker when tapping empty space
            context.read<MapTrackingBloc>().add(DeselectMarker());
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false, // We have our own button
          compassEnabled: true,
          zoomControlsEnabled: false, // Custom controls
          mapType: MapType.normal,
        ),

        // Map controls overlay
        Positioned(top: 16, left: 16, right: 16, child: _buildMapControls()),

        // Info panel overlay (if marker is selected)
        if (state.selectedMarkerId != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildInfoPanel(state.selectedMarker!),
          ),
      ],
    );
  }

  Set<Marker> _buildMarkers(MapTrackingLoaded state) {
    return state.filteredMarkers.map((mapMarker) {
      return Marker(
        markerId: MarkerId(mapMarker.id),
        position: LatLng(mapMarker.latitude, mapMarker.longitude),
        infoWindow: InfoWindow(
          title: mapMarker.title,
          snippet: mapMarker.description,
        ),
        icon: _getMarkerIcon(mapMarker),
        onTap: () {
          context.read<MapTrackingBloc>().add(
            SelectMarker(markerId: mapMarker.id),
          );
        },
      );
    }).toSet();
  }

  Set<Polyline> _buildPolylines(MapTrackingLoaded state) {
    return state.routes.where((route) => route.isVisible).map((route) {
      return Polyline(
        polylineId: PolylineId(route.id),
        points: route.waypoints
            .map((waypoint) => LatLng(waypoint.latitude, waypoint.longitude))
            .toList(),
        color: Color(route.color ?? 0xFF42A5F5),
        width: 3,
        patterns: route.routeType == MapRouteType.planned
            ? [PatternItem.dash(10), PatternItem.gap(5)]
            : [],
      );
    }).toSet();
  }

  BitmapDescriptor _getMarkerIcon(mapMarker) {
    // TODO: Create custom marker icons based on marker type and status
    switch (mapMarker.markerType) {
      case MapMarkerType.container:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case MapMarkerType.origin:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case MapMarkerType.destination:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case MapMarkerType.userLocation:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  /// Build map controls widget
  Widget _buildMapControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search location...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (query) {
                  context.read<MapTrackingBloc>().add(
                    SearchLocation(query: query),
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // TODO: Show filter dialog
              },
              tooltip: 'Filter containers',
            ),
          ],
        ),
      ),
    );
  }

  /// Build info panel for selected marker
  Widget _buildInfoPanel(MapMarker marker) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  marker.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    context.read<MapTrackingBloc>().add(const DeselectMarker());
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(marker.description),
            if (marker.container != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Status: ${marker.container!.status.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Contents: ${marker.container!.contents}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

import 'package:equatable/equatable.dart';

/// Container entity representing a shipping container in the domain layer
class Container extends Equatable {
  const Container({
    required this.id,
    required this.containerNumber,
    required this.status,
    required this.currentLocation,
    required this.destination,
    required this.origin,
    required this.contents,
    required this.weight,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.estimatedArrival,
    this.actualArrival,
    this.notes,
    this.trackingHistory = const [],
  });

  /// Unique identifier for the container
  final String id;

  /// Container number (e.g., ABCD1234567)
  final String containerNumber;

  /// Current status of the container
  final ContainerStatus status;

  /// Current location of the container
  final Location currentLocation;

  /// Destination location
  final Location destination;

  /// Origin location
  final Location origin;

  /// Contents description
  final String contents;

  /// Weight in kilograms
  final double weight;

  /// Priority level
  final Priority priority;

  /// When the container record was created
  final DateTime createdAt;

  /// When the container record was last updated
  final DateTime updatedAt;

  /// Estimated arrival date and time
  final DateTime? estimatedArrival;

  /// Actual arrival date and time
  final DateTime? actualArrival;

  /// Additional notes
  final String? notes;

  /// Tracking history entries
  final List<TrackingEntry> trackingHistory;

  @override
  List<Object?> get props => [
    id,
    containerNumber,
    status,
    currentLocation,
    destination,
    origin,
    contents,
    weight,
    priority,
    createdAt,
    updatedAt,
    estimatedArrival,
    actualArrival,
    notes,
    trackingHistory,
  ];

  /// Creates a copy of this container with updated fields
  Container copyWith({
    String? id,
    String? containerNumber,
    ContainerStatus? status,
    Location? currentLocation,
    Location? destination,
    Location? origin,
    String? contents,
    double? weight,
    Priority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
    String? notes,
    List<TrackingEntry>? trackingHistory,
  }) {
    return Container(
      id: id ?? this.id,
      containerNumber: containerNumber ?? this.containerNumber,
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      destination: destination ?? this.destination,
      origin: origin ?? this.origin,
      contents: contents ?? this.contents,
      weight: weight ?? this.weight,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      actualArrival: actualArrival ?? this.actualArrival,
      notes: notes ?? this.notes,
      trackingHistory: trackingHistory ?? this.trackingHistory,
    );
  }

  /// Returns the latest tracking entry
  TrackingEntry? get latestTrackingEntry {
    if (trackingHistory.isEmpty) return null;
    return trackingHistory.reduce(
      (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
    );
  }

  /// Returns true if the container is overdue
  bool get isOverdue {
    if (estimatedArrival == null) return false;
    return DateTime.now().isAfter(estimatedArrival!) &&
        status != ContainerStatus.delivered;
  }

  /// Returns true if the container has arrived
  bool get hasArrived {
    return status == ContainerStatus.delivered || actualArrival != null;
  }

  /// Calculates the progress percentage based on tracking history
  double get progressPercentage {
    switch (status) {
      case ContainerStatus.loading:
        return 0.1;
      case ContainerStatus.inTransit:
        return 0.5;
      case ContainerStatus.delivered:
        return 1.0;
      case ContainerStatus.delayed:
        return 0.6;
      case ContainerStatus.damaged:
        return 0.8;
      case ContainerStatus.lost:
        return 0.0;
    }
  }
}

/// Container status enumeration
enum ContainerStatus { loading, inTransit, delivered, delayed, damaged, lost }

/// Priority enumeration
enum Priority { low, medium, high, critical }

/// Location entity
class Location extends Equatable {
  const Location({
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.postalCode,
  });

  final String name;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String? postalCode;

  @override
  List<Object?> get props => [
    name,
    address,
    city,
    country,
    latitude,
    longitude,
    postalCode,
  ];

  /// Returns the full address as a single string
  String get fullAddress {
    final parts = [address, city, country];
    if (postalCode != null) {
      parts.insert(parts.length - 1, postalCode!);
    }
    return parts.join(', ');
  }

  Location copyWith({
    String? name,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? postalCode,
  }) {
    return Location(
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      postalCode: postalCode ?? this.postalCode,
    );
  }
}

/// Tracking entry entity
class TrackingEntry extends Equatable {
  const TrackingEntry({
    required this.id,
    required this.containerId,
    required this.status,
    required this.location,
    required this.timestamp,
    required this.description,
    this.notes,
  });

  final String id;
  final String containerId;
  final ContainerStatus status;
  final Location location;
  final DateTime timestamp;
  final String description;
  final String? notes;

  @override
  List<Object?> get props => [
    id,
    containerId,
    status,
    location,
    timestamp,
    description,
    notes,
  ];

  TrackingEntry copyWith({
    String? id,
    String? containerId,
    ContainerStatus? status,
    Location? location,
    DateTime? timestamp,
    String? description,
    String? notes,
  }) {
    return TrackingEntry(
      id: id ?? this.id,
      containerId: containerId ?? this.containerId,
      status: status ?? this.status,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      notes: notes ?? this.notes,
    );
  }
}

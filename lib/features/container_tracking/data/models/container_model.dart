import 'package:hive/hive.dart';
import '../../domain/entities/container.dart' as domain;

part 'container_model.g.dart';

/// Container model for data layer (Hive and API)
@HiveType(typeId: 0)
class ContainerModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String containerNumber;

  @HiveField(2)
  final String status;

  @HiveField(3)
  final LocationModel currentLocation;

  @HiveField(4)
  final LocationModel destination;

  @HiveField(5)
  final LocationModel origin;

  @HiveField(6)
  final String contents;

  @HiveField(7)
  final double weight;

  @HiveField(8)
  final String priority;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final DateTime? estimatedArrival;

  @HiveField(12)
  final DateTime? actualArrival;

  @HiveField(13)
  final String? notes;

  @HiveField(14)
  final List<TrackingEntryModel> trackingHistory;

  const ContainerModel({
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

  /// Creates a ContainerModel from a domain Container entity
  factory ContainerModel.fromEntity(domain.Container container) {
    return ContainerModel(
      id: container.id,
      containerNumber: container.containerNumber,
      status: container.status.name,
      currentLocation: LocationModel.fromEntity(container.currentLocation),
      destination: LocationModel.fromEntity(container.destination),
      origin: LocationModel.fromEntity(container.origin),
      contents: container.contents,
      weight: container.weight,
      priority: container.priority.name,
      createdAt: container.createdAt,
      updatedAt: container.updatedAt,
      estimatedArrival: container.estimatedArrival,
      actualArrival: container.actualArrival,
      notes: container.notes,
      trackingHistory: container.trackingHistory
          .map((entry) => TrackingEntryModel.fromEntity(entry))
          .toList(),
    );
  }

  /// Creates a ContainerModel from JSON (for API responses)
  factory ContainerModel.fromJson(Map<String, dynamic> json) {
    return ContainerModel(
      id: json['id'] as String,
      containerNumber: json['containerNumber'] as String,
      status: json['status'] as String,
      currentLocation: LocationModel.fromJson(
        json['currentLocation'] as Map<String, dynamic>,
      ),
      destination: LocationModel.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      origin: LocationModel.fromJson(json['origin'] as Map<String, dynamic>),
      contents: json['contents'] as String,
      weight: (json['weight'] as num).toDouble(),
      priority: json['priority'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      estimatedArrival: json['estimatedArrival'] != null
          ? DateTime.parse(json['estimatedArrival'] as String)
          : null,
      actualArrival: json['actualArrival'] != null
          ? DateTime.parse(json['actualArrival'] as String)
          : null,
      notes: json['notes'] as String?,
      trackingHistory:
          (json['trackingHistory'] as List<dynamic>?)
              ?.map(
                (entry) =>
                    TrackingEntryModel.fromJson(entry as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Converts the ContainerModel to a domain Container entity
  domain.Container toEntity() {
    return domain.Container(
      id: id,
      containerNumber: containerNumber,
      status: _parseStatus(status),
      currentLocation: currentLocation.toEntity(),
      destination: destination.toEntity(),
      origin: origin.toEntity(),
      contents: contents,
      weight: weight,
      priority: _parsePriority(priority),
      createdAt: createdAt,
      updatedAt: updatedAt,
      estimatedArrival: estimatedArrival,
      actualArrival: actualArrival,
      notes: notes,
      trackingHistory: trackingHistory
          .map((entry) => entry.toEntity())
          .toList(),
    );
  }

  /// Converts the ContainerModel to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'containerNumber': containerNumber,
      'status': status,
      'currentLocation': currentLocation.toJson(),
      'destination': destination.toJson(),
      'origin': origin.toJson(),
      'contents': contents,
      'weight': weight,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'estimatedArrival': estimatedArrival?.toIso8601String(),
      'actualArrival': actualArrival?.toIso8601String(),
      'notes': notes,
      'trackingHistory': trackingHistory
          .map((entry) => entry.toJson())
          .toList(),
    };
  }

  domain.ContainerStatus _parseStatus(String status) {
    return domain.ContainerStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => domain.ContainerStatus.loading,
    );
  }

  domain.Priority _parsePriority(String priority) {
    return domain.Priority.values.firstWhere(
      (p) => p.name == priority,
      orElse: () => domain.Priority.medium,
    );
  }
}

/// Location model for data layer
@HiveType(typeId: 1)
class LocationModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String address;

  @HiveField(2)
  final String city;

  @HiveField(3)
  final String country;

  @HiveField(4)
  final double latitude;

  @HiveField(5)
  final double longitude;

  @HiveField(6)
  final String? postalCode;

  const LocationModel({
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.postalCode,
  });

  factory LocationModel.fromEntity(domain.Location location) {
    return LocationModel(
      name: location.name,
      address: location.address,
      city: location.city,
      country: location.country,
      latitude: location.latitude,
      longitude: location.longitude,
      postalCode: location.postalCode,
    );
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      postalCode: json['postalCode'] as String?,
    );
  }

  domain.Location toEntity() {
    return domain.Location(
      name: name,
      address: address,
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      postalCode: postalCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'postalCode': postalCode,
    };
  }
}

/// Tracking entry model for data layer
@HiveType(typeId: 2)
class TrackingEntryModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String containerId;

  @HiveField(2)
  final String status;

  @HiveField(3)
  final LocationModel location;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final String? notes;

  const TrackingEntryModel({
    required this.id,
    required this.containerId,
    required this.status,
    required this.location,
    required this.timestamp,
    required this.description,
    this.notes,
  });

  factory TrackingEntryModel.fromEntity(domain.TrackingEntry entry) {
    return TrackingEntryModel(
      id: entry.id,
      containerId: entry.containerId,
      status: entry.status.name,
      location: LocationModel.fromEntity(entry.location),
      timestamp: entry.timestamp,
      description: entry.description,
      notes: entry.notes,
    );
  }

  factory TrackingEntryModel.fromJson(Map<String, dynamic> json) {
    return TrackingEntryModel(
      id: json['id'] as String,
      containerId: json['containerId'] as String,
      status: json['status'] as String,
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
      notes: json['notes'] as String?,
    );
  }

  domain.TrackingEntry toEntity() {
    return domain.TrackingEntry(
      id: id,
      containerId: containerId,
      status: _parseStatus(status),
      location: location.toEntity(),
      timestamp: timestamp,
      description: description,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'containerId': containerId,
      'status': status,
      'location': location.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'notes': notes,
    };
  }

  domain.ContainerStatus _parseStatus(String status) {
    return domain.ContainerStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => domain.ContainerStatus.loading,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContainerModelAdapter extends TypeAdapter<ContainerModel> {
  @override
  final int typeId = 0;

  @override
  ContainerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContainerModel(
      id: fields[0] as String,
      containerNumber: fields[1] as String,
      status: fields[2] as String,
      currentLocation: fields[3] as LocationModel,
      destination: fields[4] as LocationModel,
      origin: fields[5] as LocationModel,
      contents: fields[6] as String,
      weight: fields[7] as double,
      priority: fields[8] as String,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      estimatedArrival: fields[11] as DateTime?,
      actualArrival: fields[12] as DateTime?,
      notes: fields[13] as String?,
      trackingHistory: (fields[14] as List).cast<TrackingEntryModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ContainerModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.containerNumber)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.currentLocation)
      ..writeByte(4)
      ..write(obj.destination)
      ..writeByte(5)
      ..write(obj.origin)
      ..writeByte(6)
      ..write(obj.contents)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.priority)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.estimatedArrival)
      ..writeByte(12)
      ..write(obj.actualArrival)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.trackingHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationModelAdapter extends TypeAdapter<LocationModel> {
  @override
  final int typeId = 1;

  @override
  LocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationModel(
      name: fields[0] as String,
      address: fields[1] as String,
      city: fields[2] as String,
      country: fields[3] as String,
      latitude: fields[4] as double,
      longitude: fields[5] as double,
      postalCode: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.country)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.postalCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrackingEntryModelAdapter extends TypeAdapter<TrackingEntryModel> {
  @override
  final int typeId = 2;

  @override
  TrackingEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackingEntryModel(
      id: fields[0] as String,
      containerId: fields[1] as String,
      status: fields[2] as String,
      location: fields[3] as LocationModel,
      timestamp: fields[4] as DateTime,
      description: fields[5] as String,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackingEntryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.containerId)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

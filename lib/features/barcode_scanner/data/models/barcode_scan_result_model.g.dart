// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_scan_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BarcodeScanResultModelAdapter
    extends TypeAdapter<BarcodeScanResultModel> {
  @override
  final int typeId = 4;

  @override
  BarcodeScanResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BarcodeScanResultModel(
      code: fields[0] as String,
      type: fields[1] as String,
      timestamp: fields[2] as DateTime,
      format: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BarcodeScanResultModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.format);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeScanResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

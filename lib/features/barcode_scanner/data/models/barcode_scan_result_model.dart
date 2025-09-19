import 'package:hive/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/entities/barcode_scan_result.dart' as domain;

part 'barcode_scan_result_model.g.dart';

/// Barcode scan result model for data layer (Hive storage)
@HiveType(typeId: 4)
class BarcodeScanResultModel {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? format;

  const BarcodeScanResultModel({
    required this.code,
    required this.type,
    required this.timestamp,
    this.format,
  });

  /// Create from domain entity
  factory BarcodeScanResultModel.fromEntity(domain.BarcodeScanResult entity) {
    return BarcodeScanResultModel(
      code: entity.code,
      type: entity.type.name,
      timestamp: entity.timestamp,
      format: entity.format,
    );
  }

  /// Convert to domain entity
  domain.BarcodeScanResult toEntity() {
    return domain.BarcodeScanResult(
      code: code,
      type: _parseBarcodeType(type),
      timestamp: timestamp,
      format: format,
    );
  }

  /// Create from mobile_scanner Barcode
  factory BarcodeScanResultModel.fromBarcode(Barcode barcode) {
    return BarcodeScanResultModel(
      code: barcode.rawValue ?? '',
      type: _getBarcodeTypeFromFormat(barcode.format).name,
      timestamp: DateTime.now(),
      format: barcode.format.name,
    );
  }

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'format': format,
    };
  }

  /// Create from JSON
  factory BarcodeScanResultModel.fromJson(Map<String, dynamic> json) {
    return BarcodeScanResultModel(
      code: json['code'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      format: json['format'] as String?,
    );
  }

  static domain.BarcodeType _parseBarcodeType(String type) {
    switch (type.toLowerCase()) {
      case 'barcode':
        return domain.BarcodeType.barcode;
      case 'qrcode':
      case 'qr_code':
        return domain.BarcodeType.qrCode;
      default:
        return domain.BarcodeType.unknown;
    }
  }

  static domain.BarcodeType _getBarcodeTypeFromFormat(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return domain.BarcodeType.qrCode;
      case BarcodeFormat.code128:
      case BarcodeFormat.code39:
      case BarcodeFormat.code93:
      case BarcodeFormat.ean8:
      case BarcodeFormat.ean13:
      case BarcodeFormat.upcA:
      case BarcodeFormat.upcE:
        return domain.BarcodeType.barcode;
      default:
        return domain.BarcodeType.unknown;
    }
  }

  @override
  String toString() {
    return 'BarcodeScanResultModel(code: $code, type: $type, timestamp: $timestamp, format: $format)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BarcodeScanResultModel &&
        other.code == code &&
        other.type == type &&
        other.timestamp == timestamp &&
        other.format == format;
  }

  @override
  int get hashCode {
    return code.hashCode ^
        type.hashCode ^
        timestamp.hashCode ^
        (format?.hashCode ?? 0);
  }
}

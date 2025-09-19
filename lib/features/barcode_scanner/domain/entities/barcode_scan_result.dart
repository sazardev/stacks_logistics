import 'package:equatable/equatable.dart';

/// Barcode scan result entity
class BarcodeScanResult extends Equatable {
  const BarcodeScanResult({
    required this.code,
    required this.type,
    required this.timestamp,
    this.format,
  });

  /// The scanned code value
  final String code;

  /// Type of the scanned code (barcode, qr_code)
  final BarcodeType type;

  /// Timestamp when the code was scanned
  final DateTime timestamp;

  /// Format of the barcode (if available)
  final String? format;

  @override
  List<Object?> get props => [code, type, timestamp, format];

  @override
  String toString() {
    return 'BarcodeScanResult(code: $code, type: $type, timestamp: $timestamp, format: $format)';
  }
}

/// Types of barcodes that can be scanned
enum BarcodeType {
  barcode,
  qrCode,
  unknown;

  /// Get display name for the barcode type
  String get displayName {
    switch (this) {
      case BarcodeType.barcode:
        return 'Barcode';
      case BarcodeType.qrCode:
        return 'QR Code';
      case BarcodeType.unknown:
        return 'Unknown';
    }
  }
}

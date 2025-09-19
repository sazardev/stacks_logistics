import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/barcode_scan_result.dart';

/// Repository interface for barcode scanning operations
abstract class BarcodeScannerRepository {
  /// Check if the device has camera permission
  Future<Either<Failure, bool>> hasCameraPermission();

  /// Request camera permission
  Future<Either<Failure, bool>> requestCameraPermission();

  /// Check if the device supports barcode scanning
  Future<Either<Failure, bool>> isScanningSupported();

  /// Initialize the barcode scanner
  Future<Either<Failure, void>> initializeScanner();

  /// Start scanning for barcodes
  Stream<Either<Failure, BarcodeScanResult>> startScanning();

  /// Stop scanning
  Future<Either<Failure, void>> stopScanning();

  /// Toggle flashlight
  Future<Either<Failure, void>> toggleFlashlight();

  /// Check if flashlight is available
  Future<Either<Failure, bool>> isFlashlightAvailable();

  /// Save scan result to history (optional)
  Future<Either<Failure, void>> saveScanResult(BarcodeScanResult result);

  /// Get scan history
  Future<Either<Failure, List<BarcodeScanResult>>> getScanHistory();

  /// Clear scan history
  Future<Either<Failure, void>> clearScanHistory();
}

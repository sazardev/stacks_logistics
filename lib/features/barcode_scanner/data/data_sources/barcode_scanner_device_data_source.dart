import 'dart:async';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/barcode_scan_result_model.dart';
import '../../../../core/error/exceptions.dart';

/// Device data source for barcode scanner operations using mobile_scanner
abstract class BarcodeScannerDeviceDataSource {
  /// Check if the device has camera permission
  Future<bool> hasCameraPermission();

  /// Request camera permission
  Future<bool> requestCameraPermission();

  /// Check if the device supports barcode scanning
  Future<bool> isScanningSupported();

  /// Initialize the barcode scanner
  Future<void> initializeScanner();

  /// Start scanning for barcodes
  Stream<BarcodeScanResultModel> startScanning();

  /// Stop scanning
  Future<void> stopScanning();

  /// Toggle flashlight
  Future<void> toggleFlashlight();

  /// Check if flashlight is available
  Future<bool> isFlashlightAvailable();

  /// Dispose of resources
  Future<void> dispose();
}

/// Implementation of BarcodeScannerDeviceDataSource using mobile_scanner
class BarcodeScannerDeviceDataSourceImpl
    implements BarcodeScannerDeviceDataSource {
  BarcodeScannerDeviceDataSourceImpl();

  MobileScannerController? _controller;
  StreamController<BarcodeScanResultModel>? _scanStreamController;
  StreamSubscription<BarcodeCapture>? _barcodeSubscription;

  @override
  Future<bool> hasCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      throw DeviceException(
        'Failed to check camera permission: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      throw DeviceException(
        'Failed to request camera permission: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isScanningSupported() async {
    try {
      // For now, assume all devices support scanning
      // mobile_scanner will handle device-specific capabilities
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> initializeScanner() async {
    try {
      if (_controller != null) {
        await _controller!.dispose();
      }

      _controller = MobileScannerController(
        formats: [
          BarcodeFormat.qrCode,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.ean8,
          BarcodeFormat.ean13,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
        ],
        facing: CameraFacing.back,
        torchEnabled: false,
        returnImage: false,
      );

      await _controller!.start();
    } catch (e) {
      throw DeviceException('Failed to initialize scanner: ${e.toString()}');
    }
  }

  @override
  Stream<BarcodeScanResultModel> startScanning() {
    try {
      if (_controller == null) {
        throw DeviceException('Scanner not initialized');
      }

      _scanStreamController =
          StreamController<BarcodeScanResultModel>.broadcast();

      _barcodeSubscription = _controller!.barcodes.listen(
        (BarcodeCapture capture) {
          for (final barcode in capture.barcodes) {
            if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
              final result = BarcodeScanResultModel.fromBarcode(barcode);
              _scanStreamController?.add(result);
            }
          }
        },
        onError: (error) {
          _scanStreamController?.addError(
            DeviceException('Scanning error: ${error.toString()}'),
          );
        },
      );

      return _scanStreamController!.stream;
    } catch (e) {
      throw DeviceException('Failed to start scanning: ${e.toString()}');
    }
  }

  @override
  Future<void> stopScanning() async {
    try {
      await _barcodeSubscription?.cancel();
      _barcodeSubscription = null;

      await _scanStreamController?.close();
      _scanStreamController = null;

      await _controller?.stop();
    } catch (e) {
      throw DeviceException('Failed to stop scanning: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleFlashlight() async {
    try {
      if (_controller == null) {
        throw DeviceException('Scanner not initialized');
      }
      await _controller!.toggleTorch();
    } catch (e) {
      throw DeviceException('Failed to toggle flashlight: ${e.toString()}');
    }
  }

  @override
  Future<bool> isFlashlightAvailable() async {
    try {
      if (_controller == null) {
        return false;
      }
      return _controller!.torchEnabled;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await stopScanning();
      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      throw DeviceException('Failed to dispose scanner: ${e.toString()}');
    }
  }
}

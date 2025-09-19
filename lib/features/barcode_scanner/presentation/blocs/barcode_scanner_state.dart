import 'package:equatable/equatable.dart';
import '../../domain/entities/barcode_scan_result.dart';
import '../../../container_tracking/domain/entities/container.dart';

/// States for barcode scanner BLoC
abstract class BarcodeScannerState extends Equatable {
  const BarcodeScannerState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BarcodeScannerInitial extends BarcodeScannerState {
  const BarcodeScannerInitial();
}

/// Loading state
class BarcodeScannerLoading extends BarcodeScannerState {
  const BarcodeScannerLoading();
}

/// Scanner initialized and ready
class ScannerReady extends BarcodeScannerState {
  const ScannerReady({
    this.hasPermission = false,
    this.isFlashlightOn = false,
    this.isScanning = false,
  });

  final bool hasPermission;
  final bool isFlashlightOn;
  final bool isScanning;

  @override
  List<Object?> get props => [hasPermission, isFlashlightOn, isScanning];

  ScannerReady copyWith({
    bool? hasPermission,
    bool? isFlashlightOn,
    bool? isScanning,
  }) {
    return ScannerReady(
      hasPermission: hasPermission ?? this.hasPermission,
      isFlashlightOn: isFlashlightOn ?? this.isFlashlightOn,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

/// Scanning in progress
class ScannerScanning extends BarcodeScannerState {
  const ScannerScanning({this.isFlashlightOn = false});

  final bool isFlashlightOn;

  @override
  List<Object?> get props => [isFlashlightOn];
}

/// Barcode scan successful
class BarcodeScanSuccess extends BarcodeScannerState {
  const BarcodeScanSuccess({required this.result, this.isFlashlightOn = false});

  final BarcodeScanResult result;
  final bool isFlashlightOn;

  @override
  List<Object?> get props => [result, isFlashlightOn];
}

/// Container found by scanned barcode
class ContainerFoundByBarcode extends BarcodeScannerState {
  const ContainerFoundByBarcode({
    required this.result,
    required this.container,
    this.isFlashlightOn = false,
  });

  final BarcodeScanResult result;
  final Container container;
  final bool isFlashlightOn;

  @override
  List<Object?> get props => [result, container, isFlashlightOn];
}

/// No container found for scanned barcode
class ContainerNotFoundByBarcode extends BarcodeScannerState {
  const ContainerNotFoundByBarcode({
    required this.result,
    this.isFlashlightOn = false,
  });

  final BarcodeScanResult result;
  final bool isFlashlightOn;

  @override
  List<Object?> get props => [result, isFlashlightOn];
}

/// Camera permission denied
class CameraPermissionDenied extends BarcodeScannerState {
  const CameraPermissionDenied();
}

/// Scanner error state
class BarcodeScannerError extends BarcodeScannerState {
  const BarcodeScannerError({
    required this.message,
    this.isFlashlightOn = false,
  });

  final String message;
  final bool isFlashlightOn;

  @override
  List<Object?> get props => [message, isFlashlightOn];
}

/// Scan history loaded
class ScanHistoryLoaded extends BarcodeScannerState {
  const ScanHistoryLoaded({required this.scanHistory});

  final List<BarcodeScanResult> scanHistory;

  @override
  List<Object?> get props => [scanHistory];
}

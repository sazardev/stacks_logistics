import 'package:equatable/equatable.dart';
import '../../domain/entities/barcode_scan_result.dart';

/// Events for barcode scanner BLoC
abstract class BarcodeScannerEvent extends Equatable {
  const BarcodeScannerEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the barcode scanner
class InitializeScanner extends BarcodeScannerEvent {
  const InitializeScanner();
}

/// Event to check camera permission
class CheckCameraPermission extends BarcodeScannerEvent {
  const CheckCameraPermission();
}

/// Event to request camera permission
class RequestCameraPermission extends BarcodeScannerEvent {
  const RequestCameraPermission();
}

/// Event to start scanning
class StartScanning extends BarcodeScannerEvent {
  const StartScanning();
}

/// Event to stop scanning
class StopScanning extends BarcodeScannerEvent {
  const StopScanning();
}

/// Event when a barcode is scanned
class BarcodeScanned extends BarcodeScannerEvent {
  const BarcodeScanned({required this.result});

  final BarcodeScanResult result;

  @override
  List<Object?> get props => [result];
}

/// Event to toggle flashlight
class ToggleFlashlight extends BarcodeScannerEvent {
  const ToggleFlashlight();
}

/// Event to search container by scanned code
class SearchContainerByBarcode extends BarcodeScannerEvent {
  const SearchContainerByBarcode({required this.result});

  final BarcodeScanResult result;

  @override
  List<Object?> get props => [result];
}

/// Event to clear scan result
class ClearScanResult extends BarcodeScannerEvent {
  const ClearScanResult();
}

/// Event to reset scanner state
class ResetScannerState extends BarcodeScannerEvent {
  const ResetScannerState();
}

/// Event to load scan history
class LoadScanHistory extends BarcodeScannerEvent {
  const LoadScanHistory();
}

/// Event to clear scan history
class ClearScanHistory extends BarcodeScannerEvent {
  const ClearScanHistory();
}

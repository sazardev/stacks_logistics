import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/check_camera_permission_use_case.dart';
import '../../domain/use_cases/request_camera_permission_use_case.dart';
import '../../domain/use_cases/start_scanning_use_case.dart';
import '../../domain/use_cases/stop_scanning_use_case.dart';
import '../../domain/use_cases/search_container_by_scan_use_case.dart';
import '../../domain/repository_interfaces/barcode_scanner_repository.dart';
import 'barcode_scanner_event.dart';
import 'barcode_scanner_state.dart';

/// BLoC for managing barcode scanner state and operations
class BarcodeScannerBloc
    extends Bloc<BarcodeScannerEvent, BarcodeScannerState> {
  BarcodeScannerBloc({
    required this.checkCameraPermissionUseCase,
    required this.requestCameraPermissionUseCase,
    required this.startScanningUseCase,
    required this.stopScanningUseCase,
    required this.searchContainerByScanUseCase,
    required this.repository,
  }) : super(const BarcodeScannerInitial()) {
    on<InitializeScanner>(_onInitializeScanner);
    on<CheckCameraPermission>(_onCheckCameraPermission);
    on<RequestCameraPermission>(_onRequestCameraPermission);
    on<StartScanning>(_onStartScanning);
    on<StopScanning>(_onStopScanning);
    on<BarcodeScanned>(_onBarcodeScanned);
    on<ToggleFlashlight>(_onToggleFlashlight);
    on<SearchContainerByBarcode>(_onSearchContainerByBarcode);
    on<ClearScanResult>(_onClearScanResult);
    on<ResetScannerState>(_onResetScannerState);
    on<LoadScanHistory>(_onLoadScanHistory);
    on<ClearScanHistory>(_onClearScanHistory);
  }

  final CheckCameraPermissionUseCase checkCameraPermissionUseCase;
  final RequestCameraPermissionUseCase requestCameraPermissionUseCase;
  final StartScanningUseCase startScanningUseCase;
  final StopScanningUseCase stopScanningUseCase;
  final SearchContainerByScanUseCase searchContainerByScanUseCase;
  final BarcodeScannerRepository repository;

  StreamSubscription? _scanSubscription;
  bool _isFlashlightOn = false;

  Future<void> _onInitializeScanner(
    InitializeScanner event,
    Emitter<BarcodeScannerState> emit,
  ) async {
    emit(const BarcodeScannerLoading());

    // Check if scanning is supported
    final supportedResult = await repository.isScanningSupported();
    if (supportedResult.isLeft()) {
      emit(
        BarcodeScannerError(message: 'Scanning not supported on this device'),
      );
      return;
    }

    // Initialize the scanner
    final initResult = await repository.initializeScanner();
    if (initResult.isLeft()) {
      emit(BarcodeScannerError(message: 'Failed to initialize scanner'));
      return;
    }

    // Check camera permission
    final permissionResult = await checkCameraPermissionUseCase();
    permissionResult.fold(
      (failure) => emit(BarcodeScannerError(message: failure.message)),
      (hasPermission) {
        if (hasPermission) {
          emit(ScannerReady(hasPermission: true));
        } else {
          emit(const ScannerReady(hasPermission: false));
        }
      },
    );
  }

  Future<void> _onCheckCameraPermission(
    CheckCameraPermission event,
    Emitter<BarcodeScannerState> emit,
  ) async {
    final result = await checkCameraPermissionUseCase();
    result.fold(
      (failure) => emit(BarcodeScannerError(message: failure.message)),
      (hasPermission) {
        if (state is ScannerReady) {
          final currentState = state as ScannerReady;
          emit(currentState.copyWith(hasPermission: hasPermission));
        } else {
          emit(ScannerReady(hasPermission: hasPermission));
        }
      },
    );
  }

  Future<void> _onRequestCameraPermission(
    RequestCameraPermission event,
    Emitter<BarcodeScannerState> emit,
  ) async {
    emit(const BarcodeScannerLoading());

    final result = await requestCameraPermissionUseCase();
    result.fold(
      (failure) => emit(BarcodeScannerError(message: failure.message)),
      (granted) {
        if (granted) {
          emit(const ScannerReady(hasPermission: true));
        } else {
          emit(const CameraPermissionDenied());
        }
      },
    );
  }

  Future<void> _onStartScanning(
    StartScanning event,
    Emitter<BarcodeScannerState> emit,
  ) async {
    if (state is! ScannerReady) return;

    final currentState = state as ScannerReady;
    if (!currentState.hasPermission) {
      emit(const CameraPermissionDenied());
      return;
    }

    emit(ScannerScanning(isFlashlightOn: _isFlashlightOn));

    // Start listening to scan results
    _scanSubscription = startScanningUseCase().listen(
      (result) {
        result.fold(
          (failure) => emit(BarcodeScannerError(message: failure.message)),
          (scanResult) => add(BarcodeScanned(result: scanResult)),
        );
      },
      onError: (error) {
        emit(
          BarcodeScannerError(message: 'Scanning error: ${error.toString()}'),
        );
      },
    );
  }

  Future<void> _onStopScanning(
    StopScanning event,
    Emitter<BarcodeScannerState> emit,
  ) async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;

    await stopScanningUseCase();

    if (state is ScannerScanning || state is BarcodeScanSuccess) {
      emit(ScannerReady(hasPermission: true, isFlashlightOn: _isFlashlightOn));
    }
  }

  Future<void> _onBarcodeScanned(
    BarcodeScanned event,
    Emitter<BarcodeScannerState> emit,
  ) async {
    emit(
      BarcodeScanSuccess(result: event.result, isFlashlightOn: _isFlashlightOn),
    );

    // Automatically search for container
    add(SearchContainerByBarcode(result: event.result));
  }

  Future<void> _onToggleFlashlight(
    ToggleFlashlight event,
    Emitter<BarcodeScannerState> emit,
  ) async {
    final result = await repository.toggleFlashlight();
    result.fold(
      (failure) =>
          emit(BarcodeScannerError(message: 'Failed to toggle flashlight')),
      (_) {
        _isFlashlightOn = !_isFlashlightOn;

        if (state is ScannerReady) {
          final currentState = state as ScannerReady;
          emit(currentState.copyWith(isFlashlightOn: _isFlashlightOn));
        } else if (state is ScannerScanning) {
          emit(ScannerScanning(isFlashlightOn: _isFlashlightOn));
        } else if (state is BarcodeScanSuccess) {
          final currentState = state as BarcodeScanSuccess;
          emit(
            BarcodeScanSuccess(
              result: currentState.result,
              isFlashlightOn: _isFlashlightOn,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSearchContainerByBarcode(
    SearchContainerByBarcode event,
    Emitter<BarcodeScannerState> emit,
  ) async {
    final result = await searchContainerByScanUseCase(
      SearchContainerByScanParams(scanResult: event.result),
    );

    result.fold(
      (failure) => emit(BarcodeScannerError(message: failure.message)),
      (container) {
        if (container != null) {
          emit(
            ContainerFoundByBarcode(
              result: event.result,
              container: container,
              isFlashlightOn: _isFlashlightOn,
            ),
          );
        } else {
          emit(
            ContainerNotFoundByBarcode(
              result: event.result,
              isFlashlightOn: _isFlashlightOn,
            ),
          );
        }
      },
    );
  }

  void _onClearScanResult(
    ClearScanResult event,
    Emitter<BarcodeScannerState> emit,
  ) {
    emit(ScannerReady(hasPermission: true, isFlashlightOn: _isFlashlightOn));
  }

  void _onResetScannerState(
    ResetScannerState event,
    Emitter<BarcodeScannerState> emit,
  ) {
    _isFlashlightOn = false;
    emit(const BarcodeScannerInitial());
  }

  Future<void> _onLoadScanHistory(
    LoadScanHistory event,
    Emitter<BarcodeScannerState> emit,
  ) async {
    final result = await repository.getScanHistory();
    result.fold(
      (failure) => emit(BarcodeScannerError(message: failure.message)),
      (history) => emit(ScanHistoryLoaded(scanHistory: history)),
    );
  }

  Future<void> _onClearScanHistory(
    ClearScanHistory event,
    Emitter<BarcodeScannerState> emit,
  ) async {
    final result = await repository.clearScanHistory();
    result.fold(
      (failure) => emit(BarcodeScannerError(message: failure.message)),
      (_) => emit(const ScanHistoryLoaded(scanHistory: [])),
    );
  }

  @override
  Future<void> close() async {
    await _scanSubscription?.cancel();
    await repository.stopScanning();
    return super.close();
  }
}

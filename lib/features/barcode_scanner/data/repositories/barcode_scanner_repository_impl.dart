import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../domain/entities/barcode_scan_result.dart';
import '../../domain/repository_interfaces/barcode_scanner_repository.dart';
import '../data_sources/barcode_scanner_local_data_source.dart';
import '../data_sources/barcode_scanner_device_data_source.dart';
import '../models/barcode_scan_result_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exception_handler.dart';

/// Implementation of BarcodeScannerRepository
class BarcodeScannerRepositoryImpl implements BarcodeScannerRepository {
  const BarcodeScannerRepositoryImpl({
    required this.deviceDataSource,
    required this.localDataSource,
  });

  final BarcodeScannerDeviceDataSource deviceDataSource;
  final BarcodeScannerLocalDataSource localDataSource;

  @override
  Future<Either<Failure, bool>> hasCameraPermission() async {
    try {
      final hasPermission = await deviceDataSource.hasCameraPermission();
      return Right(hasPermission);
    } catch (e) {
      return Left(ExceptionHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> requestCameraPermission() async {
    try {
      final granted = await deviceDataSource.requestCameraPermission();
      return Right(granted);
    } catch (e) {
      return Left(ExceptionHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isScanningSupported() async {
    try {
      final supported = await deviceDataSource.isScanningSupported();
      return Right(supported);
    } catch (e) {
      return Left(ExceptionHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> initializeScanner() async {
    try {
      await deviceDataSource.initializeScanner();
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handleException(e));
    }
  }

  @override
  Stream<Either<Failure, BarcodeScanResult>> startScanning() {
    try {
      return deviceDataSource
          .startScanning()
          .map<Either<Failure, BarcodeScanResult>>(
            (model) => Right(model.toEntity()),
          )
          .handleError(
            (error) => Left(ExceptionHandler.handleException(error)),
          );
    } catch (e) {
      return Stream.value(Left(ExceptionHandler.handleException(e)));
    }
  }

  @override
  Future<Either<Failure, void>> stopScanning() async {
    try {
      await deviceDataSource.stopScanning();
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFlashlight() async {
    try {
      await deviceDataSource.toggleFlashlight();
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isFlashlightAvailable() async {
    try {
      final available = await deviceDataSource.isFlashlightAvailable();
      return Right(available);
    } catch (e) {
      return Left(ExceptionHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveScanResult(BarcodeScanResult result) async {
    try {
      final model = BarcodeScanResultModel.fromEntity(result);
      await localDataSource.saveScanResult(model);
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<BarcodeScanResult>>> getScanHistory() async {
    try {
      final models = await localDataSource.getScanHistory();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ExceptionHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearScanHistory() async {
    try {
      await localDataSource.clearScanHistory();
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handleException(e));
    }
  }
}

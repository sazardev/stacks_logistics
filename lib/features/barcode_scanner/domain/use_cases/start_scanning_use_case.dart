import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/barcode_scan_result.dart';
import '../repository_interfaces/barcode_scanner_repository.dart';

/// Use case for starting barcode scanning
class StartScanningUseCase implements StreamUseCaseNoParams<BarcodeScanResult> {
  const StartScanningUseCase({required this.repository});

  final BarcodeScannerRepository repository;

  @override
  Stream<Either<Failure, BarcodeScanResult>> call() {
    return repository.startScanning();
  }
}

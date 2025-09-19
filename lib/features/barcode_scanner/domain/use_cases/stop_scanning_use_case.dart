import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repository_interfaces/barcode_scanner_repository.dart';

/// Use case for stopping barcode scanning
class StopScanningUseCase implements UseCaseNoParams<void> {
  const StopScanningUseCase({required this.repository});

  final BarcodeScannerRepository repository;

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.stopScanning();
  }
}

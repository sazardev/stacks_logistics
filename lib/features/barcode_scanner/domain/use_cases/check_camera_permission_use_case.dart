import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repository_interfaces/barcode_scanner_repository.dart';

/// Use case for checking camera permission
class CheckCameraPermissionUseCase implements UseCaseNoParams<bool> {
  const CheckCameraPermissionUseCase({required this.repository});

  final BarcodeScannerRepository repository;

  @override
  Future<Either<Failure, bool>> call() async {
    return await repository.hasCameraPermission();
  }
}

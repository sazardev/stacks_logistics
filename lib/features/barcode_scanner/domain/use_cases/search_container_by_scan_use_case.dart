import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/barcode_scan_result.dart';
import '../repository_interfaces/barcode_scanner_repository.dart';
import '../../../container_tracking/domain/entities/container.dart';
import '../../../container_tracking/domain/repository_interfaces/container_repository.dart';

/// Use case for searching containers by scanned barcode
class SearchContainerByScanUseCase
    implements UseCase<Container?, SearchContainerByScanParams> {
  const SearchContainerByScanUseCase({
    required this.scannerRepository,
    required this.containerRepository,
  });

  final BarcodeScannerRepository scannerRepository;
  final ContainerRepository containerRepository;

  @override
  Future<Either<Failure, Container?>> call(
    SearchContainerByScanParams params,
  ) async {
    // Save scan result to history
    final saveResult = await scannerRepository.saveScanResult(
      params.scanResult,
    );
    if (saveResult.isLeft()) {
      // Continue even if saving fails - it's not critical
    }

    // Search for container by the scanned code
    final searchResult = await containerRepository.getContainerById(
      params.scanResult.code,
    );

    return searchResult.fold((failure) {
      // If not found by ID, try searching by container number or other fields
      return containerRepository
          .searchContainers(params.scanResult.code)
          .then(
            (searchListResult) => searchListResult.fold(
              (searchFailure) => Left(searchFailure),
              (containers) {
                if (containers.isNotEmpty) {
                  return Right(containers.first);
                } else {
                  return const Right(null); // No container found
                }
              },
            ),
          );
    }, (container) => Right(container));
  }
}

/// Parameters for searching container by scan
class SearchContainerByScanParams {
  const SearchContainerByScanParams({required this.scanResult});

  final BarcodeScanResult scanResult;
}

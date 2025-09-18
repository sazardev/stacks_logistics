import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/map_marker.dart';
import '../repository_interfaces/map_tracking_repository.dart';

/// Use case for getting all container markers
class GetContainerMarkersUseCase implements UseCaseNoParams<List<MapMarker>> {
  const GetContainerMarkersUseCase({required this.repository});

  final MapTrackingRepository repository;

  @override
  Future<Either<Failure, List<MapMarker>>> call() async {
    return await repository.getContainerMarkers();
  }
}

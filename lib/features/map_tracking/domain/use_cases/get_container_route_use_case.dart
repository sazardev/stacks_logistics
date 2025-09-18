import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/map_marker.dart';
import '../repository_interfaces/map_tracking_repository.dart';

/// Use case for getting container route
class GetContainerRouteUseCase
    implements UseCase<MapRoute?, GetContainerRouteParams> {
  const GetContainerRouteUseCase({required this.repository});

  final MapTrackingRepository repository;

  @override
  Future<Either<Failure, MapRoute?>> call(
    GetContainerRouteParams params,
  ) async {
    return await repository.getContainerRoute(params.containerId);
  }
}

/// Parameters for getting container route
class GetContainerRouteParams {
  const GetContainerRouteParams({required this.containerId});

  final String containerId;
}

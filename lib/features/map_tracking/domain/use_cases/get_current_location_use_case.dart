import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/map_marker.dart';
import '../repository_interfaces/map_tracking_repository.dart';

/// Use case for getting current user location
class GetCurrentLocationUseCase implements UseCaseNoParams<MapWaypoint> {
  const GetCurrentLocationUseCase({required this.repository});

  final MapTrackingRepository repository;

  @override
  Future<Either<Failure, MapWaypoint>> call() async {
    return await repository.getCurrentLocation();
  }
}

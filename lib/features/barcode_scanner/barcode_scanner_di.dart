import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import 'data/data_sources/barcode_scanner_local_data_source.dart';
import 'data/data_sources/barcode_scanner_device_data_source.dart';
import 'data/repositories/barcode_scanner_repository_impl.dart';
import 'data/models/barcode_scan_result_model.dart';
import 'domain/repository_interfaces/barcode_scanner_repository.dart';
import 'domain/use_cases/check_camera_permission_use_case.dart';
import 'domain/use_cases/request_camera_permission_use_case.dart';
import 'domain/use_cases/start_scanning_use_case.dart';
import 'domain/use_cases/stop_scanning_use_case.dart';
import 'domain/use_cases/search_container_by_scan_use_case.dart';
import 'presentation/blocs/barcode_scanner_bloc.dart';

/// Dependency injection for barcode scanner feature
Future<void> initBarcodeScannerDependencies(GetIt getIt) async {
  // Register Hive adapters for barcode scanner
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(BarcodeScanResultModelAdapter());
  }

  // Open Hive box for scan results
  final scanResultsBox = await Hive.openBox<BarcodeScanResultModel>(
    'scan_results',
  );

  // Data sources
  getIt.registerLazySingleton<BarcodeScannerLocalDataSource>(
    () => BarcodeScannerLocalDataSourceImpl(scanResultsBox: scanResultsBox),
  );

  getIt.registerLazySingleton<BarcodeScannerDeviceDataSource>(
    () => BarcodeScannerDeviceDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<BarcodeScannerRepository>(
    () => BarcodeScannerRepositoryImpl(
      deviceDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => CheckCameraPermissionUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton(
    () => RequestCameraPermissionUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton(() => StartScanningUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => StopScanningUseCase(repository: getIt()));
  getIt.registerLazySingleton(
    () => SearchContainerByScanUseCase(
      scannerRepository: getIt(),
      containerRepository: getIt(),
    ),
  );

  // BLoC
  getIt.registerFactory(
    () => BarcodeScannerBloc(
      checkCameraPermissionUseCase: getIt(),
      requestCameraPermissionUseCase: getIt(),
      startScanningUseCase: getIt(),
      stopScanningUseCase: getIt(),
      searchContainerByScanUseCase: getIt(),
      repository: getIt(),
    ),
  );
}

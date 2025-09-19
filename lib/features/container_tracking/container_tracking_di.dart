import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'data/data_sources/container_local_data_source.dart';
import 'data/data_sources/container_remote_data_source.dart';
import 'data/repositories/container_repository_impl.dart';
import 'data/models/container_model.dart';
import 'domain/repository_interfaces/container_repository.dart';
import 'domain/use_cases/get_all_containers.dart';
import 'domain/use_cases/get_container_by_id.dart';
import 'domain/use_cases/search_containers.dart';
import 'domain/use_cases/create_container.dart';
import 'domain/use_cases/update_container.dart';
import 'domain/use_cases/delete_container.dart';
import 'domain/use_cases/get_containers_by_status.dart';
import 'domain/use_cases/get_containers_by_priority.dart';
import 'presentation/blocs/container_tracking_bloc.dart';
import '../../core/services/container_notification_service.dart';

/// Container tracking feature dependency injection setup
class ContainerTrackingDI {
  /// Initialize all dependencies for the container tracking feature
  static Future<void> init(GetIt serviceLocator) async {
    // Initialize Hive boxes
    await _initHive();

    // Register data sources
    await _registerDataSources(serviceLocator);

    // Register repositories
    _registerRepositories(serviceLocator);

    // Register use cases
    _registerUseCases(serviceLocator);

    // Register BLoCs
    _registerBlocs(serviceLocator);
  }

  /// Initialize Hive boxes for local storage
  static Future<void> _initHive() async {
    // Register Hive adapters if they're not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ContainerModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LocationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TrackingEntryModelAdapter());
    }
  }

  /// Register data sources
  static Future<void> _registerDataSources(GetIt sl) async {
    // External dependencies
    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    sl.registerLazySingleton<Connectivity>(() => Connectivity());

    // Open Hive boxes first
    final containerBox = await Hive.openBox<ContainerModel>('containers');
    final settingsBox = await Hive.openBox('settings');

    // Register the opened boxes
    sl.registerLazySingleton<Box<ContainerModel>>(() => containerBox);
    sl.registerLazySingleton<Box<dynamic>>(() => settingsBox);

    // Local data source
    sl.registerLazySingleton<ContainerLocalDataSource>(
      () => ContainerLocalDataSourceImpl(
        containerBox: sl<Box<ContainerModel>>(),
        settingsBox: sl<Box<dynamic>>(),
      ),
    );

    // Remote data source
    sl.registerLazySingleton<ContainerRemoteDataSource>(
      () => ContainerRemoteDataSourceImpl(
        firestore: sl<FirebaseFirestore>(),
        auth: sl<FirebaseAuth>(),
      ),
    );
  }

  /// Register repositories
  static void _registerRepositories(GetIt sl) {
    sl.registerLazySingleton<ContainerRepository>(
      () => ContainerRepositoryImpl(
        localDataSource: sl<ContainerLocalDataSource>(),
        remoteDataSource: sl<ContainerRemoteDataSource>(),
        connectivity: sl<Connectivity>(),
        notificationService: sl.isRegistered<ContainerNotificationService>()
            ? sl<ContainerNotificationService>()
            : null,
      ),
    );
  }

  /// Register use cases
  static void _registerUseCases(GetIt sl) {
    sl.registerLazySingleton<GetAllContainers>(
      () => GetAllContainers(sl<ContainerRepository>()),
    );

    sl.registerLazySingleton<GetContainerById>(
      () => GetContainerById(sl<ContainerRepository>()),
    );

    sl.registerLazySingleton<SearchContainers>(
      () => SearchContainers(sl<ContainerRepository>()),
    );

    sl.registerLazySingleton<CreateContainer>(
      () => CreateContainer(sl<ContainerRepository>()),
    );

    sl.registerLazySingleton<UpdateContainer>(
      () => UpdateContainer(sl<ContainerRepository>()),
    );

    sl.registerLazySingleton<DeleteContainer>(
      () => DeleteContainer(sl<ContainerRepository>()),
    );

    sl.registerLazySingleton<GetContainersByStatus>(
      () => GetContainersByStatus(sl<ContainerRepository>()),
    );

    sl.registerLazySingleton<GetContainersByPriority>(
      () => GetContainersByPriority(sl<ContainerRepository>()),
    );
  }

  /// Register BLoCs
  static void _registerBlocs(GetIt sl) {
    sl.registerFactory<ContainerTrackingBloc>(
      () => ContainerTrackingBloc(
        getAllContainers: sl<GetAllContainers>(),
        getContainerById: sl<GetContainerById>(),
        searchContainers: sl<SearchContainers>(),
        getContainersByStatus: sl<GetContainersByStatus>(),
        getContainersByPriority: sl<GetContainersByPriority>(),
        createContainer: sl<CreateContainer>(),
        updateContainer: sl<UpdateContainer>(),
        deleteContainer: sl<DeleteContainer>(),
      ),
    );
  }
}

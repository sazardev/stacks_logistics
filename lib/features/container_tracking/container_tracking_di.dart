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
// import 'domain/use_cases/update_container.dart';
// import 'domain/use_cases/delete_container.dart';
// import 'domain/use_cases/get_containers_by_status.dart';
// import 'domain/use_cases/get_containers_by_priority.dart';
// import 'presentation/blocs/container_tracking_bloc.dart';

/// Container tracking feature dependency injection setup
class ContainerTrackingDI {
  /// Initialize all dependencies for the container tracking feature
  static Future<void> init(GetIt serviceLocator) async {
    // Initialize Hive boxes
    await _initHive();

    // Register data sources
    _registerDataSources(serviceLocator);

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
      // TODO: Register LocationModelAdapter when created
      // Hive.registerAdapter(LocationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      // TODO: Register TrackingEntryModelAdapter when created
      // Hive.registerAdapter(TrackingEntryModelAdapter());
    }
  }

  /// Register data sources
  static void _registerDataSources(GetIt sl) {
    // External dependencies
    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    sl.registerLazySingleton<Connectivity>(() => Connectivity());

    // Hive boxes - these should be opened in the main app initialization
    sl.registerLazySingletonAsync<Box<ContainerModel>>(
      () async => await Hive.openBox<ContainerModel>('containers'),
    );
    sl.registerLazySingletonAsync<Box<dynamic>>(
      () async => await Hive.openBox('settings'),
    );

    // Local data source
    sl.registerLazySingletonAsync<ContainerLocalDataSource>(
      () async => ContainerLocalDataSourceImpl(
        containerBox: sl<Box<ContainerModel>>(),
        settingsBox: sl<Box<dynamic>>(),
      ),
      dependsOn: [Box<ContainerModel>, Box<dynamic>],
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
    sl.registerLazySingletonAsync<ContainerRepository>(
      () async => ContainerRepositoryImpl(
        localDataSource: sl<ContainerLocalDataSource>(),
        remoteDataSource: sl<ContainerRemoteDataSource>(),
        connectivity: sl<Connectivity>(),
      ),
      dependsOn: [ContainerLocalDataSource],
    );
  }

  /// Register use cases
  static void _registerUseCases(GetIt sl) {
    sl.registerLazySingletonAsync<GetAllContainers>(
      () async => GetAllContainers(sl<ContainerRepository>()),
      dependsOn: [ContainerRepository],
    );

    sl.registerLazySingletonAsync<GetContainerById>(
      () async => GetContainerById(sl<ContainerRepository>()),
      dependsOn: [ContainerRepository],
    );

    sl.registerLazySingletonAsync<SearchContainers>(
      () async => SearchContainers(sl<ContainerRepository>()),
      dependsOn: [ContainerRepository],
    );

    sl.registerLazySingletonAsync<CreateContainer>(
      () async => CreateContainer(sl<ContainerRepository>()),
      dependsOn: [ContainerRepository],
    );

    sl.registerLazySingletonAsync<UpdateContainer>(
      () async => UpdateContainer(sl<ContainerRepository>()),
      dependsOn: [ContainerRepository],
    );

    sl.registerLazySingletonAsync<DeleteContainer>(
      () async => DeleteContainer(sl<ContainerRepository>()),
      dependsOn: [ContainerRepository],
    );

    sl.registerLazySingletonAsync<GetContainersByStatus>(
      () async => GetContainersByStatus(sl<ContainerRepository>()),
      dependsOn: [ContainerRepository],
    );

    sl.registerLazySingletonAsync<GetContainersByPriority>(
      () async => GetContainersByPriority(sl<ContainerRepository>()),
      dependsOn: [ContainerRepository],
    );
  }

  /// Register BLoCs
  static void _registerBlocs(GetIt sl) {
    sl.registerFactoryAsync<ContainerTrackingBloc>(
      () async => ContainerTrackingBloc(
        getAllContainers: sl<GetAllContainers>(),
        getContainerById: sl<GetContainerById>(),
        searchContainers: sl<SearchContainers>(),
        createContainer: sl<CreateContainer>(),
        updateContainer: sl<UpdateContainer>(),
        deleteContainer: sl<DeleteContainer>(),
        getContainersByStatus: sl<GetContainersByStatus>(),
        getContainersByPriority: sl<GetContainersByPriority>(),
      ),
      dependsOn: [
        GetAllContainers,
        GetContainerById,
        SearchContainers,
        CreateContainer,
        UpdateContainer,
        DeleteContainer,
        GetContainersByStatus,
        GetContainersByPriority,
      ],
    );
  }
}

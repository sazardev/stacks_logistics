import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/network_config.dart';
import '../network/network_info.dart';

// Authentication imports
import '../../features/authentication/data/data_sources/auth_remote_data_source.dart';
import '../../features/authentication/data/data_sources/auth_local_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repository_interfaces/auth_repository.dart';
import '../../features/authentication/domain/use_cases/sign_in_use_case.dart';
import '../../features/authentication/domain/use_cases/register_use_case.dart';
import '../../features/authentication/domain/use_cases/sign_out_use_case.dart';
import '../../features/authentication/domain/use_cases/get_current_user_use_case.dart';
import '../../features/authentication/domain/use_cases/send_password_reset_email_use_case.dart';
import '../../features/authentication/domain/use_cases/auth_state_changes_use_case.dart';
import '../../features/authentication/presentation/blocs/auth_bloc.dart';

/// Service locator instance
final getIt = GetIt.instance;

/// Dependency injection setup for the application
class DependencyInjection {
  /// Initializes all dependencies
  static Future<void> init() async {
    await _initCore();
    await _initLocalStorage();
    await _initNetworking();
    await _initFirebase();
    await _initAuthentication();
    // Other feature-specific dependencies will be added later
  }

  /// Initializes core dependencies
  static Future<void> _initCore() async {
    // SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton(() => sharedPreferences);

    // Connectivity
    getIt.registerLazySingleton(() => Connectivity());

    // Network Info
    getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(connectivity: getIt()),
    );
  }

  /// Initializes local storage dependencies
  static Future<void> _initLocalStorage() async {
    // Authentication Hive box
    final authBox = await Hive.openBox<Map<String, dynamic>>('auth_box');
    getIt.registerLazySingleton<Box<Map<String, dynamic>>>(
      () => authBox,
      instanceName: 'auth_box',
    );
  }

  /// Initializes networking dependencies
  static Future<void> _initNetworking() async {
    // Dio instance
    getIt.registerLazySingleton<Dio>(() => NetworkConfig.createDio());
  }

  /// Initializes Firebase dependencies
  static Future<void> _initFirebase() async {
    // Firebase Auth
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

    // Cloud Firestore
    getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }

  /// Initializes authentication dependencies
  static Future<void> _initAuthentication() async {
    // Data sources
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(firebaseAuth: getIt(), firestore: getIt()),
    );

    getIt.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(hiveBox: getIt(instanceName: 'auth_box')),
    );

    // Repository
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
        networkInfo: getIt(),
      ),
    );

    // Use cases
    getIt.registerLazySingleton(() => SignInUseCase(repository: getIt()));
    getIt.registerLazySingleton(() => RegisterUseCase(repository: getIt()));
    getIt.registerLazySingleton(() => SignOutUseCase(repository: getIt()));
    getIt.registerLazySingleton(
      () => GetCurrentUserUseCase(repository: getIt()),
    );
    getIt.registerLazySingleton(
      () => SendPasswordResetEmailUseCase(repository: getIt()),
    );
    getIt.registerLazySingleton(
      () => AuthStateChangesUseCase(repository: getIt()),
    );

    // BLoC
    getIt.registerFactory(
      () => AuthBloc(
        signInUseCase: getIt(),
        registerUseCase: getIt(),
        signOutUseCase: getIt(),
        getCurrentUserUseCase: getIt(),
        sendPasswordResetEmailUseCase: getIt(),
        authStateChangesUseCase: getIt(),
      ),
    );
  }

  /// Resets all dependencies (useful for testing)
  static Future<void> reset() async {
    await getIt.reset();
  }
}

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_config.dart';

/// Service locator instance
final getIt = GetIt.instance;

/// Dependency injection setup for the application
class DependencyInjection {
  /// Initializes all dependencies
  static Future<void> init() async {
    await _initCore();
    await _initLocalStorage();
    await _initNetworking();
    // Feature-specific dependencies will be added later
  }

  /// Initializes core dependencies
  static Future<void> _initCore() async {
    // SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton(() => sharedPreferences);
  }

  /// Initializes local storage dependencies
  static Future<void> _initLocalStorage() async {
    // Hive will be initialized in main.dart
    // Here we register the box instances once they're opened
  }

  /// Initializes networking dependencies
  static Future<void> _initNetworking() async {
    // Dio instance
    getIt.registerLazySingleton<Dio>(() => NetworkConfig.createDio());
  }

  /// Resets all dependencies (useful for testing)
  static Future<void> reset() async {
    await getIt.reset();
  }
}

import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  const Failure({required this.message, this.code, this.details});

  /// Human-readable error message
  final String message;

  /// Optional error code for categorization
  final String? code;

  /// Optional additional details about the error
  final Map<String, dynamic>? details;

  @override
  List<Object?> get props => [message, code, details];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code = 'NETWORK_ERROR',
    super.details,
  });
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code = 'SERVER_ERROR',
    super.details,
  });
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.details,
  });
}

/// Authorization-related failures (permissions)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    required super.message,
    super.code = 'AUTHORIZATION_ERROR',
    super.details,
  });
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.details,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.details,
  });
}

/// Local storage-related failures
class LocalStorageFailure extends Failure {
  const LocalStorageFailure({
    required super.message,
    super.code = 'LOCAL_STORAGE_ERROR',
    super.details,
  });
}

/// Firebase-related failures
class FirebaseFailure extends Failure {
  const FirebaseFailure({
    required super.message,
    super.code = 'FIREBASE_ERROR',
    super.details,
  });
}

/// Data parsing-related failures
class ParseFailure extends Failure {
  const ParseFailure({
    required super.message,
    super.code = 'PARSE_ERROR',
    super.details,
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code = 'NOT_FOUND_ERROR',
    super.details,
  });
}

/// Timeout-related failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required super.message,
    super.code = 'TIMEOUT_ERROR',
    super.details,
  });
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code = 'UNKNOWN_ERROR',
    super.details,
  });
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code = 'PERMISSION_ERROR',
    super.details,
  });
}

/// Device-related failures (camera, location, etc.)
class DeviceFailure extends Failure {
  const DeviceFailure({
    required super.message,
    super.code = 'DEVICE_ERROR',
    super.details,
  });
}

/// Business logic-related failures
class BusinessLogicFailure extends Failure {
  const BusinessLogicFailure({
    required super.message,
    super.code = 'BUSINESS_LOGIC_ERROR',
    super.details,
  });
}

/// Synchronization-related failures
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code = 'SYNC_ERROR',
    super.details,
  });
}

/// Base exception classes for the application
///
/// These exceptions are used at the data layer and are converted
/// to corresponding Failure objects in the domain layer.

/// Base exception for all application exceptions
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException({required String message}) : super(message);
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException(super.message);
}

/// Authorization-related exceptions (permissions)
class AuthorizationException extends AppException {
  const AuthorizationException(super.message);
}

/// Validation-related exceptions
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Local storage-related exceptions
class LocalStorageException extends AppException {
  const LocalStorageException(super.message);
}

/// Firebase-related exceptions
class AppFirebaseException extends AppException {
  const AppFirebaseException(super.message);
}

/// Data parsing-related exceptions
class ParseException extends AppException {
  const ParseException(super.message);
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Timeout-related exceptions
class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

/// Unknown/unexpected exceptions
class UnknownException extends AppException {
  const UnknownException(super.message);
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message);
}

/// Device-related exceptions (camera, location, etc.)
class DeviceException extends AppException {
  const DeviceException(super.message);
}

/// Business logic-related exceptions
class BusinessLogicException extends AppException {
  const BusinessLogicException(super.message);
}

/// Synchronization-related exceptions
class SyncException extends AppException {
  const SyncException(super.message);
}

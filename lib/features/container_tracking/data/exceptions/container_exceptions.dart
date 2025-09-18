/// Domain-specific exceptions for the container tracking feature
///
/// These exceptions represent specific error conditions that can occur
/// during container operations and provide meaningful error messages
/// to the presentation layer.

/// Exception thrown when a container is not found in the data source
class ContainerNotFoundException implements Exception {
  const ContainerNotFoundException({
    this.message = 'Container not found',
    this.containerId,
  });

  final String message;
  final String? containerId;

  @override
  String toString() {
    if (containerId != null) {
      return 'ContainerNotFoundException: $message (Container ID: $containerId)';
    }
    return 'ContainerNotFoundException: $message';
  }
}

/// Exception thrown when a user is not authenticated
class UserNotAuthenticatedException implements Exception {
  const UserNotAuthenticatedException({
    this.message = 'User is not authenticated',
  });

  final String message;

  @override
  String toString() => 'UserNotAuthenticatedException: $message';
}

/// Exception thrown when a container with the same identifier already exists
class ContainerAlreadyExistsException implements Exception {
  const ContainerAlreadyExistsException({
    this.message = 'Container already exists',
    this.containerNumber,
  });

  final String message;
  final String? containerNumber;

  @override
  String toString() {
    if (containerNumber != null) {
      return 'ContainerAlreadyExistsException: $message (Container Number: $containerNumber)';
    }
    return 'ContainerAlreadyExistsException: $message';
  }
}

/// Exception thrown when container data validation fails
class ContainerValidationException implements Exception {
  const ContainerValidationException({
    this.message = 'Container validation failed',
    this.field,
    this.value,
  });

  final String message;
  final String? field;
  final dynamic value;

  @override
  String toString() {
    if (field != null) {
      return 'ContainerValidationException: $message (Field: $field, Value: $value)';
    }
    return 'ContainerValidationException: $message';
  }
}

/// Exception thrown when container synchronization fails
class ContainerSyncException implements Exception {
  const ContainerSyncException({
    this.message = 'Container synchronization failed',
    this.containerId,
    this.syncDirection,
  });

  final String message;
  final String? containerId;
  final String? syncDirection; // 'local_to_remote' or 'remote_to_local'

  @override
  String toString() {
    final details = <String>[];
    if (containerId != null) details.add('Container ID: $containerId');
    if (syncDirection != null) details.add('Sync Direction: $syncDirection');

    if (details.isNotEmpty) {
      return 'ContainerSyncException: $message (${details.join(', ')})';
    }
    return 'ContainerSyncException: $message';
  }
}

/// Exception thrown when container permissions are insufficient
class ContainerPermissionException implements Exception {
  const ContainerPermissionException({
    this.message = 'Insufficient permissions for container operation',
    this.operation,
    this.containerId,
  });

  final String message;
  final String? operation;
  final String? containerId;

  @override
  String toString() {
    final details = <String>[];
    if (operation != null) details.add('Operation: $operation');
    if (containerId != null) details.add('Container ID: $containerId');

    if (details.isNotEmpty) {
      return 'ContainerPermissionException: $message (${details.join(', ')})';
    }
    return 'ContainerPermissionException: $message';
  }
}

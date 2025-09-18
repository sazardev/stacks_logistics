import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'failures.dart';

/// Utility class for converting exceptions to failures
class ExceptionHandler {
  /// Converts a generic exception to a Failure
  static Failure handleException(dynamic exception) {
    if (exception is DioException) {
      return _handleDioException(exception);
    } else if (exception is FirebaseAuthException) {
      return _handleFirebaseAuthException(exception);
    } else if (exception is FirebaseException) {
      return _handleFirebaseException(exception);
    } else if (exception is SocketException) {
      return NetworkFailure(
        message: 'No internet connection. Please check your network settings.',
        details: {'exception': exception.toString()},
      );
    } else if (exception is HttpException) {
      return NetworkFailure(
        message: 'Network error occurred. Please try again.',
        details: {'exception': exception.toString()},
      );
    } else if (exception is FormatException) {
      return ParseFailure(
        message: 'Invalid data format received.',
        details: {'exception': exception.toString()},
      );
    } else if (exception is TypeError) {
      return ParseFailure(
        message: 'Data type mismatch occurred.',
        details: {'exception': exception.toString()},
      );
    } else {
      return UnknownFailure(
        message: 'An unexpected error occurred. Please try again.',
        details: {'exception': exception.toString()},
      );
    }
  }

  /// Handles Dio-specific exceptions
  static Failure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return const TimeoutFailure(
          message: 'Connection timeout. Please try again.',
        );
      case DioExceptionType.sendTimeout:
        return const TimeoutFailure(
          message: 'Request timeout. Please try again.',
        );
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure(
          message: 'Response timeout. Please try again.',
        );
      case DioExceptionType.badResponse:
        return _handleHttpStatusCode(exception.response?.statusCode ?? 0);
      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'Connection error. Please check your internet connection.',
        );
      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'Certificate error. Please try again.',
        );
      case DioExceptionType.unknown:
        return NetworkFailure(
          message: 'Network error occurred. Please try again.',
          details: {'exception': exception.toString()},
        );
    }
  }

  /// Handles HTTP status codes
  static Failure _handleHttpStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return const ValidationFailure(
          message: 'Invalid request. Please check your input.',
          code: 'BAD_REQUEST',
        );
      case 401:
        return const AuthFailure(
          message: 'Authentication failed. Please log in again.',
          code: 'UNAUTHORIZED',
        );
      case 403:
        return const AuthorizationFailure(
          message:
              'Access denied. You don\'t have permission to perform this action.',
          code: 'FORBIDDEN',
        );
      case 404:
        return const NotFoundFailure(
          message: 'Requested resource not found.',
          code: 'NOT_FOUND',
        );
      case 408:
        return const TimeoutFailure(
          message: 'Request timeout. Please try again.',
          code: 'REQUEST_TIMEOUT',
        );
      case 409:
        return const ValidationFailure(
          message: 'Conflict occurred. Resource already exists.',
          code: 'CONFLICT',
        );
      case 422:
        return const ValidationFailure(
          message: 'Invalid data provided. Please check your input.',
          code: 'UNPROCESSABLE_ENTITY',
        );
      case 429:
        return const ServerFailure(
          message: 'Too many requests. Please try again later.',
          code: 'TOO_MANY_REQUESTS',
        );
      case 500:
        return const ServerFailure(
          message: 'Internal server error. Please try again later.',
          code: 'INTERNAL_SERVER_ERROR',
        );
      case 502:
        return const ServerFailure(
          message: 'Bad gateway. Please try again later.',
          code: 'BAD_GATEWAY',
        );
      case 503:
        return const ServerFailure(
          message: 'Service unavailable. Please try again later.',
          code: 'SERVICE_UNAVAILABLE',
        );
      case 504:
        return const TimeoutFailure(
          message: 'Gateway timeout. Please try again.',
          code: 'GATEWAY_TIMEOUT',
        );
      default:
        return ServerFailure(
          message: 'Server error occurred. Please try again later.',
          code: 'HTTP_$statusCode',
        );
    }
  }

  /// Handles Firebase Auth exceptions
  static Failure _handleFirebaseAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return const AuthFailure(
          message: 'No user found with this email address.',
          code: 'USER_NOT_FOUND',
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'Incorrect password. Please try again.',
          code: 'WRONG_PASSWORD',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          message: 'An account already exists with this email address.',
          code: 'EMAIL_ALREADY_IN_USE',
        );
      case 'weak-password':
        return const ValidationFailure(
          message: 'Password is too weak. Please choose a stronger password.',
          code: 'WEAK_PASSWORD',
        );
      case 'invalid-email':
        return const ValidationFailure(
          message: 'Invalid email address format.',
          code: 'INVALID_EMAIL',
        );
      case 'user-disabled':
        return const AuthFailure(
          message: 'This user account has been disabled.',
          code: 'USER_DISABLED',
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'Too many failed attempts. Please try again later.',
          code: 'TOO_MANY_REQUESTS',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          message: 'This operation is not allowed.',
          code: 'OPERATION_NOT_ALLOWED',
        );
      case 'invalid-verification-code':
        return const ValidationFailure(
          message: 'Invalid verification code.',
          code: 'INVALID_VERIFICATION_CODE',
        );
      case 'invalid-verification-id':
        return const ValidationFailure(
          message: 'Invalid verification ID.',
          code: 'INVALID_VERIFICATION_ID',
        );
      case 'network-request-failed':
        return const NetworkFailure(
          message: 'Network error. Please check your connection.',
          code: 'NETWORK_REQUEST_FAILED',
        );
      default:
        return AuthFailure(
          message: exception.message ?? 'Authentication error occurred.',
          code: exception.code,
          details: {'exception': exception.toString()},
        );
    }
  }

  /// Handles Firebase exceptions (Firestore, Storage, etc.)
  static Failure _handleFirebaseException(FirebaseException exception) {
    switch (exception.code) {
      case 'permission-denied':
        return const AuthorizationFailure(
          message:
              'Permission denied. You don\'t have access to this resource.',
          code: 'PERMISSION_DENIED',
        );
      case 'not-found':
        return const NotFoundFailure(
          message: 'Requested document or resource not found.',
          code: 'NOT_FOUND',
        );
      case 'already-exists':
        return const ValidationFailure(
          message: 'Document already exists.',
          code: 'ALREADY_EXISTS',
        );
      case 'resource-exhausted':
        return const ServerFailure(
          message: 'Quota exceeded. Please try again later.',
          code: 'RESOURCE_EXHAUSTED',
        );
      case 'failed-precondition':
        return const ValidationFailure(
          message: 'Operation failed due to failed precondition.',
          code: 'FAILED_PRECONDITION',
        );
      case 'aborted':
        return const ServerFailure(
          message: 'Operation was aborted. Please try again.',
          code: 'ABORTED',
        );
      case 'out-of-range':
        return const ValidationFailure(
          message: 'Operation was attempted past the valid range.',
          code: 'OUT_OF_RANGE',
        );
      case 'unimplemented':
        return const ServerFailure(
          message: 'Operation is not implemented or supported.',
          code: 'UNIMPLEMENTED',
        );
      case 'internal':
        return const ServerFailure(
          message: 'Internal server error. Please try again later.',
          code: 'INTERNAL',
        );
      case 'unavailable':
        return const ServerFailure(
          message: 'Service is currently unavailable. Please try again later.',
          code: 'UNAVAILABLE',
        );
      case 'data-loss':
        return const ServerFailure(
          message: 'Unrecoverable data loss or corruption.',
          code: 'DATA_LOSS',
        );
      case 'unauthenticated':
        return const AuthFailure(
          message: 'Authentication required. Please log in.',
          code: 'UNAUTHENTICATED',
        );
      default:
        return FirebaseFailure(
          message: exception.message ?? 'Firebase error occurred.',
          code: exception.code,
          details: {'exception': exception.toString()},
        );
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register a new user with email and password
  Future<Either<Failure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? companyName,
  });

  /// Sign out the current user
  Future<Either<Failure, void>> signOut();

  /// Get the current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Send email verification
  Future<Either<Failure, void>> sendEmailVerification();

  /// Verify email with token
  Future<Either<Failure, User>> verifyEmail(String token);

  /// Update user profile
  Future<Either<Failure, User>> updateUserProfile({
    String? name,
    String? photoUrl,
    String? phoneNumber,
    String? companyName,
  });

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();

  /// Check if email is available
  Future<Either<Failure, bool>> isEmailAvailable(String email);

  /// Re-authenticate user (for sensitive operations)
  Future<Either<Failure, void>> reauthenticate(String password);

  /// Stream of authentication state changes
  Stream<Either<Failure, User?>> get authStateChanges;

  /// Check if user is currently signed in
  bool get isSignedIn;
}

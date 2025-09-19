import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository_interfaces/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../data_sources/auth_local_data_source.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';

/// Implementation of AuthRepository using Firebase Auth
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final userModel = await remoteDataSource.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Cache user locally
        await localDataSource.cacheUser(userModel);

        return Right(userModel);
      } else {
        // Try to get cached user if offline
        final cachedUser = await localDataSource.getCachedUser();
        if (cachedUser != null && cachedUser.email == email) {
          return Right(cachedUser);
        }
        return const Left(
          NetworkFailure(message: 'No internet connection and no cached user'),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(AuthFailure(message: 'Sign in failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? companyName,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final userModel = await remoteDataSource.registerWithEmailAndPassword(
          email: email,
          password: password,
          name: name,
          companyName: companyName,
        );

        // Cache user locally
        await localDataSource.cacheUser(userModel);

        return Right(userModel);
      } else {
        return const Left(
          NetworkFailure(message: 'Registration requires internet connection'),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(AuthFailure(message: 'Registration failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Sign out remotely if connected
      if (await networkInfo.isConnected) {
        await remoteDataSource.signOut();
      }

      // Clear local cache
      await localDataSource.clearCachedUser();

      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(AuthFailure(message: 'Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      if (await networkInfo.isConnected) {
        final userModel = await remoteDataSource.getCurrentUser();
        if (userModel != null) {
          // Cache user locally
          await localDataSource.cacheUser(userModel);
          return Right(userModel);
        }
        return const Right(null);
      } else {
        // Return cached user if offline
        final cachedUser = await localDataSource.getCachedUser();
        return Right(cachedUser);
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(
        AuthFailure(message: 'Failed to get current user: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.sendPasswordResetEmail(email);
        return const Right(null);
      } else {
        return const Left(
          NetworkFailure(
            message: 'Password reset requires internet connection',
          ),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'Failed to send password reset email: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.sendEmailVerification();
        return const Right(null);
      } else {
        return const Left(
          NetworkFailure(
            message: 'Email verification requires internet connection',
          ),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'Failed to send email verification: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> verifyEmail(String token) async {
    try {
      if (await networkInfo.isConnected) {
        final userModel = await remoteDataSource.verifyEmail(token);

        // Update cached user
        await localDataSource.cacheUser(userModel);

        return Right(userModel);
      } else {
        return const Left(
          NetworkFailure(
            message: 'Email verification requires internet connection',
          ),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(
        AuthFailure(message: 'Email verification failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    String? name,
    String? photoUrl,
    String? phoneNumber,
    String? companyName,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final userModel = await remoteDataSource.updateUserProfile(
          name: name,
          photoUrl: photoUrl,
          phoneNumber: phoneNumber,
          companyName: companyName,
        );

        // Update cached user
        await localDataSource.cacheUser(userModel);

        return Right(userModel);
      } else {
        return const Left(
          NetworkFailure(
            message: 'Profile update requires internet connection',
          ),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(
        AuthFailure(message: 'Failed to update profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteAccount();

        // Clear local cache
        await localDataSource.clearCachedUser();

        return const Right(null);
      } else {
        return const Left(
          NetworkFailure(
            message: 'Account deletion requires internet connection',
          ),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(
        AuthFailure(message: 'Failed to delete account: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailAvailable(String email) async {
    try {
      if (await networkInfo.isConnected) {
        final isAvailable = await remoteDataSource.isEmailAvailable(email);
        return Right(isAvailable);
      } else {
        return const Left(
          NetworkFailure(
            message: 'Email availability check requires internet connection',
          ),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'Failed to check email availability: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> reauthenticate(String password) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.reauthenticate(password);
        return const Right(null);
      } else {
        return const Left(
          NetworkFailure(
            message: 'Re-authentication requires internet connection',
          ),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(
        AuthFailure(message: 'Re-authentication failed: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Either<Failure, User?>> get authStateChanges {
    try {
      return remoteDataSource.authStateChanges
          .map<Either<Failure, User?>>((user) => Right(user))
          .handleError((error) {
            if (error is AuthException) {
              return Left(AuthFailure(message: error.message));
            }
            return Left(
              AuthFailure(message: 'Auth state error: ${error.toString()}'),
            );
          });
    } catch (e) {
      return Stream.value(
        Left(AuthFailure(message: 'Failed to get auth state: ${e.toString()}')),
      );
    }
  }

  @override
  bool get isSignedIn {
    return remoteDataSource.isSignedIn;
  }
}

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/firebase_config.dart';

/// Remote data source for authentication operations using Firebase Auth
abstract class AuthRemoteDataSource {
  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register a new user with email and password
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? companyName,
  });

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Verify email with token
  Future<UserModel> verifyEmail(String token);

  /// Update user profile
  Future<UserModel> updateUserProfile({
    String? name,
    String? photoUrl,
    String? phoneNumber,
    String? companyName,
  });

  /// Delete user account
  Future<void> deleteAccount();

  /// Check if email is available
  Future<bool> isEmailAvailable(String email);

  /// Re-authenticate user
  Future<void> reauthenticate(String password);

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;

  /// Check if user is currently signed in
  bool get isSignedIn;
}

/// Implementation of AuthRemoteDataSource using Firebase Auth
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Sign in failed: No user returned');
      }

      // Get user data from Firestore
      final userDoc = await firestore
          .collection(
            FirebaseConfig.getCollectionName(FirebaseConfig.usersCollection),
          )
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        final userModel = UserModel.fromFirebaseUser(
          credential.user!,
          name: credential.user!.displayName ?? 'User',
        );
        await _createUserDocument(userModel);
        return userModel;
      }

      return UserModel.fromFirestore(userDoc.data()!, credential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? companyName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Registration failed: No user returned');
      }

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Create user model
      final userModel = UserModel.fromFirebaseUser(
        credential.user!,
        name: name,
        companyName: companyName,
      );

      // Create user document in Firestore
      await _createUserDocument(userModel);

      // Send email verification
      await credential.user!.sendEmailVerification();

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Get user data from Firestore
      final userDoc = await firestore
          .collection(
            FirebaseConfig.getCollectionName(FirebaseConfig.usersCollection),
          )
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        final userModel = UserModel.fromFirebaseUser(
          firebaseUser,
          name: firebaseUser.displayName ?? 'User',
        );
        await _createUserDocument(userModel);
        return userModel;
      }

      return UserModel.fromFirestore(userDoc.data()!, firebaseUser.uid);
    } catch (e) {
      throw AuthException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw AuthException(
        'Failed to send password reset email: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No user signed in');
      }
      await user.sendEmailVerification();
    } catch (e) {
      throw AuthException('Failed to send email verification: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> verifyEmail(String token) async {
    try {
      // For Firebase, email verification is handled by the client SDK
      // This method would be used if implementing custom email verification
      await firebaseAuth.currentUser?.reload();
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw const AuthException('No user signed in');
      }

      // Update user document with verification status
      await firestore
          .collection(
            FirebaseConfig.getCollectionName(FirebaseConfig.usersCollection),
          )
          .doc(user.uid)
          .update({'isEmailVerified': user.emailVerified});

      final userDoc = await firestore
          .collection(
            FirebaseConfig.getCollectionName(FirebaseConfig.usersCollection),
          )
          .doc(user.uid)
          .get();

      return UserModel.fromFirestore(userDoc.data()!, user.uid);
    } catch (e) {
      throw AuthException('Email verification failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    String? name,
    String? photoUrl,
    String? phoneNumber,
    String? companyName,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No user signed in');
      }

      // Update Firebase Auth profile
      if (name != null) {
        await user.updateDisplayName(name);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore document
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (companyName != null) updateData['companyName'] = companyName;
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await firestore
          .collection(
            FirebaseConfig.getCollectionName(FirebaseConfig.usersCollection),
          )
          .doc(user.uid)
          .update(updateData);

      // Get updated user data
      final userDoc = await firestore
          .collection(
            FirebaseConfig.getCollectionName(FirebaseConfig.usersCollection),
          )
          .doc(user.uid)
          .get();

      return UserModel.fromFirestore(userDoc.data()!, user.uid);
    } catch (e) {
      throw AuthException('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No user signed in');
      }

      // Delete user document from Firestore
      await firestore
          .collection(
            FirebaseConfig.getCollectionName(FirebaseConfig.usersCollection),
          )
          .doc(user.uid)
          .delete();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }

  @override
  Future<bool> isEmailAvailable(String email) async {
    try {
      // Try to create a dummy account to check if email exists
      // This is a workaround since fetchSignInMethodsForEmail is deprecated
      try {
        await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: 'temporaryPassword123!',
        );
        // If successful, email is available but we need to delete the test account
        await firebaseAuth.currentUser?.delete();
        return true;
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          return false;
        }
        // For other errors, assume email is available
        return true;
      }
    } catch (e) {
      throw AuthException(
        'Failed to check email availability: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> reauthenticate(String password) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw const AuthException('No user signed in or email not available');
      }

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw AuthException('Re-authentication failed: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await firestore
            .collection(
              FirebaseConfig.getCollectionName(FirebaseConfig.usersCollection),
            )
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) {
          final userModel = UserModel.fromFirebaseUser(
            firebaseUser,
            name: firebaseUser.displayName ?? 'User',
          );
          await _createUserDocument(userModel);
          return userModel;
        }

        return UserModel.fromFirestore(userDoc.data()!, firebaseUser.uid);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  bool get isSignedIn => firebaseAuth.currentUser != null;

  /// Creates a user document in Firestore
  Future<void> _createUserDocument(UserModel userModel) async {
    await firestore
        .collection(
          FirebaseConfig.getCollectionName(FirebaseConfig.usersCollection),
        )
        .doc(userModel.id)
        .set(userModel.toFirestore());
  }

  /// Maps Firebase Auth error codes to user-friendly messages
  String _mapFirebaseAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}

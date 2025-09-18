import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// States for authentication BLoC
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during authentication operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state
class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// User registered successfully but needs email verification
class AuthRegisteredUnverified extends AuthState {
  const AuthRegisteredUnverified(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

/// Password reset email sent
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

/// Email verification sent
class AuthVerificationEmailSent extends AuthState {
  const AuthVerificationEmailSent();
}

/// Email verified successfully
class AuthEmailVerified extends AuthState {
  const AuthEmailVerified(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

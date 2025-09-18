import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Events for authentication BLoC
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to log in with email and password
class LoginRequested extends AuthEvent {
  const LoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  final String email;
  final String password;
  final bool rememberMe;

  @override
  List<Object?> get props => [email, password, rememberMe];
}

/// Event to register a new user
class RegisterRequested extends AuthEvent {
  const RegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.companyName,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? companyName;

  @override
  List<Object?> get props => [
    email,
    password,
    firstName,
    lastName,
    companyName,
  ];
}

/// Event to log out the current user
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Event to request password reset
class PasswordResetRequested extends AuthEvent {
  const PasswordResetRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Event to check if user is already authenticated
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Event to resend email verification
class ResendVerificationEmail extends AuthEvent {
  const ResendVerificationEmail();
}

/// Event to verify email with token
class VerifyEmail extends AuthEvent {
  const VerifyEmail(this.token);

  final String token;

  @override
  List<Object?> get props => [token];
}

/// Event when authentication state changes
class AuthStateChanged extends AuthEvent {
  const AuthStateChanged(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

/// Event when authentication state has an error
class AuthStateError extends AuthEvent {
  const AuthStateError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../domain/use_cases/sign_in_use_case.dart';
import '../../domain/use_cases/register_use_case.dart';
import '../../domain/use_cases/sign_out_use_case.dart';
import '../../domain/use_cases/get_current_user_use_case.dart';
import '../../domain/use_cases/send_password_reset_email_use_case.dart';
import '../../domain/use_cases/auth_state_changes_use_case.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.signInUseCase,
    required this.registerUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.sendPasswordResetEmailUseCase,
    required this.authStateChangesUseCase,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<ResendVerificationEmail>(_onResendVerificationEmail);
    on<VerifyEmail>(_onVerifyEmail);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<AuthStateError>(_onAuthStateError);
    on<UserUnauthenticated>(_onUserUnauthenticated);

    // Listen to auth state changes
    _authStateSubscription = authStateChangesUseCase.call().listen((result) {
      result.fold(
        (failure) => add(AuthStateError(failure.message)),
        (user) => user != null
            ? add(AuthStateChanged(user))
            : add(const UserUnauthenticated()),
      );
    });
  }

  final SignInUseCase signInUseCase;
  final RegisterUseCase registerUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;
  final AuthStateChangesUseCase authStateChangesUseCase;

  StreamSubscription? _authStateSubscription;

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signInUseCase.call(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await registerUseCase.call(
      RegisterParams(
        email: event.email,
        password: event.password,
        name: '${event.firstName} ${event.lastName}',
        companyName: event.companyName,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => user.isEmailVerified
          ? emit(AuthAuthenticated(user))
          : emit(AuthRegisteredUnverified(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signOutUseCase.call();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUserUseCase.call();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await sendPasswordResetEmailUseCase.call(
      SendPasswordResetEmailParams(email: event.email),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthPasswordResetSent()),
    );
  }

  Future<void> _onResendVerificationEmail(
    ResendVerificationEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // TODO: Implement resend verification use case
    emit(const AuthVerificationEmailSent());
  }

  Future<void> _onVerifyEmail(
    VerifyEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // TODO: Implement verify email use case
    final result = await getCurrentUserUseCase.call();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => user != null
          ? emit(AuthEmailVerified(user))
          : emit(const AuthError('No user found')),
    );
  }

  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthAuthenticated(event.user));
  }

  Future<void> _onAuthStateError(
    AuthStateError event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthError(event.message));
  }

  Future<void> _onUserUnauthenticated(
    UserUnauthenticated event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthUnauthenticated());
  }
}

class NoParams {}

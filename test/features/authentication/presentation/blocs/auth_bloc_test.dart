import 'package:flutter_test/flutter_test.dart';
import 'package:stacks_logistics/features/authentication/presentation/blocs/auth_bloc.dart';
import 'package:stacks_logistics/features/authentication/presentation/blocs/auth_event.dart';
import 'package:stacks_logistics/features/authentication/presentation/blocs/auth_state.dart';

void main() {
  group('AuthBloc Tests', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc();
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state should be AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    group('LoginRequested', () {
      test(
        'should emit loading then authenticated when credentials are correct',
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password';

          // Act & Assert
          expectLater(
            authBloc.stream,
            emitsInOrder([const AuthLoading(), isA<AuthAuthenticated>()]),
          );

          authBloc.add(const LoginRequested(email: email, password: password));
        },
      );

      test(
        'should emit loading then error when credentials are incorrect',
        () async {
          // Arrange
          const email = 'wrong@example.com';
          const password = 'wrongpassword';

          // Act & Assert
          expectLater(
            authBloc.stream,
            emitsInOrder([
              const AuthLoading(),
              const AuthError('Invalid email or password'),
            ]),
          );

          authBloc.add(const LoginRequested(email: email, password: password));
        },
      );
    });

    group('RegisterRequested', () {
      test('should emit loading then registered unverified', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';

        // Act & Assert
        expectLater(
          authBloc.stream,
          emitsInOrder([const AuthLoading(), isA<AuthRegisteredUnverified>()]),
        );

        authBloc.add(
          const RegisterRequested(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ),
        );
      });
    });

    group('LogoutRequested', () {
      test('should emit loading then unauthenticated', () async {
        // Act & Assert
        expectLater(
          authBloc.stream,
          emitsInOrder([const AuthLoading(), const AuthUnauthenticated()]),
        );

        authBloc.add(const LogoutRequested());
      });
    });

    group('CheckAuthStatus', () {
      test(
        'should emit loading then unauthenticated for mock implementation',
        () async {
          // Act & Assert
          expectLater(
            authBloc.stream,
            emitsInOrder([const AuthLoading(), const AuthUnauthenticated()]),
          );

          authBloc.add(const CheckAuthStatus());
        },
      );
    });

    group('PasswordResetRequested', () {
      test('should emit loading then password reset sent', () async {
        // Arrange
        const email = 'test@example.com';

        // Act & Assert
        expectLater(
          authBloc.stream,
          emitsInOrder([const AuthLoading(), const AuthPasswordResetSent()]),
        );

        authBloc.add(const PasswordResetRequested(email));
      });
    });

    group('ResendVerificationEmail', () {
      test('should emit loading then verification email sent', () async {
        // Act & Assert
        expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthLoading(),
            const AuthVerificationEmailSent(),
          ]),
        );

        authBloc.add(const ResendVerificationEmail());
      });
    });

    group('VerifyEmail', () {
      test('should emit loading then email verified', () async {
        // Arrange
        const token = 'verification_token';

        // Act & Assert
        expectLater(
          authBloc.stream,
          emitsInOrder([const AuthLoading(), isA<AuthEmailVerified>()]),
        );

        authBloc.add(const VerifyEmail(token));
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:stacks_logistics/features/authentication/presentation/blocs/auth_bloc.dart';
import 'package:stacks_logistics/features/authentication/presentation/blocs/auth_event.dart';
import 'package:stacks_logistics/features/authentication/presentation/blocs/auth_state.dart';
import 'package:stacks_logistics/features/authentication/domain/use_cases/sign_in_use_case.dart';
import 'package:stacks_logistics/features/authentication/domain/use_cases/register_use_case.dart';
import 'package:stacks_logistics/features/authentication/domain/use_cases/sign_out_use_case.dart';
import 'package:stacks_logistics/features/authentication/domain/use_cases/get_current_user_use_case.dart';
import 'package:stacks_logistics/features/authentication/domain/use_cases/send_password_reset_email_use_case.dart';
import 'package:stacks_logistics/features/authentication/domain/use_cases/auth_state_changes_use_case.dart';
import 'package:stacks_logistics/features/authentication/domain/entities/user.dart';
import 'package:stacks_logistics/core/error/failures.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  SignInUseCase,
  RegisterUseCase,
  SignOutUseCase,
  GetCurrentUserUseCase,
  SendPasswordResetEmailUseCase,
  AuthStateChangesUseCase,
])
void main() {
  group('AuthBloc Tests', () {
    late AuthBloc authBloc;
    late MockSignInUseCase mockSignInUseCase;
    late MockRegisterUseCase mockRegisterUseCase;
    late MockSignOutUseCase mockSignOutUseCase;
    late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
    late MockSendPasswordResetEmailUseCase mockSendPasswordResetEmailUseCase;
    late MockAuthStateChangesUseCase mockAuthStateChangesUseCase;

    setUp(() {
      mockSignInUseCase = MockSignInUseCase();
      mockRegisterUseCase = MockRegisterUseCase();
      mockSignOutUseCase = MockSignOutUseCase();
      mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
      mockSendPasswordResetEmailUseCase = MockSendPasswordResetEmailUseCase();
      mockAuthStateChangesUseCase = MockAuthStateChangesUseCase();

      // Set up the auth state changes use case to return an empty stream
      when(
        mockAuthStateChangesUseCase(),
      ).thenAnswer((_) => Stream<Either<Failure, User?>>.empty());

      authBloc = AuthBloc(
        signInUseCase: mockSignInUseCase,
        registerUseCase: mockRegisterUseCase,
        signOutUseCase: mockSignOutUseCase,
        getCurrentUserUseCase: mockGetCurrentUserUseCase,
        sendPasswordResetEmailUseCase: mockSendPasswordResetEmailUseCase,
        authStateChangesUseCase: mockAuthStateChangesUseCase,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state should be AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    group('LoginRequested', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      final testUser = User(
        id: '1',
        email: testEmail,
        name: 'Test User',
        isEmailVerified: true,
        isPremiumUser: false,
        createdAt: DateTime(2023, 1, 1),
        lastLoginAt: DateTime(2023, 1, 1),
      );

      test(
        'should emit [AuthLoading, AuthAuthenticated] when login succeeds',
        () async {
          // Arrange
          when(mockSignInUseCase(any)).thenAnswer((_) async => Right(testUser));

          // Act
          authBloc.add(
            const LoginRequested(email: testEmail, password: testPassword),
          );

          // Assert
          await expectLater(
            authBloc.stream,
            emitsInOrder([const AuthLoading(), AuthAuthenticated(testUser)]),
          );
        },
      );

      test('should emit [AuthLoading, AuthError] when login fails', () async {
        // Arrange
        const failure = AuthFailure(message: 'Invalid credentials');
        when(
          mockSignInUseCase(any),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        authBloc.add(
          const LoginRequested(email: testEmail, password: testPassword),
        );

        // Assert
        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthLoading(),
            const AuthError('Invalid credentials'),
          ]),
        );
      });
    });

    group('RegisterRequested', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testFirstName = 'Test';
      const testLastName = 'User';

      final testUser = User(
        id: '1',
        email: testEmail,
        name: '$testFirstName $testLastName',
        isEmailVerified: false,
        isPremiumUser: false,
        createdAt: DateTime(2023, 1, 1),
      );

      test(
        'should emit [AuthLoading, AuthRegisteredUnverified] when registration succeeds',
        () async {
          // Arrange
          when(
            mockRegisterUseCase(any),
          ).thenAnswer((_) async => Right(testUser));

          // Act
          authBloc.add(
            const RegisterRequested(
              email: testEmail,
              password: testPassword,
              firstName: testFirstName,
              lastName: testLastName,
            ),
          );

          // Assert
          await expectLater(
            authBloc.stream,
            emitsInOrder([
              const AuthLoading(),
              AuthRegisteredUnverified(testUser),
            ]),
          );
        },
      );
    });

    group('LogoutRequested', () {
      test(
        'should emit [AuthLoading, AuthUnauthenticated] when logout succeeds',
        () async {
          // Arrange
          when(mockSignOutUseCase()).thenAnswer((_) async => const Right(null));

          // Act
          authBloc.add(const LogoutRequested());

          // Assert
          await expectLater(
            authBloc.stream,
            emitsInOrder([const AuthLoading(), const AuthUnauthenticated()]),
          );
        },
      );
    });

    group('PasswordResetRequested', () {
      const testEmail = 'test@example.com';

      test(
        'should emit [AuthLoading, AuthPasswordResetSent] when password reset succeeds',
        () async {
          // Arrange
          when(
            mockSendPasswordResetEmailUseCase(any),
          ).thenAnswer((_) async => const Right(null));

          // Act
          authBloc.add(const PasswordResetRequested(testEmail));

          // Assert
          await expectLater(
            authBloc.stream,
            emitsInOrder([const AuthLoading(), const AuthPasswordResetSent()]),
          );
        },
      );
    });
  });
}

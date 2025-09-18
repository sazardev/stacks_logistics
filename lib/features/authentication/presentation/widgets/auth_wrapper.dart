import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/auth_event.dart';
import '../pages/login_page.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../container_tracking/presentation/pages/container_list_page.dart';

/// Authentication wrapper widget that handles routing based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(const CheckAuthStatus()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Show loading screen while checking auth status
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Show main app if authenticated
          if (state is AuthAuthenticated) {
            return const ContainerListPage();
          }

          // Show login page if not authenticated
          return const LoginPage();
        },
      ),
    );
  }
}

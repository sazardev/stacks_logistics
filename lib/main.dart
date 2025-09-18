import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/dependency_injection.dart';
import 'core/themes/app_theme.dart';
import 'core/config/firebase_config.dart';
import 'features/container_tracking/container_tracking_di.dart';
import 'features/authentication/presentation/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with configuration
  await FirebaseConfig.initialize();

  // Configure Firestore settings
  await FirebaseConfig.configureFirestore();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize core dependencies
  await DependencyInjection.init();

  // Initialize feature dependencies
  await ContainerTrackingDI.init(getIt);

  runApp(const StackLogisticsApp());
}

class StackLogisticsApp extends StatelessWidget {
  const StackLogisticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stack Logistics',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

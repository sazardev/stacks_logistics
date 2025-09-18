import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Firebase configuration for different environments
class FirebaseConfig {
  /// Initialize Firebase with platform-specific options
  static Future<void> initialize() async {
    await Firebase.initializeApp(options: _getFirebaseOptions());
  }

  /// Get Firebase options based on current platform
  static FirebaseOptions _getFirebaseOptions() {
    // For development/demo purposes, using placeholder values
    // In production, replace these with your actual Firebase project values

    if (Platform.isAndroid) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDemo-AndroidAPIKey-stacklogistics123',
        appId: '1:123456789:android:demo123stacklogistics',
        messagingSenderId: '123456789',
        projectId: projectId,
        storageBucket: storageBucket,
        authDomain: authDomain,
      );
    } else if (Platform.isIOS) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDemo-iOSAPIKey-stacklogistics123',
        appId: '1:123456789:ios:demo123stacklogistics',
        messagingSenderId: '123456789',
        projectId: projectId,
        storageBucket: storageBucket,
        authDomain: authDomain,
        iosBundleId: 'com.stacklogistics.app',
      );
    } else if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDemo-WebAPIKey-stacklogistics123',
        appId: '1:123456789:web:demo123stacklogistics',
        messagingSenderId: '123456789',
        projectId: projectId,
        authDomain: authDomain,
        storageBucket: storageBucket,
        measurementId: 'G-DEMO123',
      );
    } else {
      // Desktop platforms (Windows, macOS, Linux)
      return const FirebaseOptions(
        apiKey: 'AIzaSyDemo-DesktopAPIKey-stacklogistics123',
        appId: '1:123456789:desktop:demo123stacklogistics',
        messagingSenderId: '123456789',
        projectId: projectId,
        storageBucket: storageBucket,
        authDomain: authDomain,
      );
    }
  }

  /// Environment-specific configurations
  static const String projectId = 'stack-logistics-demo';
  static const String storageBucket = 'stack-logistics-demo.appspot.com';
  static const String authDomain = 'stack-logistics-demo.firebaseapp.com';

  /// Collection names for Firestore
  static const String containersCollection = 'containers';
  static const String usersCollection = 'users';
  static const String trackingCollection = 'tracking';
  static const String notificationsCollection = 'notifications';
  static const String companiesCollection = 'companies';
  static const String rolesCollection = 'roles';

  /// Environment detection
  static bool get isDevelopment => !kReleaseMode;
  static bool get isProduction => kReleaseMode;

  /// Get collection name with environment prefix
  static String getCollectionName(String collectionName) {
    if (isDevelopment) {
      return 'dev_$collectionName';
    }
    return collectionName;
  }

  /// Firebase settings for better performance
  static Future<void> configureFirestore() async {
    final firestore = FirebaseFirestore.instance;

    // Configure settings based on platform
    if (!kIsWeb) {
      // Enable offline persistence for mobile platforms
      const settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      firestore.settings = settings;
    } else {
      // Web doesn't support offline persistence the same way
      const settings = Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
      firestore.settings = settings;
    }
  }
}

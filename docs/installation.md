# Installation Guide - Stack Logistics

This comprehensive guide will walk you through setting up Stack Logistics for development and production environments across all supported platforms.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Environment Setup](#development-environment-setup)
3. [Firebase Configuration](#firebase-configuration)
4. [Google Maps Configuration](#google-maps-configuration)
5. [Platform-Specific Setup](#platform-specific-setup)
6. [Production Build](#production-build)
7. [Deployment](#deployment)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

#### Minimum Requirements
- **RAM**: 8GB (16GB recommended)
- **Storage**: 10GB free space
- **OS**: Windows 10+, macOS 10.14+, or Ubuntu 18.04+

#### Software Dependencies
- **Flutter SDK**: 3.9.0 or higher
- **Dart SDK**: 3.0.0 or higher (included with Flutter)
- **Git**: Latest version
- **VS Code** or **Android Studio** with Flutter extensions

### Platform-Specific Tools

#### For Android Development
- **Android Studio**: Latest version
- **Android SDK**: API Level 21+ (Android 5.0+)
- **Java**: JDK 11 or higher

#### For iOS Development (macOS only)
- **Xcode**: 13.0 or higher
- **iOS SDK**: iOS 12.0 or higher
- **CocoaPods**: Latest version

#### For Web Development
- **Chrome**: Latest version (for debugging)

#### For Windows Desktop
- **Visual Studio 2019/2022**: with C++ desktop development tools

#### For Linux Desktop
- **GTK 3.0**: development libraries
- **pkg-config**: Latest version

## Development Environment Setup

### 1. Install Flutter

#### Windows
```powershell
# Download Flutter SDK
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.9.0-stable.zip" -OutFile "flutter.zip"

# Extract to C:\flutter
Expand-Archive -Path "flutter.zip" -DestinationPath "C:\"

# Add to PATH
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", [EnvironmentVariableTarget]::User)
```

#### macOS
```bash
# Using Homebrew
brew install flutter

# Or download manually
cd ~/development
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.9.0-stable.zip
unzip flutter_macos_3.9.0-stable.zip
export PATH="$PATH:`pwd`/flutter/bin"
```

#### Linux
```bash
# Download Flutter SDK
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.9.0-stable.tar.xz
tar xf flutter_linux_3.9.0-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Verify Installation
```bash
flutter doctor
```

Ensure all checkmarks are green or address any issues reported.

### 3. Clone Repository
```bash
git clone https://github.com/sazardev/stacks_logistics.git
cd stacks_logistics
```

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Generate Code
```bash
dart run build_runner build
```

## Firebase Configuration

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `stack-logistics-[env]` (e.g., `stack-logistics-dev`)
4. Enable Google Analytics (optional)
5. Create project

### 2. Configure Authentication

1. Navigate to **Authentication** > **Sign-in method**
2. Enable **Email/Password** authentication
3. Configure authorized domains for production

### 3. Set up Firestore Database

1. Navigate to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (configure rules later)
4. Select your preferred location

#### Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /containers/{document} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == resource.data.userId;
    }
    
    match /notifications/{document} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == resource.data.userId;
    }
    
    match /map_markers/{document} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == resource.data.userId;
    }
  }
}
```

### 4. Configure Cloud Messaging

1. Navigate to **Cloud Messaging**
2. Note your **Server key** for backend notifications
3. Configure platform-specific settings

### 5. Download Configuration Files

#### Android
1. Click **Add app** > **Android**
2. Enter package name: `com.stacklogistics.app`
3. Download `google-services.json`
4. Place in `android/app/google-services.json`

#### iOS
1. Click **Add app** > **iOS**
2. Enter bundle ID: `com.stacklogistics.app`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/GoogleService-Info.plist`

#### Web
1. Click **Add app** > **Web**
2. Enter app nickname: `Stack Logistics Web`
3. Copy the configuration
4. Update `web/index.html` with Firebase config:

```html
<script type="module">
  import { initializeApp } from 'https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js';
  import { getAnalytics } from 'https://www.gstatic.com/firebasejs/9.0.0/firebase-analytics.js';

  const firebaseConfig = {
    apiKey: "your-api-key",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789",
    appId: "your-app-id"
  };

  const app = initializeApp(firebaseConfig);
  const analytics = getAnalytics(app);
</script>
```

## Google Maps Configuration

### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing
3. Enable billing (required for production)

### 2. Enable Required APIs

```bash
# Enable APIs using gcloud CLI
gcloud services enable maps-android-backend.googleapis.com
gcloud services enable maps-ios-backend.googleapis.com
gcloud services enable maps-javascript-api.googleapis.com
gcloud services enable places-api.googleapis.com
```

Or enable through the console:
- Maps SDK for Android
- Maps SDK for iOS
- Maps JavaScript API
- Places API

### 3. Create API Keys

#### For Android
1. Create API key in **Credentials**
2. Restrict to **Android apps**
3. Add package name: `com.stacklogistics.app`
4. Add SHA-1 fingerprint:

```bash
# Debug key
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release key (when ready)
keytool -list -v -keystore path/to/release-key.keystore -alias your-alias
```

5. Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ANDROID_API_KEY"/>
```

#### For iOS
1. Create separate API key for iOS
2. Restrict to **iOS apps**
3. Add bundle ID: `com.stacklogistics.app`
4. Update `ios/Runner/Info.plist`:
```xml
<key>GOOGLE_MAPS_API_KEY</key>
<string>YOUR_IOS_API_KEY</string>
```

#### For Web
1. Create API key for web
2. Restrict to **HTTP referrers**
3. Add your domains (localhost for development)
4. Update `web/index.html`:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_WEB_API_KEY&libraries=places"></script>
```

## Platform-Specific Setup

### Android Setup

1. **Update Gradle files**:

`android/build.gradle`:
```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:8.0.0'
    classpath 'com.google.gms:google-services:4.3.15'
}
```

`android/app/build.gradle`:
```gradle
dependencies {
    implementation 'com.google.firebase:firebase-bom:32.2.0'
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-messaging'
}

apply plugin: 'com.google.gms.google-services'
```

2. **Configure permissions** in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS Setup

1. **Update Podfile** (`ios/Podfile`):
```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

2. **Configure permissions** in `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to track containers on the map.</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes and barcodes.</string>
```

3. **Install pods**:
```bash
cd ios
pod install
cd ..
```

### Web Setup

1. **Update web configuration** in `web/index.html`:
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Stack Logistics</title>
  <meta name="description" content="Complete shipping container management platform">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <!-- PWA Configuration -->
  <link rel="manifest" href="manifest.json">
  <link rel="icon" type="image/png" href="favicon.png"/>
  
  <!-- Firebase Configuration -->
  <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-firestore-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
  
  <!-- Google Maps -->
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_WEB_API_KEY"></script>
</head>
<body>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

2. **Configure PWA** in `web/manifest.json`:
```json
{
  "name": "Stack Logistics",
  "short_name": "StackLog",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#F5F5F5",
  "theme_color": "#42A5F5",
  "description": "Complete shipping container management platform",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### Windows Setup

1. **Install Visual Studio** with C++ desktop development tools
2. **Enable Windows development**:
```bash
flutter config --enable-windows-desktop
```

3. **Build and test**:
```bash
flutter run -d windows
```

### macOS Setup

1. **Enable macOS development**:
```bash
flutter config --enable-macos-desktop
```

2. **Configure entitlements** in `macos/Runner/DebugProfile.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.device.camera</key>
    <true/>
</dict>
</plist>
```

### Linux Setup

1. **Install dependencies**:
```bash
sudo apt-get update -y
sudo apt-get install -y ninja-build libgtk-3-dev
```

2. **Enable Linux development**:
```bash
flutter config --enable-linux-desktop
```

## Production Build

### Environment Configuration

Create environment-specific configuration files:

**lib/core/config/env_config.dart**:
```dart
class EnvConfig {
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'development');
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}
```

### Build Commands

#### Android APK
```bash
flutter build apk --release --dart-define=ENV=production --dart-define=FIREBASE_PROJECT_ID=your-prod-project
```

#### Android App Bundle (for Google Play)
```bash
flutter build appbundle --release --dart-define=ENV=production --dart-define=FIREBASE_PROJECT_ID=your-prod-project
```

#### iOS (macOS required)
```bash
flutter build ios --release --dart-define=ENV=production --dart-define=FIREBASE_PROJECT_ID=your-prod-project
```

#### Web
```bash
flutter build web --release --dart-define=ENV=production --dart-define=FIREBASE_PROJECT_ID=your-prod-project
```

#### Windows
```bash
flutter build windows --release --dart-define=ENV=production --dart-define=FIREBASE_PROJECT_ID=your-prod-project
```

#### macOS
```bash
flutter build macos --release --dart-define=ENV=production --dart-define=FIREBASE_PROJECT_ID=your-prod-project
```

#### Linux
```bash
flutter build linux --release --dart-define=ENV=production --dart-define=FIREBASE_PROJECT_ID=your-prod-project
```

### Build Script

Use the provided build script for convenience:

**Windows PowerShell**:
```powershell
./scripts/build-all-platforms.ps1 -Environment production -ProjectId your-prod-project
```

**macOS/Linux Bash**:
```bash
./scripts/build-all-platforms.sh production your-prod-project
```

## Deployment

### App Stores

#### Google Play Store (Android)
1. **Create developer account** at [Google Play Console](https://play.google.com/console)
2. **Create new app** with package name `com.stacklogistics.app`
3. **Upload App Bundle** (`.aab` file)
4. **Complete store listing** with screenshots and descriptions
5. **Submit for review**

#### Apple App Store (iOS)
1. **Create developer account** at [Apple Developer](https://developer.apple.com/)
2. **Create app record** in App Store Connect
3. **Upload build** using Xcode or Transporter
4. **Complete app information** and metadata
5. **Submit for review**

### Web Deployment

#### Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize hosting
firebase init hosting

# Deploy
firebase deploy --only hosting
```

#### Netlify
1. Connect GitHub repository
2. Set build command: `flutter build web --release`
3. Set publish directory: `build/web`
4. Deploy

#### Vercel
1. Import GitHub repository
2. Set framework to "Other"
3. Set build command: `flutter build web --release`
4. Set output directory: `build/web`
5. Deploy

### Desktop Distribution

#### Windows
1. **Package as installer** using tools like Inno Setup
2. **Code sign** the executable for security
3. **Distribute** via website or Microsoft Store

#### macOS
1. **Create DMG** or **PKG** installer
2. **Code sign** and **notarize** for macOS distribution
3. **Distribute** via website or Mac App Store

#### Linux
1. **Create packages** (DEB, RPM, AppImage)
2. **Distribute** via repositories or direct download

## Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues
```bash
# Fix Android license issues
flutter doctor --android-licenses

# Fix iOS deployment target
# Update ios/Podfile with platform :ios, '12.0'

# Fix Xcode command line tools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

#### 2. Firebase Configuration Issues
- Verify configuration files are in correct locations
- Check package names match exactly
- Ensure Firebase project is active
- Verify API keys have correct restrictions

#### 3. Google Maps Issues
- Verify API keys are correct and active
- Check billing is enabled for production
- Ensure required APIs are enabled
- Verify package names/bundle IDs match

#### 4. Build Issues
```bash
# Clean build cache
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Update dependencies
flutter pub upgrade
```

#### 5. Permission Issues
- Add required permissions to platform manifests
- Request permissions at runtime
- Test on physical devices for accurate results

### Debug Commands

```bash
# Verbose build output
flutter build [platform] --verbose

# Analyze code issues
flutter analyze

# Check for dependency issues
flutter pub deps

# Profile app performance
flutter run --profile
```

### Getting Help

1. **Documentation**: Check [Flutter docs](https://docs.flutter.dev/)
2. **Community**: Ask on [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
3. **Issues**: Report bugs on [GitHub Issues](https://github.com/sazardev/stacks_logistics/issues)
4. **Discord**: Join Flutter community Discord

---

## Next Steps

After successful installation:

1. **Run the app**: `flutter run`
2. **Explore features**: Test all functionality
3. **Configure production**: Set up production Firebase project
4. **Deploy**: Follow deployment guides for your target platforms
5. **Monitor**: Set up analytics and crash reporting

For additional help, refer to the [API Documentation](api.md) and [User Guide](user-guide.md).
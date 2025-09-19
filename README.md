# Stack Logistics - Complete Shipping Container Management Platform

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![BLoC](https://img.shields.io/badge/BLoC-00BFFF?style=for-the-badge&logo=flutter&logoColor=white)](https://bloclibrary.dev/)
[![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-4CAF50?style=for-the-badge&logo=architecture&logoColor=white)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Stack Logistics is a comprehensive, multi-platform shipping container management application built with Flutter and Clean Architecture principles. Designed for logistics companies, shipping businesses, and container fleet managers, it provides a complete solution for tracking, managing, and monitoring shipping containers across global supply chains.

## 🚀 Key Features

### 📦 Container Management
- **Complete CRUD Operations**: Create, read, update, and delete container records
- **Real-time Status Tracking**: Monitor container status (loading, in-transit, delivered, delayed, damaged, lost)
- **Priority Management**: Organize containers by priority levels (low, medium, high, critical)
- **Advanced Search & Filtering**: Find containers quickly using multiple search criteria
- **Detailed Container Profiles**: Track contents, weight, dimensions, origin, destination, and journey history

### 🗺️ Interactive Map Tracking
- **Google Maps Integration**: Visual container location tracking on interactive maps
- **Route Visualization**: Display container journey routes from origin to destination
- **Real-time Location Updates**: Live tracking of container positions
- **Marker-based Navigation**: Easy identification of container locations with custom markers
- **Geolocation Services**: Current location awareness and navigation assistance

### 📱 QR/Barcode Scanner
- **Camera-based Scanning**: Instantly identify containers using QR codes or barcodes
- **Quick Search Integration**: Automatically search container database after scanning
- **Scan History**: Keep track of all scanned codes with timestamps
- **Manual Code Input**: Alternative text input for code entry
- **Multi-format Support**: Support for various barcode and QR code formats

### 🔔 Push Notifications
- **Firebase Cloud Messaging**: Real-time notifications for container events
- **Automatic Event Triggers**: Notifications for status changes, deliveries, delays, and damage reports
- **Priority-based Alerts**: Different notification types based on container priority
- **Local Notification Storage**: Offline access to notification history
- **Customizable Settings**: Control notification preferences and types

### 🔐 Authentication & Security
- **Firebase Authentication**: Secure user registration and login
- **Role-based Access**: Different permission levels for team members
- **Local Data Caching**: Secure offline data storage with Hive
- **Session Management**: Automatic session handling and security
- **Password Recovery**: Email-based password reset functionality

### 🌐 Multi-Platform Support
- **iOS & Android**: Native mobile experience on both platforms
- **Web Application**: Progressive Web App (PWA) for browser access
- **Windows Desktop**: Full desktop application for Windows
- **macOS Desktop**: Native desktop experience for Mac users
- **Linux Support**: Cross-platform compatibility for Linux systems

## 🏗️ Technical Architecture

### Clean Architecture Implementation
```
lib/
├── core/                     # Shared utilities, constants, themes
│   ├── config/              # App configuration (Firebase, FCM)
│   ├── constants/           # Application constants
│   ├── di/                  # Dependency injection setup
│   ├── error/               # Error handling and failures
│   ├── network/             # Network configuration
│   ├── services/            # Core services
│   ├── themes/              # App theming and design system
│   └── utils/               # Utility functions
├── features/                 # Feature modules (Clean Architecture)
│   ├── authentication/      # User authentication system
│   ├── container_tracking/  # Container CRUD operations
│   ├── map_tracking/        # Map and location services
│   ├── barcode_scanner/     # QR/Barcode scanning
│   └── notifications/       # Push notification system
└── main.dart                # Application entry point
```

### Technology Stack
- **Frontend**: Flutter 3.9+ with Dart
- **State Management**: BLoC Pattern with flutter_bloc
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging, Storage)
- **Local Storage**: Hive (NoSQL) + Shared Preferences
- **Networking**: Dio HTTP client with error handling
- **Maps**: Google Maps Flutter integration
- **Dependency Injection**: GetIt service locator
- **Functional Programming**: Dartz for error handling
- **Code Generation**: build_runner for model generation

### Design Patterns
- **Clean Architecture**: Separation of Domain, Data, and Presentation layers
- **Repository Pattern**: Abstract data access with multiple sources
- **Use Case Pattern**: Business logic encapsulation
- **BLoC Pattern**: Reactive state management
- **Dependency Injection**: Loosely coupled, testable components
- **SOLID Principles**: Maintainable and scalable codebase

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Firebase project setup for backend services
- Google Maps API key for map functionality

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/sazardev/stacks_logistics.git
   cd stacks_logistics
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build
   ```

4. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add your Android/iOS/Web apps to the project
   - Download and place configuration files:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`
     - Web: Firebase config in `web/index.html`

5. **Set up Google Maps**
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Maps SDK for Android, iOS, and JavaScript
   - Add the API key to platform-specific configurations

6. **Run the application**
   ```bash
   flutter run
   ```

### Build for Production

Use the provided build script for multi-platform builds:
```bash
# Windows PowerShell
./scripts/build-all-platforms.ps1
```

Or build individually:
```bash
# Web
flutter build web --release

# Android
flutter build apk --release
flutter build appbundle --release

# Windows
flutter build windows --release

# iOS (macOS required)
flutter build ios --release

# macOS (macOS required)
flutter build macos --release
```

## 📱 Screenshots & Demo

### Container Management
- Comprehensive container listing with search and filters
- Detailed container information and editing capabilities
- Status tracking with visual indicators

### Map Integration
- Interactive Google Maps with container markers
- Route visualization from origin to destination
- Real-time location tracking

### Scanner Functionality
- Camera-based QR/barcode scanning interface
- Instant container lookup and identification
- Scan history and manual input options

### Push Notifications
- Real-time container event notifications
- Priority-based alert system
- Notification history and management

## 🧪 Testing

The application includes comprehensive testing:

```bash
# Run all tests
flutter test

# Run specific test suites
flutter test test/unit/
flutter test test/integration/
flutter test test/features/

# Generate coverage report
flutter test --coverage
```

### Test Coverage
- **Unit Tests**: Domain logic, use cases, and utilities
- **Widget Tests**: UI components and user interactions
- **Integration Tests**: Feature workflows and data flow
- **Repository Tests**: Data layer and API integration
- **BLoC Tests**: State management and business logic

Current test coverage: **29/29 tests passing** ✅

## 📁 Project Structure

### Detailed Feature Breakdown

```
features/
├── authentication/          # User Authentication System
│   ├── data/               # AuthModel, AuthRepository, Firebase/Local DataSources
│   ├── domain/             # User Entity, AuthRepository Interface, Login/Register UseCases
│   └── presentation/       # LoginPage, AuthBloc, Authentication Widgets
│
├── container_tracking/     # Container Management CRUD
│   ├── data/               # ContainerModel, Repository, Hive/Firebase DataSources
│   ├── domain/             # Container Entity, Repository Interface, CRUD UseCases
│   └── presentation/       # ContainerListPage, AddEditPage, ContainerBloc
│
├── map_tracking/          # Google Maps Integration
│   ├── data/              # LocationModel, MapRepository, GPS DataSources
│   ├── domain/            # Location Entity, Repository Interface, Map UseCases
│   └── presentation/      # MapPage, MapBloc, Location Widgets
│
├── barcode_scanner/       # QR/Barcode Scanning
│   ├── data/              # ScanResultModel, ScannerRepository, Camera DataSources
│   ├── domain/            # ScanResult Entity, Repository Interface, Scanner UseCases
│   └── presentation/      # ScannerPage, ScannerBloc, Scanner Widgets
│
└── notifications/         # Push Notification System
    ├── data/              # NotificationModel, Repository, FCM DataSources
    ├── domain/            # Notification Entity, Repository Interface, FCM UseCases
    └── presentation/      # NotificationPage, NotificationBloc, Notification Widgets
```

## 🛠️ Development Guidelines

### Code Quality Standards
- **Flutter Lints**: Strict linting with flutter_lints package
- **Clean Code**: Comprehensive documentation and clear naming
- **SOLID Principles**: Maintainable and scalable architecture
- **Test Coverage**: Unit, widget, and integration tests
- **Code Reviews**: Peer review process for quality assurance

### Performance Optimizations
- **Lazy Loading**: Efficient data loading for large container lists
- **Image Caching**: Optimized image handling and caching
- **State Management**: Efficient BLoC state management
- **Memory Management**: Proper disposal and resource cleanup
- **Network Optimization**: Dio interceptors and retry logic

### Security Implementation
- **Data Encryption**: Hive encryption for local storage
- **Firebase Security**: Firestore security rules
- **Authentication**: Secure token management
- **Permission Handling**: Runtime permission requests
- **Sensitive Data**: Secure storage for API keys and tokens

## 🤝 Contributing

We welcome contributions to Stack Logistics! Here's how you can help:

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the coding standards and architecture patterns
4. Write tests for your changes
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Contribution Guidelines
- Follow Clean Architecture principles
- Write comprehensive tests
- Update documentation for new features
- Follow the existing code style and naming conventions
- Ensure all tests pass before submitting PR

## 📊 Performance Metrics

### Application Performance
- **Startup Time**: < 3 seconds on modern devices
- **Memory Usage**: Optimized for low memory footprint
- **Battery Efficiency**: Minimal background processing
- **Network Usage**: Efficient data synchronization

### Platform Support
- **iOS**: 12.0+ (iPhone 6s and newer)
- **Android**: API Level 21+ (Android 5.0+)
- **Web**: Modern browsers (Chrome, Firefox, Safari, Edge)
- **Windows**: Windows 10+ (x64)
- **macOS**: macOS 10.14+ (Mojave and newer)
- **Linux**: Ubuntu 18.04+ and compatible distributions

## 🔧 Configuration

### Environment Setup
Create `.env` files for different environments:
```
# .env.development
FIREBASE_PROJECT_ID=your-dev-project
GOOGLE_MAPS_API_KEY=your-dev-maps-key
FCM_SERVER_KEY=your-dev-fcm-key

# .env.production
FIREBASE_PROJECT_ID=your-prod-project
GOOGLE_MAPS_API_KEY=your-prod-maps-key
FCM_SERVER_KEY=your-prod-fcm-key
```

### Firebase Configuration
1. **Authentication**: Enable Email/Password authentication
2. **Firestore**: Create collections for containers, users, notifications
3. **Cloud Messaging**: Set up FCM for push notifications
4. **Storage**: Configure for image and document uploads

### Google Maps Setup
1. Enable Maps SDK for Android, iOS, and JavaScript
2. Set up API restrictions for security
3. Configure billing (if required for production usage)

## 📈 Roadmap

### Upcoming Features
- [ ] **Multi-language Support**: Complete i18n implementation
- [ ] **Offline Sync**: Enhanced offline capabilities
- [ ] **Team Collaboration**: Role-based access and sharing
- [ ] **Advanced Analytics**: Container movement analytics
- [ ] **API Integration**: Third-party logistics APIs
- [ ] **Export Features**: CSV/PDF report generation
- [ ] **Widget Support**: Home screen widgets for quick access

### Version History
- **v1.0.0**: Initial release with core features
- **v1.1.0**: Added push notifications and map integration
- **v1.2.0**: Implemented barcode/QR scanning
- **v1.3.0**: Enhanced UI/UX and performance optimizations
- **v2.0.0**: Complete Clean Architecture refactor (current)

## 🆘 Support & Documentation

### Getting Help
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Join community discussions
- **Documentation**: Comprehensive docs in `/docs` folder
- **Email**: [support@stacklogistics.com](mailto:support@stacklogistics.com)

### Troubleshooting
Common issues and solutions:
1. **Build Issues**: Ensure Flutter and dependencies are up to date
2. **Firebase Connection**: Verify configuration files are properly placed
3. **Map Issues**: Check Google Maps API key and permissions
4. **Scanner Issues**: Verify camera permissions on device

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Third-Party Licenses
- Flutter: BSD 3-Clause License
- Firebase: Google Terms of Service
- Google Maps: Google Maps Platform Terms
- All Flutter packages: See individual package licenses

## 👥 Team

### Core Contributors
- **Lead Developer**: [Sazar Developer](https://github.com/sazardev)
- **Architecture**: Clean Architecture with BLoC pattern
- **Design**: Material Design 3 with custom theming
- **Testing**: Comprehensive test coverage

### Acknowledgments
- Flutter team for the amazing framework
- Firebase team for backend services
- Google Maps team for location services
- Open source community for valuable packages

---

## 🚀 Quick Start Guide

### For End Users
1. Download from App Store or Google Play
2. Create an account or sign in
3. Start adding your containers
4. Use the scanner to quickly identify containers
5. Track locations on the interactive map
6. Receive real-time notifications

### For Developers
1. Clone repository and install dependencies
2. Set up Firebase project and configuration
3. Configure Google Maps API
4. Run `flutter pub get` and `dart run build_runner build`
5. Run the app with `flutter run`
6. Start contributing to the project

---

**Stack Logistics** - Empowering efficient container management worldwide 🌍📦

[![Download on App Store](https://img.shields.io/badge/Download%20on-App%20Store-000000?style=for-the-badge&logo=apple&logoColor=white)](https://apps.apple.com/app/stack-logistics)
[![Get it on Google Play](https://img.shields.io/badge/Get%20it%20on-Google%20Play-4285F4?style=for-the-badge&logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=com.stacklogistics.app)
[![Launch Web App](https://img.shields.io/badge/Launch-Web%20App-FF6F00?style=for-the-badge&logo=web&logoColor=white)](https://stacklogistics.web.app)
- **Multi-Platform Support**: Access your container information from both iOS and Android devices.
- **Multi-Language Support**: Available in multiple languages to cater to a diverse user base.
- **Free to Use**: Download and use the app for free, with optional premium features for advanced users.
- **Desktop Version**: Available for Windows and MacOS for users who prefer managing logistics from their computers.
- **Data Export**: Export your container data in various formats for reporting and analysis.
- **Collaboration Tools**: Share container information with team members and collaborate on logistics management.
- **Offline Access**: Access your container information even when you're not connected to the internet.
- **Secure Data Storage**: Your data is securely stored and protected with encryption.
- **Customizable Settings**: Tailor the app to your specific needs with customizable settings and preferences.
- **Integration with Other Systems**: Seamlessly integrate with other logistics and inventory management systems.
- **Analytics and Reporting**: Generate reports and analyze your container data to make informed decisions.
- **Barcode Scanning**: Quickly add and manage containers using barcode scanning technology.
- **Support and Updates**: Regular updates and dedicated support to ensure the app meets your needs.
- **Cloud Sync**: Sync your data across multiple devices using cloud storage solutions.
- **User Roles and Permissions**: Assign different roles and permissions to team members for better access control.
- **Custom Alerts**: Set up custom alerts for specific container events or conditions.
- **Map Integration**: Visualize container locations on an interactive map for better tracking.
- **Task Management**: Create and assign tasks related to container handling and logistics.
- **Photo Attachments**: Attach photos to container records for better documentation.
- **QR Code Support**: Generate and scan QR codes for quick access to container information.
- **Multi-Currency Support**: Manage container costs and expenses in different currencies.

---

# Technologies Used

- **Flutter**: A UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
- **Dart**: The programming language used to develop Flutter applications.
- **Firebase**: A platform developed by Google for creating mobile and web applications, used for backend services like authentication, database, and cloud storage.
- **GitHub**: A web-based platform for version control and collaboration, allowing multiple developers to work on the project simultaneously.
- **BLoC (Business Logic Component)**: A state management library for Flutter that helps separate business logic from UI.
- **Shared Preferences**: A Flutter plugin for storing simple data in key-value pairs on the device.
- **GetIt**: A service locator for Dart and Flutter, used for dependency injection.
- **Hive**: A lightweight and fast key-value database written in pure Dart, used for local data storage.
- **Equatable**: A Dart package that helps to implement value equality for classes.
- **Clean Architecture**: A software design pattern that separates the application into layers, promoting maintainability and testability.
- **SOLID Principles**: A set of design principles for writing maintainable and scalable code.

The project is based on Clean Architecture and follows SOLID principles to ensure a well-structured and maintainable codebase. Every feature is implemented as a separate module, making it easy to manage and scale the application. This modular approach allows for better organization of the code and facilitates collaboration among developers. Also has dependency injection using GetIt to manage dependencies efficiently, making the code more testable and flexible.
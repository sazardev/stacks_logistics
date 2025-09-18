# Copilot Instructions for Stack Logistics

## Project Overview
Stack Logistics is a multi-platform Flutter application for shipping container logistics management. This project follows **Clean Architecture** principles and **SOLID design patterns** with modular feature organization.

## Local vs Remote Development

Every feature needs to work both locally and remotely. Use Hive for local storage and Firebase for remote data. Implement synchronization logic to keep data consistent across local and remote sources, ensuring offline-first functionality. this is not a offline functions, this is because bussiness logic need to work in both ways, because if the user pay for premium features, the data need to be stored in Firebase, but if the user is using the free version, the data need to be stored in Hive, so the app need to work in both ways. Please focus on this, every feature need to work in both ways, focus on local and remote development and synchronization logic. need to be implemented in every feature.

## Architecture & Patterns

### Clean Architecture Structure
- **Features as modules**: Each feature should be implemented as a separate module in `lib/features/`
- **Layer separation**: Domain, Data, and Presentation layers for each feature
- **Dependency injection**: Use GetIt service locator for dependency management
- **State management**: BLoC pattern with flutter_bloc for all business logic
- **Error handling**: Use `dartz` Either type for functional error handling in the domain layer
- **Local storage**: Use Hive for local data persistence, Shared Preferences for simple key-value storage.
- **Networking**: Use Dio for REST API communication with Firebase backend, including error handling and retries.

Every feature should have its own directory structure under `lib/features/feature_name/` with subdirectories for `data`, `domain`, and `presentation`, following this pattern:

```lib/features/feature_name/
├── data/
│   ├── models/
│   ├── repositories/
│   └── data_sources/
├── domain/
│   ├── entities/
│   ├── use_cases/
│   └── repository_interfaces/
└── presentation/
    ├── pages/
    ├── widgets/
    └── blocs/
```

- Every feature module should be self-contained, with clear interfaces for interaction with other modules. 
- Shared utilities, constants, and themes should be placed in `lib/core/`.
- Every feature needs to be registered in the main app module with proper routing and dependency injection setup.
- Use `Equatable` for value equality in entities and state classes.
- Follow SOLID principles strictly to ensure maintainability and scalability.
- Use `flutter_lints` for linting with minimal custom rules.
- Ensure all code is well-documented with comments and follows clean code practices.
- Write unit tests for business logic and widget tests for UI components.

### Expected Directory Structure
```
lib/
├── core/                     # Shared utilities, constants, themes
├── features/                 # Feature modules
│   ├── container_tracking/   # Example feature module
│   │   ├── data/            # Data sources, repositories, models
│   │   ├── domain/          # Entities, use cases, repository interfaces
│   │   └── presentation/    # Pages, widgets, BLoCs
│   └── inventory_management/
├── shared/                   # Shared widgets, services
└── main.dart
```

### Key Dependencies & Usage Patterns
- **flutter_bloc**: Use Cubit for simple state, BLoC for complex event handling
- **dartz**: Use `Either<Failure, Success>` for error handling in domain layer
- **dio**: HTTP client for REST API communication with Firebase backend
- **shared_preferences**: Local key-value storage for user preferences
- **google_fonts**: Consistent typography across the app

## Development Conventions

### State Management
```dart
// Use BlocProvider.of<FeatureCubit>(context) pattern
// Wrap screens with BlocProvider for dependency injection
class ContainerTrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ContainerTrackingCubit>(),
      child: BlocBuilder<ContainerTrackingCubit, ContainerTrackingState>(
        builder: (context, state) {
          // UI implementation
        },
      ),
    );
  }
}
```

### Error Handling
- Use `dartz` Either type for domain layer error handling
- Create custom `Failure` classes for different error types
- Handle network errors gracefully with user-friendly messages

### Multi-Platform Considerations
- Target iOS, Android, Web, Windows, and macOS
- Use responsive design patterns for desktop vs mobile layouts
- Platform-specific code should be minimal and abstracted

## Key Features to Implement
1. **Container Tracking**: Real-time location and status updates
2. **Inventory Management**: CRUD operations for container data
3. **Notifications**: Push notifications for container events
4. **Offline Support**: Local data caching with sync capabilities
5. **Barcode/QR Scanning**: Quick container identification
6. **Map Integration**: Visual container location tracking
7. **Multi-language Support**: i18n for English, Spanish, French
8. **User Authentication**: Firebase Auth integration
9. **Data Export**: CSV/PDF report generation
10. **Team Collaboration**: Role-based access control

## Development Workflow
- **Testing**: Write unit tests for business logic, widget tests for UI
- **Linting**: Follow `flutter_lints` rules with minimal customization
- **Build**: Support all platforms with platform-specific configurations
- **Deployment**: Target both app stores and web deployment

## Firebase Integration
- **Authentication**: User management and role-based access
- **Firestore**: Real-time container data synchronization
- **Cloud Functions**: Backend business logic for complex operations
- **Storage**: Photo attachments and document storage

## Performance Guidelines
- Use `const` constructors for static widgets
- Implement lazy loading for large container lists
- Cache network images and data appropriately
- Use `RepaintBoundary` for complex animations

When implementing new features, always start with the domain layer (entities, use cases), then data layer (repositories, data sources), and finally presentation layer (BLoCs, pages, widgets).

---

# Design Guidelines

The design of Stack Logistics should focus on usability and clarity, ensuring that users can easily navigate and manage their shipping containers. Here are some key design principles to follow:

- Follow Material Design principles for UI/UX
- Maintain consistent theming and color schemes
- Use responsive layouts for different screen sizes
- Ensure accessibility compliance (contrast ratios, font sizes)
- Use animations and transitions to enhance user experience
- Prioritize usability and intuitive navigation
- Regularly update dependencies and ensure compatibility across platforms
- Document code with comments and maintain clean code practices
- Conduct code reviews and pair programming for quality assurance

## Palettes

- Primary Color: #42A5F5 (Blue)
- Secondary Color: #FF6F00 (Orange)
- Accent Color: #FFCA28 (Yellow)
- Background Color: #F5F5F5 (Light Grey)
- Text Color: #212121 (Dark Grey)
- Error Color: #D32F2F (Red)
- Success Color: #388E3C (Green)
- Warning Color: #FBC02D (Amber)
- Info Color: #1976D2 (Blue)
- Disabled Color: #BDBDBD (Grey)
- Divider Color: #E0E0E0 (Light Grey)
- Shadow Color: #000000 (Black with 10% opacity)
- Surface Color: #FFFFFF (White)
- Card Color: #FFFFFF (White)
- Button Color: #42A5F5 (Blue)
- Link Color: #1E88E5 (Blue)
- Highlight Color: #E3F2FD (Light Blue)
- Hover Color: #BBDEFB (Light Blue)
- Focus Color: #90CAF9 (Light Blue)
- Splash Color: #64B5F6 (Light Blue)
- Selected Color: #1976D2 (Blue)
- Unselected Color: #BDBDBD (Grey)
- Text Primary Color: #212121 (Dark Grey)
- Text Secondary Color: #757575 (Grey)
- Text Disabled Color: #BDBDBD (Grey)
- Icon Color: #616161 (Grey)
- Icon Disabled Color: #BDBDBD (Grey)
- Tooltip Color: #616161 (Grey)
- AppBar Color: #42A5F5 (Blue)
- Navigation Bar Color: #FFFFFF (White)
- Tab Bar Color: #FFFFFF (White)
- Dialog Background Color: #FFFFFF (White)
- Snackbar Background Color: #323232 (Dark Grey)
- Progress Indicator Color: #42A5F5 (Blue)

## Design System

- Use a consistent typography system with Google Fonts, use Pairing Fonts like DM Sans for headings and Roboto for body text.
- Maintain a consistent spacing system with 4dp increments (4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64).
- Use a consistent iconography system with Material Icons.
- Maintain a consistent button style with rounded corners and shadow effects.
- Use a consistent card style with rounded corners and shadow effects.
- Use a consistent input field style with rounded corners and shadow effects.
- Use a consistent dialog style with rounded corners and shadow effects.
- Use a consistent snackbar style with rounded corners and shadow effects.
- NO gradients, NO background images, NO complex patterns.
- Use simple, flat design elements for a modern look, avoiding skeuomorphism, 3D effects, and excessive textures.
- NO 3D effects, NO skeuomorphism, NO excessive textures.
- Simplicity and clarity in design, avoiding clutter and unnecessary elements.
- Layout consistency across screens, using grids and alignment for a clean look.
- Use whitespace effectively to separate elements and improve readability.
- Ensure all interactive elements have clear affordances, such as buttons and links.
- Use animations and transitions sparingly to enhance user experience without overwhelming the user.
- Ensure accessibility compliance, including color contrast ratios, font sizes, and screen reader support.
- Regularly update dependencies and ensure compatibility across platforms.
- Document design decisions and maintain a design system for consistency.
- Conduct user testing and gather feedback to improve the design and usability of the app.
- Layouts need to be responsive and adapt to different screen sizes and orientations as well as platform conventions (iOS, Android, Web, Desktop).
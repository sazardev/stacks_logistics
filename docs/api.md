# API Documentation - Stack Logistics

This document provides comprehensive API documentation for Stack Logistics application, including all business logic, data models, and integration points.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Domain Layer](#domain-layer)
3. [Data Layer](#data-layer)
4. [Presentation Layer](#presentation-layer)
5. [External APIs](#external-apis)
6. [Error Handling](#error-handling)
7. [Testing](#testing)

## Architecture Overview

Stack Logistics follows Clean Architecture principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│             Presentation Layer          │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │  Pages  │ │ Widgets │ │  BLoCs  │   │
│  └─────────┘ └─────────┘ └─────────┘   │
└─────────────────────────────────────────┘
                    │
┌─────────────────────────────────────────┐
│               Domain Layer              │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │Entities │ │Use Cases│ │Repository│   │
│  │         │ │         │ │Interface │   │
│  └─────────┘ └─────────┘ └─────────┘   │
└─────────────────────────────────────────┘
                    │
┌─────────────────────────────────────────┐
│                Data Layer               │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │ Models  │ │Repository│ │Data     │   │
│  │         │ │Impl      │ │Sources  │   │
│  └─────────┘ └─────────┘ └─────────┘   │
└─────────────────────────────────────────┘
```

## Domain Layer

### Entities

#### Container Entity
```dart
class Container extends Equatable {
  final String id;
  final String name;
  final String? contents;
  final double? weight;
  final String? origin;
  final String? destination;
  final ContainerStatus status;
  final ContainerPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;

  const Container({
    required this.id,
    required this.name,
    this.contents,
    this.weight,
    this.origin,
    this.destination,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
  });
}

enum ContainerStatus {
  loading,
  inTransit,
  delivered,
  delayed,
  damaged,
  lost,
}

enum ContainerPriority {
  low,
  medium,
  high,
  critical,
}
```

#### User Entity
```dart
class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    required this.createdAt,
  });
}
```

#### Notification Entity
```dart
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? containerId;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.containerId,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });
}

enum NotificationType {
  containerUpdate,
  statusChange,
  priority,
  system,
}
```

#### Map Marker Entity
```dart
class MapMarker extends Equatable {
  final String id;
  final String containerId;
  final double latitude;
  final double longitude;
  final String title;
  final String? description;
  final DateTime timestamp;

  const MapMarker({
    required this.id,
    required this.containerId,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.description,
    required this.timestamp,
  });
}
```

#### Barcode Scan Result Entity
```dart
class BarcodeScanResult extends Equatable {
  final String id;
  final String code;
  final BarcodeType type;
  final DateTime timestamp;

  const BarcodeScanResult({
    required this.id,
    required this.code,
    required this.type,
    required this.timestamp,
  });
}

enum BarcodeType {
  qr,
  code128,
  code39,
  ean13,
  ean8,
  other,
}
```

### Use Cases

#### Container Use Cases

**GetContainersUseCase**
```dart
class GetContainersUseCase {
  final ContainerRepository repository;

  GetContainersUseCase(this.repository);

  Future<Either<Failure, List<Container>>> call() async {
    return await repository.getContainers();
  }
}
```

**AddContainerUseCase**
```dart
class AddContainerUseCase {
  final ContainerRepository repository;

  AddContainerUseCase(this.repository);

  Future<Either<Failure, void>> call(Container container) async {
    return await repository.addContainer(container);
  }
}
```

**UpdateContainerUseCase**
```dart
class UpdateContainerUseCase {
  final ContainerRepository repository;

  UpdateContainerUseCase(this.repository);

  Future<Either<Failure, void>> call(Container container) async {
    return await repository.updateContainer(container);
  }
}
```

**DeleteContainerUseCase**
```dart
class DeleteContainerUseCase {
  final ContainerRepository repository;

  DeleteContainerUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteContainer(id);
  }
}
```

**SearchContainersUseCase**
```dart
class SearchContainersUseCase {
  final ContainerRepository repository;

  SearchContainersUseCase(this.repository);

  Future<Either<Failure, List<Container>>> call(String query) async {
    return await repository.searchContainers(query);
  }
}
```

#### Authentication Use Cases

**LoginUseCase**
```dart
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
```

**RegisterUseCase**
```dart
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call(String email, String password) async {
    return await repository.register(email, password);
  }
}
```

**LogoutUseCase**
```dart
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
```

#### Map Use Cases

**GetMapMarkersUseCase**
```dart
class GetMapMarkersUseCase {
  final MapRepository repository;

  GetMapMarkersUseCase(this.repository);

  Future<Either<Failure, List<MapMarker>>> call() async {
    return await repository.getMarkers();
  }
}
```

#### Notification Use Cases

**GetNotificationsUseCase**
```dart
class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<AppNotification>>> call() async {
    return await repository.getNotifications();
  }
}
```

**MarkNotificationAsReadUseCase**
```dart
class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.markAsRead(id);
  }
}
```

#### Barcode Scanner Use Cases

**CheckCameraPermissionUseCase**
```dart
class CheckCameraPermissionUseCase {
  final BarcodeScannerRepository repository;

  CheckCameraPermissionUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.checkCameraPermission();
  }
}
```

**StartScanningUseCase**
```dart
class StartScanningUseCase {
  final BarcodeScannerRepository repository;

  StartScanningUseCase(this.repository);

  Stream<Either<Failure, BarcodeScanResult>> call() {
    return repository.scanBarcodes();
  }
}
```

### Repository Interfaces

#### ContainerRepository
```dart
abstract class ContainerRepository {
  Future<Either<Failure, List<Container>>> getContainers();
  Future<Either<Failure, Container>> getContainerById(String id);
  Future<Either<Failure, void>> addContainer(Container container);
  Future<Either<Failure, void>> updateContainer(Container container);
  Future<Either<Failure, void>> deleteContainer(String id);
  Future<Either<Failure, List<Container>>> searchContainers(String query);
}
```

#### AuthRepository
```dart
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
  Stream<User?> get authStateChanges;
}
```

#### MapRepository
```dart
abstract class MapRepository {
  Future<Either<Failure, List<MapMarker>>> getMarkers();
  Future<Either<Failure, void>> addMarker(MapMarker marker);
  Future<Either<Failure, void>> updateMarker(MapMarker marker);
  Future<Either<Failure, void>> deleteMarker(String id);
}
```

#### NotificationRepository
```dart
abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();
  Future<Either<Failure, void>> addNotification(AppNotification notification);
  Future<Either<Failure, void>> markAsRead(String id);
  Future<Either<Failure, void>> deleteNotification(String id);
}
```

#### BarcodeScannerRepository
```dart
abstract class BarcodeScannerRepository {
  Future<Either<Failure, bool>> checkCameraPermission();
  Future<Either<Failure, bool>> requestCameraPermission();
  Stream<Either<Failure, BarcodeScanResult>> scanBarcodes();
  Future<Either<Failure, void>> stopScanning();
  Future<Either<Failure, List<BarcodeScanResult>>> getScanHistory();
}
```

## Data Layer

### Models

#### ContainerModel
```dart
@HiveType(typeId: 0)
class ContainerModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? contents;
  
  @HiveField(3)
  final double? weight;
  
  @HiveField(4)
  final String? origin;
  
  @HiveField(5)
  final String? destination;
  
  @HiveField(6)
  final ContainerStatus status;
  
  @HiveField(7)
  final ContainerPriority priority;
  
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final DateTime updatedAt;
  
  @HiveField(10)
  final double? latitude;
  
  @HiveField(11)
  final double? longitude;

  ContainerModel({
    required this.id,
    required this.name,
    this.contents,
    this.weight,
    this.origin,
    this.destination,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
  });

  factory ContainerModel.fromEntity(Container container) {
    return ContainerModel(
      id: container.id,
      name: container.name,
      contents: container.contents,
      weight: container.weight,
      origin: container.origin,
      destination: container.destination,
      status: container.status,
      priority: container.priority,
      createdAt: container.createdAt,
      updatedAt: container.updatedAt,
      latitude: container.latitude,
      longitude: container.longitude,
    );
  }

  Container toEntity() {
    return Container(
      id: id,
      name: name,
      contents: contents,
      weight: weight,
      origin: origin,
      destination: destination,
      status: status,
      priority: priority,
      createdAt: createdAt,
      updatedAt: updatedAt,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contents': contents,
      'weight': weight,
      'origin': origin,
      'destination': destination,
      'status': status.index,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ContainerModel.fromJson(Map<String, dynamic> json) {
    return ContainerModel(
      id: json['id'],
      name: json['name'],
      contents: json['contents'],
      weight: json['weight']?.toDouble(),
      origin: json['origin'],
      destination: json['destination'],
      status: ContainerStatus.values[json['status']],
      priority: ContainerPriority.values[json['priority']],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}
```

### Data Sources

#### ContainerLocalDataSource
```dart
class ContainerLocalDataSource {
  static const String _boxName = 'containers';
  late Box<ContainerModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ContainerModel>(_boxName);
  }

  Future<List<ContainerModel>> getContainers() async {
    return _box.values.toList();
  }

  Future<ContainerModel?> getContainerById(String id) async {
    return _box.get(id);
  }

  Future<void> addContainer(ContainerModel container) async {
    await _box.put(container.id, container);
  }

  Future<void> updateContainer(ContainerModel container) async {
    await _box.put(container.id, container);
  }

  Future<void> deleteContainer(String id) async {
    await _box.delete(id);
  }

  Future<List<ContainerModel>> searchContainers(String query) async {
    final containers = _box.values.toList();
    return containers.where((container) {
      return container.name.toLowerCase().contains(query.toLowerCase()) ||
             (container.contents?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (container.origin?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (container.destination?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
}
```

#### ContainerRemoteDataSource
```dart
class ContainerRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _collection = 'containers';

  ContainerRemoteDataSource(this._firestore, this._auth);

  Future<List<ContainerModel>> getContainers() async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('User not authenticated');

    final querySnapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ContainerModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<ContainerModel?> getContainerById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    
    return ContainerModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> addContainer(ContainerModel container) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('User not authenticated');

    final data = container.toJson()..['userId'] = user.uid;
    await _firestore.collection(_collection).doc(container.id).set(data);
  }

  Future<void> updateContainer(ContainerModel container) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('User not authenticated');

    final data = container.toJson()..['userId'] = user.uid;
    await _firestore.collection(_collection).doc(container.id).update(data);
  }

  Future<void> deleteContainer(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
```

## Presentation Layer

### BLoC State Management

#### ContainerBloc
```dart
class ContainerBloc extends Bloc<ContainerEvent, ContainerState> {
  final GetContainersUseCase _getContainers;
  final AddContainerUseCase _addContainer;
  final UpdateContainerUseCase _updateContainer;
  final DeleteContainerUseCase _deleteContainer;
  final SearchContainersUseCase _searchContainers;

  ContainerBloc({
    required GetContainersUseCase getContainers,
    required AddContainerUseCase addContainer,
    required UpdateContainerUseCase updateContainer,
    required DeleteContainerUseCase deleteContainer,
    required SearchContainersUseCase searchContainers,
  })  : _getContainers = getContainers,
        _addContainer = addContainer,
        _updateContainer = updateContainer,
        _deleteContainer = deleteContainer,
        _searchContainers = searchContainers,
        super(ContainerInitial()) {
    on<LoadContainers>(_onLoadContainers);
    on<AddContainer>(_onAddContainer);
    on<UpdateContainer>(_onUpdateContainer);
    on<DeleteContainer>(_onDeleteContainer);
    on<SearchContainers>(_onSearchContainers);
  }

  Future<void> _onLoadContainers(
    LoadContainers event,
    Emitter<ContainerState> emit,
  ) async {
    emit(ContainerLoading());
    
    final result = await _getContainers();
    result.fold(
      (failure) => emit(ContainerError(failure.message)),
      (containers) => emit(ContainerLoaded(containers)),
    );
  }

  Future<void> _onAddContainer(
    AddContainer event,
    Emitter<ContainerState> emit,
  ) async {
    final result = await _addContainer(event.container);
    result.fold(
      (failure) => emit(ContainerError(failure.message)),
      (_) => add(LoadContainers()),
    );
  }

  Future<void> _onUpdateContainer(
    UpdateContainer event,
    Emitter<ContainerState> emit,
  ) async {
    final result = await _updateContainer(event.container);
    result.fold(
      (failure) => emit(ContainerError(failure.message)),
      (_) => add(LoadContainers()),
    );
  }

  Future<void> _onDeleteContainer(
    DeleteContainer event,
    Emitter<ContainerState> emit,
  ) async {
    final result = await _deleteContainer(event.id);
    result.fold(
      (failure) => emit(ContainerError(failure.message)),
      (_) => add(LoadContainers()),
    );
  }

  Future<void> _onSearchContainers(
    SearchContainers event,
    Emitter<ContainerState> emit,
  ) async {
    emit(ContainerLoading());
    
    final result = await _searchContainers(event.query);
    result.fold(
      (failure) => emit(ContainerError(failure.message)),
      (containers) => emit(ContainerLoaded(containers)),
    );
  }
}
```

## External APIs

### Firebase Services

#### Authentication
- **Endpoint**: Firebase Auth REST API
- **Methods**: 
  - `signInWithEmailAndPassword`
  - `createUserWithEmailAndPassword`
  - `signOut`
  - `sendPasswordResetEmail`

#### Firestore Database
- **Collections**:
  - `containers`: User container data
  - `notifications`: User notifications
  - `map_markers`: Container location markers
- **Security Rules**: User-based access control

#### Cloud Messaging
- **Service**: Firebase Cloud Messaging (FCM)
- **Token Management**: Automatic token refresh
- **Notification Types**: Data and notification messages

### Google Maps API
- **Services**:
  - Maps JavaScript API (Web)
  - Maps SDK for Android
  - Maps SDK for iOS
- **Features**:
  - Map display and interaction
  - Marker placement and clustering
  - Geolocation services

### Mobile Scanner API
- **Platform**: Native camera integration
- **Formats**: QR codes, barcodes (Code128, Code39, EAN13, etc.)
- **Permissions**: Camera access management

## Error Handling

### Failure Types
```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}
```

### Error Mapping
```dart
class ErrorHandler {
  static Failure handleError(Exception error) {
    if (error is FirebaseAuthException) {
      return AuthFailure(_getAuthErrorMessage(error.code));
    } else if (error is FirebaseException) {
      return ServerFailure(error.message ?? 'Server error occurred');
    } else if (error is DioException) {
      return NetworkFailure(_getDioErrorMessage(error));
    } else {
      return ServerFailure('An unexpected error occurred');
    }
  }

  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Email address is invalid';
      default:
        return 'Authentication failed';
    }
  }

  static String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Network connection error';
      default:
        return 'Network error occurred';
    }
  }
}
```

## Testing

### Test Structure
```
test/
├── unit/
│   ├── domain/
│   │   ├── entities/
│   │   ├── use_cases/
│   │   └── repositories/
│   └── data/
│       ├── models/
│       ├── repositories/
│       └── data_sources/
├── widget/
│   ├── pages/
│   ├── widgets/
│   └── blocs/
└── integration/
    ├── features/
    └── flows/
```

### Test Examples

#### Unit Test - Use Case
```dart
void main() {
  late GetContainersUseCase useCase;
  late MockContainerRepository mockRepository;

  setUp(() {
    mockRepository = MockContainerRepository();
    useCase = GetContainersUseCase(mockRepository);
  });

  group('GetContainersUseCase', () {
    test('should return list of containers when repository call is successful', () async {
      // arrange
      final containers = [
        Container(
          id: '1',
          name: 'Test Container',
          status: ContainerStatus.loading,
          priority: ContainerPriority.medium,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(mockRepository.getContainers()).thenAnswer((_) async => Right(containers));

      // act
      final result = await useCase();

      // assert
      expect(result, Right(containers));
      verify(mockRepository.getContainers());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository call fails', () async {
      // arrange
      when(mockRepository.getContainers()).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // act
      final result = await useCase();

      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockRepository.getContainers());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
```

#### Widget Test - BLoC
```dart
void main() {
  late ContainerBloc containerBloc;
  late MockGetContainersUseCase mockGetContainers;

  setUp(() {
    mockGetContainers = MockGetContainersUseCase();
    containerBloc = ContainerBloc(getContainers: mockGetContainers);
  });

  tearDown(() {
    containerBloc.close();
  });

  group('ContainerBloc', () {
    test('initial state should be ContainerInitial', () {
      expect(containerBloc.state, equals(ContainerInitial()));
    });

    blocTest<ContainerBloc, ContainerState>(
      'should emit [ContainerLoading, ContainerLoaded] when LoadContainers is successful',
      build: () {
        when(mockGetContainers()).thenAnswer((_) async => Right([]));
        return containerBloc;
      },
      act: (bloc) => bloc.add(LoadContainers()),
      expect: () => [
        ContainerLoading(),
        ContainerLoaded([]),
      ],
    );

    blocTest<ContainerBloc, ContainerState>(
      'should emit [ContainerLoading, ContainerError] when LoadContainers fails',
      build: () {
        when(mockGetContainers()).thenAnswer((_) async => Left(ServerFailure('Server error')));
        return containerBloc;
      },
      act: (bloc) => bloc.add(LoadContainers()),
      expect: () => [
        ContainerLoading(),
        ContainerError('Server error'),
      ],
    );
  });
}
```

### Integration Test
```dart
void main() {
  group('Container Management Flow', () {
    testWidgets('should complete full container CRUD flow', (tester) async {
      await tester.pumpWidget(MyApp());

      // Navigate to container list
      await tester.tap(find.byKey(Key('containers_tab')));
      await tester.pumpAndSettle();

      // Add new container
      await tester.tap(find.byKey(Key('add_container_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('container_name_field')), 'Test Container');
      await tester.enterText(find.byKey(Key('container_contents_field')), 'Test Contents');
      
      await tester.tap(find.byKey(Key('save_container_button')));
      await tester.pumpAndSettle();

      // Verify container appears in list
      expect(find.text('Test Container'), findsOneWidget);

      // Edit container
      await tester.tap(find.byKey(Key('container_item_0')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('edit_container_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('container_name_field')), 'Updated Container');
      await tester.tap(find.byKey(Key('save_container_button')));
      await tester.pumpAndSettle();

      // Verify update
      expect(find.text('Updated Container'), findsOneWidget);

      // Delete container
      await tester.longPress(find.byKey(Key('container_item_0')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('delete_container_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify deletion
      expect(find.text('Updated Container'), findsNothing);
    });
  });
}
```

---

## Additional Resources

- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern Documentation](https://bloclibrary.dev/)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Hive Database Documentation](https://docs.hivedb.dev/)

For more information, please refer to the inline code documentation and example implementations in the codebase.
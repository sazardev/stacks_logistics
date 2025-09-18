import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user in the domain layer
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.isPremiumUser = false,
    required this.createdAt,
    this.lastLoginAt,
    this.companyName,
    this.role = UserRole.user,
  });

  /// Unique identifier for the user
  final String id;

  /// User's email address
  final String email;

  /// User's display name
  final String name;

  /// User's profile photo URL
  final String? photoUrl;

  /// User's phone number
  final String? phoneNumber;

  /// Whether the user's email is verified
  final bool isEmailVerified;

  /// Whether the user has premium features
  final bool isPremiumUser;

  /// When the user account was created
  final DateTime createdAt;

  /// When the user last logged in
  final DateTime? lastLoginAt;

  /// User's company name
  final String? companyName;

  /// User's role in the system
  final UserRole role;

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    photoUrl,
    phoneNumber,
    isEmailVerified,
    isPremiumUser,
    createdAt,
    lastLoginAt,
    companyName,
    role,
  ];

  /// Creates a copy of this user with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    bool? isEmailVerified,
    bool? isPremiumUser,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? companyName,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      companyName: companyName ?? this.companyName,
      role: role ?? this.role,
    );
  }
}

/// User role enumeration
enum UserRole {
  /// Regular user
  user,

  /// Admin user with elevated permissions
  admin,

  /// Manager with team management permissions
  manager,

  /// Viewer with read-only access
  viewer,
}

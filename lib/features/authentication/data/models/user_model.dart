import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

/// Data model for User entity with Firebase integration
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.createdAt,
    super.photoUrl,
    super.phoneNumber,
    super.companyName,
    super.isEmailVerified,
    super.isPremiumUser,
    super.lastLoginAt,
    super.role,
  });

  /// Creates a UserModel from a Firebase User
  factory UserModel.fromFirebaseUser(
    firebase_auth.User firebaseUser, {
    required String name,
    UserRole role = UserRole.user,
    String? companyName,
  }) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: name,
      role: role,
      photoUrl: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      companyName: companyName,
      isEmailVerified: firebaseUser.emailVerified,
      lastLoginAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Creates a UserModel from Firestore document data
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: _parseUserRole(data['role']),
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      companyName: data['companyName'],
      isEmailVerified: data['isEmailVerified'] ?? false,
      isPremiumUser: data['isPremiumUser'] ?? false,
      lastLoginAt: _parseTimestamp(data['lastLoginAt']),
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }

  /// Converts UserModel to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'companyName': companyName,
      'isEmailVerified': isEmailVerified,
      'isPremiumUser': isPremiumUser,
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a copy of UserModel with updated fields
  @override
  UserModel copyWith({
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
    return UserModel(
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

  /// Parses UserRole from string
  static UserRole _parseUserRole(dynamic roleData) {
    if (roleData is String) {
      switch (roleData.toLowerCase()) {
        case 'admin':
          return UserRole.admin;
        case 'manager':
          return UserRole.manager;
        case 'user':
          return UserRole.user;
        case 'viewer':
          return UserRole.viewer;
        default:
          return UserRole.user;
      }
    }
    return UserRole.user;
  }

  /// Parses Timestamp to DateTime
  static DateTime? _parseTimestamp(dynamic timestampData) {
    if (timestampData == null) return null;

    if (timestampData is Timestamp) {
      return timestampData.toDate();
    }

    if (timestampData is DateTime) {
      return timestampData;
    }

    if (timestampData is String) {
      return DateTime.tryParse(timestampData);
    }

    return null;
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    photoUrl,
    phoneNumber,
    companyName,
    isEmailVerified,
    isPremiumUser,
    lastLoginAt,
    createdAt,
  ];

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, role: $role, '
        'photoUrl: $photoUrl, phoneNumber: $phoneNumber, companyName: $companyName, '
        'isEmailVerified: $isEmailVerified, isPremiumUser: $isPremiumUser, lastLoginAt: $lastLoginAt, '
        'createdAt: $createdAt)';
  }
}

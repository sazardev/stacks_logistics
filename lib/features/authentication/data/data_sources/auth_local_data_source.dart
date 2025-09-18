import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

/// Local data source for authentication operations using Hive
abstract class AuthLocalDataSource {
  /// Cache user data locally
  Future<void> cacheUser(UserModel user);

  /// Get cached user data
  Future<UserModel?> getCachedUser();

  /// Clear cached user data
  Future<void> clearCachedUser();

  /// Check if user is cached
  Future<bool> isUserCached();
}

/// Implementation of AuthLocalDataSource using Hive
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({required this.hiveBox});

  final Box<Map<String, dynamic>> hiveBox;

  static const String _userKey = 'cached_user';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await hiveBox.put(_userKey, user.toFirestore());
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userData = hiveBox.get(_userKey);
      if (userData == null) return null;

      // We need to get the user ID from the cached data
      final userId = userData['id'] ?? userData['uid'] ?? '';
      if (userId.isEmpty) return null;

      return UserModel.fromFirestore(userData, userId);
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await hiveBox.delete(_userKey);
    } catch (e) {
      throw CacheException('Failed to clear cached user: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUserCached() async {
    try {
      return hiveBox.containsKey(_userKey);
    } catch (e) {
      throw CacheException(
        'Failed to check if user is cached: ${e.toString()}',
      );
    }
  }
}

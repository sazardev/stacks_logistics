import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/container_model.dart';
import '../../../../core/error/exceptions.dart';
import '../exceptions/container_exceptions.dart';

/// Remote data source for container operations using Firebase Firestore
abstract class ContainerRemoteDataSource {
  Future<List<ContainerModel>> getAllContainers();
  Future<ContainerModel> getContainerById(String id);
  Future<List<ContainerModel>> searchContainers(String query);
  Future<String> createContainer(ContainerModel container);
  Future<void> updateContainer(ContainerModel container);
  Future<void> deleteContainer(String id);
  Future<List<ContainerModel>> getContainersByStatus(String status);
  Future<List<ContainerModel>> getContainersByPriority(String priority);
  Future<List<ContainerModel>> getContainersByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Stream<ContainerModel> watchContainer(String id);
  Stream<List<ContainerModel>> watchAllContainers();
  Future<List<ContainerModel>> getRecentContainers({int limit = 10});
}

/// Implementation of ContainerRemoteDataSource using Firebase Firestore
class ContainerRemoteDataSourceImpl implements ContainerRemoteDataSource {
  ContainerRemoteDataSourceImpl({required this.firestore, required this.auth});

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  static const String _containersCollection = 'containers';

  /// Get the current user's containers collection reference
  CollectionReference<Map<String, dynamic>> get _userContainersCollection {
    final user = auth.currentUser;
    if (user == null) {
      throw const UserNotAuthenticatedException();
    }
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection(_containersCollection);
  }

  @override
  Future<List<ContainerModel>> getAllContainers() async {
    try {
      final snapshot = await _userContainersCollection.get();
      return snapshot.docs
          .map((doc) => ContainerModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch containers');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch containers: $e');
    }
  }

  @override
  Future<ContainerModel> getContainerById(String id) async {
    try {
      final doc = await _userContainersCollection.doc(id).get();
      if (!doc.exists) {
        throw const ContainerNotFoundException();
      }
      return ContainerModel.fromJson({...doc.data()!, 'id': doc.id});
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch container');
    } catch (e) {
      if (e is ContainerNotFoundException) rethrow;
      throw ServerException(message: 'Failed to fetch container: $e');
    }
  }

  @override
  Future<List<ContainerModel>> searchContainers(String query) async {
    try {
      // Firestore doesn't support full-text search, so we'll use compound queries
      // For better search functionality, consider using Algolia or similar

      // Search by container number (exact match for now)
      final containerNumberQuery = await _userContainersCollection
          .where('containerNumber', isGreaterThanOrEqualTo: query)
          .where('containerNumber', isLessThan: '${query}z')
          .get();

      // Search by contents
      final contentsQuery = await _userContainersCollection
          .where('contents', isGreaterThanOrEqualTo: query)
          .where('contents', isLessThan: '${query}z')
          .get();

      // Combine results and remove duplicates
      final Map<String, ContainerModel> resultsMap = {};

      for (final doc in [...containerNumberQuery.docs, ...contentsQuery.docs]) {
        resultsMap[doc.id] = ContainerModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }

      return resultsMap.values.toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to search containers',
      );
    } catch (e) {
      throw ServerException(message: 'Failed to search containers: $e');
    }
  }

  @override
  Future<String> createContainer(ContainerModel container) async {
    try {
      final doc = await _userContainersCollection.add(container.toJson());
      return doc.id;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to create container');
    } catch (e) {
      throw ServerException(message: 'Failed to create container: $e');
    }
  }

  @override
  Future<void> updateContainer(ContainerModel container) async {
    try {
      await _userContainersCollection
          .doc(container.id)
          .update(container.toJson());
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update container');
    } catch (e) {
      throw ServerException(message: 'Failed to update container: $e');
    }
  }

  @override
  Future<void> deleteContainer(String id) async {
    try {
      await _userContainersCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to delete container');
    } catch (e) {
      throw ServerException(message: 'Failed to delete container: $e');
    }
  }

  @override
  Future<List<ContainerModel>> getContainersByStatus(String status) async {
    try {
      final snapshot = await _userContainersCollection
          .where('status', isEqualTo: status)
          .get();

      return snapshot.docs
          .map((doc) => ContainerModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to fetch containers by status',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch containers by status: $e',
      );
    }
  }

  @override
  Future<List<ContainerModel>> getContainersByPriority(String priority) async {
    try {
      final snapshot = await _userContainersCollection
          .where('priority', isEqualTo: priority)
          .get();

      return snapshot.docs
          .map((doc) => ContainerModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to fetch containers by priority',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch containers by priority: $e',
      );
    }
  }

  @override
  Future<List<ContainerModel>> getContainersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _userContainersCollection
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ContainerModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to fetch containers by date range',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch containers by date range: $e',
      );
    }
  }

  @override
  Stream<ContainerModel> watchContainer(String id) {
    try {
      return _userContainersCollection.doc(id).snapshots().map((snapshot) {
        if (!snapshot.exists) {
          throw const ContainerNotFoundException();
        }
        return ContainerModel.fromJson({
          ...snapshot.data()!,
          'id': snapshot.id,
        });
      });
    } catch (e) {
      throw ServerException(message: 'Failed to watch container: $e');
    }
  }

  @override
  Stream<List<ContainerModel>> watchAllContainers() {
    try {
      return _userContainersCollection
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) =>
                      ContainerModel.fromJson({...doc.data(), 'id': doc.id}),
                )
                .toList(),
          );
    } catch (e) {
      throw ServerException(message: 'Failed to watch containers: $e');
    }
  }

  @override
  Future<List<ContainerModel>> getRecentContainers({int limit = 10}) async {
    try {
      final snapshot = await _userContainersCollection
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ContainerModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to fetch recent containers',
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch recent containers: $e');
    }
  }
}

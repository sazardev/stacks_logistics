import 'package:hive/hive.dart';
import '../models/container_model.dart';

/// Local data source for container operations using Hive
abstract class ContainerLocalDataSource {
  Future<List<ContainerModel>> getAllContainers();
  Future<ContainerModel?> getContainerById(String id);
  Future<List<ContainerModel>> searchContainers(String query);
  Future<void> cacheContainer(ContainerModel container);
  Future<void> cacheContainers(List<ContainerModel> containers);
  Future<void> deleteContainer(String id);
  Future<void> clearCache();
  Future<bool> isContainerCached(String id);
  Future<List<ContainerModel>> getContainersByStatus(String status);
  Future<List<ContainerModel>> getContainersByPriority(String priority);
  Future<DateTime?> getLastSyncTime();
  Future<void> setLastSyncTime(DateTime syncTime);
}

/// Implementation of ContainerLocalDataSource using Hive
class ContainerLocalDataSourceImpl implements ContainerLocalDataSource {
  ContainerLocalDataSourceImpl({
    required this.containerBox,
    required this.settingsBox,
  });

  final Box<ContainerModel> containerBox;
  final Box<dynamic> settingsBox;

  static const String _lastSyncKey = 'last_container_sync';

  @override
  Future<List<ContainerModel>> getAllContainers() async {
    try {
      return containerBox.values.toList();
    } catch (e) {
      throw Exception('Failed to retrieve containers from local storage: $e');
    }
  }

  @override
  Future<ContainerModel?> getContainerById(String id) async {
    try {
      return containerBox.get(id);
    } catch (e) {
      throw Exception('Failed to retrieve container from local storage: $e');
    }
  }

  @override
  Future<List<ContainerModel>> searchContainers(String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      return containerBox.values.where((container) {
        return container.containerNumber.toLowerCase().contains(
              lowercaseQuery,
            ) ||
            container.contents.toLowerCase().contains(lowercaseQuery) ||
            container.destination.name.toLowerCase().contains(lowercaseQuery) ||
            container.origin.name.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search containers in local storage: $e');
    }
  }

  @override
  Future<void> cacheContainer(ContainerModel container) async {
    try {
      await containerBox.put(container.id, container);
    } catch (e) {
      throw Exception('Failed to cache container: $e');
    }
  }

  @override
  Future<void> cacheContainers(List<ContainerModel> containers) async {
    try {
      final containerMap = {
        for (final container in containers) container.id: container,
      };
      await containerBox.putAll(containerMap);
    } catch (e) {
      throw Exception('Failed to cache containers: $e');
    }
  }

  @override
  Future<void> deleteContainer(String id) async {
    try {
      await containerBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete container from local storage: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await containerBox.clear();
    } catch (e) {
      throw Exception('Failed to clear container cache: $e');
    }
  }

  @override
  Future<bool> isContainerCached(String id) async {
    try {
      return containerBox.containsKey(id);
    } catch (e) {
      throw Exception('Failed to check if container is cached: $e');
    }
  }

  @override
  Future<List<ContainerModel>> getContainersByStatus(String status) async {
    try {
      return containerBox.values
          .where((container) => container.status == status)
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve containers by status: $e');
    }
  }

  @override
  Future<List<ContainerModel>> getContainersByPriority(String priority) async {
    try {
      return containerBox.values
          .where((container) => container.priority == priority)
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve containers by priority: $e');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final timestamp = settingsBox.get(_lastSyncKey) as int?;
      return timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      throw Exception('Failed to get last sync time: $e');
    }
  }

  @override
  Future<void> setLastSyncTime(DateTime syncTime) async {
    try {
      await settingsBox.put(_lastSyncKey, syncTime.millisecondsSinceEpoch);
    } catch (e) {
      throw Exception('Failed to set last sync time: $e');
    }
  }
}

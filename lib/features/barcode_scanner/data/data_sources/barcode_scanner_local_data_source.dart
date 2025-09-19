import 'package:hive/hive.dart';
import '../models/barcode_scan_result_model.dart';
import '../../../../core/error/exceptions.dart';

/// Local data source for barcode scanner operations using Hive
abstract class BarcodeScannerLocalDataSource {
  /// Save scan result to local storage
  Future<void> saveScanResult(BarcodeScanResultModel result);

  /// Get scan history from local storage
  Future<List<BarcodeScanResultModel>> getScanHistory();

  /// Clear scan history
  Future<void> clearScanHistory();

  /// Get scan result by ID
  Future<BarcodeScanResultModel?> getScanResultById(String id);

  /// Delete scan result by ID
  Future<void> deleteScanResult(String id);
}

/// Implementation of BarcodeScannerLocalDataSource using Hive
class BarcodeScannerLocalDataSourceImpl
    implements BarcodeScannerLocalDataSource {
  const BarcodeScannerLocalDataSourceImpl({required this.scanResultsBox});

  final Box<BarcodeScanResultModel> scanResultsBox;

  @override
  Future<void> saveScanResult(BarcodeScanResultModel result) async {
    try {
      // Use timestamp as key for uniqueness
      final key = result.timestamp.millisecondsSinceEpoch.toString();
      await scanResultsBox.put(key, result);
    } catch (e) {
      throw CacheException('Failed to save scan result: ${e.toString()}');
    }
  }

  @override
  Future<List<BarcodeScanResultModel>> getScanHistory() async {
    try {
      final results = scanResultsBox.values.toList();
      // Sort by timestamp descending (newest first)
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    } catch (e) {
      throw CacheException('Failed to get scan history: ${e.toString()}');
    }
  }

  @override
  Future<void> clearScanHistory() async {
    try {
      await scanResultsBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear scan history: ${e.toString()}');
    }
  }

  @override
  Future<BarcodeScanResultModel?> getScanResultById(String id) async {
    try {
      return scanResultsBox.get(id);
    } catch (e) {
      throw CacheException('Failed to get scan result: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteScanResult(String id) async {
    try {
      await scanResultsBox.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete scan result: ${e.toString()}');
    }
  }
}

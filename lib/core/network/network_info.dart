import 'package:connectivity_plus/connectivity_plus.dart';

/// Network information interface
abstract class NetworkInfo {
  /// Check if device is connected to the internet
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo using connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl({required this.connectivity});

  final Connectivity connectivity;

  @override
  Future<bool> get isConnected async {
    try {
      final result = await connectivity.checkConnectivity();

      // Check if connected to any network type except none
      return result != ConnectivityResult.none;
    } catch (e) {
      // If connectivity check fails, assume we're disconnected
      return false;
    }
  }
}

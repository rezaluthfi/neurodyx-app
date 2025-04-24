import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_snack_bar.dart';

class ConnectivityService {
  // Singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  // Check if there is an internet connection (Wi-Fi or mobile)
  Future<bool> checkInternetConnection(BuildContext context) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile);
      if (!isConnected && context.mounted) {
        CustomSnackBar.show(
          context,
          message:
              'No Wi-Fi or mobile data available. Please check your network.',
          type: SnackBarType.error,
        );
      }
      return isConnected;
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Error checking network: $e',
          type: SnackBarType.error,
        );
      }
      return false;
    }
  }

  // Stream to listen for connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}

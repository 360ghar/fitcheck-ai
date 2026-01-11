import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../exceptions/app_exceptions.dart';

/// Service for monitoring network connectivity
class NetworkService extends GetxService {
  static NetworkService get instance => Get.find<NetworkService>();

  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  final RxList<ConnectivityResult> connectionStatus = <ConnectivityResult>[].obs;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  /// Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    // Get initial status
    final status = await _connectivity.checkConnectivity();
    _updateConnectionStatus(status);

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> status) {
        _updateConnectionStatus(status);
      },
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> status) {
    connectionStatus.value = status;
    isConnected.value = status.isNotEmpty &&
                         !status.contains(ConnectivityResult.none);
  }

  /// Check if device is currently connected to internet
  bool get hasConnection => isConnected.value;

  /// Check if connection is via WiFi
  bool get isOnWifi => connectionStatus.contains(ConnectivityResult.wifi);

  /// Check if connection is via Mobile
  bool get isOnMobile => connectionStatus.contains(ConnectivityResult.mobile);

  /// Check if connection is via Ethernet
  bool get isOnEthernet => connectionStatus.contains(ConnectivityResult.ethernet);

  /// Get current connectivity result list
  List<ConnectivityResult> get currentStatus => connectionStatus;
}

/// Retry logic for API requests with exponential backoff
class RetryHelper {
  /// Execute a function with retry logic
  ///
  /// [operation] - The function to execute
  /// [maxAttempts] - Maximum number of retry attempts (default: 3)
  /// [baseDelay] - Base delay for exponential backoff (default: 1 second)
  /// [maxDelay] - Maximum delay between retries (default: 30 seconds)
  static Future<T> execute<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration baseDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    bool Function(Object error)? retryIf,
  }) async {
    int attempts = 0;
    Duration currentDelay = baseDelay;

    while (true) {
      attempts++;

      try {
        return await operation();
      } catch (e) {
        // Check if we should retry
        final shouldRetry =
            _shouldRetry(e, retryIf) && attempts < maxAttempts;

        if (!shouldRetry) {
          rethrow;
        }

        // Calculate exponential backoff delay
        currentDelay = _calculateBackoffDelay(attempts, baseDelay, maxDelay);

        // Wait before retrying
        await Future.delayed(currentDelay);
      }
    }
  }

  static bool _shouldRetry(Object error, bool Function(Object error)? retryIf) {
    if (retryIf != null) {
      return retryIf(error);
    }

    if (error is AppException) {
      return error is NetworkException ||
          error.errorCode == 'TIMEOUT' ||
          error.errorCode == 'NO_CONNECTION';
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return true;
        default:
          return false;
      }
    }

    return false;
  }

  static Duration _calculateBackoffDelay(
    int attempt,
    Duration baseDelay,
    Duration maxDelay,
  ) {
    // Exponential backoff: delay = baseDelay * (2 ^ (attempt - 1))
    final exponentialDelay = baseDelay * (1 << (attempt - 1));

    // Cap at max delay
    if (exponentialDelay > maxDelay) {
      return maxDelay;
    }

    return exponentialDelay;
  }
}

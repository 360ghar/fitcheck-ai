import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../exceptions/app_exceptions.dart';

/// Service for monitoring network connectivity
class NetworkService {
  NetworkService._() {
    _initConnectivity();
  }

  /// Created on first use; monitors connectivity for the app's lifetime.
  static final instance = NetworkService._();

  final Connectivity _connectivity = Connectivity();
  final isConnected = ValueNotifier<bool>(true);
  List<ConnectivityResult> connectionStatus = const [];
  // ignore: unused_field
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    // A platform failure here must not crash startup. Keep the optimistic
    // default (connected) and let requests report real failures.
    try {
      _updateConnectionStatus(await _connectivity.checkConnectivity());
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (Object _) {},
      );
    } catch (_) {}
  }

  void _updateConnectionStatus(List<ConnectivityResult> status) {
    connectionStatus = status;
    isConnected.value =
        status.isNotEmpty && !status.contains(ConnectivityResult.none);
  }

  /// Check if device is currently connected to internet
  bool get hasConnection => isConnected.value;

  /// Check if connection is via WiFi
  bool get isOnWifi => connectionStatus.contains(ConnectivityResult.wifi);

  /// Check if connection is via Mobile
  bool get isOnMobile => connectionStatus.contains(ConnectivityResult.mobile);

  /// Check if connection is via Ethernet
  bool get isOnEthernet =>
      connectionStatus.contains(ConnectivityResult.ethernet);

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
        final shouldRetry = _shouldRetry(e, retryIf) && attempts < maxAttempts;

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
      if (error.errorCode == 'TIMEOUT' || error.errorCode == 'NO_CONNECTION') {
        return true;
      }
      // handleDioException maps unlisted 4xx codes and cancelled requests to
      // NetworkException. A retry cannot fix either one.
      final status = error.statusCode;
      final isClientError = status != null && status >= 400 && status < 500;
      return error is NetworkException &&
          !isClientError &&
          error.errorCode != 'REQUEST_CANCELLED';
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

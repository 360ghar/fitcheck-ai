import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'network_service.dart';

/// Represents a queued operation to be executed when online
class QueuedOperation {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final int maxRetries;

  QueuedOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.maxRetries = 3,
  });

  bool get hasRetriesRemaining => retryCount < maxRetries;

  QueuedOperation copyWithRetry() {
    return QueuedOperation(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount + 1,
      maxRetries: maxRetries,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
        'maxRetries': maxRetries,
      };

  factory QueuedOperation.fromJson(Map<String, dynamic> json) {
    return QueuedOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      maxRetries: json['maxRetries'] as int? ?? 3,
    );
  }
}

/// Callback type for operation handlers
typedef OperationHandler = Future<bool> Function(QueuedOperation operation);

/// Offline queue service for managing operations when offline
/// Persists operations to disk and processes them when connectivity returns
class OfflineQueueService extends GetxService {
  static OfflineQueueService get instance => Get.find<OfflineQueueService>();

  // Queue storage
  final RxList<QueuedOperation> queue = <QueuedOperation>[].obs;
  final RxBool isProcessing = false.obs;

  // Operation handlers by type
  final Map<String, OperationHandler> _handlers = {};

  // File persistence
  File? _queueFile;
  StreamSubscription? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initQueue();
    _listenToConnectivity();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  Future<void> _initQueue() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _queueFile = File('${appDir.path}/offline_queue.json');

      if (await _queueFile!.exists()) {
        final content = await _queueFile!.readAsString();
        final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
        queue.value = jsonList
            .map((json) =>
                QueuedOperation.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading offline queue: $e');
      }
    }
  }

  void _listenToConnectivity() {
    // Listen for connectivity changes and process queue when online
    _connectivitySubscription =
        NetworkService.instance.isConnected.listen((isConnected) {
      if (isConnected && queue.isNotEmpty) {
        processQueue();
      }
    });
  }

  /// Register a handler for a specific operation type
  void registerHandler(String type, OperationHandler handler) {
    _handlers[type] = handler;
  }

  /// Unregister a handler
  void unregisterHandler(String type) {
    _handlers.remove(type);
  }

  /// Add an operation to the queue
  Future<void> enqueue({
    required String type,
    required Map<String, dynamic> payload,
    int maxRetries = 3,
  }) async {
    final operation = QueuedOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
      maxRetries: maxRetries,
    );

    queue.add(operation);
    await _persistQueue();

    // Try to process immediately if online
    if (NetworkService.instance.hasConnection) {
      processQueue();
    }
  }

  /// Process all queued operations
  Future<void> processQueue() async {
    if (isProcessing.value || queue.isEmpty) return;
    if (!NetworkService.instance.hasConnection) return;

    isProcessing.value = true;

    try {
      // Process in order (FIFO)
      while (queue.isNotEmpty && NetworkService.instance.hasConnection) {
        final operation = queue.first;

        final handler = _handlers[operation.type];
        if (handler == null) {
          if (kDebugMode) {
            debugPrint('No handler for operation type: ${operation.type}');
          }
          // Remove unhandled operations
          queue.removeAt(0);
          continue;
        }

        try {
          final success = await handler(operation);

          if (success) {
            queue.removeAt(0);
          } else if (operation.hasRetriesRemaining) {
            // Move to end of queue with incremented retry count
            queue.removeAt(0);
            queue.add(operation.copyWithRetry());
          } else {
            // Max retries exceeded, remove from queue
            queue.removeAt(0);
            if (kDebugMode) {
              debugPrint(
                  'Operation ${operation.id} failed after ${operation.maxRetries} retries');
            }
          }
        } catch (e) {
          if (operation.hasRetriesRemaining) {
            queue.removeAt(0);
            queue.add(operation.copyWithRetry());
          } else {
            queue.removeAt(0);
          }
          if (kDebugMode) {
            debugPrint('Error processing operation ${operation.id}: $e');
          }
        }
      }
    } finally {
      isProcessing.value = false;
      await _persistQueue();
    }
  }

  /// Remove a specific operation from the queue
  Future<void> remove(String operationId) async {
    queue.removeWhere((op) => op.id == operationId);
    await _persistQueue();
  }

  /// Clear all queued operations
  Future<void> clear() async {
    queue.clear();
    await _persistQueue();
  }

  /// Persist queue to disk
  Future<void> _persistQueue() async {
    if (_queueFile == null) return;

    try {
      final jsonList = queue.map((op) => op.toJson()).toList();
      await _queueFile!.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error persisting offline queue: $e');
      }
    }
  }

  /// Get count of pending operations
  int get pendingCount => queue.length;

  /// Check if there are pending operations
  bool get hasPending => queue.isNotEmpty;

  /// Get pending operations by type
  List<QueuedOperation> getByType(String type) {
    return queue.where((op) => op.type == type).toList();
  }
}

import 'dart:io';

import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/core/services/offline_queue_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// A test double for [NetworkService] that avoids the connectivity_plus plugin
/// (unavailable in a pure Dart test environment) and lets tests drive the
/// connection state directly.
class FakeNetworkService extends NetworkService {
  FakeNetworkService({bool connected = false}) {
    isConnected.value = connected;
  }

  set connected(bool value) => isConnected.value = value;

  @override
  // ignore: must_call_super
  void onInit() {
    // Intentionally skip the real connectivity subscription.
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('offline_queue_test');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      // Covers both the darwin (getApplicationDocumentsDirectory) and the
      // android/linux paths used by path_provider in tests.
      return tempDir.path;
    });

    // Fresh DI container per test. Register under the NetworkService type so
    // NetworkService.instance (Get.find<NetworkService>()) resolves the fake.
    Get.reset();
    Get.put<NetworkService>(FakeNetworkService());
  });

  tearDown(() async {
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<OfflineQueueService> buildService() async {
    final service = OfflineQueueService();
    service.onInit();
    // onInit fires _initQueue() without awaiting it; give it a tick so the
    // queue file handle is ready before tests enqueue/persist.
    await Future.delayed(const Duration(milliseconds: 50));
    return service;
  }

  group('OfflineQueueService enqueue', () {
    test('adds an operation to the queue', () async {
      final service = await buildService();

      await service.enqueue(type: 'toggle_favorite', payload: {'id': 'a'});

      expect(service.pendingCount, 1);
      expect(service.hasPending, isTrue);
      expect(service.queue.first.type, 'toggle_favorite');
      expect(service.queue.first.payload['id'], 'a');
    });

    test('generates unique IDs even for same-millisecond enqueues', () async {
      final service = await buildService();

      // Enqueue many items back-to-back; IDs must not collide.
      for (var i = 0; i < 20; i++) {
        await service.enqueue(type: 'op', payload: {'i': i});
      }

      final ids = service.queue.map((op) => op.id).toList();
      expect(ids.toSet().length, ids.length,
          reason: 'All operation IDs must be unique');
    });

    test('enforces max queue size by evicting oldest operations', () async {
      final service = await buildService();

      // Network is offline so processQueue is never triggered during enqueue.
      for (var i = 0; i < OfflineQueueService.maxQueueSize + 25; i++) {
        await service.enqueue(type: 'op', payload: {'i': i});
      }

      expect(service.pendingCount, OfflineQueueService.maxQueueSize);
      // The oldest 25 operations should have been evicted; the newest remain.
      expect(service.queue.last.payload['i'],
          OfflineQueueService.maxQueueSize + 24);
    });

    test('persists the queue to disk', () async {
      final service = await buildService();

      await service.enqueue(type: 'op', payload: {'x': 1});

      final queueFile = File('${tempDir.path}/offline_queue.json');
      expect(queueFile.existsSync(), isTrue);
      expect(queueFile.readAsStringSync(), contains('"op"'));
    });
  });

  group('OfflineQueueService processQueue', () {
    // Helper: add an operation directly to the queue (bypasses enqueue's
    // fire-and-forget processQueue call, avoiding a race with the explicit
    // processQueue() the tests await).
    void seedQueue(OfflineQueueService service, {String type = 'op', int maxRetries = 3, DateTime? createdAt}) {
      service.queue.add(QueuedOperation(
        id: 'seed-${service.queue.length}',
        type: type,
        payload: {},
        createdAt: createdAt ?? DateTime.now(),
        maxRetries: maxRetries,
      ));
    }

    test('removes an operation after a successful handler', () async {
      final net = Get.find<NetworkService>() as FakeNetworkService;
      net.connected = true; // Set before buildService so listener doesn't fire
      final service = await buildService();
      service.registerHandler('op', (operation) async => true);

      seedQueue(service);
      await service.processQueue();

      expect(service.pendingCount, 0);
    });

    test('retries a failed operation up to maxRetries then drops it', () async {
      final net = Get.find<NetworkService>() as FakeNetworkService;
      net.connected = true;
      final service = await buildService();

      var attempts = 0;
      service.registerHandler('op', (operation) async {
        attempts++;
        return false; // always fails
      });

      seedQueue(service, maxRetries: 2);
      await service.processQueue();

      // With maxRetries=2: initial attempt + 2 retries = 3 handler calls,
      // then the operation is dropped.
      expect(service.pendingCount, 0);
      expect(attempts, 3);
    });

    test('drops operations with no registered handler', () async {
      final net = Get.find<NetworkService>() as FakeNetworkService;
      net.connected = true;
      final service = await buildService();

      seedQueue(service, type: 'unhandled');
      await service.processQueue();

      expect(service.pendingCount, 0);
    });

    test('drops expired operations based on TTL', () async {
      final net = Get.find<NetworkService>() as FakeNetworkService;
      net.connected = true;
      final service = await buildService();
      var handled = false;
      service.registerHandler('op', (operation) async {
        handled = true;
        return true;
      });

      seedQueue(service,
          createdAt: DateTime.now().subtract(
            OfflineQueueService.operationTtl + const Duration(days: 1),
          ));
      await service.processQueue();

      expect(service.pendingCount, 0);
      expect(handled, isFalse,
          reason: 'Expired operations must not be handed to the handler');
    });

    test('does not process while offline', () async {
      // NetworkService defaults to offline (connected=false) in setUp.
      final service = await buildService();
      var handled = false;
      service.registerHandler('op', (operation) async {
        handled = true;
        return true;
      });

      seedQueue(service);
      await service.processQueue();

      expect(handled, isFalse);
      expect(service.pendingCount, 1);
    });
  });

  group('OfflineQueueService management', () {
    test('remove deletes a specific operation by id', () async {
      final service = await buildService();

      await service.enqueue(type: 'op', payload: {});
      final id = service.queue.first.id;

      await service.remove(id);

      expect(service.pendingCount, 0);
    });

    test('clear empties the entire queue', () async {
      final service = await buildService();

      await service.enqueue(type: 'op', payload: {'i': 1});
      await service.enqueue(type: 'op', payload: {'i': 2});
      expect(service.pendingCount, 2);

      await service.clear();

      expect(service.pendingCount, 0);
      expect(service.hasPending, isFalse);
    });

    test('getByType filters operations', () async {
      final service = await buildService();

      await service.enqueue(type: 'favorite', payload: {});
      await service.enqueue(type: 'delete', payload: {});
      await service.enqueue(type: 'favorite', payload: {});

      expect(service.getByType('favorite').length, 2);
      expect(service.getByType('delete').length, 1);
    });
  });

  group('QueuedOperation', () {
    test('hasRetriesRemaining reflects retryCount vs maxRetries', () {
      final op = QueuedOperation(
        id: '1',
        type: 'op',
        payload: {},
        createdAt: DateTime.now(),
        retryCount: 0,
        maxRetries: 2,
      );

      expect(op.hasRetriesRemaining, isTrue);
      expect(op.copyWithRetry().retryCount, 1);
      expect(op.copyWithRetry().copyWithRetry().hasRetriesRemaining, isFalse);
    });

    test('round-trips through JSON serialization', () {
      final op = QueuedOperation(
        id: 'abc',
        type: 'toggle',
        payload: {'id': 'item-1'},
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        retryCount: 1,
        maxRetries: 5,
      );

      final restored = QueuedOperation.fromJson(op.toJson());

      expect(restored.id, op.id);
      expect(restored.type, op.type);
      expect(restored.payload, op.payload);
      expect(restored.retryCount, op.retryCount);
      expect(restored.maxRetries, op.maxRetries);
      expect(restored.createdAt, op.createdAt);
    });
  });
}

import 'dart:async';
import 'dart:io';

import 'package:fitcheck_ai/core/utils/error_handler.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/batch_extraction_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/batch_extraction_models.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/batch_extraction_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Condition;
import 'package:sentry_flutter/sentry_flutter.dart';

/// A fake [BatchExtractionRepository] whose status endpoint is driven by a
/// callback, so tests can simulate a permanently unreachable backend without
/// any network involvement.
class FakeBatchExtractionRepository extends BatchExtractionRepository {
  int getJobStatusCalls = 0;
  Future<BatchJobStatusResponse> Function(String jobId)? onGetJobStatus;
  Stream<SSEEvent> Function(String jobId)? onSubscribeToEvents;

  @override
  Future<BatchJobStatusResponse> getJobStatus(String jobId) {
    getJobStatusCalls++;
    final handler = onGetJobStatus;
    if (handler != null) return handler(jobId);
    return Future.value(
      BatchJobStatusResponse(
        jobId: jobId,
        status: 'extracting',
        totalImages: 1,
      ),
    );
  }

  @override
  Stream<SSEEvent> subscribeToEvents(String jobId) {
    final handler = onSubscribeToEvents;
    return handler?.call(jobId) ?? const Stream<SSEEvent>.empty();
  }
}

/// A fake [ItemRepository] whose image-upload methods record their inputs so
/// tests can assert the save-time upload strategy without any network.
class FakeItemRepository extends ItemRepository {
  final List<String> base64Uploads = [];
  final List<String> urlUploads = [];
  final List<List<String>> fileUploads = [];
  final List<String> createdItemIds = [];
  int getItemCalls = 0;

  Future<ItemImage?> Function(String itemId, String base64Image)? onUploadBase64;
  Future<ItemImage?> Function(String itemId, String imageUrl)? onUploadFromUrl;
  Future<List<ItemImage>> Function(String itemId, List<File> images)?
  onUploadFiles;
  Future<ItemModel> Function(String itemId)? onGetItem;

  @override
  Future<ItemModel> createItem(CreateItemRequest request) async {
    final id = 'item-${createdItemIds.length + 1}';
    createdItemIds.add(id);
    return ItemModel(
      id: id,
      userId: 'user-1',
      name: request.name,
      category: request.category,
      condition: request.condition,
    );
  }

  @override
  Future<ItemImage?> uploadImageFromBase64(
    String itemId,
    String base64Image,
  ) async {
    base64Uploads.add(base64Image);
    final handler = onUploadBase64;
    return handler == null ? null : await handler(itemId, base64Image);
  }

  @override
  Future<ItemImage?> uploadImageFromUrl(
    String itemId,
    String imageUrl,
  ) async {
    urlUploads.add(imageUrl);
    final handler = onUploadFromUrl;
    return handler == null ? null : await handler(itemId, imageUrl);
  }

  @override
  Future<List<ItemImage>> uploadImages(
    String itemId,
    List<File> images,
  ) async {
    fileUploads.add(images.map((f) => f.path).toList());
    final handler = onUploadFiles;
    return handler == null
        ? [
            ItemImage(
              id: 'img-$itemId',
              url: 'https://cdn.example.com/items/$itemId.png',
            ),
          ]
        : await handler(itemId, images);
  }

  @override
  Future<ItemModel> getItem(String itemId) async {
    getItemCalls++;
    final handler = onGetItem;
    if (handler != null) return handler(itemId);
    return ItemModel(
      id: itemId,
      userId: 'user-1',
      name: 'saved',
      category: Category.tops,
      condition: Condition.clean,
      itemImages: [
        ItemImage(
          id: 'img-$itemId',
          url: 'https://cdn.example.com/items/$itemId.png',
        ),
      ],
    );
  }
}

BatchExtractedItem generatedItem({
  String id = 'temp-1',
  String sourceImageId = 'img-src-1',
  String? generatedImageBase64,
  String? generatedImageUrl,
}) => BatchExtractedItem(
  id: id,
  sourceImageId: sourceImageId,
  name: 'Blue Shirt',
  category: Category.tops,
  status: BatchItemStatus.generated,
  isSelected: true,
  includeInWardrobe: true,
  generatedImageBase64: generatedImageBase64,
  generatedImageUrl: generatedImageUrl,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(Get.reset);
  tearDown(Get.reset);

  // The polling futures below are deliberately not awaited: the loop only
  // advances as the test pumps the fake clock, so awaiting would deadlock.

  /// Advances the fake clock far past the polling cap. Each pump flushes
  /// microtasks so the loop's `await`s resolve between ticks.
  Future<void> runClock(WidgetTester tester, {int ticks = 200}) async {
    for (var i = 0; i < ticks; i++) {
      await tester.pump(const Duration(seconds: 2));
    }
  }

  group('BatchExtractionController.pollJobStatus', () {
    testWidgets('clean SSE close falls back to status polling', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final repo = FakeBatchExtractionRepository()
        ..onGetJobStatus = (id) async => BatchJobStatusResponse(
          jobId: id,
          status: 'completed',
          totalImages: 1,
        );

      final controller = BatchExtractionController(batchRepository: repo)
        ..jobId.value = 'job-1';
      controller.subscribeToEventsForTesting('job-1');
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(repo.getJobStatusCalls, 1);
      expect(controller.isComplete, isTrue);

      controller.onClose();
    });

    testWidgets('gives up after maxPollAttempts and surfaces the failure', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final repo = FakeBatchExtractionRepository()
        ..onGetJobStatus = (_) async => throw Exception('network down');

      final controller = BatchExtractionController(batchRepository: repo)
        ..jobId.value = 'job-1';
      unawaited(controller.pollJobStatus('job-1'));
      await runClock(tester);

      // Pre-fix the catch neither reported nor rescheduled, so this made
      // exactly 1 call and left the page frozen at its last percentage with
      // no error and no status transition.
      expect(
        repo.getJobStatusCalls,
        BatchExtractionController.maxPollAttempts,
        reason: 'transient failures must be retried, up to the cap',
      );
      expect(
        controller.error.value,
        isNotEmpty,
        reason: 'user must see an error, not a frozen progress bar',
      );
      expect(
        controller.isFailed,
        isTrue,
        reason: 'job must transition out of the processing state',
      );

      controller.onClose();
    });

    testWidgets('caps a job that never reaches a terminal status', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      // Backend is reachable but the job is wedged in "extracting" forever.
      final repo = FakeBatchExtractionRepository();

      final controller = BatchExtractionController(batchRepository: repo)
        ..jobId.value = 'job-1';
      unawaited(controller.pollJobStatus('job-1'));
      await runClock(tester);

      expect(
        repo.getJobStatusCalls,
        BatchExtractionController.maxPollAttempts,
        reason:
            'pre-fix this recursed once per clock tick forever '
            '(201 calls for this clock budget)',
      );
      expect(controller.error.value, isNotEmpty);
      expect(controller.isFailed, isTrue);

      controller.onClose();
    });

    testWidgets('abandons the chain when the user starts a different job', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final repo = FakeBatchExtractionRepository();

      final controller = BatchExtractionController(batchRepository: repo)
        ..jobId.value = 'job-1';
      unawaited(controller.pollJobStatus('job-1'));
      await runClock(tester, ticks: 5);
      final callsBeforeReset = repo.getJobStatusCalls;
      expect(callsBeforeReset, greaterThan(1));

      // "Try Again" on the progress page calls reset(), which clears jobId.
      controller.reset();
      await runClock(tester, ticks: 20);

      expect(
        repo.getJobStatusCalls,
        callsBeforeReset,
        reason:
            'a stale chain must not keep polling (or keep writing '
            'progress) for an abandoned job',
      );
      expect(controller.error.value, isEmpty);
      expect(controller.isIdle, isTrue);

      controller.onClose();
    });

    testWidgets('a second call while polling does not start a second chain', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final repo = FakeBatchExtractionRepository()
        ..onGetJobStatus = (_) async => throw Exception('network down');

      final controller = BatchExtractionController(batchRepository: repo)
        ..jobId.value = 'job-1';
      unawaited(controller.pollJobStatus('job-1'));
      unawaited(controller.pollJobStatus('job-1'));
      unawaited(controller.pollJobStatus('job-1'));
      await runClock(tester);

      // Without the single-flight guard every SSE onError starts its own
      // chain with a fresh counter, so N x cap is still unbounded.
      expect(repo.getJobStatusCalls, BatchExtractionController.maxPollAttempts);

      controller.onClose();
    });

    testWidgets('stops immediately on a terminal status', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final repo = FakeBatchExtractionRepository()
        ..onGetJobStatus = (id) async => BatchJobStatusResponse(
          jobId: id,
          status: 'completed',
          totalImages: 1,
        );

      final controller = BatchExtractionController(batchRepository: repo)
        ..jobId.value = 'job-1';
      await controller.pollJobStatus('job-1');
      await runClock(tester, ticks: 5);

      expect(repo.getJobStatusCalls, 1);
      expect(controller.isComplete, isTrue);
      expect(controller.error.value, isEmpty);

      controller.onClose();
    });

    testWidgets('recovers from a transient failure without erroring out', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final repo = FakeBatchExtractionRepository();
      var calls = 0;
      repo.onGetJobStatus = (id) async {
        calls++;
        if (calls == 1) throw Exception('transient blip');
        return BatchJobStatusResponse(
          jobId: id,
          status: 'completed',
          totalImages: 1,
        );
      };

      final controller = BatchExtractionController(batchRepository: repo)
        ..jobId.value = 'job-1';
      unawaited(controller.pollJobStatus('job-1'));
      await runClock(tester, ticks: 5);

      expect(controller.isComplete, isTrue);
      expect(
        controller.error.value,
        isEmpty,
        reason: 'one blip must be retried, not reported to the user',
      );

      controller.onClose();
    });
  });

  group('Sentry capture guard', () {
    test('captureToSentry is a no-op while Sentry is not initialised', () {
      expect(Sentry.isEnabled, isFalse);
      // Must not throw even though SentryFlutter.init never ran.
      ErrorHandler.captureToSentry(
        Exception('boom'),
        stackTrace: StackTrace.current,
      );
      ErrorHandler.reportError(Exception('boom'), 'test failure');
    });

    test('ErrorHandler is the only Sentry capture site in lib/', () {
      const guardFile = 'lib/core/utils/error_handler.dart';
      final offenders = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => f.path.replaceAll(r'\', '/') != guardFile)
          .where((f) => f.readAsStringSync().contains('Sentry.capture'))
          .map((f) => f.path)
          .toList();

      expect(
        offenders,
        isEmpty,
        reason:
            'Sentry.captureException/captureMessage must go through '
            'ErrorHandler.captureToSentry, which guards on Sentry.isEnabled. '
            'Unguarded call sites found in: $offenders',
      );
    });
  });

  group('BatchExtractionController.saveSelectedItems image strategy', () {
    testWidgets(
      'saves a URL-only generated image via uploadImageFromUrl '
      '(regression: the URL was previously mis-routed into base64Decode '
      'and silently dropped)',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        final repo = FakeItemRepository();
        final controller = BatchExtractionController(itemRepository: repo);
        // Post-job_complete state: the backend ships generated_image_base64
        // as null for URL-backed items, so only the presigned URL remains.
        controller.extractedItems.add(
          generatedItem(
            generatedImageUrl: 'https://cdn.example.com/generated/1.png',
          ),
        );

        final saved = await controller.saveSelectedItems();

        expect(repo.urlUploads, ['https://cdn.example.com/generated/1.png']);
        expect(
          repo.base64Uploads,
          isEmpty,
          reason: 'an http URL is not base64 and must never reach '
              'base64Decode',
        );
        expect(repo.fileUploads, isEmpty);
        expect(saved, hasLength(1));
        controller.onClose();
      },
    );

    testWidgets('saves a data-URI image via uploadImageFromBase64', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final repo = FakeItemRepository();
      final controller = BatchExtractionController(itemRepository: repo);
      controller.extractedItems.add(
        generatedItem(
          generatedImageUrl: 'data:image/png;base64,QUJD',
        ),
      );

      final saved = await controller.saveSelectedItems();

      expect(repo.base64Uploads, ['QUJD']);
      expect(repo.urlUploads, isEmpty);
      expect(repo.fileUploads, isEmpty);
      expect(saved, hasLength(1));
      controller.onClose();
    });

    testWidgets('saves an in-memory base64 image via uploadImageFromBase64', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final repo = FakeItemRepository();
      final controller = BatchExtractionController(itemRepository: repo);
      controller.extractedItems.add(
        generatedItem(generatedImageBase64: 'QUJD'),
      );

      final saved = await controller.saveSelectedItems();

      expect(repo.base64Uploads, ['QUJD']);
      expect(repo.urlUploads, isEmpty);
      expect(repo.fileUploads, isEmpty);
      expect(saved, hasLength(1));
      controller.onClose();
    });

    testWidgets('falls back to the source photo when the URL upload fails', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final repo = FakeItemRepository()
        ..onUploadFromUrl = (_, _) async => null;
      final controller = BatchExtractionController(itemRepository: repo);
      controller.extractedItems.add(
        generatedItem(
          generatedImageUrl: 'https://cdn.example.com/generated/1.png',
        ),
      );
      controller.selectedImages.add(
        BatchImage(id: 'img-src-1', filePath: '/tmp/source_photo.jpg'),
      );

      final saved = await controller.saveSelectedItems();

      expect(repo.urlUploads, ['https://cdn.example.com/generated/1.png']);
      expect(
        repo.fileUploads,
        [
          ['/tmp/source_photo.jpg'],
        ],
        reason: 'a failed generated-image upload must degrade to the source '
            'photo instead of saving the item image-less',
      );
      expect(saved, hasLength(1));
      controller.onClose();
    });

    testWidgets('falls back to the URL when the base64 upload fails', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final repo = FakeItemRepository()
        ..onUploadBase64 = (_, _) async => null;
      final controller = BatchExtractionController(itemRepository: repo);
      controller.extractedItems.add(
        generatedItem(
          generatedImageBase64: 'QUJD',
          generatedImageUrl: 'https://cdn.example.com/generated/1.png',
        ),
      );

      final saved = await controller.saveSelectedItems();

      expect(repo.base64Uploads, ['QUJD']);
      expect(
        repo.urlUploads,
        ['https://cdn.example.com/generated/1.png'],
        reason: 'a failed base64 upload must degrade to the URL strategy',
      );
      expect(saved, hasLength(1));
      controller.onClose();
    });

    testWidgets(
      'keeps the saved item and refreshes it when every upload strategy '
      'fails (no crash, no silent success)',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        final repo = FakeItemRepository();
        repo.onUploadBase64 = (_, _) async => null;
        repo.onUploadFromUrl = (_, _) async => null;
        repo.onUploadFiles = (_, _) async => <ItemImage>[];
        final controller = BatchExtractionController(itemRepository: repo);
        controller.extractedItems.add(
          generatedItem(
            generatedImageBase64: 'QUJD',
            generatedImageUrl: 'https://cdn.example.com/generated/1.png',
          ),
        );

        final saved = await controller.saveSelectedItems();

        expect(repo.createdItemIds, hasLength(1));
        expect(saved, hasLength(1));
        expect(repo.getItemCalls, 1);
        controller.onClose();
      },
    );
  });
}

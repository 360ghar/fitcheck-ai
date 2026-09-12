import 'dart:async';
import 'dart:io';

import 'package:fitcheck_ai/core/services/ai_consent_service.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/item_add_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/models/batch_extraction_models.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Condition;

class _GrantedConsent extends AiConsentService {
  @override
  Future<bool> ensureConsent({required String featureLabel}) async => true;

  @override
  // Consent is already granted; do not load platform preferences.
  // ignore: must_call_super
  void onInit() {}
}

class _ExtractionRepository extends FakeItemRepository {
  final events = <String, StreamController<SSEEvent>>{};
  final status = Completer<Map<String, dynamic>>();
  final starts = <String>[];
  final cancellations = <String>[];
  final polls = <String>[];
  Completer<SingleExtractionJob>? startGate;
  Completer<void>? cancelGate;

  @override
  Future<SingleExtractionJob> extractItemsFromImageAsync(File image) async {
    final id = 'job-${starts.length + 1}';
    starts.add(id);
    events[id] = StreamController<SSEEvent>.broadcast();
    return startGate?.future ??
        SingleExtractionJob(
          jobId: id,
          status: 'pending',
          totalImages: 1,
          sseUrl: '/events',
        );
  }

  @override
  Stream<SSEEvent> subscribeSingleExtractionEvents(String jobId) =>
      events[jobId]!.stream;

  @override
  Future<Map<String, dynamic>> getSingleJobStatus(String jobId) {
    polls.add(jobId);
    return status.future;
  }

  @override
  Future<void> cancelSingleExtraction(String jobId) async {
    cancellations.add(jobId);
    await cancelGate?.future;
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
  int createItemWithImageCalls = 0;
  bool useRealSourceCreate = false;

  Future<ItemImage?> Function(String itemId, String base64Image)?
  onUploadBase64;
  Future<ItemImage?> Function(String itemId, String imageUrl)? onUploadFromUrl;
  Future<List<ItemImage>> Function(String itemId, List<File> images)?
  onUploadFiles;

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
  Future<ItemModel> createItemWithImage({
    required File image,
    required CreateItemRequest request,
  }) async {
    if (useRealSourceCreate) {
      return super.createItemWithImage(image: image, request: request);
    }
    createItemWithImageCalls++;
    return ItemModel(
      id: 'item-src-$createItemWithImageCalls',
      userId: 'user-1',
      name: request.name,
      category: request.category,
      condition: request.condition,
      itemImages: [
        ItemImage(
          id: 'img-src-$createItemWithImageCalls',
          url: 'https://cdn.example.com/src/$createItemWithImageCalls.png',
        ),
      ],
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
  Future<ItemImage?> uploadImageFromUrl(String itemId, String imageUrl) async {
    urlUploads.add(imageUrl);
    final handler = onUploadFromUrl;
    return handler == null ? null : await handler(itemId, imageUrl);
  }

  @override
  Future<List<ItemImage>> uploadImages(String itemId, List<File> images) async {
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

DetectedItemDataWithImage generatedItem({
  String tempId = 'temp-1',
  String? generatedImageUrl,
  String? name,
}) => DetectedItemDataWithImage(
  tempId: tempId,
  category: 'tops',
  name: name ?? 'Blue Shirt',
  confidence: 0.95,
  generatedImageUrl: generatedImageUrl,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(Get.reset);
  tearDown(Get.reset);

  /// Hosts the controller's `Get.back()` + success snackbar: pushes a real
  /// route so the pop is a no-op-safe navigation back to the home route, and
  /// flushes the snackbar's auto-dismiss timer.
  Future<ItemAddController> hostController(
    WidgetTester tester,
    FakeItemRepository repo,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(home: const Scaffold(body: Text('home'))),
    );
    Get.to(const Scaffold(body: Text('page')));
    await tester.pumpAndSettle();
    return ItemAddController(itemRepository: repo);
  }

  /// Flushes the success snackbar timer (4s display + dismiss animation).
  Future<void> flushSnackbar(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('ItemAddController extraction lifetime', () {
    for (final action in ['reset', 'cancel', 'replace', 'dispose']) {
      testWidgets('ignores a late poll after $action', (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
        Get.put<AiConsentService>(_GrantedConsent());
        final repo = _ExtractionRepository();
        final controller = ItemAddController(itemRepository: repo);
        await controller.processImage(File('/tmp/old.jpg'));
        repo.events['job-1']!.addError(Exception('stream lost'));
        await tester.pump();
        expect(repo.polls, ['job-1']);

        switch (action) {
          case 'reset':
            controller.reset();
          case 'cancel':
            await controller.cancelExtraction();
          case 'replace':
            await controller.processImage(File('/tmp/new.jpg'));
          case 'dispose':
            controller.onDelete();
        }
        repo.status.complete({
          'status': 'completed',
          'items': [
            {'temp_id': 'old-item', 'category': 'tops', 'confidence': 0.9},
          ],
        });
        await tester.pump();
        expect(controller.generatedItems, isEmpty);
        expect(controller.currentPhase.value, isNot('complete'));
        if (action == 'replace') {
          expect(controller.selectedImage.value?.path, '/tmp/new.jpg');
          expect(controller.isProcessing.value, isTrue);
          expect(repo.events['job-1']!.hasListener, isFalse);
          expect(repo.events['job-2']!.hasListener, isTrue);
        }
        controller.onDelete();
        for (final events in repo.events.values) {
          await events.close();
        }
        await tester.pump(const Duration(seconds: 46));
        expect(repo.polls, ['job-1']);
      });
    }

    testWidgets('cancel during start never installs the late job stream', (
      tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
      Get.put<AiConsentService>(_GrantedConsent());
      final repo = _ExtractionRepository()
        ..startGate = Completer<SingleExtractionJob>();
      final controller = ItemAddController(itemRepository: repo);
      final pending = controller.processImage(File('/tmp/photo.jpg'));
      await tester.pump();
      await controller.cancelExtraction();
      repo.startGate!.complete(
        const SingleExtractionJob(
          jobId: 'job-1',
          status: 'pending',
          totalImages: 1,
          sseUrl: '/events',
        ),
      );
      await pending;
      expect(controller.isProcessing.value, isFalse);
      expect(repo.events['job-1']!.hasListener, isFalse);
      expect(repo.cancellations, ['job-1']);
      controller.onDelete();
      await repo.events['job-1']!.close();
    });

    testWidgets('late cancel response does not stop the replacement job', (
      tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
      Get.put<AiConsentService>(_GrantedConsent());
      final repo = _ExtractionRepository()..cancelGate = Completer<void>();
      final controller = ItemAddController(itemRepository: repo);
      await controller.processImage(File('/tmp/old.jpg'));
      final pendingCancel = controller.cancelExtraction();
      await controller.processImage(File('/tmp/new.jpg'));
      repo.cancelGate!.complete();
      await pendingCancel;
      expect(controller.isProcessing.value, isTrue);
      expect(repo.events['job-2']!.hasListener, isTrue);
      controller.onDelete();
      for (final events in repo.events.values) {
        await events.close();
      }
    });
  });

  group('ItemAddController.saveGeneratedItems image strategy', () {
    testWidgets('saves a URL-only generated image via uploadImageFromUrl '
        '(regression: the URL was previously mis-routed into base64Decode, '
        'threw, and the item was saved image-less)', (tester) async {
      final repo = FakeItemRepository();
      final controller = await hostController(tester, repo);
      // Post-job_complete state: the backend ships generated_image_base64
      // as null for URL-backed items, so only the presigned URL remains.
      controller.generatedItems.add(
        generatedItem(
          generatedImageUrl: 'https://cdn.example.com/generated/1.png',
        ),
      );

      await controller.saveGeneratedItems();

      expect(repo.urlUploads, ['https://cdn.example.com/generated/1.png']);
      expect(
        repo.base64Uploads,
        isEmpty,
        reason:
            'an http URL is not base64 and must never reach '
            'base64Decode',
      );
      expect(repo.fileUploads, isEmpty);
      expect(controller.createdItems, hasLength(1));
      await flushSnackbar(tester);
      controller.onClose();
    });

    testWidgets('saves a data-URI image via uploadImageFromBase64', (
      tester,
    ) async {
      final repo = FakeItemRepository();
      final controller = await hostController(tester, repo);
      controller.generatedItems.add(
        generatedItem(generatedImageUrl: 'data:image/png;base64,QUJD'),
      );

      await controller.saveGeneratedItems();

      expect(repo.base64Uploads, ['QUJD']);
      expect(repo.urlUploads, isEmpty);
      expect(repo.fileUploads, isEmpty);
      expect(controller.createdItems, hasLength(1));
      await flushSnackbar(tester);
      controller.onClose();
    });

    testWidgets('falls back to the source photo when the URL upload fails', (
      tester,
    ) async {
      final repo = FakeItemRepository()..onUploadFromUrl = (_, _) async => null;
      final controller = await hostController(tester, repo);
      controller.generatedItems.add(
        generatedItem(
          generatedImageUrl: 'https://cdn.example.com/generated/1.png',
        ),
      );
      controller.selectedImage.value = File('/tmp/source_photo.jpg');

      await controller.saveGeneratedItems();

      expect(repo.urlUploads, ['https://cdn.example.com/generated/1.png']);
      expect(
        repo.fileUploads,
        [
          ['/tmp/source_photo.jpg'],
        ],
        reason:
            'a failed generated-image upload must degrade to the source '
            'photo instead of saving the item image-less',
      );
      expect(controller.createdItems, hasLength(1));
      await flushSnackbar(tester);
      controller.onClose();
    });

    testWidgets('falls back to the source photo when the base64 upload fails '
        '(a data URI must never reach the URL strategy)', (tester) async {
      final repo = FakeItemRepository()..onUploadBase64 = (_, _) async => null;
      final controller = await hostController(tester, repo);
      controller.generatedItems.add(
        generatedItem(generatedImageUrl: 'data:image/png;base64,QUJD'),
      );
      controller.selectedImage.value = File('/tmp/source_photo.jpg');

      await controller.saveGeneratedItems();

      expect(repo.base64Uploads, ['QUJD']);
      expect(
        repo.urlUploads,
        isEmpty,
        reason:
            'a data URI is not fetchable and must never reach the '
            'URL strategy',
      );
      expect(repo.fileUploads, [
        ['/tmp/source_photo.jpg'],
      ]);
      expect(controller.createdItems, hasLength(1));
      await flushSnackbar(tester);
      controller.onClose();
    });

    testWidgets('keeps the item when every upload strategy fails '
        '(no crash, no silent success)', (tester) async {
      final repo = FakeItemRepository();
      repo.onUploadBase64 = (_, _) async => null;
      repo.onUploadFromUrl = (_, _) async => null;
      repo.onUploadFiles = (_, _) async => <ItemImage>[];
      final controller = await hostController(tester, repo);
      controller.generatedItems.add(
        generatedItem(
          generatedImageUrl: 'https://cdn.example.com/generated/1.png',
        ),
      );

      await controller.saveGeneratedItems();

      expect(repo.createdItemIds, hasLength(1));
      expect(controller.createdItems, hasLength(1));
      expect(repo.getItemCalls, 0);
      await flushSnackbar(tester);
      controller.onClose();
    });

    for (final generatedPhoto in [true, false]) {
      testWidgets(
        'retains created item after photo upload throws: generated=$generatedPhoto',
        (tester) async {
          final repo = FakeItemRepository()..useRealSourceCreate = true;
          repo.onUploadFromUrl = (_, _) async => null;
          repo.onUploadFiles = (_, _) async =>
              throw StateError('Upload failed');
          final controller = await hostController(tester, repo);
          controller.generatedItems.add(
            generatedItem(
              generatedImageUrl: generatedPhoto
                  ? 'https://cdn.example.com/generated.png'
                  : null,
            ),
          );
          controller.selectedImage.value = File('/tmp/source_photo.jpg');
          await controller.saveGeneratedItems();
          expect(repo.createdItemIds, hasLength(1));
          expect(controller.createdItems.single.id, repo.createdItemIds.single);
          await flushSnackbar(tester);
          controller.onClose();
        },
      );
    }

    testWidgets('uses the source photo when generation has no image yet', (
      tester,
    ) async {
      final repo = FakeItemRepository();
      final controller = await hostController(tester, repo);
      controller.generatedItems.add(generatedItem(generatedImageUrl: null));
      controller.selectedImage.value = File('/tmp/source_photo.jpg');

      await controller.saveGeneratedItems();

      expect(repo.createItemWithImageCalls, 1);
      expect(repo.urlUploads, isEmpty);
      expect(repo.base64Uploads, isEmpty);
      expect(controller.createdItems, hasLength(1));
      await flushSnackbar(tester);
      controller.onClose();
    });
  });
}

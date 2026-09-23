import 'dart:async';
import 'dart:io';

import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart';
import 'package:fitcheck_ai/features/wardrobe/models/batch_extraction_models.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/batch_extraction_provider.dart'
    show aiConsentGateProvider;
import 'package:fitcheck_ai/features/wardrobe/providers/item_add_provider.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/wardrobe_providers.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake [ItemRepository] whose calls record their inputs so tests can
/// assert the save-time upload strategy and the job lifecycle without any
/// network.
class FakeItemRepository extends ItemRepository {
  final List<String> base64Uploads = [];
  final List<String> urlUploads = [];
  final List<List<String>> fileUploads = [];
  final List<String> createdItemIds = [];
  int getItemCalls = 0;
  int createItemWithImageCalls = 0;
  int statusCalls = 0;
  int jobsStarted = 0;

  /// Idempotency keys sent, in call order (TD-109).
  final List<String?> createRequestIds = [];
  final List<String?> createWithImageRequestIds = [];

  /// One SSE stream per started job, by job id.
  final Map<String, StreamController<SSEEvent>> streams = {};

  Future<ItemModel> Function(CreateItemRequest request, String? id)?
  onCreateItem;
  Future<ItemImage?> Function(String itemId, String base64Image)?
  onUploadBase64;
  Future<ItemImage?> Function(String itemId, String imageUrl)? onUploadFromUrl;
  Future<List<ItemImage>> Function(String itemId, List<File> images)?
  onUploadFiles;
  Future<Map<String, dynamic>> Function(String jobId)? onStatus;

  @override
  Future<SingleExtractionJob> extractItemsFromImageAsync(File image) async {
    jobsStarted++;
    final id = 'job-$jobsStarted';
    streams[id] = StreamController<SSEEvent>();
    return SingleExtractionJob(
      jobId: id,
      status: 'pending',
      totalImages: 1,
      sseUrl: '/events/$id',
    );
  }

  @override
  Stream<SSEEvent> subscribeSingleExtractionEvents(String jobId) =>
      streams[jobId]!.stream;

  @override
  Future<Map<String, dynamic>> getSingleJobStatus(String jobId) {
    statusCalls++;
    return onStatus?.call(jobId) ??
        Future.value(<String, dynamic>{
          'status': 'processing',
          'items': <Object>[],
        });
  }

  @override
  Future<ItemModel> createItem(
    CreateItemRequest request, {
    String? clientRequestId,
  }) async {
    createRequestIds.add(clientRequestId);
    final hook = onCreateItem;
    if (hook != null) return hook(request, clientRequestId);
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
    String? clientRequestId,
  }) async {
    createWithImageRequestIds.add(clientRequestId);
    createItemWithImageCalls++;
    return ItemModel(
      id: 'item-src-$createItemWithImageCalls',
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
    return onUploadBase64 == null
        ? null
        : await onUploadBase64!(itemId, base64Image);
  }

  @override
  Future<ItemImage?> uploadImageFromUrl(String itemId, String imageUrl) async {
    urlUploads.add(imageUrl);
    return onUploadFromUrl == null
        ? null
        : await onUploadFromUrl!(itemId, imageUrl);
  }

  @override
  Future<List<ItemImage>> uploadImages(String itemId, List<File> images) async {
    fileUploads.add(images.map((f) => f.path).toList());
    return onUploadFiles == null
        ? [
            ItemImage(
              id: 'img-$itemId',
              url: 'https://cdn.example.com/items/$itemId.png',
            ),
          ]
        : await onUploadFiles!(itemId, images);
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

const session = 0;

/// A container with fakes, holding the session open like the add page does.
({ProviderContainer container, ItemAddNotifier notifier}) host(
  FakeItemRepository repo,
) {
  final container = ProviderContainer(
    retry: noRetry,
    overrides: [
      itemRepositoryProvider.overrideWithValue(repo),
      aiConsentGateProvider.overrideWithValue((_) async => true),
    ],
  );
  addTearDown(container.dispose);
  container.listen(itemAddProvider(session), (_, _) {});
  return (
    container: container,
    notifier: container.read(itemAddProvider(session).notifier),
  );
}

void seed(
  ItemAddNotifier notifier,
  List<DetectedItemDataWithImage> items, {
  File? image,
}) => notifier.debugSetState(ItemAddState(items: items, image: image));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ItemAddNotifier.saveGeneratedItems image strategy', () {
    test('saves a URL-only generated image via uploadImageFromUrl', () async {
      final repo = FakeItemRepository();
      final h = host(repo);
      // After job_complete the backend ships only the presigned URL.
      seed(h.notifier, [
        generatedItem(
          generatedImageUrl: 'https://cdn.example.com/generated/1.png',
        ),
      ]);

      final result = await h.notifier.saveGeneratedItems();

      expect(repo.urlUploads, ['https://cdn.example.com/generated/1.png']);
      expect(
        repo.base64Uploads,
        isEmpty,
        reason: 'a URL must never reach base64Decode',
      );
      expect(repo.fileUploads, isEmpty);
      expect(result.saved, hasLength(1));
      expect(result.failed, 0);
    });

    test('saves a data-URI image via uploadImageFromBase64', () async {
      final repo = FakeItemRepository();
      final h = host(repo);
      seed(h.notifier, [
        generatedItem(generatedImageUrl: 'data:image/png;base64,QUJD'),
      ]);

      final result = await h.notifier.saveGeneratedItems();

      expect(repo.base64Uploads, ['QUJD']);
      expect(repo.urlUploads, isEmpty);
      expect(repo.fileUploads, isEmpty);
      expect(result.saved, hasLength(1));
    });

    test('falls back to the source photo when the URL upload fails', () async {
      final repo = FakeItemRepository()..onUploadFromUrl = (_, _) async => null;
      final h = host(repo);
      seed(h.notifier, [
        generatedItem(
          generatedImageUrl: 'https://cdn.example.com/generated/1.png',
        ),
      ], image: File('/tmp/source_photo.jpg'));

      final result = await h.notifier.saveGeneratedItems();

      expect(repo.urlUploads, ['https://cdn.example.com/generated/1.png']);
      expect(repo.fileUploads, [
        ['/tmp/source_photo.jpg'],
      ]);
      expect(result.saved, hasLength(1));
    });

    test(
      'a data URI never reaches the URL strategy when base64 fails',
      () async {
        final repo = FakeItemRepository()
          ..onUploadBase64 = (_, _) async => null;
        final h = host(repo);
        seed(h.notifier, [
          generatedItem(generatedImageUrl: 'data:image/png;base64,QUJD'),
        ], image: File('/tmp/source_photo.jpg'));

        final result = await h.notifier.saveGeneratedItems();

        expect(repo.base64Uploads, ['QUJD']);
        expect(repo.urlUploads, isEmpty);
        expect(repo.fileUploads, [
          ['/tmp/source_photo.jpg'],
        ]);
        expect(result.saved, hasLength(1));
      },
    );

    test('keeps the item and refreshes it when every strategy fails', () async {
      final repo = FakeItemRepository();
      repo.onUploadBase64 = (_, _) async => null;
      repo.onUploadFromUrl = (_, _) async => null;
      repo.onUploadFiles = (_, _) async => <ItemImage>[];
      final h = host(repo);
      seed(h.notifier, [
        generatedItem(
          generatedImageUrl: 'https://cdn.example.com/generated/1.png',
        ),
      ]);

      final result = await h.notifier.saveGeneratedItems();

      expect(repo.createdItemIds, hasLength(1));
      expect(result.saved, hasLength(1));
      expect(repo.getItemCalls, 1);
    });

    test('uses the source photo when generation has no image yet', () async {
      final repo = FakeItemRepository();
      final h = host(repo);
      seed(h.notifier, [generatedItem()], image: File('/tmp/source_photo.jpg'));

      final result = await h.notifier.saveGeneratedItems();

      expect(repo.createItemWithImageCalls, 1);
      expect(repo.urlUploads, isEmpty);
      expect(repo.base64Uploads, isEmpty);
      expect(result.saved, hasLength(1));
    });

    test('re-tapping Save reuses the same client_request_id (TD-109) and '
        'skips pieces already saved', () async {
      final repo = FakeItemRepository();
      var failSecond = true;
      repo.onCreateItem = (request, _) async {
        if (failSecond && request.name == 'Second') {
          throw Exception('response lost in transit');
        }
        return ItemModel(
          id: 'item-${request.name}',
          userId: 'user-1',
          name: request.name,
          category: request.category,
          condition: request.condition,
        );
      };
      final h = host(repo);
      seed(h.notifier, [
        generatedItem(
          tempId: 'temp-1',
          name: 'First',
          generatedImageUrl: 'https://cdn.example.com/1.png',
        ),
        generatedItem(
          tempId: 'temp-2',
          name: 'Second',
          generatedImageUrl: 'https://cdn.example.com/2.png',
        ),
      ]);

      final first = await h.notifier.saveGeneratedItems();
      expect(first.saved, hasLength(1));
      expect(first.failed, 1);
      failSecond = false;
      final second = await h.notifier.saveGeneratedItems();

      // The retry sends only the failed piece, under the key it had before,
      // so a create whose response was lost is replayed, not duplicated.
      expect(second.saved, hasLength(1));
      expect(repo.createRequestIds, hasLength(3));
      expect(repo.createRequestIds[0], isNotNull);
      expect(repo.createRequestIds[2], repo.createRequestIds[1]);
      expect(repo.createRequestIds[0], isNot(repo.createRequestIds[1]));
    });

    test(
      'two garments with no temp_id do not collapse into one (TD-109)',
      () async {
        final repo = FakeItemRepository();
        final h = host(repo);
        seed(h.notifier, [
          generatedItem(
            tempId: 'unknown',
            name: 'First',
            generatedImageUrl: 'https://cdn.example.com/1.png',
          ),
          generatedItem(
            tempId: 'unknown',
            name: 'Second',
            generatedImageUrl: 'https://cdn.example.com/2.png',
          ),
        ]);

        await h.notifier.saveGeneratedItems();

        expect(repo.createRequestIds, hasLength(2));
        expect(repo.createRequestIds[0], isNot(repo.createRequestIds[1]));
      },
    );
  });

  group('ItemAddNotifier job lifecycle', () {
    test(
      'a second processImage while the first starts starts one job',
      () async {
        final repo = FakeItemRepository();
        final h = host(repo);
        final image = File('/tmp/photo.jpg');

        await Future.wait([
          h.notifier.processImage(image),
          h.notifier.processImage(image),
        ]);

        expect(repo.jobsStarted, 1);
      },
    );

    test(
      'a stale event from the previous job does not change the new job',
      () async {
        final repo = FakeItemRepository();
        final h = host(repo);
        final image = File('/tmp/photo.jpg');

        await h.notifier.processImage(image);
        repo.streams['job-1']!.add(
          const SSEEvent(
            type: 'image_extraction_failed',
            data: {'error': 'blurry'},
          ),
        );
        await pumpEventQueue();
        expect(h.container.read(itemAddProvider(session)).failure, isNotNull);

        // Retry: a new job starts.
        await h.notifier.processImage(image);
        expect(h.notifier.debugJobId, 'job-2');
        expect(h.container.read(itemAddProvider(session)).processing, isTrue);

        // The old job's late terminal event must not reset the new job's UI.
        repo.streams['job-1']!.add(
          const SSEEvent(type: 'job_failed', data: {'error': 'late'}),
        );
        await pumpEventQueue();
        final state = h.container.read(itemAddProvider(session));
        expect(state.processing, isTrue);
        expect(state.failure, isNull);
      },
    );

    test('connection messages are matched case-insensitively', () {
      expect(
        ItemAddFailure.from(Exception('Connection was lost. Try again.')).kind,
        ItemAddFailureKind.connection,
      );
      expect(
        ItemAddFailure.from(Exception('No items detected')).kind,
        ItemAddFailureKind.noItems,
      );
    });

    testWidgets('no polling runs after the provider is disposed', (
      tester,
    ) async {
      final repo = FakeItemRepository();
      final h = host(repo);
      await h.notifier.processImage(File('/tmp/photo.jpg'));

      // The stream drops mid-job: the notifier reconciles by polling.
      await repo.streams['job-1']!.close();
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      final before = repo.statusCalls;
      expect(before, greaterThan(0));

      h.container.dispose();
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(seconds: 3));
      }
      expect(
        repo.statusCalls,
        before,
        reason: 'the loop must stop with the page',
      );
    });

    test('cancel stops listening even when the server cancel fails', () async {
      final repo = _FailingCancelRepository();
      final h = host(repo);
      await h.notifier.processImage(File('/tmp/photo.jpg'));

      await h.notifier.cancelExtraction();

      final state = h.container.read(itemAddProvider(session));
      expect(state.processing, isFalse);
      expect(state.image, isNull);
      expect(h.notifier.debugJobId, isNull);
      expect(repo.streams['job-1']!.hasListener, isFalse);
    });
  });
}

class _FailingCancelRepository extends FakeItemRepository {
  @override
  Future<void> cancelSingleExtraction(String jobId) async =>
      throw Exception('offline');
}

import 'dart:async';
import 'dart:io';

import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/core/utils/error_handler.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart';
import 'package:fitcheck_ai/features/wardrobe/models/batch_extraction_models.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/models/social_import_models.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/batch_extraction_provider.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/wardrobe_providers.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/batch_extraction_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/social_import_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// A fake [BatchExtractionRepository]: the status endpoint and the SSE stream
/// are driven by callbacks, and job starts are counted.
class FakeBatchExtractionRepository extends BatchExtractionRepository {
  int getJobStatusCalls = 0;
  int startCalls = 0;
  Future<BatchJobStatusResponse> Function(String jobId)? onGetJobStatus;
  Stream<SSEEvent> Function(String jobId)? onSubscribeToEvents;

  @override
  Future<BatchExtractionResponse> startBatchExtraction({
    required List<BatchImageInput> images,
    bool autoGenerate = true,
    int generationBatchSize = 5,
  }) async {
    startCalls++;
    return BatchExtractionResponse(
      jobId: 'job-$startCalls',
      status: 'pending',
      totalImages: images.length,
    );
  }

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
  Stream<SSEEvent> subscribeToEvents(String jobId) =>
      onSubscribeToEvents?.call(jobId) ?? const Stream<SSEEvent>.empty();
}

SocialImportJobData socialJob(String id, SocialImportJobStatus status) =>
    SocialImportJobData(
      id: id,
      status: status,
      platform: SocialPlatform.instagram,
      sourceUrl: 'https://instagram.com/x',
      normalizedUrl: 'https://instagram.com/x',
      totalPhotos: 10,
      discoveredPhotos: 5,
      processedPhotos: 2,
      approvedPhotos: 2,
      rejectedPhotos: 0,
      failedPhotos: 0,
      authRequired: false,
      discoveryCompleted: false,
      queuedCount: 3,
    );

/// A fake [SocialImportRepository]: its SSE stream is a test-driven
/// controller, so tests can mimic the SSE service's single-error contract.
class FakeSocialImportRepository extends SocialImportRepository {
  final StreamController<SocialImportSSEEvent> events =
      StreamController<SocialImportSSEEvent>.broadcast();

  int getStatusCalls = 0;
  Future<SocialImportJobData> Function(String jobId)? onGetStatus;
  Future<void> Function()? onScraperLogin;

  @override
  Future<SocialImportJobData> getStatus(String jobId) {
    getStatusCalls++;
    final handler = onGetStatus;
    if (handler != null) return handler(jobId);
    // Terminal after a few polls so the bounded loop exits.
    return Future.value(
      socialJob(
        jobId,
        getStatusCalls >= 3
            ? SocialImportJobStatus.completed
            : SocialImportJobStatus.processing,
      ),
    );
  }

  @override
  Stream<SocialImportSSEEvent> subscribeToEvents(
    String jobId, {
    int? lastEventId,
  }) => events.stream;

  @override
  Future<void> submitScraperLogin(
    String jobId, {
    required String username,
    required String password,
    String? otpCode,
    String? twoFactorIdentifier,
  }) => onScraperLogin?.call() ?? Future.value();
}

/// In-memory [PersistenceService]: no SharedPreferences in unit tests.
class InMemoryPersistenceService extends PersistenceService {
  final Map<String, Object> _store = {};

  @override
  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<String?> getString(String key) async => _store[key] as String?;

  @override
  Future<bool> setInt(String key, int value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async => _store[key] as int?;

  @override
  Future<bool> remove(String key) async {
    _store.remove(key);
    return true;
  }
}

/// A fake [ItemRepository] that records uploads and idempotency keys.
class FakeItemRepository extends ItemRepository {
  final List<String> base64Uploads = [];
  final List<String> urlUploads = [];
  final List<List<String>> fileUploads = [];
  final List<String> createdItemIds = [];
  final List<String?> createRequestIds = [];
  int getItemCalls = 0;

  Future<ItemModel> Function(CreateItemRequest request)? onCreateItem;
  Future<ItemImage?> Function(String itemId, String base64Image)?
  onUploadBase64;
  Future<ItemImage?> Function(String itemId, String imageUrl)? onUploadFromUrl;
  Future<List<ItemImage>> Function(String itemId, List<File> images)?
  onUploadFiles;

  @override
  Future<ItemModel> createItem(
    CreateItemRequest request, {
    String? clientRequestId,
  }) async {
    createRequestIds.add(clientRequestId);
    if (onCreateItem != null) return onCreateItem!(request);
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

BatchExtractedItem generatedItem({
  String id = 'temp-1',
  String name = 'Blue Shirt',
  String sourceImageId = 'img-src-1',
  String? generatedImageBase64,
  String? generatedImageUrl,
}) => BatchExtractedItem(
  id: id,
  sourceImageId: sourceImageId,
  name: name,
  category: Category.tops,
  status: BatchItemStatus.generated,
  isSelected: true,
  includeInWardrobe: true,
  generatedImageBase64: generatedImageBase64,
  generatedImageUrl: generatedImageUrl,
);

/// A container with fakes, holding the session open like the batch pages.
({ProviderContainer container, BatchExtractionNotifier notifier}) host({
  FakeBatchExtractionRepository? batch,
  FakeItemRepository? items,
  FakeSocialImportRepository? social,
}) {
  final container = ProviderContainer(
    retry: noRetry,
    overrides: [
      batchExtractionRepositoryProvider.overrideWithValue(
        batch ?? FakeBatchExtractionRepository(),
      ),
      itemRepositoryProvider.overrideWithValue(items ?? FakeItemRepository()),
      socialImportRepositoryProvider.overrideWithValue(
        social ?? FakeSocialImportRepository(),
      ),
      aiConsentGateProvider.overrideWithValue((_) async => true),
      persistenceServiceProvider.overrideWithValue(
        InMemoryPersistenceService(),
      ),
      socialCallbackLinksProvider.overrideWithValue(const Stream<Uri>.empty()),
      batchImageEncoderProvider.overrideWithValue((_) async => 'QUJD'),
    ],
  );
  addTearDown(container.dispose);
  container.listen(batchExtractionProvider, (_, _) {});
  return (
    container: container,
    notifier: container.read(batchExtractionProvider.notifier),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Polling futures are not awaited: the loop advances only as the test
  // pumps the fake clock, so awaiting would deadlock.
  Future<void> runClock(WidgetTester tester, {int ticks = 200}) async {
    for (var i = 0; i < ticks; i++) {
      await tester.pump(const Duration(seconds: 2));
    }
  }

  BatchState read(ProviderContainer c) => c.read(batchExtractionProvider);

  group('BatchExtractionNotifier.pollJobStatus', () {
    testWidgets('clean SSE close falls back to status polling', (tester) async {
      final repo = FakeBatchExtractionRepository()
        ..onGetJobStatus = (id) async => BatchJobStatusResponse(
          jobId: id,
          status: 'completed',
          totalImages: 1,
        );
      final h = host(batch: repo);
      h.notifier.debugSetState(const BatchState(jobId: 'job-1'));

      h.notifier.subscribeToEventsForTesting('job-1');
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(repo.getJobStatusCalls, 1);
      expect(read(h.container).isComplete, isTrue);
    });

    testWidgets('gives up after maxPollAttempts and surfaces the failure', (
      tester,
    ) async {
      final repo = FakeBatchExtractionRepository()
        ..onGetJobStatus = (_) async => throw Exception('network down');
      final h = host(batch: repo);
      h.notifier.debugSetState(const BatchState(jobId: 'job-1'));

      unawaited(h.notifier.pollJobStatus('job-1'));
      await runClock(tester);

      expect(repo.getJobStatusCalls, BatchExtractionNotifier.maxPollAttempts);
      expect(
        read(h.container).error,
        isNotEmpty,
        reason: 'no frozen progress bar',
      );
      expect(read(h.container).isFailed, isTrue);
    });

    testWidgets('caps a job that never reaches a terminal status', (
      tester,
    ) async {
      final repo = FakeBatchExtractionRepository();
      final h = host(batch: repo);
      h.notifier.debugSetState(const BatchState(jobId: 'job-1'));

      unawaited(h.notifier.pollJobStatus('job-1'));
      await runClock(tester);

      expect(repo.getJobStatusCalls, BatchExtractionNotifier.maxPollAttempts);
      expect(read(h.container).error, isNotEmpty);
      expect(read(h.container).isFailed, isTrue);
    });

    testWidgets('abandons the chain when the job is reset', (tester) async {
      final repo = FakeBatchExtractionRepository();
      final h = host(batch: repo);
      h.notifier.debugSetState(const BatchState(jobId: 'job-1'));

      unawaited(h.notifier.pollJobStatus('job-1'));
      await runClock(tester, ticks: 5);
      final before = repo.getJobStatusCalls;
      expect(before, greaterThan(1));

      h.notifier.reset();
      await runClock(tester, ticks: 20);

      expect(repo.getJobStatusCalls, before);
      expect(read(h.container).error, isEmpty);
      expect(read(h.container).isIdle, isTrue);
    });

    testWidgets('stops polling when the provider is disposed', (tester) async {
      final repo = FakeBatchExtractionRepository();
      final h = host(batch: repo);
      h.notifier.debugSetState(const BatchState(jobId: 'job-1'));

      unawaited(h.notifier.pollJobStatus('job-1'));
      await runClock(tester, ticks: 3);
      final before = repo.getJobStatusCalls;
      h.container.dispose();
      await runClock(tester, ticks: 20);

      expect(repo.getJobStatusCalls, before);
    });

    testWidgets('a second call while polling does not start a second chain', (
      tester,
    ) async {
      final repo = FakeBatchExtractionRepository()
        ..onGetJobStatus = (_) async => throw Exception('network down');
      final h = host(batch: repo);
      h.notifier.debugSetState(const BatchState(jobId: 'job-1'));

      unawaited(h.notifier.pollJobStatus('job-1'));
      unawaited(h.notifier.pollJobStatus('job-1'));
      unawaited(h.notifier.pollJobStatus('job-1'));
      await runClock(tester);

      expect(repo.getJobStatusCalls, BatchExtractionNotifier.maxPollAttempts);
    });

    testWidgets('stops immediately on a terminal status', (tester) async {
      final repo = FakeBatchExtractionRepository()
        ..onGetJobStatus = (id) async => BatchJobStatusResponse(
          jobId: id,
          status: 'completed',
          totalImages: 1,
        );
      final h = host(batch: repo);
      h.notifier.debugSetState(const BatchState(jobId: 'job-1'));

      await h.notifier.pollJobStatus('job-1');
      await runClock(tester, ticks: 5);

      expect(repo.getJobStatusCalls, 1);
      expect(read(h.container).isComplete, isTrue);
      expect(read(h.container).error, isEmpty);
    });

    testWidgets('recovers from a transient failure without erroring out', (
      tester,
    ) async {
      var calls = 0;
      final repo = FakeBatchExtractionRepository()
        ..onGetJobStatus = (id) async {
          calls++;
          if (calls == 1) throw Exception('transient blip');
          return BatchJobStatusResponse(
            jobId: id,
            status: 'completed',
            totalImages: 1,
          );
        };
      final h = host(batch: repo);
      h.notifier.debugSetState(const BatchState(jobId: 'job-1'));

      unawaited(h.notifier.pollJobStatus('job-1'));
      await runClock(tester, ticks: 5);

      expect(read(h.container).isComplete, isTrue);
      expect(read(h.container).error, isEmpty);
    });

    testWidgets(
      'the synthetic SSE error event keeps error empty while recovery '
      'polling runs',
      (tester) async {
        final events = StreamController<SSEEvent>();
        var polls = 0;
        final repo = FakeBatchExtractionRepository()
          ..onSubscribeToEvents = ((_) => events.stream)
          ..onGetJobStatus = (id) async {
            polls++;
            return BatchJobStatusResponse(
              jobId: id,
              status: polls >= 3 ? 'completed' : 'extracting',
              totalImages: 1,
            );
          };
        final h = host(batch: repo);
        h.notifier.debugSetState(const BatchState(jobId: 'job-1'));
        h.notifier.subscribeToEventsForTesting('job-1');

        events.add(
          const SSEEvent(
            type: 'error',
            data: {'message': 'Connection failed after 3 attempts'},
          ),
        );
        await events.close();
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));

        expect(
          repo.getJobStatusCalls,
          greaterThan(0),
          reason: 'onDone must recover',
        );
        expect(
          read(h.container).error,
          isEmpty,
          reason: 'a recovering job is not a failure',
        );
        expect(read(h.container).isFailed, isFalse);

        await runClock(tester, ticks: 5);
        expect(read(h.container).isComplete, isTrue);
        expect(read(h.container).error, isEmpty);
      },
    );
  });

  group('BatchExtractionNotifier.startExtraction', () {
    test(
      'two back-to-back calls start one paid job and clear the last run',
      () async {
        final events = StreamController<SSEEvent>();
        addTearDown(events.close);
        final repo = FakeBatchExtractionRepository()
          ..onSubscribeToEvents = ((_) => events.stream);
        final h = host(batch: repo);
        h.notifier.debugSetState(
          BatchState(
            images: const [BatchImage(id: 'a', filePath: '/tmp/a.jpg')],
            items: [generatedItem()],
            extractedCount: 4,
            generatedCount: 3,
          ),
        );

        await Future.wait([
          h.notifier.startExtraction(),
          h.notifier.startExtraction(),
        ]);

        expect(repo.startCalls, 1);
        final state = read(h.container);
        expect(state.jobId, 'job-1');
        expect(state.items, isEmpty);
        expect(state.extractedCount, 0);
        expect(state.generatedCount, 0);
      },
    );

    test('a second run after reset navigates to review again', () {
      final h = host();
      expect(h.notifier.claimReviewNavigation(), isTrue);
      expect(
        h.notifier.claimReviewNavigation(),
        isFalse,
        reason: 'once per job',
      );

      h.notifier.reset();
      expect(h.notifier.claimReviewNavigation(), isTrue);

      h.notifier.resetJob();
      expect(h.notifier.claimReviewNavigation(), isTrue);
    });

    test('a job event from an earlier job is ignored', () async {
      final events = StreamController<SSEEvent>.broadcast();
      addTearDown(events.close);
      final repo = FakeBatchExtractionRepository()
        ..onSubscribeToEvents = ((_) => events.stream);
      final h = host(batch: repo);
      h.notifier.debugSetState(const BatchState(jobId: 'job-1'));
      h.notifier.subscribeToEventsForTesting('job-1');
      h.notifier.debugSetState(const BatchState(jobId: 'job-2'));

      events.add(const SSEEvent(type: 'job_failed', data: {'error': 'old'}));
      await pumpEventQueue();

      expect(read(h.container).isFailed, isFalse);
    });
  });

  group('BatchExtractionNotifier social import', () {
    testWidgets('synthetic error event starts the polling fallback', (
      tester,
    ) async {
      final repo = FakeSocialImportRepository();
      final h = host(social: repo);
      h.notifier.debugSetState(const BatchState(socialJobId: 'social-1'));

      h.notifier.subscribeToSocialEventsForTesting('social-1');
      await tester.pump();
      repo.events.add(
        const SocialImportSSEEvent(
          type: 'error',
          data: {'message': 'Connection failed after 3 attempts'},
        ),
      );
      await repo.events.close();
      await tester.pump(const Duration(seconds: 2));

      expect(repo.getStatusCalls, greaterThan(1));
      expect(read(h.container).socialConnected, isFalse);

      await runClock(tester);
      expect(
        read(h.container).socialJob?.status,
        SocialImportJobStatus.completed,
      );
    });

    test('an older status response never overwrites a newer one', () async {
      final slow = Completer<SocialImportJobData>();
      var calls = 0;
      final repo = FakeSocialImportRepository()
        ..onGetStatus = (id) {
          calls++;
          return calls == 1
              ? slow.future
              : Future.value(socialJob(id, SocialImportJobStatus.completed));
        };
      final h = host(social: repo);
      h.notifier.debugSetState(const BatchState(socialJobId: 'social-1'));

      final first = h.notifier.refreshSocialStatus();
      await h.notifier.refreshSocialStatus();
      slow.complete(socialJob('social-1', SocialImportJobStatus.processing));
      await first;

      expect(
        read(h.container).socialJob?.status,
        SocialImportJobStatus.completed,
      );
    });

    test('the password is held only until the 2FA code is sent', () async {
      final repo = FakeSocialImportRepository();
      var needOtp = true;
      repo.onScraperLogin = () async {
        if (needOtp) throw Exception('two_factor_required');
      };
      final h = host(social: repo);
      h.notifier.debugSetState(const BatchState(socialJobId: 'social-1'));

      await h.notifier.submitSocialScraperAuth(
        username: 'me',
        password: 'secret',
      );
      expect(read(h.container).waitingForOtp, isTrue);
      expect(h.notifier.debugHoldsCredentials, isTrue);

      needOtp = false;
      await h.notifier.submitSocialOtp('123456');
      expect(h.notifier.debugHoldsCredentials, isFalse);
      expect(read(h.container).waitingForOtp, isFalse);
    });

    test(
      'a failed sign-in without 2FA keeps no password and shows no raw error',
      () async {
        final repo = FakeSocialImportRepository()
          ..onScraperLogin = () async => throw Exception('Invalid credentials');
        final h = host(social: repo);
        h.notifier.debugSetState(const BatchState(socialJobId: 'social-1'));

        await h.notifier.submitSocialScraperAuth(
          username: 'me',
          password: 'secret',
        );

        expect(h.notifier.debugHoldsCredentials, isFalse);
        expect(read(h.container).socialError, 'Invalid credentials');
      },
    );
  });

  group('Sentry capture guard', () {
    test('captureToSentry is a no-op while Sentry is not initialised', () {
      expect(Sentry.isEnabled, isFalse);
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
      expect(offenders, isEmpty);
    });
  });

  group('BatchExtractionNotifier.saveSelectedItems image strategy', () {
    Future<List<ItemModel>> save(
      FakeItemRepository repo,
      List<BatchExtractedItem> items, {
      List<BatchImage> images = const [],
    }) {
      final h = host(items: repo);
      h.notifier.debugSetState(BatchState(items: items, images: images));
      return h.notifier.saveSelectedItems();
    }

    test('saves a URL-only generated image via uploadImageFromUrl', () async {
      final repo = FakeItemRepository();
      final saved = await save(repo, [
        generatedItem(
          generatedImageUrl: 'https://cdn.example.com/generated/1.png',
        ),
      ]);
      expect(repo.urlUploads, ['https://cdn.example.com/generated/1.png']);
      expect(repo.base64Uploads, isEmpty);
      expect(repo.fileUploads, isEmpty);
      expect(saved, hasLength(1));
    });

    test('saves a data-URI image via uploadImageFromBase64', () async {
      final repo = FakeItemRepository();
      final saved = await save(repo, [
        generatedItem(generatedImageUrl: 'data:image/png;base64,QUJD'),
      ]);
      expect(repo.base64Uploads, ['QUJD']);
      expect(repo.urlUploads, isEmpty);
      expect(repo.fileUploads, isEmpty);
      expect(saved, hasLength(1));
    });

    test('saves an in-memory base64 image via uploadImageFromBase64', () async {
      final repo = FakeItemRepository();
      final saved = await save(repo, [
        generatedItem(generatedImageBase64: 'QUJD'),
      ]);
      expect(repo.base64Uploads, ['QUJD']);
      expect(repo.urlUploads, isEmpty);
      expect(repo.fileUploads, isEmpty);
      expect(saved, hasLength(1));
    });

    test('falls back to the source photo when the URL upload fails', () async {
      final repo = FakeItemRepository()..onUploadFromUrl = (_, _) async => null;
      final saved = await save(
        repo,
        [
          generatedItem(
            generatedImageUrl: 'https://cdn.example.com/generated/1.png',
          ),
        ],
        images: const [
          BatchImage(id: 'img-src-1', filePath: '/tmp/source_photo.jpg'),
        ],
      );
      expect(repo.urlUploads, ['https://cdn.example.com/generated/1.png']);
      expect(repo.fileUploads, [
        ['/tmp/source_photo.jpg'],
      ]);
      expect(saved, hasLength(1));
    });

    test('falls back to the URL when the base64 upload fails', () async {
      final repo = FakeItemRepository()..onUploadBase64 = (_, _) async => null;
      final saved = await save(repo, [
        generatedItem(
          generatedImageBase64: 'QUJD',
          generatedImageUrl: 'https://cdn.example.com/generated/1.png',
        ),
      ]);
      expect(repo.base64Uploads, ['QUJD']);
      expect(repo.urlUploads, ['https://cdn.example.com/generated/1.png']);
      expect(saved, hasLength(1));
    });

    test('keeps the item and refreshes it when every strategy fails', () async {
      final repo = FakeItemRepository();
      repo.onUploadBase64 = (_, _) async => null;
      repo.onUploadFromUrl = (_, _) async => null;
      repo.onUploadFiles = (_, _) async => <ItemImage>[];
      final saved = await save(repo, [
        generatedItem(
          generatedImageBase64: 'QUJD',
          generatedImageUrl: 'https://cdn.example.com/generated/1.png',
        ),
      ]);
      expect(repo.createdItemIds, hasLength(1));
      expect(saved, hasLength(1));
      expect(repo.getItemCalls, 1);
    });

    test('saving twice after a partial failure reuses the same request ids '
        '(TD-109) and does not re-create saved pieces', () async {
      final repo = FakeItemRepository();
      var failSecond = true;
      repo.onCreateItem = (request) async {
        if (failSecond && request.name == 'Second') throw Exception('lost');
        return ItemModel(
          id: 'item-${request.name}',
          userId: 'user-1',
          name: request.name,
          category: request.category,
          condition: request.condition,
        );
      };
      final h = host(items: repo);
      h.notifier.debugSetState(
        BatchState(
          items: [
            generatedItem(
              id: 't1',
              name: 'First',
              generatedImageBase64: 'QUJD',
            ),
            generatedItem(
              id: 't2',
              name: 'Second',
              generatedImageBase64: 'QUJD',
            ),
          ],
        ),
      );

      final first = await h.notifier.saveSelectedItems();
      expect(first, hasLength(1));
      expect(read(h.container).saveFailures, ['Second']);
      expect(read(h.container).items.map((i) => i.id), ['t2']);

      failSecond = false;
      final second = await h.notifier.saveSelectedItems();

      expect(second, hasLength(1));
      expect(read(h.container).saveFailures, isEmpty);
      expect(repo.createRequestIds, hasLength(3));
      expect(repo.createRequestIds[2], repo.createRequestIds[1]);
      expect(repo.createRequestIds[0], isNot(repo.createRequestIds[1]));
    });
  });
}

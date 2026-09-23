import 'dart:async';
import 'dart:io';

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/core/services/ai_consent_service.dart';
import 'package:fitcheck_ai/core/services/sse_service.dart';
import 'package:fitcheck_ai/features/photoshoot/models/photoshoot_models.dart';
import 'package:fitcheck_ai/features/photoshoot/providers/photoshoot_provider.dart';
import 'package:fitcheck_ai/features/photoshoot/repositories/photoshoot_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAiConsentService extends AiConsentService {
  @override
  Future<bool> ensureConsent({required String featureLabel}) async => true;
}

class FakePhotoshootRepository extends PhotoshootRepository {
  final events = StreamController<ServerSentEvent>.broadcast();

  PhotoshootJobResponse jobResponse = const PhotoshootJobResponse(
    jobId: 'job-1',
    status: 'pending',
  );
  Object? startError;
  Object? cancelError;
  Object? usageError;
  PhotoshootJobStatusResponse? statusToReturn;

  /// Holds status fetches in flight so races are deterministic.
  Completer<void>? statusGate;

  /// Job id of every status fetch.
  final statusCalls = <String>[];

  @override
  Future<PhotoshootUsage> getUsage() async {
    if (usageError != null) throw usageError!;
    return const PhotoshootUsage(remaining: 10);
  }

  @override
  Future<PhotoshootJobResponse> startGeneration({
    required List<String> photos,
    required PhotoshootUseCase useCase,
    String? customPrompt,
    int numImages = 10,
    int batchSize = 10,
    PhotoshootAspectRatio aspectRatio = PhotoshootAspectRatio.square,
  }) async {
    if (startError != null) throw startError!;
    return jobResponse;
  }

  @override
  Stream<ServerSentEvent> subscribeToEvents(String jobId) => events.stream;

  @override
  Future<void> cancelJob(String jobId) async {
    if (cancelError != null) throw cancelError!;
  }

  @override
  Future<PhotoshootJobStatusResponse> getJobStatus(String jobId) async {
    statusCalls.add(jobId);
    final gate = statusGate;
    if (gate != null) await gate.future;
    return statusToReturn!;
  }
}

const _twoImages = [
  GeneratedImage(id: 'img_1', index: 0, imageUrl: 'https://cdn.example/1.png'),
  GeneratedImage(id: 'img_2', index: 1, imageUrl: 'https://cdn.example/2.png'),
];

ServerSentEvent _jobComplete(String jobId) => ServerSentEvent(
  type: 'job_complete',
  data: {
    'job_id': jobId,
    'session_id': 'ps_1',
    'generated_count': 2,
    'failed_count': 0,
    'failed_indices': <int>[],
    'partial_success': false,
  },
);

Future<void> _settle([int ms = 50]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePhotoshootRepository repo;
  late ProviderContainer container;
  late File photo;

  setUp(() async {
    PhotoshootNotifier.pollInterval = const Duration(milliseconds: 20);
    final dir = await Directory.systemTemp.createTemp('photoshoot_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    photo = File('${dir.path}/photo.jpg')
      ..writeAsBytesSync(const [0xFF, 0xD8, 0xFF, 0xE0]);

    repo = FakePhotoshootRepository();
    container = ProviderContainer(
      retry: noRetry,
      overrides: [
        aiConsentServiceProvider.overrideWithValue(FakeAiConsentService()),
        photoshootRepositoryProvider.overrideWithValue(repo),
      ],
    );
    // The tab keeps the autoDispose state alive by watching it.
    container.listen(photoshootProvider, (_, _) {});
    await _settle(10);
  });

  tearDown(() {
    container.dispose();
  });

  PhotoshootNotifier notifier() => container.read(photoshootProvider.notifier);
  PhotoshootState state() => container.read(photoshootProvider);

  Future<void> startJob({int numImages = 2}) async {
    notifier()
      ..addPhotos([photo])
      ..setNumImages(numImages);
    expect(await notifier().generate(), PhotoshootStart.started);
  }

  test('job_complete fills the gallery from the job status', () async {
    await startJob();
    repo.events.add(
      const ServerSentEvent(
        type: 'image_complete',
        data: {
          'id': 'img_1',
          'index': 0,
          'image_url': 'https://cdn.example/1.png',
          'total_count': 2,
        },
      ),
    );
    await _settle();
    expect(state().images, hasLength(1));
    expect(state().progress, 55);

    repo.statusToReturn = const PhotoshootJobStatusResponse(
      jobId: 'job-1',
      status: 'complete',
      generatedCount: 2,
      totalCount: 2,
      images: _twoImages,
    );
    repo.events.add(_jobComplete('job-1'));
    await _settle(150);

    expect(state().step, PhotoshootStep.results);
    expect(state().images, hasLength(2));
    expect(state().sessionId, 'ps_1');
  });

  test('a second completion signal after job_complete is ignored', () async {
    await startJob();
    repo.statusToReturn = const PhotoshootJobStatusResponse(
      jobId: 'job-1',
      status: 'complete',
      generatedCount: 2,
      totalCount: 2,
      images: _twoImages,
    );
    repo.statusGate = Completer<void>();

    // SSE error -> the poll fallback starts a status fetch (call 1).
    repo.events.add(const ServerSentEvent(type: 'error'));
    await _settle(20);
    // job_complete while the poll fetch waits: the completion reconcile
    // fetches too (call 2).
    repo.events.add(_jobComplete('job-1'));
    await _settle(20);

    // Both fetches resolve 'complete'; the poll's completion re-entry must be
    // swallowed (no third fetch, no second snackbar or analytics event).
    repo.statusGate!.complete();
    repo.statusGate = null;
    await _settle(150);

    expect(state().step, PhotoshootStep.results);
    expect(state().images, hasLength(2));
    expect(repo.statusCalls, hasLength(2));
  });

  test('a stale job poll stops after the job id changes', () async {
    await startJob();
    repo.statusToReturn = const PhotoshootJobStatusResponse(
      jobId: 'job-1',
      status: 'processing',
      generatedCount: 1,
      totalCount: 2,
      images: [
        GeneratedImage(id: 'old', index: 0, imageUrl: 'https://cdn/old.png'),
      ],
    );
    repo.statusGate = Completer<void>();
    repo.events.add(const ServerSentEvent(type: 'error'));
    await _settle(20);
    expect(repo.statusCalls, ['job-1']);

    // Cancel, then start again while job-1's poll fetch is still in flight.
    expect(await notifier().cancel(), isTrue);
    repo.jobResponse = const PhotoshootJobResponse(
      jobId: 'job-2',
      status: 'pending',
    );
    expect(await notifier().generate(), PhotoshootStart.started);
    expect(state().jobId, 'job-2');

    repo.statusGate!.complete();
    repo.statusGate = null;
    await _settle(150);

    // job-1's images never reach job-2, and job-1 is never polled again.
    expect(state().images, isEmpty);
    expect(state().isGenerating, isTrue);
    expect(repo.statusCalls, ['job-1']);
  });

  test('a failed cancel keeps the running job on screen', () async {
    await startJob();
    repo.cancelError = const ServerException(message: 'boom', statusCode: 500);

    expect(await notifier().cancel(), isFalse);

    expect(state().step, PhotoshootStep.generating);
    expect(state().jobId, 'job-1');
    expect(state().cancelling, isFalse);
    // The job still reports progress.
    repo.events.add(
      const ServerSentEvent(
        type: 'image_complete',
        data: {'id': 'a', 'index': 0, 'image_url': 'https://cdn/a.png'},
      ),
    );
    await _settle();
    expect(state().images, hasLength(1));
  });

  test('a 429 plan limit asks for the referral dialog', () async {
    repo.startError = RateLimitException.defaultError();
    notifier().addPhotos([photo]);

    expect(await notifier().generate(), PhotoshootStart.limitReached);
    expect(state().step, PhotoshootStep.configure);
    expect(state().error, isNull);
  });

  test('server busy is an error, not a limit', () async {
    repo.startError = const RateLimitException(
      message: 'Busy',
      errorCode: 'SERVER_BUSY',
    );
    notifier().addPhotos([photo]);

    expect(await notifier().generate(), PhotoshootStart.notStarted);
    expect(state().step, PhotoshootStep.configure);
    expect(state().error, isA<RateLimitException>());
  });

  test('a failed usage fetch does not block generation', () async {
    repo.usageError = const NetworkException(message: 'offline');
    await notifier().fetchUsage();

    expect(state().usage, isNull);
    expect(state().usageError, isNotNull);
    expect(state().remainingToday, PhotoshootNotifier.maxImages);
  });
}

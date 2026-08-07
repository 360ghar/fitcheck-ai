import 'dart:async';
import 'dart:io';

import 'package:fitcheck_ai/core/services/ai_consent_service.dart';
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/core/services/sse_service.dart';
import 'package:fitcheck_ai/features/photoshoot/controllers/photoshoot_controller.dart';
import 'package:fitcheck_ai/features/photoshoot/models/photoshoot_models.dart';
import 'package:fitcheck_ai/features/photoshoot/repositories/photoshoot_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// In-memory persistence stub so the real [AiConsentService.onInit] consent
/// cache load has a backing store instead of a failed `Get.find`.
class FakePersistenceService extends PersistenceService {
  @override
  Future<bool?> getBool(String key) async => false;
}

class FakeAiConsentService extends AiConsentService {
  @override
  Future<bool> ensureConsent({required String featureLabel}) async => true;
}

class FakePhotoshootRepository extends PhotoshootRepository {
  final StreamController<ServerSentEvent> events =
      StreamController<ServerSentEvent>.broadcast();

  PhotoshootJobResponse jobResponse = const PhotoshootJobResponse(
    jobId: 'job-1',
    status: 'pending',
    message: 'ok',
  );
  PhotoshootJobStatusResponse? statusToReturn;

  /// When set, [getJobStatus] waits on it before returning, so tests can hold
  /// status fetches in flight to exercise completion races deterministically.
  Completer<void>? statusGate;

  /// Number of [getJobStatus] calls. The completion reconcile and each poll
  /// tick each fetch once, so a duplicate completion run shows up as an extra
  /// fetch.
  int getJobStatusCalls = 0;

  @override
  Future<PhotoshootJobResponse> startGeneration({
    required List<String> photos,
    required PhotoshootUseCase useCase,
    String? customPrompt,
    int numImages = 10,
    int batchSize = 10,
    PhotoshootAspectRatio aspectRatio = PhotoshootAspectRatio.square,
  }) async =>
      jobResponse;

  @override
  Stream<ServerSentEvent> subscribeToEvents(String jobId) => events.stream;

  @override
  Future<PhotoshootJobStatusResponse> getJobStatus(String jobId) async {
    getJobStatusCalls++;
    final gate = statusGate;
    if (gate != null) await gate.future;
    return statusToReturn ?? super.getJobStatus(jobId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
  });

  testWidgets('job_complete reconciles gallery from status', (tester) async {
    Get.put<PersistenceService>(FakePersistenceService());
    Get.put<AiConsentService>(FakeAiConsentService());
    final repo = FakePhotoshootRepository();
    final controller = PhotoshootController(repository: repo);

    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: SizedBox())),
    );
    await tester.pump();

    late File photoFile;
    await tester.runAsync(() async {
      final tmpDir = await Directory.systemTemp.createTemp('photoshoot_test');
      addTearDown(() => tmpDir.deleteSync(recursive: true));
      photoFile = File('${tmpDir.path}/photo.jpg');
      await photoFile.writeAsBytes(const [0xFF, 0xD8, 0xFF, 0xE0]);
    });
    controller.selectedPhotos.add(photoFile);
    controller.numImages.value = 2;

    await tester.runAsync(() async {
      await controller.generatePhotoshoot();
      repo.events.add(ServerSentEvent(
        type: 'image_complete',
        data: {
          'id': 'img_1',
          'index': 0,
          'image_base64': 'cGF5bG9hZA==',
          'image_url': 'https://cdn.example/1.png',
          'generated_count': 1,
          'total_count': 2,
        },
      ));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      repo.statusToReturn = const PhotoshootJobStatusResponse(
        jobId: 'job-1',
        status: 'complete',
        generatedCount: 2,
        failedCount: 0,
        failedIndices: [],
        totalCount: 2,
        images: [
          GeneratedImage(
              id: 'img_1', index: 0, imageUrl: 'https://cdn.example/1.png'),
          GeneratedImage(
              id: 'img_2', index: 1, imageUrl: 'https://cdn.example/2.png'),
        ],
        usage: null,
      );
      repo.events.add(ServerSentEvent(
        type: 'job_complete',
        data: {
          'job_id': 'job-1',
          'session_id': 'ps_1',
          'generated_count': 2,
          'failed_count': 0,
          'failed_indices': <int>[],
          'partial_success': false,
          'usage': null,
          'timestamp': '2026-08-05T00:00:00Z',
        },
      ));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(controller.jobId.value, 'job-1');
      expect(controller.currentStep.value, PhotoshootStep.results);
      expect(controller.generatedImages.length, 2);
    });

    // The success snackbar shown by _handleJobComplete runs in the real zone
    // (SSE listener zone), so its animation ticker never advanced under pump.
    // Close it and flush timers/animations before the widget tree finalizes,
    // otherwise the overlay is disposed with an active ticker and the test
    // fails at teardown. Same pattern as wardrobe_controller_test.dart.
    Get.closeAllSnackbars();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('second completion signal after job_complete is ignored',
      (tester) async {
    Get.put<PersistenceService>(FakePersistenceService());
    Get.put<AiConsentService>(FakeAiConsentService());
    final repo = FakePhotoshootRepository();
    final controller = PhotoshootController(repository: repo);

    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: SizedBox())),
    );
    await tester.pump();

    late File photoFile;
    await tester.runAsync(() async {
      final tmpDir = await Directory.systemTemp.createTemp('photoshoot_test');
      addTearDown(() => tmpDir.deleteSync(recursive: true));
      photoFile = File('${tmpDir.path}/photo.jpg');
      await photoFile.writeAsBytes(const [0xFF, 0xD8, 0xFF, 0xE0]);
    });
    controller.selectedPhotos.add(photoFile);
    controller.numImages.value = 2;

    await tester.runAsync(() async {
      await controller.generatePhotoshoot();

      // The job is already complete from the status endpoint's perspective.
      repo.statusToReturn = const PhotoshootJobStatusResponse(
        jobId: 'job-1',
        status: 'complete',
        generatedCount: 2,
        failedCount: 0,
        failedIndices: [],
        totalCount: 2,
        images: [
          GeneratedImage(
              id: 'img_1', index: 0, imageUrl: 'https://cdn.example/1.png'),
          GeneratedImage(
              id: 'img_2', index: 1, imageUrl: 'https://cdn.example/2.png'),
        ],
        usage: null,
      );
      // Hold every status fetch in flight so the race is deterministic.
      repo.statusGate = Completer<void>();

      // SSE connection error -> poll fallback starts a status fetch (call 1).
      repo.events.add(const ServerSentEvent(type: 'error', data: null));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // The job completes over SSE while that poll fetch is still in flight:
      // the completion reconcile fetches again (call 2) and both wait on the
      // gate. The terminal job_complete also closes the stream -> onDone ->
      // _startPollFallback, which the completion guard must make a no-op.
      repo.events.add(const ServerSentEvent(
        type: 'job_complete',
        data: {
          'job_id': 'job-1',
          'session_id': 'ps_1',
          'generated_count': 2,
          'failed_count': 0,
          'failed_indices': <int>[],
          'partial_success': false,
          'usage': null,
          'timestamp': '2026-08-05T00:00:00Z',
        },
      ));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Release both in-flight fetches. The poll now resolves 'complete' and
      // re-enters _handleJobComplete - the completion guard must swallow it
      // (no third status fetch, no second snackbar/analytics pass).
      repo.statusGate!.complete();
      repo.statusGate = null;
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(controller.currentStep.value, PhotoshootStep.results);
      expect(controller.isGenerating.value, isFalse);
      expect(controller.generatedImages.length, 2);
      // Exactly 2 status fetches: one for the completion reconcile and one for
      // the poll's own status check. A second _handleJobComplete run would
      // have reconciled again (a third fetch) and duplicated the analytics
      // event and the success snackbar.
      expect(repo.getJobStatusCalls, 2);
    });

    Get.closeAllSnackbars();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}

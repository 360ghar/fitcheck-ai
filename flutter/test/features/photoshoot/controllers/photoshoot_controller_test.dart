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
  Future<PhotoshootJobStatusResponse> getJobStatus(String jobId) async =>
      statusToReturn ?? super.getJobStatus(jobId);
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
}

import 'dart:async';
import 'dart:io';

import 'package:fitcheck_ai/core/utils/error_handler.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/batch_extraction_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/batch_extraction_models.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/batch_extraction_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// A fake [BatchExtractionRepository] whose status endpoint is driven by a
/// callback, so tests can simulate a permanently unreachable backend without
/// any network involvement.
class FakeBatchExtractionRepository extends BatchExtractionRepository {
  int getJobStatusCalls = 0;
  Future<BatchJobStatusResponse> Function(String jobId)? onGetJobStatus;

  @override
  Future<BatchJobStatusResponse> getJobStatus(String jobId) {
    getJobStatusCalls++;
    final handler = onGetJobStatus;
    if (handler != null) return handler(jobId);
    return Future.value(
      BatchJobStatusResponse(jobId: jobId, status: 'extracting', totalImages: 1),
    );
  }
}

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
    testWidgets('gives up after maxPollAttempts and surfaces the failure',
        (tester) async {
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
      expect(repo.getJobStatusCalls,
          BatchExtractionController.maxPollAttempts,
          reason: 'transient failures must be retried, up to the cap');
      expect(controller.error.value, isNotEmpty,
          reason: 'user must see an error, not a frozen progress bar');
      expect(controller.isFailed, isTrue,
          reason: 'job must transition out of the processing state');

      controller.onClose();
    });

    testWidgets('caps a job that never reaches a terminal status',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      // Backend is reachable but the job is wedged in "extracting" forever.
      final repo = FakeBatchExtractionRepository();

      final controller = BatchExtractionController(batchRepository: repo)
        ..jobId.value = 'job-1';
      unawaited(controller.pollJobStatus('job-1'));
      await runClock(tester);

      expect(repo.getJobStatusCalls,
          BatchExtractionController.maxPollAttempts,
          reason: 'pre-fix this recursed once per clock tick forever '
              '(201 calls for this clock budget)');
      expect(controller.error.value, isNotEmpty);
      expect(controller.isFailed, isTrue);

      controller.onClose();
    });

    testWidgets('abandons the chain when the user starts a different job',
        (tester) async {
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

      expect(repo.getJobStatusCalls, callsBeforeReset,
          reason: 'a stale chain must not keep polling (or keep writing '
              'progress) for an abandoned job');
      expect(controller.error.value, isEmpty);
      expect(controller.isIdle, isTrue);

      controller.onClose();
    });

    testWidgets('a second call while polling does not start a second chain',
        (tester) async {
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
      expect(repo.getJobStatusCalls,
          BatchExtractionController.maxPollAttempts);

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

    testWidgets('recovers from a transient failure without erroring out',
        (tester) async {
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
      expect(controller.error.value, isEmpty,
          reason: 'one blip must be retried, not reported to the user');

      controller.onClose();
    });
  });

  group('Sentry capture guard', () {
    test('captureToSentry is a no-op while Sentry is not initialised', () {
      expect(Sentry.isEnabled, isFalse);
      // Must not throw even though SentryFlutter.init never ran.
      ErrorHandler.captureToSentry(Exception('boom'), stackTrace: StackTrace.current);
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
        reason: 'Sentry.captureException/captureMessage must go through '
            'ErrorHandler.captureToSentry, which guards on Sentry.isEnabled. '
            'Unguarded call sites found in: $offenders',
      );
    });
  });
}

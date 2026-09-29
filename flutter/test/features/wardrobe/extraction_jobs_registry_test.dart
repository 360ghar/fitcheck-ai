import 'dart:async';

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/features/wardrobe/models/batch_extraction_models.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/batch_extraction_provider.dart'
    show batchExtractionRepositoryProvider;
import 'package:fitcheck_ai/features/wardrobe/providers/extraction_jobs_provider.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/batch_extraction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryPersistence extends PersistenceService {
  final Map<String, String> _store = {};

  @override
  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<String?> getString(String key) async => _store[key];
}

class _FakeBatchRepo extends BatchExtractionRepository {
  int subscribes = 0;
  Object? statusError;
  Object? cancelError;
  final List<StreamController<SSEEvent>> streams = [];

  @override
  Stream<SSEEvent> subscribeToEvents(String jobId) {
    subscribes++;
    final controller = StreamController<SSEEvent>();
    streams.add(controller);
    return controller.stream;
  }

  @override
  Future<BatchJobStatusResponse> getJobStatus(String jobId) async {
    final error = statusError;
    if (error != null) throw error;
    return BatchJobStatusResponse(
      jobId: jobId,
      status: 'extracting',
      totalImages: 1,
    );
  }

  @override
  Future<void> cancelJob(String jobId) async {
    final error = cancelError;
    if (error != null) throw error;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ({
    ProviderContainer container,
    ExtractionJobsNotifier jobs,
    _FakeBatchRepo repo,
  })
  host() {
    final repo = _FakeBatchRepo();
    final container = ProviderContainer(
      overrides: [
        batchExtractionRepositoryProvider.overrideWithValue(repo),
        extractionJobsPersistenceProvider.overrideWithValue(
          _MemoryPersistence(),
        ),
        extractionJobsDocsDirProvider.overrideWithValue(
          () async => throw StateError('no documents directory in unit tests'),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(extractionJobsProvider, (_, _) {});
    return (
      container: container,
      jobs: container.read(extractionJobsProvider.notifier),
      repo: repo,
    );
  }

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  test('a stream that closes while the job runs is resubscribed', () async {
    final h = host();
    await h.jobs.trackBatch(
      jobId: 'j1',
      label: '1 photo',
      sourcePaths: const [],
    );
    expect(h.repo.subscribes, 1);

    await h.repo.streams.first.close();
    await settle();

    expect(h.repo.subscribes, 2, reason: 'recovery must open a new stream');
  });

  test('pages attached before a drop keep receiving events after it', () async {
    final h = host();
    await h.jobs.trackBatch(
      jobId: 'j1',
      label: '1 photo',
      sourcePaths: const [],
    );
    final received = <String>[];
    var closed = false;
    h.jobs
        .events('j1')!
        .listen((e) => received.add(e.type), onDone: () => closed = true);

    await h.repo.streams.first.close();
    await settle();
    h.repo.streams.last.add(const SSEEvent(type: 'generation_started'));
    await settle();

    expect(closed, isFalse, reason: 'the page-facing broadcast stays open');
    expect(received, ['generation_started']);
  });

  test('resubscribing stops after the cap', () async {
    final h = host();
    await h.jobs.trackBatch(
      jobId: 'j1',
      label: '1 photo',
      sourcePaths: const [],
    );

    for (var i = 0; i < 6; i++) {
      await h.repo.streams.last.close();
      await settle();
    }

    expect(h.repo.subscribes, 4, reason: '1 initial + 3 recoveries');
  });

  test(
    'a failed server cancel still ends the job locally and rethrows',
    () async {
      final h = host();
      h.repo.cancelError = Exception('offline');
      await h.jobs.trackBatch(
        jobId: 'j1',
        label: '1 photo',
        sourcePaths: const [],
      );

      await expectLater(h.jobs.cancel('j1'), throwsException);

      final job = h.container.read(extractionJobsProvider).job('j1')!;
      expect(job.status, TrackedJobStatus.cancelled);
      expect(job.isActive, isFalse);
    },
  );

  test(
    'a job the server no longer knows ends instead of running forever',
    () async {
      final h = host();
      await h.jobs.trackBatch(
        jobId: 'j1',
        label: '1 photo',
        sourcePaths: const [],
      );
      h.repo.statusError = NotFoundException(message: 'gone');

      final terminal = await h.jobs.refreshStatus('j1');

      expect(terminal, isTrue);
      final job = h.container.read(extractionJobsProvider).job('j1')!;
      expect(job.status, TrackedJobStatus.failed);
      expect(job.error, 'This scan expired.');
    },
  );

  test('an unreachable server leaves the job running', () async {
    final h = host();
    await h.jobs.trackBatch(
      jobId: 'j1',
      label: '1 photo',
      sourcePaths: const [],
    );
    h.repo.statusError = Exception('offline');

    expect(await h.jobs.refreshStatus('j1'), isFalse);
    expect(
      h.container.read(extractionJobsProvider).job('j1')!.isActive,
      isTrue,
    );
  });
}

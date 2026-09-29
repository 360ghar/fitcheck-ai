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

  /// Runs on every write, before the value is stored.
  void Function()? onSet;

  @override
  Future<bool> setString(String key, String value) async {
    onSet?.call();
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
    _MemoryPersistence persistence,
  })
  host() {
    final repo = _FakeBatchRepo();
    final persistence = _MemoryPersistence();
    final container = ProviderContainer(
      overrides: [
        batchExtractionRepositoryProvider.overrideWithValue(repo),
        extractionJobsPersistenceProvider.overrideWithValue(persistence),
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
      persistence: persistence,
    );
  }

  /// Short pause for the negative case ("nothing more happens").
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  /// Bounded poll (100 x 10 ms): waits for [cond] without a fixed sleep.
  Future<void> until(bool Function() cond) async {
    for (var i = 0; i < 100 && !cond(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test('a stream that closes while the job runs is resubscribed', () async {
    final h = host();
    await h.jobs.trackBatch(
      jobId: 'j1',
      label: '1 photo',
      sourcePaths: const [],
    );
    expect(h.repo.subscribes, 1);

    await h.repo.streams.first.close();
    await until(() => h.repo.subscribes == 2);

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
    await until(() => h.repo.subscribes == 2);
    h.repo.streams.last.add(const SSEEvent(type: 'generation_started'));
    await until(() => received.isNotEmpty);

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
      // Recoveries 1-3 resubscribe; later closes must change nothing.
      if (i < 3) {
        await until(() => h.repo.subscribes == i + 2);
      } else {
        await settle();
      }
    }

    expect(h.repo.subscribes, 4, reason: '1 initial + 3 recoveries');
  });

  test('an event right after trackBatch returns reaches a page', () async {
    final h = host();
    var subscribesWhilePersisting = -1;
    h.persistence.onSet = () {
      // First write only: later events persist too, after subscribing.
      if (subscribesWhilePersisting == -1) {
        subscribesWhilePersisting = h.repo.subscribes;
      }
    };

    await h.jobs.trackBatch(
      jobId: 'j1',
      label: '1 photo',
      sourcePaths: const [],
    );
    final received = <String>[];
    h.jobs.events('j1')!.listen((e) => received.add(e.type));
    h.repo.streams.last.add(const SSEEvent(type: 'generation_started'));
    await until(() => received.isNotEmpty);

    expect(
      subscribesWhilePersisting,
      0,
      reason: 'persist must finish before subscribing (nothing awaited after)',
    );
    expect(received, ['generation_started']);
  });

  test('events() is null once the job is terminal', () async {
    final h = host();
    await h.jobs.trackBatch(
      jobId: 'j1',
      label: '1 photo',
      sourcePaths: const [],
    );
    expect(h.jobs.events('j1'), isNotNull);

    h.repo.streams.last.add(const SSEEvent(type: 'job_cancelled'));
    await until(() => !h.container.read(extractionJobsProvider).isActive('j1'));

    expect(h.jobs.events('j1'), isNull);
    expect(h.jobs.events('unknown'), isNull);
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

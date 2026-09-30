import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show max;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState, WidgetsBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/exceptions/app_exceptions.dart' show NotFoundException;
import '../../../core/services/job_notifications.dart';
import '../../../core/services/persistence_service.dart';
import '../models/batch_extraction_models.dart';
import 'batch_extraction_provider.dart' show batchExtractionRepositoryProvider;
import 'wardrobe_providers.dart' show itemRepositoryProvider;

/// Persistence of the tracked extraction jobs (same pattern as the social
/// import job: a JSON blob under one key).
final extractionJobsPersistenceProvider = Provider<PersistenceService>(
  (ref) => PersistenceService.instance,
);

/// Where durable photo copies live. Overridden in tests: an unmocked
/// path_provider channel never answers under the test binding.
final extractionJobsDocsDirProvider = Provider<Future<Directory> Function()>(
  (ref) => getApplicationDocumentsDirectory,
);

/// Single-photo scan vs multi-photo batch.
enum TrackedJobKind { single, batch }

/// Lifecycle of a tracked job. `running` covers uploading, extracting and
/// generating — the banner and jobs list show counts, not phases.
enum TrackedJobStatus { running, complete, failed, cancelled }

/// One extraction job owned by the registry instead of a page. Survives
/// navigation (pages attach/detach) and app kills (persisted + restored).
@immutable
class TrackedJob {
  const TrackedJob({
    required this.jobId,
    required this.kind,
    required this.label,
    required this.sourcePaths,
    this.sourceIds = const [],
    required this.createdAt,
    this.status = TrackedJobStatus.running,
    this.extracted = 0,
    this.generated = 0,
    this.total = 0,
    this.error = '',
    this.notified = false,
  });

  final String jobId;
  final TrackedJobKind kind;

  /// Human label: 'Scan' for single, '12 photos' for batch.
  final String label;

  /// Durable copies under the app documents dir (image_picker cache paths
  /// may be purged while the job runs).
  final List<String> sourcePaths;

  /// Client image ids parallel to [sourcePaths] (batch only): the status
  /// endpoint keys extracted pieces to photos by this id, so resume can
  /// rebuild the per-photo cards. Empty for single-photo jobs.
  final List<String> sourceIds;
  final DateTime createdAt;
  final TrackedJobStatus status;
  final int extracted;
  final int generated;
  final int total;
  final String error;

  /// A terminal notification was already shown for this job.
  final bool notified;

  bool get isActive => status == TrackedJobStatus.running;
  bool get isComplete => status == TrackedJobStatus.complete;

  /// Fraction done, 0 to 1, in two equal halves: photos read (`extracted`
  /// of the picked photos) and studio photos made (`generated` of the pieces
  /// found so far). The counters are different units, so they never mix.
  double get progress {
    if (isComplete) return 1;
    final photos = sourcePaths.isEmpty ? 1 : sourcePaths.length;
    final read = (extracted / photos).clamp(0.0, 1.0);
    final made = total > 0 ? (generated / total).clamp(0.0, 1.0) : 0.0;
    return (read + made) / 2;
  }

  String get progressText {
    if (isComplete) return 'Ready to review';
    if (status == TrackedJobStatus.failed) {
      return error.isEmpty ? 'Stopped' : error;
    }
    if (status == TrackedJobStatus.cancelled) return 'Cancelled';
    if (generated > 0) {
      return total > 0
          ? '$generated of $total studio photos'
          : '$generated studio photos';
    }
    if (total > 0) return '$total pieces found so far';
    return 'Looking at your photos';
  }

  TrackedJob copyWith({
    TrackedJobStatus? status,
    int? extracted,
    int? generated,
    int? total,
    String? error,
    bool? notified,
  }) => TrackedJob(
    jobId: jobId,
    kind: kind,
    label: label,
    sourcePaths: sourcePaths,
    sourceIds: sourceIds,
    createdAt: createdAt,
    status: status ?? this.status,
    extracted: extracted ?? this.extracted,
    generated: generated ?? this.generated,
    total: total ?? this.total,
    error: error ?? this.error,
    notified: notified ?? this.notified,
  );

  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'kind': kind.name,
    'label': label,
    'sourcePaths': sourcePaths,
    'sourceIds': sourceIds,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'extracted': extracted,
    'generated': generated,
    'total': total,
    'error': error,
    'notified': notified,
  };

  factory TrackedJob.fromJson(Map<String, dynamic> json) => TrackedJob(
    jobId: json['jobId']?.toString() ?? '',
    kind: json['kind'] == 'batch'
        ? TrackedJobKind.batch
        : TrackedJobKind.single,
    label: json['label']?.toString() ?? '',
    sourcePaths:
        (json['sourcePaths'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    sourceIds:
        (json['sourceIds'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    createdAt:
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    status: switch (json['status']?.toString()) {
      'complete' => TrackedJobStatus.complete,
      'failed' => TrackedJobStatus.failed,
      'cancelled' => TrackedJobStatus.cancelled,
      _ => TrackedJobStatus.running,
    },
    extracted: (json['extracted'] as num?)?.toInt() ?? 0,
    generated: (json['generated'] as num?)?.toInt() ?? 0,
    total: (json['total'] as num?)?.toInt() ?? 0,
    error: json['error']?.toString() ?? '',
    notified: json['notified'] == true,
  );
}

/// Registry state: every tracked job by id, insertion-ordered.
@immutable
class ExtractionJobsState {
  const ExtractionJobsState({this.jobs = const {}});

  final Map<String, TrackedJob> jobs;

  TrackedJob? job(String jobId) => jobs[jobId];

  List<TrackedJob> get active => [
    for (final job in jobs.values)
      if (job.isActive) job,
  ];

  List<TrackedJob> get recent => [
    for (final job in jobs.values.toList().reversed) job,
  ];

  bool isActive(String jobId) => jobs[jobId]?.isActive ?? false;
}

/// App-scoped owner of extraction SSE streams. Pages attach to a job's
/// broadcast and detach when popped; the stream (and the server job) keeps
/// running. Jobs persist across app kills and restore on next launch.
final extractionJobsProvider =
    NotifierProvider<ExtractionJobsNotifier, ExtractionJobsState>(
      ExtractionJobsNotifier.new,
    );

class ExtractionJobsNotifier extends Notifier<ExtractionJobsState> {
  static const String _registryKey = 'fitcheck.extraction_jobs.registry';
  static const int _maxJobs = 20;
  static const Duration _recentTtl = Duration(days: 7);

  final Map<String, StreamSubscription<SSEEvent>> _subscriptions = {};
  final Map<String, StreamController<SSEEvent>> _controllers = {};

  /// Consecutive stream recoveries per job (reset by any live event): bounds
  /// resubscribe loops when the server is down; snapshots cover the rest.
  final Map<String, int> _resubscribes = {};
  static const int _maxResubscribes = 3;

  /// Pages with a job open. A terminal transition notifies the shade unless a
  /// page is open AND the app is in the foreground.
  final Map<String, int> _attachCounts = {};

  @override
  ExtractionJobsState build() {
    ref.onDispose(() {
      for (final sub in _subscriptions.values) {
        sub.cancel();
      }
      for (final controller in _controllers.values) {
        controller.close();
      }
      _subscriptions.clear();
      _controllers.clear();
      _attachCounts.clear();
    });
    unawaited(_restore());
    return const ExtractionJobsState();
  }

  bool get _alive => ref.mounted;

  bool get _appInForeground {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  @visibleForTesting
  void debugSetState(ExtractionJobsState value) => state = value;

  PersistenceService get _persistence =>
      ref.read(extractionJobsPersistenceProvider);

  // ------------------------------------------------------------------
  // Tracking
  // ------------------------------------------------------------------

  /// Takes ownership of a new single-photo job: durable photo copy,
  /// persistence, one SSE subscription fanned out to attached pages.
  Future<void> trackSingle({
    required String jobId,
    required String label,
    required String sourcePath,
  }) async {
    final durable = await _durablize(jobId, [sourcePath]);
    // The notifier can be disposed while awaiting: state and ref are unusable.
    if (!_alive) return;
    _upsert(
      TrackedJob(
        jobId: jobId,
        kind: TrackedJobKind.single,
        label: label,
        sourcePaths: durable,
        createdAt: DateTime.now(),
      ),
    );
    // Persist first: nothing may be awaited between subscribing and
    // returning, or early events fire before the caller can listen.
    await _persist();
    if (!_alive) return;
    _subscribe(jobId, TrackedJobKind.single);
  }

  /// Takes ownership of a new batch job (same contract as [trackSingle]).
  /// [imageIds] are the client's per-photo ids parallel to [sourcePaths].
  Future<void> trackBatch({
    required String jobId,
    required String label,
    required List<String> sourcePaths,
    List<String> imageIds = const [],
  }) async {
    final durable = await _durablize(jobId, sourcePaths);
    if (!_alive) return;
    _upsert(
      TrackedJob(
        jobId: jobId,
        kind: TrackedJobKind.batch,
        label: label,
        sourcePaths: durable,
        sourceIds: imageIds,
        createdAt: DateTime.now(),
      ),
    );
    await _persist();
    if (!_alive) return;
    _subscribe(jobId, TrackedJobKind.batch);
  }

  /// Copies picked photos (cache dir, purgeable) into the app documents dir
  /// so resume-after-kill always has the source images. Best-effort: a
  /// failed copy keeps the original path.
  Future<List<String>> _durablize(String jobId, List<String> paths) async {
    try {
      final docs = await ref.read(extractionJobsDocsDirProvider)();
      final dir = Directory('${docs.path}/extraction_jobs/$jobId');
      await dir.create(recursive: true);
      final durable = <String>[];
      for (var i = 0; i < paths.length; i++) {
        final path = paths[i];
        try {
          final source = File(path);
          if (!await source.exists()) {
            durable.add(path);
            continue;
          }
          // Index prefix: two photos from different folders can share a
          // basename and must not collapse onto one copy.
          final name = '$i-${path.split('/').last}';
          final target = File('${dir.path}/$name');
          if (!await target.exists()) {
            await source.copy(target.path);
          }
          durable.add(target.path);
        } catch (_) {
          durable.add(path);
        }
      }
      return durable;
    } catch (_) {
      return paths;
    }
  }

  /// Deletes a job's durable photo copies. Best-effort: a failure only
  /// leaves files the OS reclaims with the app data.
  Future<void> _deletePhotos(String jobId) async {
    try {
      final docs = await ref.read(extractionJobsDocsDirProvider)();
      final dir = Directory('${docs.path}/extraction_jobs/$jobId');
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {
      // Nothing to clean up, or storage unavailable.
    }
  }

  /// A page opens a job: suppresses the terminal shade notification while
  /// open. Must be balanced with [detach].
  void attach(String jobId) {
    _attachCounts[jobId] = (_attachCounts[jobId] ?? 0) + 1;
  }

  /// A page closes a job view. The job keeps running.
  void detach(String jobId) {
    final count = (_attachCounts[jobId] ?? 1) - 1;
    if (count <= 0) {
      _attachCounts.remove(jobId);
    } else {
      _attachCounts[jobId] = count;
    }
  }

  /// Live events for a job, fanned out to every attached page. Null when the
  /// job is unknown (e.g. pruned) or already terminal (its broadcast stays
  /// open but never emits again) — callers fall back to [refreshStatus].
  Stream<SSEEvent>? events(String jobId) {
    final job = state.job(jobId);
    if (job == null || !job.isActive) return null;
    return _controllers[jobId]?.stream;
  }

  /// Cancels the server job and marks it cancelled. Attached pages observe
  /// the broadcast close and must NOT reconcile (see [isActive]).
  Future<void> cancel(String jobId) async {
    final job = state.job(jobId);
    _subscriptions.remove(jobId)?.cancel();
    _resubscribes.remove(jobId);
    await _closeController(jobId);
    if (job == null) return;
    try {
      if (job.kind == TrackedJobKind.batch) {
        await ref.read(batchExtractionRepositoryProvider).cancelJob(jobId);
      } else {
        await ref.read(itemRepositoryProvider).cancelSingleExtraction(jobId);
      }
    } finally {
      // Local state always stops, even when the server call fails: an
      // unreachable job must still leave the active list. The error still
      // surfaces at the call site.
      if (_alive) {
        _upsert(job.copyWith(status: TrackedJobStatus.cancelled));
        await _persist();
      }
    }
  }

  /// Drops a job from the registry (stops nothing server-side; use [cancel]
  /// first for running jobs).
  Future<void> forget(String jobId) async {
    _subscriptions.remove(jobId)?.cancel();
    _resubscribes.remove(jobId);
    await _closeController(jobId);
    if (!_alive) return;
    _attachCounts.remove(jobId);
    final jobs = Map<String, TrackedJob>.from(state.jobs)..remove(jobId);
    state = ExtractionJobsState(jobs: jobs);
    await _persist();
    await _deletePhotos(jobId);
  }

  // ------------------------------------------------------------------
  // Progress snapshot (restore + resume without SSE replay)
  // ------------------------------------------------------------------

  /// Polls the status endpoint and folds the snapshot into the tracked job.
  /// Returns true when the job reached a terminal state.
  Future<bool> refreshStatus(String jobId) async {
    final job = state.job(jobId);
    if (job == null || !_alive) return false;
    try {
      if (job.kind == TrackedJobKind.batch) {
        final status = await ref
            .read(batchExtractionRepositoryProvider)
            .getJobStatus(jobId);
        if (!_alive || state.job(jobId) == null) return false;
        return _applyBatchSnapshot(job, status);
      }
      final raw = await ref
          .read(itemRepositoryProvider)
          .getSingleJobStatus(jobId);
      if (!_alive || state.job(jobId) == null) return false;
      return _applySingleSnapshot(job, raw);
    } on NotFoundException {
      // Expired or deleted server-side: nothing will ever update this job,
      // so end it (otherwise it stays running and cannot be dismissed).
      final fresh = state.job(jobId);
      if (!_alive || fresh == null || !fresh.isActive) return false;
      _markTerminal(
        fresh,
        TrackedJobStatus.failed,
        error: 'This scan expired.',
      );
      return true;
    } catch (_) {
      // Unreachable for now (offline, 5xx): leave the job running; the SSE
      // stream or the next refresh decides.
      return false;
    }
  }

  /// Best-effort terminal classification for raw single-job status payloads.
  bool _applySingleSnapshot(TrackedJob job, Map<String, dynamic> raw) {
    final status = raw['status']?.toString() ?? '';
    final items = raw['items'];
    final count = items is List ? items.length : job.total;
    switch (status) {
      case 'completed':
        _markTerminal(job, TrackedJobStatus.complete, total: count);
        return true;
      case 'failed':
        _markTerminal(
          job,
          TrackedJobStatus.failed,
          error: raw['error']?.toString() ?? 'Finding pieces failed.',
        );
        return true;
      case 'cancelled':
        _markTerminal(job, TrackedJobStatus.cancelled);
        return true;
      default:
        _upsert(job.copyWith(total: count));
        unawaited(_persist());
        return false;
    }
  }

  bool _applyBatchSnapshot(TrackedJob job, BatchJobStatusResponse status) {
    final generated = status.generatedCount;
    final total = status.detectedItems?.length ?? job.total;
    switch (status.status) {
      case 'completed':
        _markTerminal(
          job,
          TrackedJobStatus.complete,
          total: total,
          generated: generated,
        );
        return true;
      case 'failed':
        _markTerminal(
          job,
          TrackedJobStatus.failed,
          error: status.error ?? 'Finding pieces failed.',
        );
        return true;
      case 'cancelled':
        _markTerminal(job, TrackedJobStatus.cancelled);
        return true;
      default:
        _upsert(
          job.copyWith(
            extracted: status.extractedCount,
            generated: generated,
            total: total,
          ),
        );
        unawaited(_persist());
        // A restored-while-running batch has no live stream yet: resubscribe.
        if (!_subscriptions.containsKey(job.jobId) &&
            !_controllers.containsKey(job.jobId)) {
          _subscribe(job.jobId, job.kind);
        }
        return false;
    }
  }

  // ------------------------------------------------------------------
  // Event fan-out
  // ------------------------------------------------------------------

  void _subscribe(String jobId, TrackedJobKind kind) {
    _subscriptions[jobId]?.cancel();
    // A recovery resubscribes upstream but keeps the open broadcast, so pages
    // already attached to it keep receiving live events.
    final existing = _controllers[jobId];
    final StreamController<SSEEvent> controller;
    if (existing != null && !existing.isClosed) {
      controller = existing;
    } else {
      controller = StreamController<SSEEvent>.broadcast();
      _controllers[jobId] = controller;
    }
    final stream = kind == TrackedJobKind.batch
        ? ref.read(batchExtractionRepositoryProvider).subscribeToEvents(jobId)
        : ref
              .read(itemRepositoryProvider)
              .subscribeSingleExtractionEvents(jobId);
    late final StreamSubscription<SSEEvent> subscription;
    subscription = stream.listen(
      (event) {
        _resubscribes.remove(jobId);
        _onEvent(jobId, event);
        if (!_controllers.containsKey(jobId)) return;
        try {
          controller.add(event);
        } catch (_) {
          // Closed between check and add (cancel/forget race): dropped.
        }
      },
      onError: (Object e) {
        // Forward the stream failure so attached pages run their own poll
        // fallbacks (they already implement them for direct subscriptions).
        try {
          controller.add(
            SSEEvent(type: 'error', data: {'message': e.toString()}),
          );
        } catch (_) {
          // Closed between check and add (cancel/forget race): dropped.
        }
      },
      onDone: () {
        // This stream is finished: drop it so recovery can resubscribe
        // (a newer subscription for the same job is left alone).
        if (identical(_subscriptions[jobId], subscription)) {
          _subscriptions.remove(jobId);
        }
        // A clean close without a terminal event is a dropped connection,
        // not success: snapshot, then resubscribe (capped) while running.
        final job = state.job(jobId);
        if (job == null || !job.isActive) return;
        unawaited(_recoverStream(jobId, kind));
      },
    );
    _subscriptions[jobId] = subscription;
  }

  /// Snapshot-first stream recovery: a fresh status tells us whether the job
  /// is already terminal (common after a process death); otherwise one more
  /// live subscription, up to [_maxResubscribes] consecutive recoveries.
  Future<void> _recoverStream(String jobId, TrackedJobKind kind) async {
    if (!_alive) return;
    final terminal = await refreshStatus(jobId);
    if (!_alive || terminal) return;
    final job = state.job(jobId);
    if (job == null || !job.isActive) return;
    if (_subscriptions.containsKey(jobId)) return;
    final count = (_resubscribes[jobId] ?? 0) + 1;
    if (count > _maxResubscribes) return;
    _resubscribes[jobId] = count;
    _subscribe(jobId, kind);
  }

  Future<void> _closeController(String jobId) async {
    final controller = _controllers.remove(jobId);
    if (controller == null) return;
    try {
      await controller.close();
    } catch (_) {
      // Already closed by a racing cancel/forget.
    }
  }

  /// Folds one SSE event into the tracked counters. Terminal events mark the
  /// job and notify the shade when nobody is watching.
  void _onEvent(String jobId, SSEEvent event) {
    final job = state.job(jobId);
    if (job == null || !job.isActive) return;
    final data = event.data ?? const <String, dynamic>{};
    switch (event.type) {
      case 'image_extraction_complete':
        // Absolute counter, never summed: the stream replays history on
        // reconnect, and summing would double-count. `total` (pieces found)
        // only ever comes from absolute sources below.
        final completed =
            (data['completed_count'] as num?)?.toInt() ?? job.extracted + 1;
        _upsert(job.copyWith(extracted: max(job.extracted, completed)));
      case 'image_extraction_failed':
        // Per-photo failure: counts stay; the batch failedCount is folded on
        // the next status snapshot. Single-photo failure is terminal below.
        if (job.kind == TrackedJobKind.single) {
          _markTerminal(
            job,
            TrackedJobStatus.failed,
            error:
                data['error']?.toString() ??
                rawError(data) ??
                'Extraction failed',
          );
        }
      case 'all_extractions_complete':
        final detected = (data['total_items_detected'] as num?)?.toInt();
        if (detected != null && detected > job.total) {
          _upsert(job.copyWith(total: detected));
        }
      case 'generation_started':
        final total = (data['total_items'] as num?)?.toInt() ?? job.total;
        if (total > job.total) _upsert(job.copyWith(total: total));
      case 'item_generation_complete':
        final done =
            (data['completed_count'] as num?)?.toInt() ?? job.generated + 1;
        final total = (data['total_items'] as num?)?.toInt() ?? job.total;
        _upsert(
          job.copyWith(
            generated: max(job.generated, done),
            total: max(job.total, total),
          ),
        );
      case 'job_complete':
        final items = data['items'];
        _markTerminal(
          job,
          TrackedJobStatus.complete,
          total: items is List ? items.length : job.total,
        );
      case 'job_failed':
        _markTerminal(
          job,
          TrackedJobStatus.failed,
          error: data['error']?.toString() ?? rawError(data) ?? 'Job failed',
        );
      case 'job_cancelled':
        _markTerminal(job, TrackedJobStatus.cancelled);
    }
    unawaited(_persist());
  }

  /// Some failure events carry the message outside `error` (stream-level
  /// synthetic events use `message`).
  String? rawError(Map<String, dynamic> data) => data['message']?.toString();

  void _markTerminal(
    TrackedJob job,
    TrackedJobStatus status, {
    int? total,
    int? generated,
    String? error,
  }) {
    _subscriptions.remove(job.jobId)?.cancel();
    // The broadcast stays open so attached pages still receive the terminal
    // event itself; it closes on forget/cancel or the next track.
    _upsert(
      job.copyWith(
        status: status,
        total: total ?? job.total,
        generated: generated ?? job.generated,
        error: error ?? job.error,
      ),
    );
    unawaited(_persist());
    final fresh = state.job(job.jobId);
    if (fresh == null || fresh.notified) return;
    if ((_attachCounts[job.jobId] ?? 0) > 0 && _appInForeground) {
      // The user is watching: the page shows the outcome, no shade noise.
      // A page still open under a backgrounded app is not watching.
      _upsert(fresh.copyWith(notified: true));
      unawaited(_persist());
      return;
    }
    _upsert(fresh.copyWith(notified: true));
    unawaited(_persist());
    unawaited(_notifyTerminal(fresh.copyWith(status: status)));
  }

  Future<void> _notifyTerminal(TrackedJob job) async {
    final notifications = JobNotifications.instance;
    if (job.status == TrackedJobStatus.complete) {
      final count = job.total > 0 ? '${job.total} pieces' : 'pieces';
      await notifications.showJobComplete(
        jobId: job.jobId,
        title: 'Your pieces are ready',
        body: job.kind == TrackedJobKind.batch
            ? 'Review $count from ${job.label}.'
            : 'Review $count.',
      );
    } else if (job.status == TrackedJobStatus.failed) {
      await notifications.showJobFailed(
        jobId: job.jobId,
        title: 'The scan stopped',
        body: job.error.isEmpty ? 'Open the app to try again.' : job.error,
      );
    }
  }

  // ------------------------------------------------------------------
  // Persistence + restore
  // ------------------------------------------------------------------

  void _upsert(TrackedJob job) {
    final jobs = Map<String, TrackedJob>.from(state.jobs);
    jobs[job.jobId] = job;
    // Cap + TTL prune on every write: the registry is small by construction.
    final now = DateTime.now();
    final pruned = <String, TrackedJob>{};
    for (final entry in jobs.entries) {
      final j = entry.value;
      if (!j.isActive && now.difference(j.createdAt) > _recentTtl) continue;
      pruned[entry.key] = j;
    }
    while (pruned.length > _maxJobs) {
      // Drop the oldest terminal job; actives are never pruned by cap.
      final oldest = pruned.entries
          .where((e) => !e.value.isActive)
          .fold<MapEntry<String, TrackedJob>?>(null, (a, b) {
            if (a == null) return b;
            return a.value.createdAt.isBefore(b.value.createdAt) ? a : b;
          });
      if (oldest == null) break;
      pruned.remove(oldest.key);
    }
    // Pruned jobs can no longer be resumed: free their photo copies.
    for (final id in jobs.keys) {
      if (!pruned.containsKey(id)) unawaited(_deletePhotos(id));
    }
    state = ExtractionJobsState(jobs: pruned);
  }

  Future<void> _persist() async {
    if (!_alive) return;
    try {
      final payload = jsonEncode([
        for (final job in state.jobs.values) job.toJson(),
      ]);
      await _persistence.setString(_registryKey, payload);
    } catch (_) {
      // Best-effort: a failed write only loses kill-restore for this update.
    }
  }

  /// Restores persisted jobs on launch: terminal snapshots notify
  /// "finished while you were away"; running ones resubscribe.
  Future<void> _restore() async {
    List<dynamic> raw;
    try {
      final stored = await _persistence.getString(_registryKey);
      if (stored == null || stored.isEmpty || !_alive) return;
      raw = jsonDecode(stored) as List<dynamic>;
    } catch (_) {
      return;
    }
    for (final entry in raw) {
      if (!_alive) return;
      if (entry is! Map<String, dynamic>) continue;
      final job = TrackedJob.fromJson(entry);
      if (job.jobId.isEmpty) continue;
      if (!job.isActive) {
        _upsert(job);
        continue;
      }
      _upsert(job);
      final terminal = await refreshStatus(job.jobId);
      if (!_alive) return;
      final fresh = state.job(job.jobId);
      if (fresh == null) continue;
      if (terminal) {
        // Finished while dead: the _markTerminal path already ran through
        // refreshStatus; surface the away-notification exactly once.
        if (!fresh.notified) {
          _upsert(fresh.copyWith(notified: true));
          await _persist();
          await JobNotifications.instance.showFinishedWhileAway(
            jobId: fresh.jobId,
            title: fresh.isComplete
                ? 'Your pieces are ready'
                : 'The scan stopped',
            body: fresh.isComplete
                ? 'Review ${fresh.total > 0 ? '${fresh.total} pieces' : 'your pieces'}.'
                : (fresh.error.isEmpty
                      ? 'Open the app to try again.'
                      : fresh.error),
          );
        }
      } else {
        // Still running: ensure a live stream even when the snapshot came
        // from the single-job path (which never resubscribes itself).
        if (!_subscriptions.containsKey(job.jobId)) {
          _subscribe(job.jobId, job.kind);
        }
      }
    }
    await _persist();
  }
}

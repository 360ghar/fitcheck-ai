import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/request_id.dart';
import '../../../domain/constants/use_cases.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart' as domain;
import '../models/batch_extraction_models.dart';
import '../models/item_model.dart';
import 'batch_extraction_provider.dart' show aiConsentGateProvider;
import 'wardrobe_providers.dart';

/// Why a single-photo extraction stopped without results. Picks the copy and
/// the next step on the add page.
enum ItemAddFailureKind {
  connection,
  dailyLimit,
  busy,
  noItems,
  aiUnavailable,
  other,
}

@immutable
class ItemAddFailure {
  const ItemAddFailure(this.kind, this.message);

  final ItemAddFailureKind kind;
  final String message;

  /// Maps an error to a kind. Structured backend codes win; stream failures
  /// arrive as plain messages, so those are matched case-insensitively.
  factory ItemAddFailure.from(Object error) {
    final message = ErrorHandler.extractMessage(error);
    final lower = message.toLowerCase();
    final code = error is AppException ? error.errorCode : null;
    final kind =
        (code == 'RATE_LIMIT_EXCEEDED' ||
            lower.contains('rate limit') ||
            lower.contains('limit exceeded'))
        ? ItemAddFailureKind.dailyLimit
        : (code == 'SERVER_BUSY' ||
              lower.contains('capacity') ||
              lower.contains('unavailable') ||
              lower.contains('quota') ||
              lower.contains('resource_exhausted') ||
              lower.contains('high demand') ||
              lower.contains('service is busy'))
        ? ItemAddFailureKind.busy
        : (lower.contains('timeout') ||
              lower.contains('timed out') ||
              lower.contains('connection'))
        ? ItemAddFailureKind.connection
        : (lower.contains('no items') || lower.contains('not detected'))
        ? ItemAddFailureKind.noItems
        : (lower.contains('validation') ||
              lower.contains('bounding_box') ||
              lower.contains('ai service'))
        ? ItemAddFailureKind.aiUnavailable
        : ItemAddFailureKind.other;
    return ItemAddFailure(kind, message);
  }
}

/// One single-photo add session.
@immutable
class ItemAddState {
  const ItemAddState({
    this.image,
    this.processing = false,
    this.generating = false,
    this.saving = false,
    this.phase = '',
    this.progress = 0,
    this.secondsLeft = 0,
    this.statusText = '',
    this.items = const [],
    this.itemStatus = const {},
    this.generatingIndex = 0,
    this.generatingName = '',
    this.useCases = const {},
    this.manualEntry = false,
    this.failure,
    this.cached = false,
  });

  final File? image;

  /// Upload and analysis run (before the pieces are shown).
  final bool processing;

  /// Studio photos are being made before any piece was shown.
  final bool generating;
  final bool saving;

  /// upload, connected, analyzing, extracting, generating, review, complete.
  final String phase;

  /// 0 to 100.
  final double progress;
  final int secondsLeft;
  final String statusText;
  final List<DetectedItemDataWithImage> items;

  /// temp id to pending, complete or failed.
  final Map<String, String> itemStatus;
  final int generatingIndex;
  final String generatingName;
  final Set<String> useCases;
  final bool manualEntry;
  final ItemAddFailure? failure;
  final bool cached;

  int get includedCount => items.where((i) => i.includeInWardrobe).length;
  int get readyCount =>
      items.where((i) => i.generatedImageUrl?.isNotEmpty ?? false).length;

  ItemAddState copyWith({
    File? Function()? image,
    bool? processing,
    bool? generating,
    bool? saving,
    String? phase,
    double? progress,
    int? secondsLeft,
    String? statusText,
    List<DetectedItemDataWithImage>? items,
    Map<String, String>? itemStatus,
    int? generatingIndex,
    String? generatingName,
    Set<String>? useCases,
    bool? manualEntry,
    ItemAddFailure? Function()? failure,
    bool? cached,
  }) => ItemAddState(
    image: image == null ? this.image : image(),
    processing: processing ?? this.processing,
    generating: generating ?? this.generating,
    saving: saving ?? this.saving,
    phase: phase ?? this.phase,
    progress: progress ?? this.progress,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    statusText: statusText ?? this.statusText,
    items: items ?? this.items,
    itemStatus: itemStatus ?? this.itemStatus,
    generatingIndex: generatingIndex ?? this.generatingIndex,
    generatingName: generatingName ?? this.generatingName,
    useCases: useCases ?? this.useCases,
    manualEntry: manualEntry ?? this.manualEntry,
    failure: failure == null ? this.failure : failure(),
    cached: cached ?? this.cached,
  );
}

/// Result of a save pass.
typedef ItemAddSaveResult = ({List<ItemModel> saved, int failed});

/// Keyed by a per-page session id: every add page owns its own state, even
/// when two add pages are stacked.
final itemAddProvider = NotifierProvider.autoDispose
    .family<ItemAddNotifier, ItemAddState, int>(ItemAddNotifier.new);

var _nextItemAddSession = 0;

/// A fresh key for [itemAddProvider], one per add page.
int newItemAddSession() => _nextItemAddSession++;

class ItemAddNotifier extends Notifier<ItemAddState> {
  ItemAddNotifier(this.session);

  final int session;

  StreamSubscription<SSEEvent>? _sse;
  Timer? _watchdog;
  String? _jobId;
  bool _starting = false;
  bool _decoupledToReview = false;
  bool _reconciling = false;

  /// Bumped by [reset] and on dispose so an extraction start still in
  /// flight knows it was abandoned and cancels itself server-side.
  int _generation = 0;
  final Map<String, DetectedItemData> _extracted = {};

  /// Idempotency keys per detected piece (TD-109). A re-tapped Save sends
  /// the same key per piece, so the backend replays committed rows.
  final Map<String, String> _createRequestIds = {};

  /// Pieces an earlier save of this photo already added.
  final Set<String> _savedTempIds = {};

  @override
  ItemAddState build() {
    ref.onDispose(() {
      _generation++;
      _stopJob();
    });
    return const ItemAddState();
  }

  String _requestIdFor(String tempId, Object item) => _createRequestIds
      .putIfAbsent(requestIdIdentity(tempId, item), () => newRequestId('item'));

  bool _isCurrent(String jobId) => ref.mounted && jobId == _jobId;

  @visibleForTesting
  void debugSetState(ItemAddState value) => state = value;

  @visibleForTesting
  String? get debugJobId => _jobId;

  /// Starts an extraction job for [image]. Does nothing while a job is being
  /// started or is running.
  Future<void> processImage(File image) async {
    if (_starting || state.processing || state.generating) return;
    _starting = true;
    final generation = _generation;
    final repository = ref.read(itemRepositoryProvider);
    try {
      if (!await ref.read(aiConsentGateProvider)('AI Wardrobe Extraction')) {
        return;
      }
      if (!ref.mounted || generation != _generation) return;
      _stopJob();
      _extracted.clear();
      _createRequestIds.clear();
      _savedTempIds.clear();
      _decoupledToReview = false;
      state = ItemAddState(
        image: image,
        processing: true,
        phase: 'upload',
        secondsLeft: 60,
        useCases: state.useCases,
      );

      final job = await repository.extractItemsFromImageAsync(image);
      if (generation != _generation) {
        // Reset, cancelled, or disposed while the start request was in
        // flight: the job exists server-side but nobody is watching it.
        try {
          await repository.cancelSingleExtraction(job.jobId);
        } catch (_) {
          // Best effort; nothing is listening either way.
        }
        return;
      }
      if (!ref.mounted) return;
      final jobId = job.jobId;
      _jobId = jobId;
      if (job.message?.contains('cached') ?? false) {
        state = state.copyWith(
          cached: true,
          phase: 'complete',
          progress: 100,
          statusText: 'Found in an earlier scan',
        );
      }
      _sse = ref
          .read(itemRepositoryProvider)
          .subscribeSingleExtractionEvents(jobId)
          .listen(
            (event) => _onEvent(jobId, event),
            onError: (Object _) {
              if (_isCurrent(jobId) && state.phase != 'complete') {
                _reconcile(jobId);
              }
            },
            onDone: () {
              // A drop mid-job: reconcile by polling instead of stranding
              // the spinner.
              if (_shouldReconcile(jobId)) _reconcile(jobId);
            },
          );
      _armWatchdog(jobId);
    } catch (e) {
      if (ref.mounted) _fail(e);
    } finally {
      _starting = false;
    }
  }

  bool _shouldReconcile(String jobId) =>
      _isCurrent(jobId) && state.phase != 'complete' && !_reconciling;

  /// The backend heartbeats every ~30 s, so 45 s of silence means the
  /// connection is dead or hung.
  void _armWatchdog(String jobId) {
    _watchdog?.cancel();
    _watchdog = Timer(const Duration(seconds: 45), () {
      if (_shouldReconcile(jobId)) _reconcile(jobId);
    });
  }

  void _onEvent(String jobId, SSEEvent event) {
    if (!_isCurrent(jobId)) return;
    final data = event.data ?? const <String, dynamic>{};
    _armWatchdog(jobId);

    switch (event.type) {
      case 'connected':
        state = state.copyWith(phase: 'connected', progress: 5);
      case 'extraction_started':
        state = state.copyWith(
          phase: 'analyzing',
          progress: 10,
          secondsLeft: 45,
          statusText: 'Looking at your photo',
        );
      case 'image_extraction_complete':
        final status = {...state.itemStatus};
        final raw = data['items'];
        if (raw is List) {
          for (final item in raw.whereType<Map<String, dynamic>>()) {
            final parsed = DetectedItemData.fromJson(item);
            _extracted[parsed.tempId] = parsed;
            status[parsed.tempId] = 'pending';
          }
        }
        state = state.copyWith(
          phase: 'extracting',
          progress: 60,
          secondsLeft: 30,
          statusText: 'Pieces found',
          itemStatus: status,
        );
      case 'image_extraction_failed':
        // Terminal for a one-photo job: stop listening so a late event of
        // this job can never reach a retry.
        _stopJob();
        _fail(Exception(data['error'] ?? 'Extraction failed'));
      case 'all_extractions_complete':
        _seedReview();
      case 'generation_started':
        state = state.copyWith(
          phase: _decoupledToReview ? null : 'generating',
          progress: _decoupledToReview ? null : 65,
          generating: _decoupledToReview ? null : true,
          secondsLeft: 25,
          statusText: 'Making studio photos',
        );
      case 'item_generation_complete':
        _onItemGenerated(data);
      case 'item_generation_failed':
        final tempId = data['temp_id']?.toString();
        if (tempId != null && tempId.isNotEmpty) {
          state = state.copyWith(
            itemStatus: {...state.itemStatus, tempId: 'failed'},
          );
        }
      case 'job_complete':
        _onJobComplete(data);
      case 'job_failed':
        _stopJob();
        _fail(Exception(data['error'] ?? 'Job failed'));
      case 'job_cancelled':
        _stopJob();
        state = state.copyWith(
          processing: false,
          generating: false,
          statusText: 'Cancelled',
        );
    }
  }

  void _onItemGenerated(Map<String, dynamic> data) {
    final tempId = data['temp_id']?.toString();
    final status = {...state.itemStatus};
    if (tempId != null && tempId.isNotEmpty) status[tempId] = 'complete';
    final eventTotal = (data['total_items'] as num?)?.toInt();
    final total = (eventTotal != null && eventTotal > 0)
        ? eventTotal
        : (status.isNotEmpty ? status.length : 1);
    final done =
        ((data['completed_count'] as num?)?.toInt() ??
                status.values.where((s) => s == 'complete').length)
            .clamp(0, total)
            .toInt();
    final source = tempId == null ? null : _extracted[tempId];
    var items = state.items;
    if (source != null) {
      final url = data['generated_image_url']?.toString();
      final base64 = data['generated_image_base64']?.toString();
      final generated = _withImage(
        source,
        status: 'generated',
        imageUrl: (url != null && url.isNotEmpty)
            ? url
            : (base64 != null && base64.isNotEmpty)
            ? 'data:image/png;base64,$base64'
            : null,
      );
      final existing = items
          .where((i) => i.tempId == generated.tempId)
          .firstOrNull;
      final merged = existing == null
          ? generated
          : generated.copyWith(
              includeInWardrobe: existing.includeInWardrobe,
              name: existing.name ?? generated.name,
            );
      items = existing == null
          ? [...items, merged]
          : [for (final i in items) i.tempId == merged.tempId ? merged : i];
    }
    final candidate = source?.subCategory ?? source?.category;
    state = state.copyWith(
      itemStatus: status,
      generatingIndex: done,
      generatingName: (candidate?.isNotEmpty ?? false)
          ? candidate
          : (done > 0 ? 'Piece $done' : 'Piece'),
      progress: 65 + 30 * done / total,
      secondsLeft: (total - done) > 0 ? (total - done) * 5 : 0,
      items: items,
    );
  }

  void _onJobComplete(Map<String, dynamic> data) {
    final parsed = _parseItems(data['items']);
    var next = state;
    if (parsed.isNotEmpty) {
      // Keep include toggles and edited names from the review list.
      final existing = {for (final i in state.items) i.tempId: i};
      next = next.copyWith(
        items: [
          for (final p in parsed)
            existing[p.tempId] == null
                ? p
                : p.copyWith(
                    includeInWardrobe: existing[p.tempId]!.includeInWardrobe,
                    name: existing[p.tempId]!.name ?? p.name,
                  ),
        ],
        itemStatus: {
          for (final p in parsed)
            p.tempId: p.generationError != null
                ? 'failed'
                : ((p.generatedImageUrl?.isNotEmpty ?? false)
                      ? 'complete'
                      : 'pending'),
        },
      );
    }
    _stopJob();
    state = next.copyWith(
      phase: 'complete',
      progress: 100,
      secondsLeft: 0,
      statusText: 'Done',
      processing: false,
      generating: false,
      failure: next.items.isEmpty
          ? () => const ItemAddFailure(ItemAddFailureKind.noItems, '')
          : null,
    );
  }

  List<DetectedItemDataWithImage> _parseItems(Object? raw) => raw is List
      ? raw
            .whereType<Map<String, dynamic>>()
            .map(DetectedItemDataWithImage.fromJson)
            .toList()
      : const [];

  DetectedItemDataWithImage _withImage(
    DetectedItemData s, {
    required String status,
    String? imageUrl,
  }) => DetectedItemDataWithImage(
    tempId: s.tempId,
    category: s.category,
    subCategory: s.subCategory,
    colors: s.colors,
    material: s.material,
    pattern: s.pattern,
    brand: s.brand,
    confidence: s.confidence,
    detailedDescription: s.detailedDescription,
    personId: s.personId,
    personLabel: s.personLabel,
    isCurrentUserPerson: s.isCurrentUserPerson,
    includeInWardrobe: s.includeInWardrobe,
    status: status,
    generatedImageUrl: imageUrl,
    name: s.subCategory ?? s.category,
  );

  /// Shows the found pieces at once; studio photos swap in as they arrive.
  void _seedReview() {
    if (_extracted.isEmpty || _decoupledToReview) return;
    _decoupledToReview = true;
    state = state.copyWith(
      items: [
        for (final s in _extracted.values) _withImage(s, status: 'detected'),
      ],
      phase: 'review',
      progress: 100,
      secondsLeft: 0,
      processing: false,
      statusText: 'Making studio photos',
    );
  }

  /// Polls the job status when the stream dies, hangs or the job is lost.
  /// Bounded by 2 minutes and 3 failures in a row. Stops as soon as the
  /// provider is disposed or another job starts.
  Future<void> _reconcile(String jobId) async {
    if (!_isCurrent(jobId) || _reconciling) return;
    _reconciling = true;
    _watchdog?.cancel();
    var failures = 0;
    final deadline = DateTime.now().add(const Duration(minutes: 2));
    try {
      while (_isCurrent(jobId)) {
        try {
          final status = await ref
              .read(itemRepositoryProvider)
              .getSingleJobStatus(jobId);
          if (!_isCurrent(jobId)) return;
          failures = 0;
          final existing = {for (final i in state.items) i.tempId: i};
          var items = state.items;
          for (final parsed in _parseItems(status['items'])) {
            final old = existing[parsed.tempId];
            final merged = old == null
                ? parsed
                : parsed.copyWith(
                    includeInWardrobe: old.includeInWardrobe,
                    name: old.name ?? parsed.name,
                  );
            items = old == null
                ? [...items, merged]
                : [
                    for (final i in items)
                      i.tempId == merged.tempId ? merged : i,
                  ];
          }
          state = state.copyWith(items: items);
          switch (status['status']?.toString() ?? '') {
            case 'completed':
              _finishReconcile(success: true);
              return;
            case 'failed':
            case 'cancelled':
              _finishReconcile(
                success: state.items.isNotEmpty,
                error: status['error']?.toString() ?? 'Extraction failed',
              );
              return;
            default:
              if (state.items.isNotEmpty && !_decoupledToReview) {
                _decoupledToReview = true;
                state = state.copyWith(phase: 'review', processing: false);
              }
          }
        } catch (_) {
          if (!_isCurrent(jobId)) return;
          failures++;
          if (state.items.isNotEmpty || failures >= 3) {
            _finishReconcile(
              success: state.items.isNotEmpty,
              error: 'Connection was lost. Try again.',
            );
            return;
          }
        }
        if (DateTime.now().isAfter(deadline)) {
          _finishReconcile(
            success: state.items.isNotEmpty,
            error: 'Connection lost while processing.',
          );
          return;
        }
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    } finally {
      _reconciling = false;
    }
  }

  void _finishReconcile({required bool success, String? error}) {
    _stopJob();
    if (success) {
      state = state.copyWith(
        processing: false,
        generating: false,
        phase: 'complete',
        progress: 100,
        secondsLeft: 0,
      );
    } else {
      _fail(Exception(error ?? 'Extraction failed'));
    }
  }

  void _fail(Object error) {
    state = state.copyWith(
      processing: false,
      generating: false,
      failure: () => ItemAddFailure.from(error),
    );
  }

  /// Stops listening to the current job: stream, watchdog and polling.
  void _stopJob() {
    _watchdog?.cancel();
    _watchdog = null;
    _sse?.cancel();
    _sse = null;
    _jobId = null;
  }

  /// Cancels the running job and returns to the start. Local listening
  /// always stops; a failed server cancel is shown.
  Future<void> cancelExtraction() async {
    final jobId = _jobId;
    reset();
    if (jobId == null) return;
    try {
      await ref.read(itemRepositoryProvider).cancelSingleExtraction(jobId);
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not cancelled', stackTrace: stack);
    }
  }

  /// Saves the included pieces with their studio photos. Pieces an earlier
  /// save added are skipped; a failed piece keeps its idempotency key.
  /// A call while saving does nothing.
  Future<ItemAddSaveResult> saveGeneratedItems() async {
    if (state.saving) return (saved: const <ItemModel>[], failed: 0);
    final toSave = [
      for (final i in state.items)
        if (i.includeInWardrobe && !_savedTempIds.contains(i.tempId)) i,
    ];
    if (toSave.isEmpty) return (saved: const <ItemModel>[], failed: 0);
    state = state.copyWith(saving: true);
    final repository = ref.read(itemRepositoryProvider);
    final source = state.image;
    final occasionTags = state.useCases.isEmpty
        ? null
        : UseCases.normalizeList(state.useCases);
    final saved = <ItemModel>[];
    var failed = 0;

    for (final item in toSave) {
      final request = CreateItemRequest(
        name: item.name ?? item.subCategory ?? item.category,
        category: Category.fromString(item.category),
        colors: item.colors,
        material: item.material,
        pattern: item.pattern,
        description: item.detailedDescription,
        condition: domain.Condition.clean,
        occasionTags: occasionTags,
      );
      try {
        final ItemModel result;
        final url = item.generatedImageUrl;
        if (url != null) {
          // Studio photo ready: create, then upload it. Strategy in order:
          //  1. A data URI: strip the prefix, upload the bytes.
          //  2. A storage URL (after job_complete only the URL remains):
          //     download and re-upload.
          //  3. The source photo, so a piece is never saved without one.
          final created = await repository.createItem(
            request,
            clientRequestId: _requestIdFor(item.tempId, item),
          );
          var uploaded = false;
          if (url.startsWith('data:image')) {
            final base64 = url.replaceFirst(
              RegExp(r'^data:image/\w+;base64,', caseSensitive: false),
              '',
            );
            if (base64.isNotEmpty) {
              uploaded =
                  await repository.uploadImageFromBase64(created.id, base64) !=
                  null;
            }
          }
          if (!uploaded && !url.startsWith('data:')) {
            uploaded =
                await repository.uploadImageFromUrl(created.id, url) != null;
          }
          if (!uploaded && source != null) {
            uploaded = (await repository.uploadImages(created.id, [
              source,
            ])).isNotEmpty;
          }
          result = await repository.getItem(created.id);
          if (!uploaded && (result.itemImages?.isEmpty ?? true)) {
            ErrorHandler.reportError(
              StateError('Item image upload failed'),
              'saveGeneratedItems: created item ${created.id} '
              '("${request.name}") has no images after all upload strategies',
            );
          }
        } else if (source != null) {
          // No studio photo yet: save with the original photo.
          result = await repository.createItemWithImage(
            image: source,
            request: request,
            clientRequestId: _requestIdFor(item.tempId, item),
          );
        } else {
          continue;
        }
        _savedTempIds.add(item.tempId);
        if (!saved.any((s) => s.id == result.id)) saved.add(result);
      } catch (e, stack) {
        failed++;
        ErrorHandler.reportError(e, 'Item add save failed', stackTrace: stack);
      }
    }

    if (saved.isNotEmpty && ref.exists(wardrobeProvider)) {
      ref.read(wardrobeProvider.notifier).addItems(saved);
    }
    if (ref.mounted) state = state.copyWith(saving: false);
    if (failed == 0) {
      ErrorHandler.showSuccess(
        saved.length == 1
            ? '1 piece is in your closet.'
            : '${saved.length} pieces are in your closet.',
        title: 'Saved',
      );
    } else if (saved.isNotEmpty) {
      ErrorHandler.showWarning(
        '${saved.length} of ${saved.length + failed} pieces saved. Tap save to try the rest again.',
        title: 'Some pieces not saved',
      );
    } else {
      ErrorHandler.showError(
        'Nothing was saved. Try again.',
        title: 'Not saved',
      );
    }
    return (saved: saved, failed: failed);
  }

  void toggleInclude(String tempId) => state = state.copyWith(
    items: [
      for (final i in state.items)
        i.tempId == tempId
            ? i.copyWith(includeInWardrobe: !i.includeInWardrobe)
            : i,
    ],
  );

  void setPersonInclusion(String personId, bool include) =>
      state = state.copyWith(
        items: [
          for (final i in state.items)
            (i.personId ?? 'unassigned') == personId
                ? i.copyWith(includeInWardrobe: include)
                : i,
        ],
      );

  void toggleUseCase(String useCase) {
    final value = UseCases.normalize(useCase);
    if (value.isEmpty) return;
    final next = {...state.useCases};
    if (!next.remove(value)) next.add(value);
    state = state.copyWith(useCases: next);
  }

  void openManualEntry() => state = state.copyWith(manualEntry: true);

  void closeManualEntry() => state = state.copyWith(manualEntry: false);

  /// Back to the start. Stops the job and forgets the photo.
  void reset() {
    _generation++; // any start still in flight must cancel itself
    _stopJob();
    _extracted.clear();
    _createRequestIds.clear();
    _savedTempIds.clear();
    _decoupledToReview = false;
    state = const ItemAddState();
  }
}

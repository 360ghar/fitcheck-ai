import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/ai_consent_service.dart';
import '../../../core/services/persistence_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/request_id.dart';
import '../../../domain/constants/use_cases.dart';
import '../../../domain/enums/condition.dart' as domain;
import '../models/batch_extraction_models.dart';
import '../models/item_model.dart';
import '../models/social_import_models.dart';
import '../repositories/batch_extraction_repository.dart';
import '../repositories/social_import_repository.dart';
import 'wardrobe_providers.dart';

// Dependencies of the add flows, as providers so tests can override them.

final batchExtractionRepositoryProvider = Provider<BatchExtractionRepository>(
  (ref) => BatchExtractionRepository(),
);

final socialImportRepositoryProvider = Provider<SocialImportRepository>(
  (ref) => SocialImportRepository(),
);

/// Third-party AI data-sharing consent (Apple 5.1.2(i)). Returns false when
/// the user declines; the caller must then start no AI work.
final aiConsentGateProvider = Provider<Future<bool> Function(String feature)>(
  (ref) =>
      (feature) => ref
          .read(aiConsentServiceProvider)
          .ensureConsent(featureLabel: feature),
);

final persistenceServiceProvider = Provider<PersistenceService>(
  (ref) => PersistenceService.instance,
);

/// Compresses one photo and returns its base64 payload, or null.
final batchImageEncoderProvider = Provider<Future<String?> Function(File)>(
  (ref) =>
      (file) => ImageUtils.compressAndEncode(file),
);

/// Deep links that may carry the social OAuth callback: the launch link, then
/// every later link.
final socialCallbackLinksProvider = Provider<Stream<Uri>>((ref) async* {
  final links = AppLinks();
  try {
    final initial = await links.getInitialLink();
    if (initial != null) yield initial;
  } catch (_) {
    // No launch link (or no plugin in tests).
  }
  yield* links.uriLinkStream;
});

enum BatchInputMode { upload, social }

/// One batch-add session: the selected photos, the extraction job, the
/// review list and the social import.
@immutable
class BatchState {
  const BatchState({
    this.images = const [],
    this.mode = BatchInputMode.upload,
    this.status = BatchJobStatus.idle,
    this.jobId = '',
    this.error = '',
    this.uploadProgress = 0,
    this.extractedCount = 0,
    this.generatedCount = 0,
    this.failedCount = 0,
    this.currentBatch = 0,
    this.totalBatches = 0,
    this.totalItems = 0,
    this.items = const [],
    this.useCases = const {},
    this.saving = false,
    this.saveFailures = const [],
    this.socialJobId = '',
    this.socialJob,
    this.socialError = '',
    this.socialLoading = false,
    this.socialConnected = false,
    this.socialLastEventId = -1,
    this.waitingForOtp = false,
    this.twoFactorIdentifier = '',
    this.socialUrl = '',
    this.socialUrlError = '',
    this.validSocialUrl = false,
  });

  final List<BatchImage> images;
  final BatchInputMode mode;
  final BatchJobStatus status;
  final String jobId;

  /// A user-facing message. Empty when nothing failed.
  final String error;
  final double uploadProgress;
  final int extractedCount;
  final int generatedCount;
  final int failedCount;
  final int currentBatch;
  final int totalBatches;
  final int totalItems;
  final List<BatchExtractedItem> items;
  final Set<String> useCases;
  final bool saving;

  /// Names of the pieces the last save could not add.
  final List<String> saveFailures;

  final String socialJobId;
  final SocialImportJobData? socialJob;
  final String socialError;
  final bool socialLoading;
  final bool socialConnected;
  final int socialLastEventId;
  final bool waitingForOtp;
  final String twoFactorIdentifier;
  final String socialUrl;
  final String socialUrlError;
  final bool validSocialUrl;

  bool get isIdle => status == BatchJobStatus.idle;
  bool get isUploading => status == BatchJobStatus.uploading;
  bool get isExtracting => status == BatchJobStatus.extracting;
  bool get isGenerating => status == BatchJobStatus.generating;
  bool get isComplete => status == BatchJobStatus.complete;
  bool get isFailed => status == BatchJobStatus.failed;
  bool get isCancelled => status == BatchJobStatus.cancelled;
  bool get isProcessing => isUploading || isExtracting || isGenerating;
  bool get hasError => error.isNotEmpty;
  bool get isSocialMode => mode == BatchInputMode.social;
  int get remainingSlots => BatchExtractionNotifier.maxImages - images.length;

  bool get isSocialAuthRequired =>
      socialJob?.authRequired == true ||
      socialJob?.status == SocialImportJobStatus.awaitingAuth;

  /// Pieces the next save adds.
  List<BatchExtractedItem> get selectedItems => [
    for (final item in items)
      if (item.isSelected && item.includeInWardrobe) item,
  ];

  int get selectedItemCount => selectedItems.length;

  /// Fraction of the current phase that is done, 0 to 1.
  double get progress {
    if (isUploading) return uploadProgress;
    if (isExtracting) {
      final total = images.length;
      // Failed images never become "extracted": leave them out of the
      // denominator so the bar can reach the end.
      final expected = total - failedCount;
      if (total <= 0) return 0;
      if (expected <= 0 || extractedCount >= expected) return 1;
      return extractedCount / expected;
    }
    if (isGenerating) {
      return totalItems > 0
          ? (generatedCount / totalItems).clamp(0, 1).toDouble()
          : 0;
    }
    return isComplete ? 1 : 0;
  }

  BatchState copyWith({
    List<BatchImage>? images,
    BatchInputMode? mode,
    BatchJobStatus? status,
    String? jobId,
    String? error,
    double? uploadProgress,
    int? extractedCount,
    int? generatedCount,
    int? failedCount,
    int? currentBatch,
    int? totalBatches,
    int? totalItems,
    List<BatchExtractedItem>? items,
    Set<String>? useCases,
    bool? saving,
    List<String>? saveFailures,
    String? socialJobId,
    SocialImportJobData? Function()? socialJob,
    String? socialError,
    bool? socialLoading,
    bool? socialConnected,
    int? socialLastEventId,
    bool? waitingForOtp,
    String? twoFactorIdentifier,
    String? socialUrl,
    String? socialUrlError,
    bool? validSocialUrl,
  }) => BatchState(
    images: images ?? this.images,
    mode: mode ?? this.mode,
    status: status ?? this.status,
    jobId: jobId ?? this.jobId,
    error: error ?? this.error,
    uploadProgress: uploadProgress ?? this.uploadProgress,
    extractedCount: extractedCount ?? this.extractedCount,
    generatedCount: generatedCount ?? this.generatedCount,
    failedCount: failedCount ?? this.failedCount,
    currentBatch: currentBatch ?? this.currentBatch,
    totalBatches: totalBatches ?? this.totalBatches,
    totalItems: totalItems ?? this.totalItems,
    items: items ?? this.items,
    useCases: useCases ?? this.useCases,
    saving: saving ?? this.saving,
    saveFailures: saveFailures ?? this.saveFailures,
    socialJobId: socialJobId ?? this.socialJobId,
    socialJob: socialJob == null ? this.socialJob : socialJob(),
    socialError: socialError ?? this.socialError,
    socialLoading: socialLoading ?? this.socialLoading,
    socialConnected: socialConnected ?? this.socialConnected,
    socialLastEventId: socialLastEventId ?? this.socialLastEventId,
    waitingForOtp: waitingForOtp ?? this.waitingForOtp,
    twoFactorIdentifier: twoFactorIdentifier ?? this.twoFactorIdentifier,
    socialUrl: socialUrl ?? this.socialUrl,
    socialUrlError: socialUrlError ?? this.socialUrlError,
    validSocialUrl: validSocialUrl ?? this.validSocialUrl,
  );
}

/// Scope: one provider shared by the selector, progress and review routes.
/// The selector route stays in the stack under the other two (they are
/// pushed with `toNamed` / `offNamed`), so it keeps the session alive while
/// the user moves between them. Leaving the flow pops every route, and the
/// dispose hook cancels the SSE streams, polling and the deep-link listener.
final batchExtractionProvider =
    NotifierProvider.autoDispose<BatchExtractionNotifier, BatchState>(
      BatchExtractionNotifier.new,
    );

class BatchExtractionNotifier extends Notifier<BatchState> {
  static const int maxImages = 50;

  /// Upper bound on the SSE-fallback polling loops: about 2 minutes at the
  /// 2 s cadence.
  static const int maxPollAttempts = 60;
  static const int generationBatchSize = 5;
  static const String socialOAuthCallbackUri =
      'fitcheck.ai://social-import-callback';
  static const String _socialJobKey = 'fitcheck.social_import.active_job_id';
  static const String _socialEventKey = 'fitcheck.social_import.last_event_id';

  BatchExtractionRepository get _batchRepo =>
      ref.read(batchExtractionRepositoryProvider);
  SocialImportRepository get _socialRepo =>
      ref.read(socialImportRepositoryProvider);
  PersistenceService get _persistence => ref.read(persistenceServiceProvider);

  StreamSubscription<SSEEvent>? _sse;
  StreamSubscription<SocialImportSSEEvent>? _socialSse;
  bool _pollingJob = false;
  bool _pollingSocial = false;

  /// True from the first line of [startExtraction] until the job is running
  /// or the start failed: blocks a second paid job from a double tap.
  bool _starting = false;
  bool _navigatedToReview = false;
  int _socialStatusGeneration = 0;

  /// Idempotency keys per extracted item (TD-109). Stable across saves of
  /// one session, so a re-tapped Save replays committed rows instead of
  /// inserting duplicates. Cleared when a new job starts or on [reset].
  final Map<String, String> _createRequestIds = {};

  /// Items already added by an earlier save of this session.
  final Set<String> _savedItemIds = {};

  /// Scraper credentials, held only while a 2FA code is pending.
  ({String username, String password})? _pendingLogin;

  @override
  BatchState build() {
    final links = ref
        .read(socialCallbackLinksProvider)
        .listen(_handleSocialOAuthUri, onError: (Object _) {});
    ref.onDispose(() {
      links.cancel();
      _sse?.cancel();
      _socialSse?.cancel();
      _pendingLogin = null;
    });
    unawaited(_restoreSocialImportState());
    return const BatchState();
  }

  bool get _alive => ref.mounted;

  String _requestIdFor(String tempId, Object item) => _createRequestIds
      .putIfAbsent(requestIdIdentity(tempId, item), () => newRequestId('item'));

  @visibleForTesting
  void debugSetState(BatchState value) => state = value;

  // Photo selection.

  /// Adds picked photos up to the free slots. Invalid photos are skipped;
  /// returns the message of the last rejection, or null.
  Future<String?> addImages(List<File> files) async {
    String? rejected;
    final added = <BatchImage>[];
    for (final file in files.take(state.remainingSlots)) {
      final problem = await ImageUtils.validateImage(file);
      if (problem != null) {
        rejected = problem;
        continue;
      }
      added.add(
        BatchImage(id: ImageUtils.generateImageId(), filePath: file.path),
      );
    }
    if (_alive && added.isNotEmpty) {
      state = state.copyWith(
        images: [...state.images, ...added].take(maxImages).toList(),
      );
    }
    return rejected;
  }

  void removeImage(String imageId) => state = state.copyWith(
    images: [
      for (final i in state.images)
        if (i.id != imageId) i,
    ],
  );

  void clearAllImages() => state = state.copyWith(images: const []);

  void setInputMode(BatchInputMode mode) =>
      state = mode == BatchInputMode.upload
      ? state.copyWith(mode: mode, socialError: '')
      : state.copyWith(mode: mode, error: '');

  // Batch extraction.

  /// Compresses the selected photos and starts one extraction job. A call
  /// while another start or job is running does nothing.
  Future<void> startExtraction() async {
    if (_starting || state.isProcessing) return;
    _starting = true;
    try {
      if (!await ref.read(aiConsentGateProvider)('AI Wardrobe Extraction')) {
        return;
      }
      if (!_alive) return;
      if (state.images.isEmpty) {
        state = state.copyWith(error: 'Choose at least one photo.');
        return;
      }
      _sse?.cancel();
      _createRequestIds.clear();
      _savedItemIds.clear();
      _navigatedToReview = false;
      state = state.copyWith(
        status: BatchJobStatus.uploading,
        jobId: '',
        error: '',
        uploadProgress: 0,
        extractedCount: 0,
        generatedCount: 0,
        failedCount: 0,
        currentBatch: 0,
        totalBatches: 0,
        totalItems: 0,
        items: const [],
        saveFailures: const [],
        images: [
          for (final i in state.images)
            i.copyWith(
              status: BatchImageStatus.pending,
              error: null,
              extractedItems: const [],
            ),
        ],
      );

      final encode = ref.read(batchImageEncoderProvider);
      final inputs = <BatchImageInput>[];
      final images = state.images;
      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        _updateImage(
          image.id,
          (img) => img.copyWith(status: BatchImageStatus.uploading),
        );
        String? base64;
        try {
          base64 = await encode(File(image.filePath));
        } catch (_) {
          base64 = null;
        }
        if (!_alive) return;
        if (base64 == null) {
          _updateImage(
            image.id,
            (img) => img.copyWith(
              status: BatchImageStatus.failed,
              error: 'This photo could not be read.',
            ),
          );
        } else {
          inputs.add(BatchImageInput(imageId: image.id, imageBase64: base64));
        }
        state = state.copyWith(uploadProgress: (i + 1) / images.length);
      }

      if (inputs.isEmpty) {
        state = state.copyWith(
          error: 'None of these photos could be read. Try other photos.',
          status: BatchJobStatus.failed,
        );
        return;
      }

      final response = await _batchRepo.startBatchExtraction(
        images: inputs,
        autoGenerate: true,
        generationBatchSize: generationBatchSize,
      );
      if (!_alive) return;
      state = state.copyWith(jobId: response.jobId);
      _subscribeToEvents(response.jobId);
    } catch (e, stack) {
      ErrorHandler.reportError(
        e,
        'Batch extraction start failed',
        stackTrace: stack,
      );
      if (_alive) {
        state = state.copyWith(
          error: ErrorHandler.extractMessage(e),
          status: BatchJobStatus.failed,
        );
      }
    } finally {
      _starting = false;
    }
  }

  /// True once per job: the progress page navigates to review only when
  /// this returns true.
  bool claimReviewNavigation() {
    if (_navigatedToReview) return false;
    _navigatedToReview = true;
    return true;
  }

  @visibleForTesting
  void subscribeToEventsForTesting(String id) => _subscribeToEvents(id);

  void _subscribeToEvents(String id) {
    _sse?.cancel();
    _sse = _batchRepo
        .subscribeToEvents(id)
        .listen(
          (event) => _onEvent(id, event),
          onError: (Object e) => pollJobStatus(id),
          onDone: () {
            // A clean close is not always a terminal event (proxy timeouts):
            // reconcile against the server.
            if (_alive &&
                id == state.jobId &&
                !state.isComplete &&
                !state.isFailed &&
                !state.isCancelled) {
              pollJobStatus(id);
            }
          },
        );
  }

  void _onEvent(String id, SSEEvent event) {
    if (!_alive || id != state.jobId) return;
    final data = event.data;
    switch (event.type) {
      case 'extraction_started':
        state = state.copyWith(status: BatchJobStatus.extracting);
      case 'image_extraction_complete':
        _onImageExtracted(data);
      case 'image_extraction_failed':
        _onImageFailed(data);
      case 'generation_started':
        // Under the overlapped pipeline this is the count detected so far;
        // item events backfill the growing total.
        final items = state.items;
        state = state.copyWith(
          status: BatchJobStatus.generating,
          totalItems: (data?['total_items'] as num?)?.toInt() ?? items.length,
          totalBatches:
              (data?['total_batches'] as num?)?.toInt() ??
              (items.isEmpty ? 0 : (items.length / generationBatchSize).ceil()),
          images: [
            for (final i in state.images)
              i.status == BatchImageStatus.failed
                  ? i
                  : i.copyWith(status: BatchImageStatus.generating),
          ],
        );
      case 'item_generation_complete':
        _onItemGenerated(data);
      case 'item_generation_failed':
        _onItemGenerationFailed(data);
      case 'job_complete':
        final raw = data?['items'];
        var next = state;
        if (raw is List) {
          final parsed = raw
              .whereType<Map<String, dynamic>>()
              .map(BatchExtractedItem.fromJson)
              .toList();
          next = next.copyWith(
            items: parsed,
            totalItems: parsed.length,
            generatedCount: parsed
                .where((i) => i.status == BatchItemStatus.generated)
                .length,
          );
        }
        state = next.copyWith(
          status: BatchJobStatus.complete,
          images: [
            for (final i in next.images)
              i.status == BatchImageStatus.failed
                  ? i
                  : i.copyWith(status: BatchImageStatus.generated),
          ],
        );
        _sse?.cancel();
      case 'job_failed':
        state = state.copyWith(
          error: data?['error']?.toString() ?? 'Finding pieces failed.',
          status: BatchJobStatus.failed,
        );
        _sse?.cancel();
      case 'job_cancelled':
        state = state.copyWith(status: BatchJobStatus.cancelled);
        _sse?.cancel();
      // 'error' is the SSE service's synthetic retry-exhausted event. The
      // stream closes right after it and onDone starts recovery polling, so
      // it is not a job failure and must not show one.
    }
  }

  void _onImageExtracted(Map<String, dynamic>? data) {
    final imageId = data?['image_id'] as String?;
    if (data == null || imageId == null) return;
    final items = _batchRepo.parseExtractedItems(data, imageId);
    _updateImage(
      imageId,
      (img) => img.copyWith(
        status: BatchImageStatus.extracted,
        extractedItems: items,
      ),
    );
    state = state.copyWith(
      extractedCount:
          (data['completed_count'] as num?)?.toInt() ??
          state.extractedCount + 1,
      items: [...state.items, ...items],
    );
  }

  void _onImageFailed(Map<String, dynamic>? data) {
    if (data == null) return;
    final imageId = data['image_id'] as String?;
    if (imageId != null) {
      _updateImage(
        imageId,
        (img) => img.copyWith(
          status: BatchImageStatus.failed,
          error: data['error']?.toString() ?? 'No pieces found in this photo.',
        ),
      );
    }
    state = state.copyWith(
      failedCount:
          (data['failed_count'] as num?)?.toInt() ?? state.failedCount + 1,
    );
  }

  int _backfilledTotal(Map<String, dynamic> data) {
    final total = (data['total_items'] as num?)?.toInt();
    return total != null && total > state.totalItems ? total : state.totalItems;
  }

  void _onItemGenerated(Map<String, dynamic>? data) {
    final itemId = data?['temp_id'] as String?;
    if (data == null || itemId == null) return;
    final base64 = data['generated_image_base64']?.toString();
    state = state.copyWith(
      items: [
        for (final i in state.items)
          i.id == itemId
              ? i.copyWith(
                  status: BatchItemStatus.generated,
                  generatedImageBase64: base64,
                  generatedImageUrl: base64 != null && base64.isNotEmpty
                      ? 'data:image/png;base64,$base64'
                      : i.generatedImageUrl,
                )
              : i,
      ],
      generatedCount:
          (data['completed_count'] as num?)?.toInt() ??
          state.generatedCount + 1,
      totalItems: _backfilledTotal(data),
    );
  }

  void _onItemGenerationFailed(Map<String, dynamic>? data) {
    if (data == null) return;
    final itemId = data['temp_id'] as String?;
    state = state.copyWith(
      totalItems: _backfilledTotal(data),
      items: itemId == null
          ? null
          : [
              for (final i in state.items)
                i.id == itemId
                    ? i.copyWith(
                        status: BatchItemStatus.failed,
                        error: data['error']?.toString(),
                      )
                    : i,
            ],
    );
  }

  void _updateImage(String id, BatchImage Function(BatchImage) update) {
    state = state.copyWith(
      images: [for (final i in state.images) i.id == id ? update(i) : i],
    );
  }

  /// Fallback polling when the SSE stream errors or closes early. One chain
  /// at a time, at most [maxPollAttempts] requests, and it stops as soon as
  /// the provider is disposed or a different job starts.
  @visibleForTesting
  Future<void> pollJobStatus(String id) async {
    if (!_alive || id.isEmpty || id != state.jobId || _pollingJob) return;
    _pollingJob = true;
    Object? lastError;
    try {
      for (var attempt = 0; attempt < maxPollAttempts; attempt++) {
        if (!_alive || id != state.jobId) return;
        try {
          final status = await _batchRepo.getJobStatus(id);
          if (!_alive || id != state.jobId) return;
          lastError = null;
          var next = state.copyWith(
            extractedCount: status.extractedCount,
            generatedCount: status.generatedCount,
            failedCount: status.failedCount + status.generationFailedCount,
            currentBatch: status.currentBatch,
            totalBatches: status.totalBatches,
            totalItems: status.detectedItems?.length ?? state.items.length,
            items: status.detectedItems,
          );
          switch (status.status) {
            case 'pending':
            case 'extracting':
              next = next.copyWith(status: BatchJobStatus.extracting);
            case 'generating':
              next = next.copyWith(status: BatchJobStatus.generating);
            case 'completed':
              state = next.copyWith(status: BatchJobStatus.complete);
              return;
            case 'failed':
              state = next.copyWith(
                error: status.error ?? 'Finding pieces failed.',
                status: BatchJobStatus.failed,
              );
              return;
            case 'cancelled':
              state = next.copyWith(status: BatchJobStatus.cancelled);
              return;
          }
          state = next;
        } catch (e) {
          // Retried until the cap; only the give-up is reported.
          lastError = e;
        }
        await Future<void>.delayed(const Duration(seconds: 2));
      }
      if (!_alive || id != state.jobId) return;
      state = state.copyWith(
        error: 'We lost the connection while working. Try again.',
        status: BatchJobStatus.failed,
      );
      ErrorHandler.reportError(
        lastError ?? 'Batch extraction polling timed out',
        'Batch extraction polling exhausted after $maxPollAttempts attempts',
      );
    } finally {
      _pollingJob = false;
    }
  }

  /// Cancels the running job and returns to the selection with the photos
  /// kept. The local stream always stops; a failed server cancel is shown.
  Future<void> cancelExtraction() async {
    final id = state.jobId;
    resetJob();
    if (id.isEmpty) return;
    try {
      await _batchRepo.cancelJob(id);
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not cancelled', stackTrace: stack);
    }
  }

  // Review.

  void toggleItemInclude(String itemId) => state = state.copyWith(
    items: [
      for (final i in state.items)
        i.id == itemId
            ? i.copyWith(
                includeInWardrobe: !i.includeInWardrobe,
                isSelected: !i.includeInWardrobe,
              )
            : i,
    ],
  );

  void setAllIncluded(bool include) => state = state.copyWith(
    items: [
      for (final i in state.items)
        i.copyWith(includeInWardrobe: include, isSelected: include),
    ],
  );

  void setPersonInclusion(String personId, bool include) =>
      state = state.copyWith(
        items: [
          for (final i in state.items)
            (i.personId ?? 'unassigned') == personId
                ? i.copyWith(includeInWardrobe: include, isSelected: include)
                : i,
        ],
      );

  void removeItem(String itemId) => state = state.copyWith(
    items: [
      for (final i in state.items)
        if (i.id != itemId) i,
    ],
  );

  void toggleUseCase(String useCase) {
    final value = UseCases.normalize(useCase);
    if (value.isEmpty) return;
    final next = {...state.useCases};
    if (!next.remove(value)) next.add(value);
    state = state.copyWith(useCases: next);
  }

  void addUseCase(String useCase) {
    final value = UseCases.normalize(useCase);
    if (value.isEmpty) return;
    state = state.copyWith(useCases: {...state.useCases, value});
  }

  /// Saves the selected pieces. Pieces an earlier save already added are
  /// skipped; a piece that failed keeps its idempotency key, so a retry
  /// replays a create whose response was lost instead of duplicating it.
  /// Returns the pieces added by this call. A call while saving does nothing.
  Future<List<ItemModel>> saveSelectedItems() async {
    if (state.saving) return const [];
    final selected = [
      for (final i in state.selectedItems)
        if (!_savedItemIds.contains(i.id)) i,
    ];
    if (selected.isEmpty) {
      state = state.copyWith(saveFailures: const []);
      return const [];
    }
    state = state.copyWith(saving: true, saveFailures: const [], error: '');
    final itemRepo = ref.read(itemRepositoryProvider);
    final occasionTags = state.useCases.isEmpty
        ? null
        : UseCases.normalizeList(state.useCases);
    final images = state.images;
    final saved = <ItemModel>[];
    final failures = <String>[];

    for (final item in selected) {
      try {
        final created = await itemRepo.createItem(
          CreateItemRequest(
            name: item.name.isNotEmpty
                ? item.name
                : (item.subCategory ?? item.category.name),
            category: item.category,
            colors: item.colors,
            material: item.material,
            pattern: item.pattern,
            description: item.description,
            condition: domain.Condition.clean,
            occasionTags: occasionTags,
          ),
          clientRequestId: _requestIdFor(item.id, item),
        );

        // Image strategy, in order; each runs only when the previous one
        // stored nothing:
        //  1. In-memory generated base64 (from SSE events).
        //  2. A data-URI generated image: strip the prefix, upload the bytes.
        //  3. A storage URL (the normal post-job_complete state): download
        //     and re-upload.
        //  4. The source photo the piece was found in.
        final url = item.generatedImageUrl;
        final isDataUri = url != null && url.startsWith('data:image');
        var uploaded = false;
        final base64 =
            item.generatedImageBase64 ??
            (isDataUri
                ? url.replaceFirst(
                    RegExp(r'^data:image/\w+;base64,', caseSensitive: false),
                    '',
                  )
                : null);
        if (base64 != null && base64.isNotEmpty) {
          uploaded =
              await itemRepo.uploadImageFromBase64(created.id, base64) != null;
        }
        if (!uploaded &&
            url != null &&
            url.isNotEmpty &&
            !url.startsWith('data:')) {
          uploaded = await itemRepo.uploadImageFromUrl(created.id, url) != null;
        }
        if (!uploaded) {
          final source = images
              .where((i) => i.id == item.sourceImageId)
              .firstOrNull;
          if (source != null) {
            uploaded = (await itemRepo.uploadImages(created.id, [
              File(source.filePath),
            ])).isNotEmpty;
          }
        }

        final savedItem = await itemRepo.getItem(created.id);
        if (!uploaded && (savedItem.itemImages?.isEmpty ?? true)) {
          ErrorHandler.reportError(
            StateError('Item image upload failed'),
            'saveSelectedItems: created item ${created.id} '
            '("${item.name}") has no images after all upload strategies',
          );
        }
        _savedItemIds.add(item.id);
        // A replayed create returns the committed row: keep one copy.
        if (!saved.any((s) => s.id == savedItem.id)) saved.add(savedItem);
      } catch (e, stack) {
        failures.add(item.name);
        ErrorHandler.reportError(
          e,
          'Batch item save failed',
          stackTrace: stack,
        );
      }
    }

    if (saved.isNotEmpty && ref.exists(wardrobeProvider)) {
      ref.read(wardrobeProvider.notifier).addItems(saved);
    }
    if (_alive) {
      // After a partial save only the pieces still to save stay on the list.
      state = state.copyWith(
        saving: false,
        saveFailures: failures,
        items: failures.isEmpty
            ? null
            : [
                for (final i in state.items)
                  if (!_savedItemIds.contains(i.id)) i,
              ],
      );
    }
    return saved;
  }

  /// Clears the job, keeps the selected photos (reset to pending).
  void resetJob() {
    _sse?.cancel();
    _sse = null;
    _navigatedToReview = false;
    _createRequestIds.clear();
    _savedItemIds.clear();
    state = state.copyWith(
      status: BatchJobStatus.idle,
      jobId: '',
      error: '',
      uploadProgress: 0,
      extractedCount: 0,
      generatedCount: 0,
      failedCount: 0,
      currentBatch: 0,
      totalBatches: 0,
      totalItems: 0,
      items: const [],
      saving: false,
      saveFailures: const [],
      images: [
        for (final i in state.images)
          i.copyWith(
            status: BatchImageStatus.pending,
            error: null,
            extractedItems: const [],
          ),
      ],
    );
  }

  /// Ends the session: job, photos, review list and social import.
  void reset() {
    resetJob();
    resetSocialImportState();
    state = const BatchState();
  }

  // Social import.

  static final _instagramProfile = RegExp(
    r'^https?://(www\.)?instagram\.com/[^/]+/?$',
    caseSensitive: false,
  );
  static final _instagramPost = RegExp(
    r'^https?://(www\.)?instagram\.com/p/',
    caseSensitive: false,
  );
  static final _facebookProfile = RegExp(
    r'^https?://(www\.)?facebook\.com/[^/]+/?$',
    caseSensitive: false,
  );
  static final _fbProfile = RegExp(
    r'^https?://fb\.com/[^/]+/?$',
    caseSensitive: false,
  );

  void validateSocialUrl(String raw) {
    final url = raw.trim();
    String error = '';
    var valid = false;
    if (url.isEmpty) {
      // Nothing typed yet.
    } else if (_instagramPost.hasMatch(url)) {
      error = 'Post links are not supported. Enter a profile link.';
    } else if (url.contains(' ')) {
      error = 'Links cannot contain spaces.';
    } else if (_instagramProfile.hasMatch(url) ||
        _facebookProfile.hasMatch(url) ||
        _fbProfile.hasMatch(url)) {
      valid = true;
    } else if (url.startsWith('http')) {
      error = 'Enter an Instagram or Facebook profile link.';
    }
    state = state.copyWith(
      socialUrl: url,
      socialUrlError: error,
      validSocialUrl: valid,
    );
  }

  Future<void> startSocialImport(String sourceUrl) async {
    if (state.socialLoading) return;
    final url = sourceUrl.trim();
    if (url.isEmpty) {
      state = state.copyWith(socialError: 'Enter a profile link.');
      return;
    }
    state = state.copyWith(socialLoading: true, socialError: '');
    try {
      if (!await ref.read(aiConsentGateProvider)('AI Wardrobe Extraction')) {
        return;
      }
      final started = await _socialRepo.startJob(sourceUrl: url);
      if (!_alive) return;
      state = state.copyWith(socialJobId: started.jobId, socialLastEventId: -1);
      _persistSocialImportState();
      await refreshSocialStatus();
      _subscribeToSocialEvents(started.jobId);
    } catch (e) {
      if (_alive) {
        state = state.copyWith(socialError: ErrorHandler.extractMessage(e));
      }
    } finally {
      if (_alive) state = state.copyWith(socialLoading: false);
    }
  }

  /// Fetches the job. Responses that arrive after a newer request started
  /// are dropped, so an older status never overwrites a newer one.
  Future<void> refreshSocialStatus() async {
    final id = state.socialJobId;
    if (id.isEmpty) return;
    final generation = ++_socialStatusGeneration;
    try {
      final job = await _socialRepo.getStatus(id);
      if (!_alive ||
          generation != _socialStatusGeneration ||
          id != state.socialJobId) {
        return;
      }
      _applySocialJob(job);
    } catch (e) {
      if (!_alive || generation != _socialStatusGeneration) return;
      state = state.copyWith(socialError: ErrorHandler.extractMessage(e));
    }
  }

  Future<void> startSocialOAuthConnect() async {
    final id = state.socialJobId;
    if (id.isEmpty || state.socialLoading) return;
    state = state.copyWith(socialLoading: true, socialError: '');
    try {
      final oauth = await _socialRepo.getOAuthConnectUrl(
        id,
        mobileRedirectUri: socialOAuthCallbackUri,
      );
      final launched = await launchUrl(
        Uri.parse(oauth.authUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('The sign-in page did not open. Try again.');
      }
      ErrorHandler.showInfo(
        'Sign in in your browser, then come back to FitCheck.',
        title: 'Connect your account',
      );
    } catch (e) {
      if (_alive) {
        state = state.copyWith(socialError: ErrorHandler.extractMessage(e));
      }
    } finally {
      if (_alive) state = state.copyWith(socialLoading: false);
    }
  }

  /// Sends scraper credentials. The password is held only while a 2FA code
  /// is pending, and dropped as soon as the code is sent.
  Future<void> submitSocialScraperAuth({
    required String username,
    required String password,
    String? otpCode,
  }) async {
    final id = state.socialJobId;
    if (id.isEmpty || state.socialLoading) return;
    final otp = otpCode?.trim() ?? '';
    state = state.copyWith(socialLoading: true, socialError: '');
    try {
      await _socialRepo.submitScraperLogin(
        id,
        username: username.trim(),
        password: password,
        otpCode: otp.isEmpty ? null : otp,
        twoFactorIdentifier: state.twoFactorIdentifier.isEmpty
            ? null
            : state.twoFactorIdentifier,
      );
      _pendingLogin = null;
      if (!_alive) return;
      state = state.copyWith(waitingForOtp: false, twoFactorIdentifier: '');
      await refreshSocialStatus();
      _subscribeToSocialEvents(id);
    } catch (e) {
      final message = ErrorHandler.extractMessage(e);
      final lower = message.toLowerCase();
      final needsOtp =
          otp.isEmpty &&
          (lower.contains('two_factor') ||
              lower.contains('2fa') ||
              lower.contains('otp') ||
              lower.contains('two factor'));
      _pendingLogin = needsOtp
          ? (username: username, password: password)
          : null;
      if (!_alive) return;
      if (needsOtp) {
        state = state.copyWith(
          waitingForOtp: true,
          socialError: 'Enter the code from your authenticator app.',
        );
      } else if (lower.contains('checkpoint') || lower.contains('security')) {
        state = state.copyWith(
          socialError:
              'Instagram wants a security check. Sign in in your browser first.',
        );
      } else {
        state = state.copyWith(socialError: message);
      }
    } finally {
      if (_alive) state = state.copyWith(socialLoading: false);
    }
  }

  /// Sends the 2FA code with the credentials held from the first attempt.
  Future<void> submitSocialOtp(String code) async {
    final login = _pendingLogin;
    if (login == null) {
      state = state.copyWith(
        waitingForOtp: false,
        socialError: 'Enter your username and password again.',
      );
      return;
    }
    _pendingLogin = null;
    await submitSocialScraperAuth(
      username: login.username,
      password: login.password,
      otpCode: code,
    );
  }

  /// Leaves the 2FA step and drops the held credentials.
  void cancelSocialOtp() {
    _pendingLogin = null;
    state = state.copyWith(waitingForOtp: false, socialError: '');
  }

  @visibleForTesting
  bool get debugHoldsCredentials => _pendingLogin != null;

  Future<void> patchSocialItem({
    required String photoId,
    required String itemId,
    required Map<String, dynamic> updates,
  }) async {
    final id = state.socialJobId;
    if (id.isEmpty) return;
    final payload = Map<String, dynamic>.from(updates)
      ..removeWhere((key, value) => value == null);
    if (payload.isEmpty) return;
    try {
      await _socialRepo.patchItem(id, photoId, itemId, payload);
      await refreshSocialStatus();
    } catch (e) {
      if (_alive) {
        state = state.copyWith(socialError: ErrorHandler.extractMessage(e));
      }
    }
  }

  Future<void> approveAwaitingSocialPhoto() => _reviewPhoto(approve: true);

  Future<void> rejectAwaitingSocialPhoto() => _reviewPhoto(approve: false);

  Future<void> _reviewPhoto({required bool approve}) async {
    final id = state.socialJobId;
    final photo = state.socialJob?.awaitingReviewPhoto;
    if (id.isEmpty || photo == null || state.socialLoading) return;
    state = state.copyWith(socialLoading: true, socialError: '');
    try {
      if (approve) {
        await _socialRepo.approvePhoto(id, photo.id);
      } else {
        await _socialRepo.rejectPhoto(id, photo.id);
      }
      await refreshSocialStatus();
      if (approve && ref.exists(wardrobeProvider)) {
        unawaited(ref.read(wardrobeProvider.notifier).refresh());
      }
      if (_alive && state.socialJob != null && !state.socialJob!.isTerminal) {
        _subscribeToSocialEvents(id, lastEventId: _lastEventIdOrNull);
      }
    } catch (e) {
      if (_alive) {
        state = state.copyWith(socialError: ErrorHandler.extractMessage(e));
      }
    } finally {
      if (_alive) state = state.copyWith(socialLoading: false);
    }
  }

  int? get _lastEventIdOrNull =>
      state.socialLastEventId > 0 ? state.socialLastEventId : null;

  Future<void> cancelSocialImportJob() async {
    final id = state.socialJobId;
    if (id.isEmpty || state.socialLoading) return;
    state = state.copyWith(socialLoading: true, socialError: '');
    try {
      await _socialRepo.cancelJob(id);
      await refreshSocialStatus();
      _socialSse?.cancel();
      if (!_alive) return;
      state = state.copyWith(socialConnected: false);
      if (state.socialJob?.isTerminal == true) {
        _clearPersistedSocialImportState();
      }
    } catch (e) {
      if (_alive) {
        state = state.copyWith(socialError: ErrorHandler.extractMessage(e));
      }
    } finally {
      if (_alive) state = state.copyWith(socialLoading: false);
    }
  }

  void resetSocialImportState() {
    _socialSse?.cancel();
    _socialSse = null;
    _pendingLogin = null;
    _socialStatusGeneration++;
    state = state.copyWith(
      socialJobId: '',
      socialJob: () => null,
      socialError: '',
      socialLoading: false,
      socialConnected: false,
      socialLastEventId: -1,
      waitingForOtp: false,
      twoFactorIdentifier: '',
      socialUrl: '',
      socialUrlError: '',
      validSocialUrl: false,
    );
    _clearPersistedSocialImportState();
  }

  void _applySocialJob(SocialImportJobData job) {
    var next = state.copyWith(
      socialJob: () => job,
      socialError: (job.errorMessage ?? '').trim(),
    );
    if (job.status == SocialImportJobStatus.awaitingAuth &&
        (job.authReason?.isNotEmpty ?? false)) {
      next = job.authReason == 'two_factor_required'
          ? next.copyWith(
              waitingForOtp: true,
              twoFactorIdentifier: job.twoFactorIdentifier ?? '',
            )
          : next.copyWith(waitingForOtp: false);
    }
    if (job.isTerminal) {
      state = next.copyWith(socialConnected: false);
      _socialSse?.cancel();
      _clearPersistedSocialImportState();
      return;
    }
    state = next;
    _persistSocialImportState();
  }

  @visibleForTesting
  void subscribeToSocialEventsForTesting(String id) =>
      _subscribeToSocialEvents(id);

  void _subscribeToSocialEvents(String jobId, {int? lastEventId}) {
    _socialSse?.cancel();
    _socialSse = _socialRepo
        .subscribeToEvents(jobId, lastEventId: lastEventId)
        .listen(
          (event) => _onSocialEvent(jobId, event),
          onError: (Object _) {
            if (!_alive || jobId != state.socialJobId) return;
            state = state.copyWith(socialConnected: false);
            _pollSocialStatus(jobId);
          },
          onDone: () {
            if (_alive && jobId == state.socialJobId) {
              state = state.copyWith(socialConnected: false);
            }
          },
        );
  }

  void _onSocialEvent(String jobId, SocialImportSSEEvent event) {
    if (!_alive || jobId != state.socialJobId) return;
    var next = state.copyWith(socialConnected: true);
    if (event.id != null) next = next.copyWith(socialLastEventId: event.id);

    if (event.type == 'auth_required') {
      final reason = event.data['reason']?.toString();
      final message = event.data['message']?.toString();
      next = switch (reason) {
        'two_factor_required' => next.copyWith(
          waitingForOtp: true,
          twoFactorIdentifier:
              event.data['two_factor_identifier']?.toString() ?? '',
          socialError: message ?? 'Enter the code from your authenticator app.',
        ),
        'checkpoint_required' => next.copyWith(
          waitingForOtp: false,
          socialError:
              message ??
              'Instagram wants a security check. Sign in in your browser first.',
        ),
        'login_failed' => next.copyWith(
          waitingForOtp: false,
          socialError:
              message ?? 'Sign-in failed. Check your username and password.',
        ),
        _ => next.copyWith(
          waitingForOtp: false,
          socialError: message ?? 'Sign in to keep importing.',
        ),
      };
    }
    state = next;
    if (event.id != null) _persistSocialImportState();

    if (event.type == 'heartbeat' || event.type == 'connected') return;
    // SSE retry exhaustion arrives as this synthetic event, then the stream
    // closes. onError does not fire, so start the polling fallback here.
    if (event.type == 'error') {
      state = state.copyWith(socialConnected: false);
      _pollSocialStatus(jobId);
      return;
    }
    unawaited(refreshSocialStatus());
  }

  Future<void> _pollSocialStatus(String id) async {
    if (!_alive || id.isEmpty || id != state.socialJobId || _pollingSocial) {
      return;
    }
    _pollingSocial = true;
    Object? lastError;
    try {
      for (var attempt = 0; attempt < maxPollAttempts; attempt++) {
        if (!_alive || id != state.socialJobId) return;
        try {
          final job = await _socialRepo.getStatus(id);
          if (!_alive || id != state.socialJobId) return;
          lastError = null;
          _socialStatusGeneration++;
          _applySocialJob(job);
          if (job.isTerminal || state.socialConnected) return;
        } catch (e) {
          lastError = e;
        }
        await Future<void>.delayed(const Duration(seconds: 2));
      }
      if (!_alive || id != state.socialJobId) return;
      state = state.copyWith(
        socialError:
            'We lost the connection to the import. Refresh to check it.',
      );
      ErrorHandler.reportError(
        lastError ?? 'Social import polling timed out',
        'Social import polling exhausted after $maxPollAttempts attempts',
      );
    } finally {
      _pollingSocial = false;
    }
  }

  Future<void> _handleSocialOAuthUri(Uri uri) async {
    if (uri.scheme != 'fitcheck.ai' || uri.host != 'social-import-callback') {
      return;
    }
    if (!_alive) return;
    final callbackJobId = uri.queryParameters['job_id'];
    if (callbackJobId != null && callbackJobId.isNotEmpty) {
      if (state.socialJobId.isNotEmpty && callbackJobId != state.socialJobId) {
        return;
      }
      state = state.copyWith(socialJobId: callbackJobId);
      _persistSocialImportState();
    }
    final status = (uri.queryParameters['status'] ?? '').toLowerCase();
    final message =
        uri.queryParameters['message'] ?? 'Your account was not connected.';
    if (status == 'success') {
      await refreshSocialStatus();
      if (_alive && state.socialJob != null && !state.socialJob!.isTerminal) {
        _subscribeToSocialEvents(
          state.socialJobId,
          lastEventId: _lastEventIdOrNull,
        );
      }
      ErrorHandler.showSuccess(message, title: 'Account connected');
      return;
    }
    if (_alive) state = state.copyWith(socialError: message);
    await refreshSocialStatus();
    ErrorHandler.showError(message, title: 'Not connected');
  }

  Future<void> _restoreSocialImportState() async {
    try {
      final persisted = (await _persistence.getString(_socialJobKey) ?? '')
          .trim();
      if (!_alive || persisted.isEmpty || state.socialJobId.isNotEmpty) return;
      final lastEvent = await _persistence.getInt(_socialEventKey) ?? -1;
      if (!_alive) return;
      state = state.copyWith(
        socialJobId: persisted,
        socialLastEventId: lastEvent,
      );
      await refreshSocialStatus();
      if (!_alive) return;
      final job = state.socialJob;
      if (job == null || job.isTerminal) {
        _clearPersistedSocialImportState();
        return;
      }
      _subscribeToSocialEvents(persisted, lastEventId: _lastEventIdOrNull);
    } catch (e, stack) {
      ErrorHandler.reportError(
        e,
        'Social import restore failed',
        stackTrace: stack,
      );
    }
  }

  void _persistSocialImportState() {
    final id = state.socialJobId.trim();
    if (id.isEmpty) {
      _clearPersistedSocialImportState();
      return;
    }
    final lastEvent = _lastEventIdOrNull;
    final persistence = _persistence;
    unawaited(() async {
      await persistence.setString(_socialJobKey, id);
      if (lastEvent != null) {
        await persistence.setInt(_socialEventKey, lastEvent);
      } else {
        await persistence.remove(_socialEventKey);
      }
    }());
  }

  void _clearPersistedSocialImportState() {
    final persistence = _persistence;
    unawaited(() async {
      await persistence.remove(_socialJobKey);
      await persistence.remove(_socialEventKey);
    }());
  }
}

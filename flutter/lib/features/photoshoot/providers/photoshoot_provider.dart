import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/ai_consent_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/sse_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/permission_helper.dart';
import '../models/photoshoot_models.dart';
import '../repositories/photoshoot_repository.dart';

enum PhotoshootStep { upload, configure, generating, results }

/// What [PhotoshootNotifier.generate] did.
enum PhotoshootStart {
  started,

  /// The daily limit is used up. The view offers the referral dialog.
  limitReached,

  /// Blocked by consent or validation, or the start request failed.
  notStarted,
}

final photoshootRepositoryProvider = Provider<PhotoshootRepository>(
  (ref) => PhotoshootRepository(),
);

/// The Photoshoot tab state.
///
/// autoDispose: the shell's IndexedStack keeps the tab mounted once it is
/// opened, so a running generation survives tab switches and pushed routes.
/// Sign-out removes the shell route, which disposes the state, so one
/// account's photos never carry into the next session.
final photoshootProvider =
    NotifierProvider.autoDispose<PhotoshootNotifier, PhotoshootState>(
      PhotoshootNotifier.new,
    );

const _unset = Object();

@immutable
class PhotoshootState {
  const PhotoshootState({
    this.step = PhotoshootStep.upload,
    this.photos = const [],
    this.useCase = PhotoshootUseCase.linkedin,
    this.aspectRatio = PhotoshootAspectRatio.square,
    this.customPrompt = '',
    this.numImages = PhotoshootNotifier.maxImages,
    this.usage,
    this.usageLoading = false,
    this.usageError,
    this.jobId = '',
    this.progress = 0,
    this.status = '',
    this.currentBatch = 0,
    this.totalBatches = 0,
    this.etaSeconds = 0,
    this.sceneLabel = '',
    this.images = const [],
    this.failedIndices = const [],
    this.failedCount = 0,
    this.partialSuccess = false,
    this.sessionId = '',
    this.cancelling = false,
    this.downloadingIndex,
    this.downloadingAll = false,
    this.retryingIndex,
    this.error,
  });

  final PhotoshootStep step;
  final List<File> photos;
  final PhotoshootUseCase useCase;
  final PhotoshootAspectRatio aspectRatio;
  final String customPrompt;
  final int numImages;

  /// Null until loaded, or when the load failed (free defaults apply).
  final PhotoshootUsage? usage;
  final bool usageLoading;
  final Object? usageError;

  final String jobId;

  /// 0 to 100: 10 for the upload, 90 spread over the images.
  final int progress;
  final String status;
  final int currentBatch;
  final int totalBatches;
  final int etaSeconds;
  final String sceneLabel;

  final List<GeneratedImage> images;
  final List<int> failedIndices;
  final int failedCount;
  final bool partialSuccess;
  final String sessionId;

  final bool cancelling;

  /// Index of the image being saved, while a save runs.
  final int? downloadingIndex;
  final bool downloadingAll;

  /// Failed slot being retried.
  final int? retryingIndex;

  /// Last generation failure, shown as a banner on the configure step.
  final Object? error;

  bool get isGenerating => step == PhotoshootStep.generating;
  bool get isDownloading => downloadingIndex != null;

  int get remainingToday => usage?.remaining ?? PhotoshootNotifier.maxImages;
  int get effectiveMaxImages => remainingToday.clamp(
    PhotoshootNotifier.minImages,
    PhotoshootNotifier.maxImages,
  );

  bool get canGenerate =>
      photos.isNotEmpty &&
      numImages <= remainingToday &&
      (useCase != PhotoshootUseCase.custom || customPrompt.trim().isNotEmpty);

  PhotoshootState copyWith({
    PhotoshootStep? step,
    List<File>? photos,
    PhotoshootUseCase? useCase,
    PhotoshootAspectRatio? aspectRatio,
    String? customPrompt,
    int? numImages,
    Object? usage = _unset,
    bool? usageLoading,
    Object? usageError = _unset,
    String? jobId,
    int? progress,
    String? status,
    int? currentBatch,
    int? totalBatches,
    int? etaSeconds,
    String? sceneLabel,
    List<GeneratedImage>? images,
    List<int>? failedIndices,
    int? failedCount,
    bool? partialSuccess,
    String? sessionId,
    bool? cancelling,
    Object? downloadingIndex = _unset,
    bool? downloadingAll,
    Object? retryingIndex = _unset,
    Object? error = _unset,
  }) => PhotoshootState(
    step: step ?? this.step,
    photos: photos ?? this.photos,
    useCase: useCase ?? this.useCase,
    aspectRatio: aspectRatio ?? this.aspectRatio,
    customPrompt: customPrompt ?? this.customPrompt,
    numImages: numImages ?? this.numImages,
    usage: identical(usage, _unset) ? this.usage : usage as PhotoshootUsage?,
    usageLoading: usageLoading ?? this.usageLoading,
    usageError: identical(usageError, _unset) ? this.usageError : usageError,
    jobId: jobId ?? this.jobId,
    progress: progress ?? this.progress,
    status: status ?? this.status,
    currentBatch: currentBatch ?? this.currentBatch,
    totalBatches: totalBatches ?? this.totalBatches,
    etaSeconds: etaSeconds ?? this.etaSeconds,
    sceneLabel: sceneLabel ?? this.sceneLabel,
    images: images ?? this.images,
    failedIndices: failedIndices ?? this.failedIndices,
    failedCount: failedCount ?? this.failedCount,
    partialSuccess: partialSuccess ?? this.partialSuccess,
    sessionId: sessionId ?? this.sessionId,
    cancelling: cancelling ?? this.cancelling,
    downloadingIndex: identical(downloadingIndex, _unset)
        ? this.downloadingIndex
        : downloadingIndex as int?,
    downloadingAll: downloadingAll ?? this.downloadingAll,
    retryingIndex: identical(retryingIndex, _unset)
        ? this.retryingIndex
        : retryingIndex as int?,
    error: identical(error, _unset) ? this.error : error,
  );
}

class PhotoshootNotifier extends Notifier<PhotoshootState> {
  static const int maxPhotos = 4;
  static const int minImages = 1;
  static const int maxImages = 10;
  static const int batchSize = 10;
  static const int maxPollAttempts = 60;

  /// Delay between status polls. Tests shorten it.
  @visibleForTesting
  static Duration pollInterval = const Duration(seconds: 2);

  late PhotoshootRepository _repo;
  final ImagePicker _picker = ImagePicker();

  StreamSubscription<ServerSentEvent>? _sse;
  Timer? _pollTimer;

  /// One poll loop per run: SSE error, a silent stream end and the synthetic
  /// `error` event all report the same failure.
  bool _pollStarted = false;

  /// Set before the first await of the completion flow. The terminal
  /// `job_complete` closes the stream, whose onDone would otherwise start a
  /// poll that runs the completion (snackbar, analytics) a second time.
  bool _completionHandled = false;

  /// Base64 of each photo by path, so a slot retry does not re-encode.
  final Map<String, String> _encoded = {};

  final Map<int, String> _sceneLabels = {};
  final List<int> _latencySamples = [];
  DateTime _lastImageAt = DateTime.now();

  @override
  PhotoshootState build() {
    _repo = ref.watch(photoshootRepositoryProvider);
    ref.onDispose(_stopJobListeners);
    unawaited(Future<void>.value().then((_) => fetchUsage()));
    return const PhotoshootState(usageLoading: true);
  }

  void _stopJobListeners() {
    _sse?.cancel();
    _sse = null;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// True while [id] is the job this notifier is running. Every async
  /// continuation checks it before writing state, so a cancelled or replaced
  /// job can never write into the current run.
  bool _isCurrent(String id) =>
      ref.mounted && id.isNotEmpty && id == state.jobId && state.isGenerating;

  Future<void> fetchUsage() async {
    if (!ref.mounted) return;
    state = state.copyWith(usageLoading: true, usageError: null);
    try {
      final usage = await _repo.getUsage();
      if (!ref.mounted) return;
      final remaining = usage.remaining.clamp(minImages, maxImages);
      state = state.copyWith(
        usage: usage,
        usageLoading: false,
        numImages: state.numImages > usage.remaining ? remaining : null,
      );
    } catch (e) {
      // Non-blocking: usage stays null, so the free default applies and a
      // failed fetch never locks the user out.
      if (!ref.mounted) return;
      state = state.copyWith(usage: null, usageLoading: false, usageError: e);
    }
  }

  // Photos ------------------------------------------------------------------

  Future<void> pickPhotos() async {
    if (state.photos.length >= maxPhotos) {
      ErrorHandler.showValidation(
        'You can add up to $maxPhotos photos.',
        title: 'Photo limit',
      );
      return;
    }
    if (!await PermissionHelper.confirmPhotoRationale()) return;
    final List<XFile> picked;
    try {
      picked = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (_) {
      await PermissionHelper.showDeniedRecovery(permissionName: 'Photos');
      return;
    }
    addPhotos([for (final x in picked) File(x.path)]);
  }

  Future<void> pickFromCamera() async {
    if (state.photos.length >= maxPhotos) {
      ErrorHandler.showValidation(
        'You can add up to $maxPhotos photos.',
        title: 'Photo limit',
      );
      return;
    }
    if (!await PermissionHelper.confirmCameraRationale()) return;
    final XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (_) {
      await PermissionHelper.showDeniedRecovery(permissionName: 'Camera');
      return;
    }
    if (picked != null) addPhotos([File(picked.path)]);
  }

  /// Adds photos up to [maxPhotos].
  void addPhotos(List<File> files) {
    if (!ref.mounted || files.isEmpty) return;
    final room = maxPhotos - state.photos.length;
    if (room <= 0) return;
    state = state.copyWith(photos: [...state.photos, ...files.take(room)]);
  }

  void removePhoto(int index) {
    if (index < 0 || index >= state.photos.length) return;
    final removed = state.photos[index];
    _encoded.remove(removed.path);
    state = state.copyWith(photos: [...state.photos]..removeAt(index));
  }

  // Configuration -----------------------------------------------------------

  void setUseCase(PhotoshootUseCase useCase) => state = state.copyWith(
    useCase: useCase,
    customPrompt: useCase == PhotoshootUseCase.custom ? null : '',
  );

  void setCustomPrompt(String prompt) =>
      state = state.copyWith(customPrompt: prompt);

  void setNumImages(int count) => state = state.copyWith(
    numImages: count.clamp(minImages, state.effectiveMaxImages),
  );

  void setAspectRatio(PhotoshootAspectRatio ratio) =>
      state = state.copyWith(aspectRatio: ratio);

  void goToConfigure() {
    if (state.photos.isEmpty) {
      ErrorHandler.showValidation(
        'Add at least one photo.',
        title: 'No photos',
      );
      return;
    }
    state = state.copyWith(step: PhotoshootStep.configure);
  }

  void backToUpload() {
    if (state.step == PhotoshootStep.configure) {
      state = state.copyWith(step: PhotoshootStep.upload, error: null);
    }
  }

  // Generation --------------------------------------------------------------

  Future<List<String>> _encodePhotos(List<File> photos) => Future.wait(
    photos.map((file) async {
      final cached = _encoded[file.path];
      if (cached != null) return cached;
      final bytes = await file.readAsBytes();
      return _encoded[file.path] = await compute(_encodeBase64, bytes);
    }),
  );

  Future<PhotoshootStart> generate() async {
    final s = state;
    if (s.isGenerating || s.photos.isEmpty) return PhotoshootStart.notStarted;
    if (s.useCase == PhotoshootUseCase.custom &&
        s.customPrompt.trim().isEmpty) {
      ErrorHandler.showValidation(
        'Describe the look you want.',
        title: 'Prompt needed',
      );
      return PhotoshootStart.notStarted;
    }
    if (s.numImages > s.remainingToday) return PhotoshootStart.limitReached;

    // Third-party AI consent (Apple 5.1.2(i)) before any photo is read.
    if (!await ref.read(aiConsentServiceProvider).ensureConsent(
      featureLabel: 'AI Photoshoot',
    )) {
      return PhotoshootStart.notStarted;
    }
    if (!ref.mounted || state.isGenerating) return PhotoshootStart.notStarted;

    _stopJobListeners();
    _pollStarted = false;
    _completionHandled = false;
    _sceneLabels.clear();
    _latencySamples.clear();
    _lastImageAt = DateTime.now();
    state = state.copyWith(
      step: PhotoshootStep.generating,
      jobId: '',
      error: null,
      progress: 0,
      status: 'Preparing your photos',
      currentBatch: 0,
      totalBatches: 0,
      etaSeconds: 0,
      sceneLabel: '',
      images: const [],
      failedIndices: const [],
      failedCount: 0,
      partialSuccess: false,
      sessionId: '',
      cancelling: false,
    );

    final useCase = state.useCase;
    AnalyticsService.instance.track(
      'photoshoot_session_started',
      properties: {
        'use_case': useCase.name,
        'num_images': state.numImages,
        'photo_count': state.photos.length,
        'source': 'flutter_app',
      },
    );

    try {
      final photos = await _encodePhotos(state.photos);
      if (!ref.mounted) return PhotoshootStart.notStarted;
      state = state.copyWith(status: 'Starting', progress: 10);
      final response = await _repo.startGeneration(
        photos: photos,
        useCase: useCase,
        customPrompt: useCase == PhotoshootUseCase.custom
            ? state.customPrompt
            : null,
        numImages: state.numImages,
        batchSize: batchSize,
        aspectRatio: state.aspectRatio,
      );
      if (!ref.mounted || !state.isGenerating) {
        return PhotoshootStart.notStarted;
      }
      state = state.copyWith(jobId: response.jobId);
      _subscribe(response.jobId);
      return PhotoshootStart.started;
    } catch (e, stack) {
      if (!ref.mounted) return PhotoshootStart.notStarted;
      final limit = e is RateLimitException && e.errorCode != 'SERVER_BUSY';
      AnalyticsService.instance.track(
        'photoshoot_session_failed',
        properties: {
          'use_case': useCase.name,
          'num_images': state.numImages,
          'error_message': ErrorHandler.extractMessage(e),
          'source': 'flutter_app',
        },
      );
      state = state.copyWith(
        step: PhotoshootStep.configure,
        error: limit ? null : e,
      );
      if (limit) return PhotoshootStart.limitReached;
      // Shown as the banner on the configure step, with a retry.
      ErrorHandler.reportError(
        e,
        ErrorHandler.extractMessage(e),
        stackTrace: stack,
      );
      return PhotoshootStart.notStarted;
    }
  }

  void _subscribe(String id) {
    _sse?.cancel();
    _sse = _repo
        .subscribeToEvents(id)
        .listen(
          (event) => _onEvent(id, event),
          onError: (Object e) {
            debugPrint('Photoshoot SSE error: $e');
            _startPollFallback(id);
          },
          onDone: () {
            // A stream that ends while the job runs falls back to polling.
            if (_isCurrent(id)) _startPollFallback(id);
          },
        );
  }

  void _startPollFallback(String id) {
    if (_completionHandled || _pollStarted || !_isCurrent(id)) return;
    _pollStarted = true;
    _poll(id);
  }

  void _onEvent(String id, ServerSentEvent event) {
    if (!_isCurrent(id)) return;
    final data = event.data;
    switch (event.type) {
      case 'generation_started':
        state = state.copyWith(
          status: 'Generating',
          totalBatches: _int(data?['total_batches']) ?? 1,
        );
      case 'batch_started':
        final batch = _int(data?['batch_index']) ?? 0;
        state = state.copyWith(
          currentBatch: batch,
          status: 'Batch ${batch + 1} of ${state.totalBatches}',
        );
        final labels = data?['scene_labels'];
        if (labels is Map) {
          _sceneLabels.clear();
          for (final entry in labels.entries) {
            final index = int.tryParse(entry.key.toString());
            final label = entry.value?.toString();
            if (index != null && label != null && label.isNotEmpty) {
              _sceneLabels[index] = label;
            }
          }
          _updateScene();
        }
      case 'image_complete':
        if (data != null) _onImage(data);
      case 'image_failed':
        final failedIndex = data?['index'];
        final failed = [...state.failedIndices];
        if (failedIndex is int && !failed.contains(failedIndex)) {
          failed
            ..add(failedIndex)
            ..sort();
        }
        final count = _int(data?['failed_count']) ?? failed.length;
        state = state.copyWith(
          failedIndices: failed,
          failedCount: count,
          partialSuccess: count > 0,
        );
        _updateScene();
      case 'job_complete':
        _complete(id, data);
      case 'job_failed':
        _fail(id, data?['error']?.toString() ?? 'Generation failed.');
      case 'job_cancelled':
        _stopJobListeners();
        state = state.copyWith(step: PhotoshootStep.configure, jobId: '');
      case 'error':
        _startPollFallback(id);
    }
  }

  void _onImage(Map<String, dynamic> data) {
    final image = GeneratedImage.fromJson(data);
    // Replay-safe: a reconnect replays history, so a known id is ignored.
    if (state.images.any((g) => g.id == image.id)) return;
    final images = [...state.images, image];
    // The server total wins over the requested count when present.
    final total = data['total_count'];
    final denominator = total is int && total > 0 ? total : state.numImages;
    final fraction = (images.length / denominator).clamp(0.0, 1.0);
    final now = DateTime.now();
    _latencySamples.add(now.difference(_lastImageAt).inMilliseconds);
    _lastImageAt = now;
    state = state.copyWith(
      images: images,
      progress: 10 + (fraction * 90).toInt(),
      status: '${images.length} of $denominator done',
      etaSeconds: _eta(images.length),
    );
    _updateScene();
  }

  /// Rolling ETA from per-image latency. The first sample includes planning,
  /// so the ETA starts from the second image.
  int _eta(int done) {
    final remaining = state.numImages - done;
    if (_latencySamples.length < 2 || remaining <= 0) return 0;
    final avg =
        _latencySamples.reduce((a, b) => a + b) / _latencySamples.length;
    return ((avg * remaining) / 1000).round();
  }

  /// Shows the next scene whose slot has no image yet.
  void _updateScene() {
    final done = {for (final img in state.images) img.index};
    final next =
        (_sceneLabels.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
            .where((e) => !done.contains(e.key))
            .firstOrNull;
    state = state.copyWith(sceneLabel: next?.value ?? '');
  }

  /// Merges an authoritative status. Idempotent.
  void _reconcile(PhotoshootJobStatusResponse status) {
    final failed = [...status.failedIndices]..sort();
    state = state.copyWith(
      images: listEquals(state.images, status.images) ? null : status.images,
      failedIndices: listEquals(state.failedIndices, failed) ? null : failed,
      failedCount: status.failedCount,
      partialSuccess: status.partialSuccess,
    );
  }

  void _fail(String id, String message) {
    _stopJobListeners();
    _sceneLabels.clear();
    _latencySamples.clear();
    AnalyticsService.instance.track(
      'photoshoot_session_failed',
      properties: {
        'job_id': id,
        'use_case': state.useCase.name,
        'num_images': state.numImages,
        'error_message': message,
        'source': 'flutter_app',
      },
    );
    state = state.copyWith(
      step: PhotoshootStep.configure,
      jobId: '',
      etaSeconds: 0,
      sceneLabel: '',
      error: message,
    );
    // Shown as the banner on the configure step, with a retry.
    ErrorHandler.reportError(message, 'Photoshoot job failed');
  }

  Future<void> _complete(String id, Map<String, dynamic>? data) async {
    if (_completionHandled) return;
    _completionHandled = true;
    _sceneLabels.clear();
    _latencySamples.clear();

    final failedFromEvent =
        (data?['failed_indices'] as List<dynamic>? ?? [])
            .whereType<int>()
            .toList()
          ..sort();
    final failed = failedFromEvent.isNotEmpty
        ? failedFromEvent
        : state.failedIndices;
    final failedCount = _int(data?['failed_count']) ?? failed.length;
    final usage = data?['usage'];
    state = state.copyWith(
      progress: 100,
      status: 'Done',
      etaSeconds: 0,
      sceneLabel: '',
      sessionId: data?['session_id']?.toString() ?? id,
      usage: usage is Map<String, dynamic>
          ? PhotoshootUsage.fromJson(usage)
          : state.usage,
      failedIndices: failed,
      failedCount: failedCount,
      partialSuccess: data?['partial_success'] as bool? ?? failedCount > 0,
    );

    // job_complete carries counts, not images: fill the gallery from the
    // status before showing results, so a dropped image_complete event can
    // never produce an empty results screen.
    try {
      final status = await _repo.getJobStatus(id);
      if (!_isCurrent(id)) return;
      _reconcile(status);
      if (status.usage != null) state = state.copyWith(usage: status.usage);
    } catch (e) {
      // Non-fatal: results open with the images SSE delivered.
      debugPrint('Photoshoot final status reconcile failed: $e');
    }
    if (!_isCurrent(id)) return;

    _stopJobListeners();
    state = state.copyWith(step: PhotoshootStep.results, cancelling: false);
    final s = state;
    AnalyticsService.instance.track(
      'photoshoot_session_completed',
      properties: {
        'session_id': s.sessionId,
        'job_id': id,
        'use_case': s.useCase.name,
        'num_images': s.numImages,
        'generated_count': s.images.length,
        'failed_count': s.failedCount,
        'partial_success': s.partialSuccess,
        'source': 'flutter_app',
      },
    );
    if (s.partialSuccess) {
      ErrorHandler.showWarning(
        '${s.images.length} ready, ${s.failedCount} failed.',
        title: 'Partly done',
      );
    } else {
      ErrorHandler.showSuccess(
        '${s.images.length} photos are ready.',
        title: 'Done',
      );
    }
  }

  Future<void> _wait(Duration delay) {
    final done = Completer<void>();
    _pollTimer?.cancel();
    _pollTimer = Timer(delay, done.complete);
    // A cancelled timer never completes the future, which ends the loop.
    return done.future;
  }

  Future<void> _poll(String id, {int attempt = 0}) async {
    if (!_isCurrent(id)) return;
    if (attempt >= maxPollAttempts) {
      _fail(id, 'We lost the connection. Please try again.');
      return;
    }
    final PhotoshootJobStatusResponse status;
    try {
      status = await _repo.getJobStatus(id);
    } catch (e) {
      if (attempt + 1 >= maxPollAttempts) {
        ErrorHandler.reportError(e, 'Photoshoot polling exhausted');
      }
      if (!_isCurrent(id)) return;
      await _wait(pollInterval * 1.5);
      return _poll(id, attempt: attempt + 1);
    }
    if (!_isCurrent(id)) return;

    _reconcile(status);
    if (status.totalCount > 0) {
      state = state.copyWith(
        progress:
            10 + ((status.generatedCount / status.totalCount) * 90).toInt(),
      );
    }
    _updateScene();

    switch (status.status) {
      case 'complete':
        await _complete(id, {
          'session_id': status.jobId,
          'failed_count': status.failedCount,
          'failed_indices': status.failedIndices,
          'partial_success': status.partialSuccess,
          if (status.usage != null) 'usage': status.usage!.toJson(),
        });
      case 'failed':
        _fail(id, status.error ?? 'Generation failed.');
      case 'cancelled':
        _stopJobListeners();
        state = state.copyWith(step: PhotoshootStep.configure, jobId: '');
      default:
        await _wait(pollInterval);
        return _poll(id, attempt: attempt + 1);
    }
  }

  /// Cancels the running job. Returns false when the server did not accept
  /// the cancel; the job then keeps running and the progress stays on screen.
  Future<bool> cancel() async {
    final id = state.jobId;
    if (id.isEmpty || !state.isGenerating || state.cancelling) return false;
    state = state.copyWith(cancelling: true);
    try {
      await _repo.cancelJob(id);
    } catch (e, stack) {
      if (_isCurrent(id)) state = state.copyWith(cancelling: false);
      ErrorHandler.showError(e, title: 'Could not cancel', stackTrace: stack);
      return false;
    }
    if (!_isCurrent(id)) return true;
    _stopJobListeners();
    state = state.copyWith(
      step: PhotoshootStep.configure,
      jobId: '',
      cancelling: false,
      etaSeconds: 0,
      sceneLabel: '',
    );
    return true;
  }

  // Results -----------------------------------------------------------------

  /// Generates one image into a failed slot.
  Future<void> retryFailedSlot(int index) async {
    final s = state;
    if (!s.failedIndices.contains(index) ||
        s.retryingIndex != null ||
        s.photos.isEmpty) {
      return;
    }
    if (!await ref.read(aiConsentServiceProvider).ensureConsent(
      featureLabel: 'AI Photoshoot',
    )) {
      return;
    }
    if (!ref.mounted) return;
    state = state.copyWith(retryingIndex: index);
    try {
      final result = await _repo.generateSync(
        photos: await _encodePhotos(state.photos),
        useCase: state.useCase,
        customPrompt: state.useCase == PhotoshootUseCase.custom
            ? state.customPrompt
            : null,
        numImages: 1,
        aspectRatio: state.aspectRatio,
      );
      if (!ref.mounted) return;
      if (result.images.isEmpty) {
        throw Exception('No replacement image came back.');
      }
      final replacement = result.images.first.copyWith(index: index);
      final images = [
        ...state.images.where((img) => img.index != index),
        replacement,
      ]..sort((a, b) => a.index.compareTo(b.index));
      final failed = [...state.failedIndices]..remove(index);
      state = state.copyWith(
        images: images,
        failedIndices: failed,
        failedCount: failed.length,
        partialSuccess: failed.isNotEmpty,
        usage: result.usage ?? state.usage,
      );
      ErrorHandler.showSuccess(
        'Photo ${index + 1} is ready.',
        title: 'Replaced',
      );
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Retry failed', stackTrace: stack);
    } finally {
      if (ref.mounted) state = state.copyWith(retryingIndex: null);
    }
  }

  Future<void> _save(int index) async {
    final bytes = await _repo.imageBytes(state.images[index]);
    await _repo.saveToGallery(bytes, 'photoshoot_${state.sessionId}_$index');
  }

  Future<void> downloadImage(int index) async {
    if (index < 0 || index >= state.images.length || state.isDownloading) {
      return;
    }
    state = state.copyWith(downloadingIndex: index);
    try {
      await _save(index);
      ErrorHandler.showSuccess('Saved to your gallery.', title: 'Saved');
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
    } finally {
      if (ref.mounted) state = state.copyWith(downloadingIndex: null);
    }
  }

  Future<void> downloadAll() async {
    if (state.images.isEmpty || state.isDownloading) return;
    final total = state.images.length;
    final failed = <int>[];
    Object? lastError;
    for (var i = 0; i < total; i++) {
      if (!ref.mounted) return;
      state = state.copyWith(downloadingIndex: i, downloadingAll: true);
      try {
        await _save(i);
      } catch (e) {
        failed.add(i + 1);
        lastError = e;
      }
    }
    if (!ref.mounted) return;
    state = state.copyWith(downloadingIndex: null, downloadingAll: false);
    if (failed.isEmpty) {
      ErrorHandler.showSuccess(
        'All $total photos are in your gallery.',
        title: 'Saved',
      );
    } else {
      ErrorHandler.showError(
        '${total - failed.length} of $total saved. '
        '${ErrorHandler.extractMessage(lastError)}',
        title: 'Some photos not saved',
      );
    }
  }

  /// Starts over. With [keepPhotos] the photos stay and the flow returns to
  /// the configure step ("New style").
  void reset({bool keepPhotos = false}) {
    _stopJobListeners();
    _pollStarted = false;
    _completionHandled = false;
    _sceneLabels.clear();
    _latencySamples.clear();
    if (!keepPhotos) _encoded.clear();
    state = PhotoshootState(
      step: keepPhotos ? PhotoshootStep.configure : PhotoshootStep.upload,
      photos: keepPhotos ? state.photos : const [],
      usage: state.usage,
      numImages: state.effectiveMaxImages,
    );
    unawaited(fetchUsage());
  }
}

String _encodeBase64(Uint8List bytes) => base64Encode(bytes);

int? _int(Object? value) => value is num ? value.toInt() : null;

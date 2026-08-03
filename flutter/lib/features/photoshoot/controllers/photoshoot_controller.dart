import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/env_config.dart';
import '../../../core/services/ai_consent_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/sse_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/permission_helper.dart';
import '../models/photoshoot_models.dart';
import '../repositories/photoshoot_repository.dart';
import '../../../core/utils/frame_safe.dart';

/// Steps in the photoshoot generation flow
enum PhotoshootStep { upload, configure, generating, results }

/// Controller for AI Photoshoot Generator feature
class PhotoshootController extends GetxController {
  final PhotoshootRepository _repository = PhotoshootRepository();
  final ImagePicker _imagePicker = ImagePicker();

  // TextEditingController for custom prompt field
  final TextEditingController customPromptController = TextEditingController();

  // SSE subscription for real-time progress
  StreamSubscription<ServerSentEvent>? _sseSubscription;

  // Guards the bounded poll fallback so SSE error, silent stream end, and the
  // synthetic `error` event (SSEService fires all three for one failure) can
  // never start overlapping poll loops.
  bool _pollStarted = false;

  // Current step in the flow
  final Rx<PhotoshootStep> currentStep = PhotoshootStep.upload.obs;

  // Photo upload state (1-4 photos)
  final RxList<File> selectedPhotos = <File>[].obs;
  static const int maxPhotos = 4;

  // Configuration state
  final Rx<PhotoshootUseCase> selectedUseCase = PhotoshootUseCase.linkedin.obs;
  final Rx<PhotoshootAspectRatio> selectedAspectRatio =
      PhotoshootAspectRatio.square.obs;
  final RxString customPrompt = ''.obs;
  final RxInt numImages = 10.obs;
  static const int minImages = 1;
  static const int maxImages = 10;
  static const int batchSize = 10;

  // Usage state
  final Rx<PhotoshootUsage?> usage = Rx<PhotoshootUsage?>(null);
  final RxBool isLoadingUsage = false.obs;

  // Generation state
  final RxBool isGenerating = false.obs;
  final RxInt generationProgress = 0.obs;
  final RxString generationStatus = ''.obs;
  final RxString jobId = ''.obs;
  final RxInt currentBatch = 0.obs;
  final RxInt totalBatches = 0.obs;

  // Live generation visibility (photoshoot speed pass, 2026-08-03)
  final RxInt etaSeconds = 0.obs;
  final RxString currentSceneLabel = ''.obs;
  final Map<int, String> _sceneLabels = {};
  final List<int> _latencySamples = [];
  DateTime _lastImageAt = DateTime.now();

  // Results state
  final RxList<GeneratedImage> generatedImages = <GeneratedImage>[].obs;
  final RxList<int> failedIndices = <int>[].obs;
  final RxInt failedCount = 0.obs;
  final RxBool partialSuccess = false.obs;
  final RxString sessionId = ''.obs;

  // Download state
  final RxBool isDownloading = false.obs;
  final RxInt downloadingIndex = (-1).obs;
  final RxInt retryingFailedIndex = (-1).obs;

  // Error state
  final RxString error = ''.obs;

  // Computed properties
  int get remainingToday => usage.value?.remaining ?? 10;
  int get effectiveMaxImages => remainingToday.clamp(minImages, maxImages);
  bool get canGenerate =>
      selectedPhotos.isNotEmpty &&
      numImages.value <= remainingToday &&
      (selectedUseCase.value != PhotoshootUseCase.custom ||
          customPrompt.value.isNotEmpty);

  @override
  void onInit() {
    super.onInit();
    fetchUsage();
  }

  @override
  void onClose() {
    _sseSubscription?.cancel();
    customPromptController.dispose();
    super.onClose();
  }

  /// Fetch current usage stats
  Future<void> fetchUsage() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    isLoadingUsage.value = true;
    try {
      usage.value = await _repository.getUsage();
      // Adjust numImages if it exceeds remaining
      if (numImages.value > remainingToday) {
        numImages.value = remainingToday.clamp(minImages, maxImages);
      }
    } catch (e) {
      // Non-blocking, default to free limits. Keep usage null (rather than a
      // PhotoshootUsage with remaining: 0) so the computed remainingToday
      // falls back to the free default and the user isn't locked out of
      // generating because a usage fetch failed.
      usage.value = null;
    } finally {
      isLoadingUsage.value = false;
    }
  }

  /// Pick photos from gallery (adds to existing photos)
  Future<void> pickPhotos() async {
    if (!await PermissionHelper.confirmPhotoRationale()) return;

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // Calculate how many more photos we can add
        final spotsAvailable = maxPhotos - selectedPhotos.length;
        if (spotsAvailable <= 0) {
          ErrorHandler.showValidation('Maximum $maxPhotos photos allowed', title: 'Limit Reached');
          return;
        }

        // Add new photos to existing ones (up to the limit)
        final newFiles = images
            .take(spotsAvailable)
            .map((x) => File(x.path))
            .toList();
        selectedPhotos.addAll(newFiles);
        error.value = '';
      }
    } catch (e) {
      await PermissionHelper.showDeniedRecovery(permissionName: 'Photos');
    }
  }

  /// Pick a single photo from camera
  Future<void> pickFromCamera() async {
    if (selectedPhotos.length >= maxPhotos) {
      ErrorHandler.showValidation('Maximum $maxPhotos photos allowed', title: 'Limit Reached');
      return;
    }

    if (!await PermissionHelper.confirmCameraRationale()) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedPhotos.add(File(image.path));
        error.value = '';
      }
    } catch (e) {
      await PermissionHelper.showDeniedRecovery(permissionName: 'Camera');
    }
  }

  /// Remove a photo from selection
  void removePhoto(int index) {
    if (index >= 0 && index < selectedPhotos.length) {
      selectedPhotos.removeAt(index);
    }
  }

  /// Update selected use case
  void setUseCase(PhotoshootUseCase useCase) {
    selectedUseCase.value = useCase;
    if (useCase != PhotoshootUseCase.custom) {
      customPrompt.value = '';
    }
  }

  /// Update custom prompt
  void setCustomPrompt(String prompt) {
    customPrompt.value = prompt;
  }

  /// Update number of images
  void setNumImages(int count) {
    numImages.value = count.clamp(minImages, effectiveMaxImages);
  }

  /// Update aspect ratio
  void setAspectRatio(PhotoshootAspectRatio ratio) {
    selectedAspectRatio.value = ratio;
  }

  /// Navigate to next step
  void nextStep() {
    switch (currentStep.value) {
      case PhotoshootStep.upload:
        if (selectedPhotos.isEmpty) {
          ErrorHandler.showValidation('Please add at least one photo', title: 'No Photos');
          return;
        }
        currentStep.value = PhotoshootStep.configure;
        break;
      case PhotoshootStep.configure:
        if (!canGenerate) {
          if (selectedUseCase.value == PhotoshootUseCase.custom &&
              customPrompt.value.isEmpty) {
            ErrorHandler.showValidation('Please enter a custom prompt', title: 'Custom Prompt Required');
            return;
          }
          if (numImages.value > remainingToday) {
            _showReferralPrompt();
            return;
          }
        }
        generatePhotoshoot();
        break;
      case PhotoshootStep.generating:
        // No action during generation
        break;
      case PhotoshootStep.results:
        // Reset for new generation
        reset();
        break;
    }
  }

  /// Go back to previous step
  void previousStep() {
    switch (currentStep.value) {
      case PhotoshootStep.upload:
        // Already at first step
        break;
      case PhotoshootStep.configure:
        currentStep.value = PhotoshootStep.upload;
        break;
      case PhotoshootStep.generating:
        // Cannot go back during generation
        break;
      case PhotoshootStep.results:
        currentStep.value = PhotoshootStep.configure;
        break;
    }
  }

  /// Generate photoshoot images with SSE progress
  Future<void> generatePhotoshoot() async {
    // Third-party AI data-sharing consent gate (Apple 5.1.2(i)) — must run
    // before any photo bytes are read or uploaded.
    if (!await Get.find<AiConsentService>().ensureConsent(
      featureLabel: 'AI Photoshoot',
    )) {
      return;
    }

    if (!canGenerate) return;

    // Cancel any existing SSE subscription
    _sseSubscription?.cancel();
    // A fresh run may poll again; clear the previous run's fallback guard.
    _pollStarted = false;

    isGenerating.value = true;
    error.value = '';
    generationProgress.value = 0;
    generationStatus.value = 'Preparing your photos...';
    currentStep.value = PhotoshootStep.generating;
    generatedImages.clear();
    failedIndices.clear();
    failedCount.value = 0;
    partialSuccess.value = false;
    // Live-generation visibility state
    etaSeconds.value = 0;
    currentSceneLabel.value = '';
    _sceneLabels.clear();
    _latencySamples.clear();
    _lastImageAt = DateTime.now();

    AnalyticsService.instance.track(
      'photoshoot_session_started',
      properties: {
        'use_case': selectedUseCase.value.name,
        'num_images': numImages.value,
        'photo_count': selectedPhotos.length,
        'source': 'flutter_app',
      },
    );

    try {
      // Convert photos to base64
      generationStatus.value = 'Processing photos...';
      final List<String> photosBase64 = await Future.wait(
        selectedPhotos.map((file) async {
          final bytes = await file.readAsBytes();
          return await compute(_encodeBase64, bytes);
        }),
      );

      generationStatus.value = 'Starting generation...';
      generationProgress.value = 10;

      // Start generation job
      final response = await _repository.startGeneration(
        photos: photosBase64,
        useCase: selectedUseCase.value,
        customPrompt: selectedUseCase.value == PhotoshootUseCase.custom
            ? customPrompt.value
            : null,
        numImages: numImages.value,
        batchSize: batchSize,
        aspectRatio: selectedAspectRatio.value,
      );

      jobId.value = response.jobId;

      // Subscribe to SSE events for real-time progress
      _subscribeToEvents(response.jobId);
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
      AnalyticsService.instance.track(
        'photoshoot_session_failed',
        properties: {
          'use_case': selectedUseCase.value.name,
          'num_images': numImages.value,
          'error_message': error.value,
          'source': 'flutter_app',
        },
      );

      if (error.value.contains('limit') || error.value.contains('exceeded')) {
        _showReferralPrompt();
      } else {
        ErrorHandler.showError(error.value, title: 'Generation Failed');
      }

      currentStep.value = PhotoshootStep.configure;
      isGenerating.value = false;
    }
  }

  /// Update the ETA from rolling per-image latency (needs >= 2 samples).
  void _updateEta() {
    final remaining = numImages.value - generatedImages.length;
    if (_latencySamples.length < 2 || remaining <= 0) {
      etaSeconds.value = 0;
      return;
    }
    final avgMs =
        _latencySamples.reduce((a, b) => a + b) / _latencySamples.length;
    etaSeconds.value = ((avgMs * remaining) / 1000).round();
  }

  /// Show the label of the next scene whose slot has not produced an image.
  void _updateCurrentScene() {
    final done = generatedImages.map((img) => img.index).toSet();
    final entries = _sceneLabels.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in entries) {
      if (!done.contains(entry.key)) {
        currentSceneLabel.value = entry.value;
        return;
      }
    }
    currentSceneLabel.value = '';
  }

  /// Subscribe to SSE events for real-time progress
  void _subscribeToEvents(String id) {
    _sseSubscription?.cancel();
    _sseSubscription = _repository
        .subscribeToEvents(id)
        .listen(
          _handleSSEEvent,
          onError: (e) {
            debugPrint('SSE error: $e');
            // Fallback to polling if SSE fails
            _startPollFallback(id);
          },
          onDone: () {
            debugPrint('SSE stream ended');
            // If still generating, stream ended unexpectedly - fallback to polling
            if (isGenerating.value &&
                currentStep.value == PhotoshootStep.generating) {
              _startPollFallback(id);
            }
          },
        );
  }

  /// Start the bounded poll fallback once per run. SSE errors surface through
  /// several channels (stream onError, a synthetic `error` event, silent
  /// onDone), so the `_pollStarted` guard keeps exactly one poll loop alive.
  void _startPollFallback(String id) {
    if (_pollStarted) return;
    _pollStarted = true;
    _pollJobStatus(id);
  }

  /// Handle incoming SSE events
  void _handleSSEEvent(ServerSentEvent event) {
    debugPrint('Photoshoot SSE: ${event.type}');

    switch (event.type) {
      case 'connected':
      case 'heartbeat':
        break;

      case 'generation_started':
        generationStatus.value = 'Generating images...';
        totalBatches.value = event.data?['total_batches'] ?? 1;
        break;

      case 'batch_started':
        currentBatch.value = event.data?['batch_index'] ?? 0;
        generationStatus.value =
            'Processing batch ${currentBatch.value + 1}/${totalBatches.value}...';
        // Scene labels for the batch's slots: show which scene is generating.
        final labels = event.data?['scene_labels'];
        if (labels is Map) {
          _sceneLabels.clear();
          for (final entry in labels.entries) {
            final index = int.tryParse(entry.key.toString());
            final label = entry.value?.toString();
            if (index != null && label != null && label.isNotEmpty) {
              _sceneLabels[index] = label;
            }
          }
          _updateCurrentScene();
        }
        break;

      case 'image_complete':
        final imageData = event.data;
        if (imageData != null) {
          final image = GeneratedImage.fromJson(imageData);
          // Replay-safe: SSEService reconnects and the backend replays event
          // history, so a duplicate id must not re-append or re-roll ETA.
          if (!generatedImages.any((g) => g.id == image.id)) {
            generatedImages.add(image);
            // Update progress: 10% for upload, 90% for generation
            generationProgress.value =
                10 + ((generatedImages.length / numImages.value) * 90).toInt();
            generationStatus.value =
                'Generated ${generatedImages.length}/${numImages.value} images...';
            // Rolling latency for the ETA; the first sample is the planning
            // phase + first image, so the ETA only kicks in from image 2+.
            final now = DateTime.now();
            _latencySamples.add(now.difference(_lastImageAt).inMilliseconds);
            _lastImageAt = now;
            _updateEta();
            _updateCurrentScene();
          }
        }
        break;

      case 'image_failed':
        final failedIndex = event.data?['index'];
        if (failedIndex is int && !failedIndices.contains(failedIndex)) {
          failedIndices.add(failedIndex);
          failedIndices.sort();
        }
        failedCount.value = event.data?['failed_count'] ?? failedIndices.length;
        partialSuccess.value = failedCount.value > 0;
        _updateCurrentScene();
        debugPrint('Image generation failed at index: $failedIndex');
        break;

      case 'batch_complete':
        break;

      case 'job_complete':
        _handleJobComplete(event.data);
        break;

      case 'job_failed':
        error.value = event.data?['error'] ?? 'Generation failed';
        etaSeconds.value = 0;
        currentSceneLabel.value = '';
        _sceneLabels.clear();
        _latencySamples.clear();
        AnalyticsService.instance.track(
          'photoshoot_session_failed',
          properties: {
            'session_id': sessionId.value.isNotEmpty ? sessionId.value : jobId.value,
            'job_id': jobId.value,
            'use_case': selectedUseCase.value.name,
            'num_images': numImages.value,
            'error_message': error.value,
            'source': 'flutter_app',
          },
        );
        ErrorHandler.showError(error.value, title: 'Generation Failed');
        currentStep.value = PhotoshootStep.configure;
        isGenerating.value = false;
        _sseSubscription?.cancel();
        break;

      case 'job_cancelled':
        currentStep.value = PhotoshootStep.configure;
        isGenerating.value = false;
        _sseSubscription?.cancel();
        break;

      case 'error':
        // SSE connection error, fallback to polling (guarded: the stream's
        // onError callback fires for the same failure).
        _startPollFallback(jobId.value);
        break;
    }
  }

  /// Handle job completion
  void _handleJobComplete(Map<String, dynamic>? data) {
    generationProgress.value = 100;
    generationStatus.value = 'Complete!';
    etaSeconds.value = 0;
    currentSceneLabel.value = '';
    _sceneLabels.clear();
    _latencySamples.clear();

    if (data?['session_id'] != null) {
      sessionId.value = data!['session_id'];
    } else {
      sessionId.value = jobId.value;
    }

    if (data?['usage'] != null) {
      usage.value = PhotoshootUsage.fromJson(data!['usage']);
    }

    final completedFailedIndices =
        (data?['failed_indices'] as List<dynamic>? ?? [])
            .whereType<int>()
            .toList();
    if (completedFailedIndices.isNotEmpty) {
      failedIndices.assignAll(completedFailedIndices..sort());
    }
    failedCount.value = data?['failed_count'] ?? failedIndices.length;
    partialSuccess.value = data?['partial_success'] ?? (failedCount.value > 0);

    currentStep.value = PhotoshootStep.results;
    isGenerating.value = false;
    _sseSubscription?.cancel();

    AnalyticsService.instance.track(
      'photoshoot_session_completed',
      properties: {
        'session_id': sessionId.value,
        'job_id': jobId.value,
        'use_case': selectedUseCase.value.name,
        'num_images': numImages.value,
        'generated_count': generatedImages.length,
        'failed_count': failedCount.value,
        'partial_success': partialSuccess.value,
        'source': 'flutter_app',
      },
    );

    if (partialSuccess.value) {
      ErrorHandler.showWarning(
        '${generatedImages.length} generated, ${failedCount.value} failed.',
        title: 'Partially Complete',
      );
    } else {
      ErrorHandler.showSuccess(
        '${generatedImages.length} images generated!',
        title: 'Success',
      );
    }
  }

  /// Fallback polling if SSE fails
  Future<void> _pollJobStatus(String id, {int attempt = 0}) async {
    if (id.isEmpty || isClosed) return;

    // Bound the polling loop so a permanently unreachable job status endpoint
    // cannot spin forever (previously this recursion had no max-attempts cap).
    const maxPollAttempts = 60; // ~2 minutes at 2s cadence
    if (attempt >= maxPollAttempts) {
      debugPrint('Polling for job $id gave up after $attempt attempts');
      error.value = 'Lost connection while generating. Please try again.';
      ErrorHandler.showError(error.value, title: 'Connection Lost');
      currentStep.value = PhotoshootStep.configure;
      isGenerating.value = false;
      return;
    }

    try {
      final status = await _repository.getJobStatus(id);

      // Skip no-op updates: RxList.assignAll notifies even when identical,
      // and a changed-value check keeps the UI quiet on unchanged ticks.
      if (!listEquals(generatedImages, status.images)) {
        generatedImages.assignAll(status.images);
      }
      final failed = List<int>.from(status.failedIndices)..sort();
      if (!listEquals(failedIndices, failed)) {
        failedIndices.assignAll(failed);
      }
      if (failedCount.value != status.failedCount) {
        failedCount.value = status.failedCount;
      }
      if (partialSuccess.value != status.partialSuccess) {
        partialSuccess.value = status.partialSuccess;
      }
      if (status.totalCount > 0) {
        final progress =
            10 + ((status.generatedCount / status.totalCount) * 90).toInt();
        if (generationProgress.value != progress) {
          generationProgress.value = progress;
        }
      }
      _updateCurrentScene();

      switch (status.status) {
        case 'pending':
        case 'processing':
          await Future.delayed(const Duration(seconds: 2));
          if (isGenerating.value && !isClosed) {
            _pollJobStatus(id, attempt: attempt + 1);
          }
          break;
        case 'complete':
          _handleJobComplete({
            'session_id': status.jobId,
            'failed_count': status.failedCount,
            'failed_indices': status.failedIndices,
            'partial_success': status.partialSuccess,
            if (status.usage != null) 'usage': status.usage!.toJson(),
          });
          break;
        case 'failed':
          error.value = status.error ?? 'Generation failed';
          ErrorHandler.showError(error.value, title: 'Generation Failed');
          currentStep.value = PhotoshootStep.configure;
          isGenerating.value = false;
          break;
        case 'cancelled':
          currentStep.value = PhotoshootStep.configure;
          isGenerating.value = false;
          break;
      }
    } catch (e) {
      debugPrint('Poll status error (attempt ${attempt + 1}): $e');
      // Transient polling errors are retried until the bounded cap above is
      // reached. We report only on the final attempt to avoid spamming
      // telemetry on every transient network blip.
      if (attempt + 1 >= maxPollAttempts) {
        ErrorHandler.reportError(e, 'Photoshoot polling exhausted');
      }
      await Future.delayed(const Duration(seconds: 3));
      if (isGenerating.value && !isClosed) {
        _pollJobStatus(id, attempt: attempt + 1);
      }
    }
  }

  /// Retry a single failed slot by generating one new image and filling the slot index.
  Future<void> retryFailedSlot(int failedIndex) async {
    // Third-party AI data-sharing consent gate (Apple 5.1.2(i)) — must run
    // before any photo bytes are read or uploaded.
    if (!await Get.find<AiConsentService>().ensureConsent(
      featureLabel: 'AI Photoshoot',
    )) {
      return;
    }

    if (!failedIndices.contains(failedIndex)) return;
    if (retryingFailedIndex.value != -1) return;
    if (selectedPhotos.isEmpty) return;

    retryingFailedIndex.value = failedIndex;
    error.value = '';

    try {
      final List<String> photosBase64 = await Future.wait(
        selectedPhotos.map((file) async {
          final bytes = await file.readAsBytes();
          return await compute(_encodeBase64, bytes);
        }),
      );

      final result = await _repository.generateSync(
        photos: photosBase64,
        useCase: selectedUseCase.value,
        customPrompt: selectedUseCase.value == PhotoshootUseCase.custom
            ? customPrompt.value
            : null,
        numImages: 1,
        aspectRatio: selectedAspectRatio.value,
      );

      if (result.images.isEmpty) {
        ErrorHandler.showError('Could not generate replacement image', title: 'Retry Failed');
        return;
      }

      final replacement = result.images.first.copyWith(index: failedIndex);
      final nextImages = [
        ...generatedImages.where((img) => img.index != failedIndex),
        replacement,
      ]..sort((a, b) => a.index.compareTo(b.index));

      generatedImages.assignAll(nextImages);
      failedIndices.remove(failedIndex);
      failedIndices.sort();
      failedCount.value = failedIndices.length;
      partialSuccess.value = failedCount.value > 0;

      if (result.usage != null) {
        usage.value = result.usage;
      }

      ErrorHandler.showError('Failed slot #${failedIndex + 1} has been replaced', title: 'Slot Retried');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Retry Failed');
    } finally {
      retryingFailedIndex.value = -1;
    }
  }

  /// Cancel generation job
  Future<void> cancelGeneration() async {
    if (jobId.value.isEmpty) return;

    try {
      await _repository.cancelJob(jobId.value);
    } catch (e) {
      debugPrint('Failed to cancel job: $e');
    }

    _sseSubscription?.cancel();
    currentStep.value = PhotoshootStep.configure;
    isGenerating.value = false;
  }

  /// Download a single image to gallery
  Future<void> downloadImage(int index) async {
    if (index < 0 || index >= generatedImages.length) return;
    if (isDownloading.value) return;

    isDownloading.value = true;
    downloadingIndex.value = index;

    try {
      final image = generatedImages[index];
      final bytes = await _getImageBytes(image);

      await Gal.putImageBytes(
        Uint8List.fromList(bytes),
        name: 'photoshoot_${sessionId.value}_$index',
      );

      ErrorHandler.showSuccess('Image saved to gallery', title: 'Saved');
    } catch (e) {
      ErrorHandler.showError('Failed to save image: $e', title: 'Error');
    } finally {
      isDownloading.value = false;
      downloadingIndex.value = -1;
    }
  }

  /// Download all images to gallery
  Future<void> downloadAll() async {
    if (generatedImages.isEmpty) return;
    if (isDownloading.value) return;

    isDownloading.value = true;
    final List<int> failedIndices = [];

    try {
      int savedCount = 0;
      for (int i = 0; i < generatedImages.length; i++) {
        downloadingIndex.value = i;
        final image = generatedImages[i];

        try {
          final bytes = await _getImageBytes(image);
          await Gal.putImageBytes(
            Uint8List.fromList(bytes),
            name: 'photoshoot_${sessionId.value}_$i',
          );
          savedCount++;
        } catch (e) {
          failedIndices.add(i + 1);
          debugPrint('Failed to save image $i: $e');
        }
      }

      if (failedIndices.isEmpty) {
        ErrorHandler.showSuccess('All $savedCount images saved to gallery', title: 'Saved');
      } else {
        ErrorHandler.showError('$savedCount of ${generatedImages.length} saved. Failed: ${failedIndices.join(", ")}', title: 'Partially Saved');
      }
    } catch (e) {
      ErrorHandler.showError('Failed to save images: $e', title: 'Error');
    } finally {
      isDownloading.value = false;
      downloadingIndex.value = -1;
    }
  }

  Future<List<int>> _getImageBytes(GeneratedImage image) async {
    final base64Data = image.imageBase64;
    if (base64Data != null && base64Data.isNotEmpty) {
      return base64Decode(base64Data);
    }

    final url = image.imageUrl;
    if (url != null && url.isNotEmpty) {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      throw Exception('Failed to download image (${response.statusCode})');
    }

    throw Exception('No image data available');
  }

  /// Show referral prompt when limit exceeded
  void _showReferralPrompt() {
    Get.dialog(
      ReferralLimitDialog(
        onReferFriend: () {
          Get.back();
          Get.toNamed(Routes.referral);
        },
        // WS3: only offer the paid upgrade path when the paywall is enabled.
        // When disabled, the dialog still shows the free referral option and
        // daily-reset messaging without any upgrade CTA.
        onUpgrade: EnvConfig.paywallEnabled
            ? () {
                Get.back();
                Get.toNamed(Routes.subscription);
              }
            : null,
      ),
      barrierDismissible: true,
    );
  }

  /// Reset to the initial state. With `keepPhotos: true` the selected photos
  /// are kept and the flow returns to the configure step (used after a
  /// completed generation for "New Style"); otherwise everything clears and
  /// the flow returns to upload ("New Photos").
  void reset({bool keepPhotos = false}) {
    _sseSubscription?.cancel();
    _pollStarted = false;
    if (!keepPhotos) {
      selectedPhotos.clear();
    }
    customPrompt.value = '';
    customPromptController.clear();
    selectedUseCase.value = PhotoshootUseCase.linkedin;
    selectedAspectRatio.value = PhotoshootAspectRatio.square;
    numImages.value = effectiveMaxImages.clamp(minImages, maxImages);
    generatedImages.clear();
    failedIndices.clear();
    failedCount.value = 0;
    partialSuccess.value = false;
    sessionId.value = '';
    jobId.value = '';
    currentBatch.value = 0;
    totalBatches.value = 0;
    error.value = '';
    generationProgress.value = 0;
    generationStatus.value = '';
    isDownloading.value = false;
    downloadingIndex.value = -1;
    etaSeconds.value = 0;
    currentSceneLabel.value = '';
    _sceneLabels.clear();
    _latencySamples.clear();
    currentStep.value =
        keepPhotos ? PhotoshootStep.configure : PhotoshootStep.upload;
    fetchUsage();
  }
}

String _encodeBase64(Uint8List bytes) => base64Encode(bytes);

/// Referral limit dialog widget
class ReferralLimitDialog extends StatelessWidget {
  final VoidCallback onReferFriend;

  /// When null, the upgrade CTA is hidden (WS3 paywall disabled).
  final VoidCallback? onUpgrade;

  const ReferralLimitDialog({
    super.key,
    required this.onReferFriend,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily Limit Reached'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.photo_camera, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            "You've used all your free images today!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Your free images reset tomorrow. Refer a friend and both get '
            '1 month Pro free!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        if (onUpgrade != null)
          TextButton(onPressed: onUpgrade, child: const Text('Upgrade to Pro')),
        ElevatedButton(
          onPressed: onReferFriend,
          child: const Text('Refer a Friend'),
        ),
      ],
    );
  }
}

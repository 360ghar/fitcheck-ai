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
import '../../../core/services/sse_service.dart';
import '../models/photoshoot_models.dart';
import '../repositories/photoshoot_repository.dart';

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
    isLoadingUsage.value = true;
    try {
      usage.value = await _repository.getUsage();
      // Adjust numImages if it exceeds remaining
      if (numImages.value > remainingToday) {
        numImages.value = remainingToday.clamp(minImages, maxImages);
      }
    } catch (e) {
      // Non-blocking, default to free limits
      usage.value = const PhotoshootUsage();
    } finally {
      isLoadingUsage.value = false;
    }
  }

  /// Pick photos from gallery (adds to existing photos)
  Future<void> pickPhotos() async {
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
          Get.snackbar('Limit Reached', 'Maximum $maxPhotos photos allowed');
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
      Get.snackbar('Error', 'Failed to pick photos: ${e.toString()}');
    }
  }

  /// Pick a single photo from camera
  Future<void> pickFromCamera() async {
    if (selectedPhotos.length >= maxPhotos) {
      Get.snackbar('Limit Reached', 'Maximum $maxPhotos photos allowed');
      return;
    }

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
      Get.snackbar('Error', 'Failed to access camera: ${e.toString()}');
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
          Get.snackbar('No Photos', 'Please add at least one photo');
          return;
        }
        currentStep.value = PhotoshootStep.configure;
        break;
      case PhotoshootStep.configure:
        if (!canGenerate) {
          if (selectedUseCase.value == PhotoshootUseCase.custom &&
              customPrompt.value.isEmpty) {
            Get.snackbar(
              'Custom Prompt Required',
              'Please enter a custom prompt',
            );
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
    if (!canGenerate) return;

    // Cancel any existing SSE subscription
    _sseSubscription?.cancel();

    isGenerating.value = true;
    error.value = '';
    generationProgress.value = 0;
    generationStatus.value = 'Preparing your photos...';
    currentStep.value = PhotoshootStep.generating;
    generatedImages.clear();
    failedIndices.clear();
    failedCount.value = 0;
    partialSuccess.value = false;

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
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');

      if (error.value.contains('limit') || error.value.contains('exceeded')) {
        _showReferralPrompt();
      } else {
        Get.snackbar('Generation Failed', error.value);
      }

      currentStep.value = PhotoshootStep.configure;
      isGenerating.value = false;
    }
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
            _pollJobStatus(id);
          },
          onDone: () {
            debugPrint('SSE stream ended');
            // If still generating, stream ended unexpectedly - fallback to polling
            if (isGenerating.value &&
                currentStep.value == PhotoshootStep.generating) {
              _pollJobStatus(id);
            }
          },
        );
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
        break;

      case 'image_complete':
        final imageData = event.data;
        if (imageData != null) {
          final image = GeneratedImage.fromJson(imageData);
          generatedImages.add(image);
          // Update progress: 10% for upload, 90% for generation
          generationProgress.value =
              10 + ((generatedImages.length / numImages.value) * 90).toInt();
          generationStatus.value =
              'Generated ${generatedImages.length}/${numImages.value} images...';
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
        debugPrint('Image generation failed at index: $failedIndex');
        break;

      case 'batch_complete':
        break;

      case 'job_complete':
        _handleJobComplete(event.data);
        break;

      case 'job_failed':
        error.value = event.data?['error'] ?? 'Generation failed';
        Get.snackbar('Generation Failed', error.value);
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
        // SSE connection error, fallback to polling
        _pollJobStatus(jobId.value);
        break;
    }
  }

  /// Handle job completion
  void _handleJobComplete(Map<String, dynamic>? data) {
    generationProgress.value = 100;
    generationStatus.value = 'Complete!';

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

    Get.snackbar(
      partialSuccess.value ? 'Partially Complete' : 'Success',
      partialSuccess.value
          ? '${generatedImages.length} generated, ${failedCount.value} failed.'
          : '${generatedImages.length} images generated!',
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Fallback polling if SSE fails
  Future<void> _pollJobStatus(String id) async {
    if (id.isEmpty) return;

    try {
      final status = await _repository.getJobStatus(id);

      generatedImages.assignAll(status.images);
      failedIndices.assignAll(List<int>.from(status.failedIndices)..sort());
      failedCount.value = status.failedCount;
      partialSuccess.value = status.partialSuccess;
      if (status.totalCount > 0) {
        generationProgress.value =
            10 + ((status.generatedCount / status.totalCount) * 90).toInt();
      }

      switch (status.status) {
        case 'pending':
        case 'processing':
          await Future.delayed(const Duration(seconds: 2));
          if (isGenerating.value) {
            _pollJobStatus(id);
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
          Get.snackbar('Generation Failed', error.value);
          currentStep.value = PhotoshootStep.configure;
          isGenerating.value = false;
          break;
        case 'cancelled':
          currentStep.value = PhotoshootStep.configure;
          isGenerating.value = false;
          break;
      }
    } catch (e) {
      debugPrint('Poll status error: $e');
      // Retry after delay
      await Future.delayed(const Duration(seconds: 3));
      if (isGenerating.value) {
        _pollJobStatus(id);
      }
    }
  }

  /// Retry a single failed slot by generating one new image and filling the slot index.
  Future<void> retryFailedSlot(int failedIndex) async {
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
        Get.snackbar('Retry Failed', 'Could not generate replacement image');
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

      Get.snackbar(
        'Slot Retried',
        'Failed slot #${failedIndex + 1} has been replaced',
      );
    } catch (e) {
      Get.snackbar('Retry Failed', e.toString().replaceAll('Exception: ', ''));
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

      Get.snackbar('Saved', 'Image saved to gallery');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save image: $e');
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
        Get.snackbar('Saved', 'All $savedCount images saved to gallery');
      } else {
        Get.snackbar(
          'Partially Saved',
          '$savedCount of ${generatedImages.length} saved. Failed: ${failedIndices.join(", ")}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save images: $e');
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
        onUpgrade: () {
          Get.back();
          Get.toNamed(Routes.subscription);
        },
      ),
      barrierDismissible: true,
    );
  }

  /// Reset to initial state for new generation
  void reset() {
    _sseSubscription?.cancel();
    selectedPhotos.clear();
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
    currentStep.value = PhotoshootStep.upload;
    fetchUsage();
  }

  /// Reset for new generation with same photos
  /// Clears results and config but keeps selected photos
  void resetForNewGeneration() {
    _sseSubscription?.cancel();
    // Keep selectedPhotos - don't clear
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
    currentStep.value = PhotoshootStep.configure;
    fetchUsage();
  }
}

String _encodeBase64(Uint8List bytes) => base64Encode(bytes);

/// Referral limit dialog widget
class ReferralLimitDialog extends StatelessWidget {
  final VoidCallback onReferFriend;
  final VoidCallback onUpgrade;

  const ReferralLimitDialog({
    super.key,
    required this.onReferFriend,
    required this.onUpgrade,
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
            'Refer a friend and both get 1 month Pro free!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onUpgrade, child: const Text('Upgrade to Pro')),
        ElevatedButton(
          onPressed: onReferFriend,
          child: const Text('Refer a Friend'),
        ),
      ],
    );
  }
}

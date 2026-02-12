import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/image_utils.dart';
import '../../../domain/constants/use_cases.dart';
import '../../../domain/enums/condition.dart' as domain;
import '../models/batch_extraction_models.dart';
import '../models/item_model.dart';
import '../models/social_import_models.dart';
import '../repositories/batch_extraction_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/social_import_repository.dart';
import 'wardrobe_controller.dart';

enum BatchInputMode { upload, social }

/// Controller for batch image extraction flow
///
/// Manages the multi-step process:
/// 1. Image selection (up to 50 images)
/// 2. Upload and batch extraction via SSE
/// 3. Review extracted items
/// 4. Save selected items to wardrobe
class BatchExtractionController extends GetxController {
  final BatchExtractionRepository _batchRepo = BatchExtractionRepository();
  final ItemRepository _itemRepo = ItemRepository();
  final SocialImportRepository _socialRepo = SocialImportRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final AppLinks _appLinks = AppLinks();

  // Constants
  static const int maxImages = 50;
  static const int generationBatchSize = 5;
  static const String socialOAuthCallbackUri =
      'fitcheck.ai://social-import-callback';

  // Selected images
  final RxList<BatchImage> selectedImages = <BatchImage>[].obs;
  final RxInt remainingSlots = maxImages.obs;
  final Rx<BatchInputMode> inputMode = BatchInputMode.upload.obs;

  // Job state
  final Rx<BatchJobStatus> jobStatus = BatchJobStatus.idle.obs;
  final RxString jobId = ''.obs;
  final RxString error = ''.obs;

  // Progress tracking
  final RxDouble uploadProgress = 0.0.obs;
  final RxInt extractedCount = 0.obs;
  final RxInt generatedCount = 0.obs;
  final RxInt failedCount = 0.obs;
  final RxInt currentBatch = 0.obs;
  final RxInt totalBatches = 0.obs;
  final RxInt totalItems = 0.obs;

  // Extracted items for review
  final RxList<BatchExtractedItem> extractedItems = <BatchExtractedItem>[].obs;
  final RxSet<String> selectedUseCases = <String>{}.obs;

  // Batch SSE subscription
  StreamSubscription? _sseSubscription;

  // Social import state
  final RxString socialJobId = ''.obs;
  final Rx<SocialImportJobData?> socialJob = Rx<SocialImportJobData?>(null);
  final RxString socialError = ''.obs;
  final RxBool socialIsLoading = false.obs;
  final RxBool socialIsConnected = false.obs;
  final RxInt socialLastEventId = (-1).obs;

  StreamSubscription? _socialSseSubscription;
  StreamSubscription<Uri>? _socialOAuthLinkSubscription;

  // Computed properties
  bool get isIdle => jobStatus.value == BatchJobStatus.idle;
  bool get isUploading => jobStatus.value == BatchJobStatus.uploading;
  bool get isExtracting => jobStatus.value == BatchJobStatus.extracting;
  bool get isGenerating => jobStatus.value == BatchJobStatus.generating;
  bool get isComplete => jobStatus.value == BatchJobStatus.complete;
  bool get isFailed => jobStatus.value == BatchJobStatus.failed;
  bool get isCancelled => jobStatus.value == BatchJobStatus.cancelled;
  bool get isProcessing => isUploading || isExtracting || isGenerating;
  bool get hasImages => selectedImages.isNotEmpty;
  bool get hasError => error.value.isNotEmpty;
  bool get isSocialMode => inputMode.value == BatchInputMode.social;
  bool get hasActiveSocialJob => socialJobId.value.isNotEmpty;
  bool get hasSocialError => socialError.value.isNotEmpty;
  bool get isSocialAuthRequired =>
      socialJob.value?.authRequired == true ||
      socialJob.value?.status == SocialImportJobStatus.awaitingAuth;
  bool get isSocialProcessing {
    final status = socialJob.value?.status;
    return status == SocialImportJobStatus.created ||
        status == SocialImportJobStatus.discovering ||
        status == SocialImportJobStatus.processing ||
        status == SocialImportJobStatus.awaitingAuth ||
        status == SocialImportJobStatus.pausedRateLimited;
  }

  SocialImportPhoto? get socialAwaitingPhoto =>
      socialJob.value?.awaitingReviewPhoto;
  SocialImportPhoto? get socialBufferedPhoto => socialJob.value?.bufferedPhoto;
  SocialImportPhoto? get socialProcessingPhoto =>
      socialJob.value?.processingPhoto;
  double get socialProgress {
    final job = socialJob.value;
    if (job == null || job.totalPhotos <= 0) return 0;
    return (job.processedPhotos / job.totalPhotos).clamp(0, 1).toDouble();
  }

  int get selectedItemCount => extractedItems
      .where((item) => item.isSelected && item.includeInWardrobe)
      .length;

  @override
  void onInit() {
    super.onInit();
    _listenForSocialOAuthCallbacks();
  }

  @override
  void onClose() {
    _sseSubscription?.cancel();
    _socialSseSubscription?.cancel();
    _socialOAuthLinkSubscription?.cancel();
    super.onClose();
  }

  /// Pick images from gallery
  Future<void> pickFromGallery() async {
    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isEmpty) return;

      // Limit to remaining slots
      final toAdd = images.take(remainingSlots.value).toList();

      for (final xFile in toAdd) {
        final file = File(xFile.path);
        final validationError = await ImageUtils.validateImage(file);
        if (validationError != null) {
          if (kDebugMode) {
            print('Skipping invalid image: $validationError');
          }
          continue;
        }

        final batchImage = BatchImage(
          id: ImageUtils.generateImageId(),
          filePath: file.path,
        );
        selectedImages.add(batchImage);
      }

      _updateRemainingSlots();
    } catch (e) {
      error.value = 'Failed to pick images: $e';
    }
  }

  /// Take a photo with camera
  Future<void> pickFromCamera() async {
    try {
      if (remainingSlots.value <= 0) {
        error.value = 'Maximum $maxImages images allowed';
        return;
      }

      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      final file = File(image.path);
      final validationError = await ImageUtils.validateImage(file);
      if (validationError != null) {
        error.value = validationError;
        return;
      }

      final batchImage = BatchImage(
        id: ImageUtils.generateImageId(),
        filePath: file.path,
      );
      selectedImages.add(batchImage);
      _updateRemainingSlots();
    } catch (e) {
      error.value = 'Failed to capture image: $e';
    }
  }

  /// Remove an image from selection
  void removeImage(String imageId) {
    selectedImages.removeWhere((img) => img.id == imageId);
    _updateRemainingSlots();
  }

  /// Clear all selected images
  void clearAllImages() {
    selectedImages.clear();
    _updateRemainingSlots();
  }

  void _updateRemainingSlots() {
    remainingSlots.value = maxImages - selectedImages.length;
  }

  void setInputMode(BatchInputMode mode) {
    inputMode.value = mode;
    if (mode == BatchInputMode.upload) {
      socialError.value = '';
      return;
    }
    error.value = '';
  }

  Future<void> startSocialImport(String sourceUrl) async {
    final normalized = sourceUrl.trim();
    if (normalized.isEmpty) {
      socialError.value = 'Profile URL is required';
      return;
    }

    try {
      socialIsLoading.value = true;
      socialError.value = '';

      final started = await _socialRepo.startJob(sourceUrl: normalized);
      socialJobId.value = started.jobId;
      socialLastEventId.value = -1;

      await refreshSocialStatus();
      _subscribeToSocialEvents(started.jobId);
    } catch (e) {
      socialError.value = 'Failed to start import: $e';
    } finally {
      socialIsLoading.value = false;
    }
  }

  Future<void> refreshSocialStatus() async {
    if (socialJobId.value.isEmpty) return;

    try {
      final job = await _socialRepo.getStatus(socialJobId.value);
      _applySocialJob(job);
    } catch (e) {
      socialError.value = 'Failed to refresh social import status: $e';
    }
  }

  Future<void> startSocialOAuthConnect() async {
    if (socialJobId.value.isEmpty) return;

    try {
      socialIsLoading.value = true;
      socialError.value = '';

      final oauth = await _socialRepo.getOAuthConnectUrl(
        socialJobId.value,
        mobileRedirectUri: socialOAuthCallbackUri,
      );

      final launched = await launchUrl(
        Uri.parse(oauth.authUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('Unable to open social login. Please try again.');
      }

      Get.snackbar(
        'Connect social account',
        'Complete login in your browser, then return to FitCheck.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      socialError.value = 'Failed to connect social account: $e';
    } finally {
      socialIsLoading.value = false;
    }
  }

  Future<void> submitSocialScraperAuth({
    required String username,
    required String password,
    String? otpCode,
  }) async {
    if (socialJobId.value.isEmpty) return;
    try {
      socialIsLoading.value = true;
      socialError.value = '';
      await _socialRepo.submitScraperLogin(
        socialJobId.value,
        username: username.trim(),
        password: password,
        otpCode: otpCode?.trim().isNotEmpty == true ? otpCode!.trim() : null,
      );
      await refreshSocialStatus();
      _subscribeToSocialEvents(socialJobId.value);
    } catch (e) {
      socialError.value = 'Failed to submit credentials: $e';
    } finally {
      socialIsLoading.value = false;
    }
  }

  Future<void> patchSocialItem({
    required String photoId,
    required String itemId,
    required Map<String, dynamic> updates,
  }) async {
    if (socialJobId.value.isEmpty) return;

    final payload = Map<String, dynamic>.from(updates)
      ..removeWhere((key, value) => value == null);
    if (payload.isEmpty) return;

    try {
      await _socialRepo.patchItem(socialJobId.value, photoId, itemId, payload);
      await refreshSocialStatus();
    } catch (e) {
      socialError.value = 'Failed to update item: $e';
    }
  }

  Future<void> approveAwaitingSocialPhoto() async {
    final currentPhoto = socialAwaitingPhoto;
    if (socialJobId.value.isEmpty || currentPhoto == null) return;

    try {
      socialIsLoading.value = true;
      socialError.value = '';
      await _socialRepo.approvePhoto(socialJobId.value, currentPhoto.id);
      await refreshSocialStatus();
      if (Get.isRegistered<WardrobeController>()) {
        await Get.find<WardrobeController>().fetchItems(refresh: true);
      }
      if (socialJob.value != null && !socialJob.value!.isTerminal) {
        _subscribeToSocialEvents(
          socialJobId.value,
          lastEventId: socialLastEventId.value > 0
              ? socialLastEventId.value
              : null,
        );
      }
    } catch (e) {
      socialError.value = 'Failed to approve photo: $e';
    } finally {
      socialIsLoading.value = false;
    }
  }

  Future<void> rejectAwaitingSocialPhoto() async {
    final currentPhoto = socialAwaitingPhoto;
    if (socialJobId.value.isEmpty || currentPhoto == null) return;

    try {
      socialIsLoading.value = true;
      socialError.value = '';
      await _socialRepo.rejectPhoto(socialJobId.value, currentPhoto.id);
      await refreshSocialStatus();
      if (socialJob.value != null && !socialJob.value!.isTerminal) {
        _subscribeToSocialEvents(
          socialJobId.value,
          lastEventId: socialLastEventId.value > 0
              ? socialLastEventId.value
              : null,
        );
      }
    } catch (e) {
      socialError.value = 'Failed to reject photo: $e';
    } finally {
      socialIsLoading.value = false;
    }
  }

  Future<void> cancelSocialImportJob() async {
    if (socialJobId.value.isEmpty) return;
    try {
      socialIsLoading.value = true;
      socialError.value = '';
      await _socialRepo.cancelJob(socialJobId.value);
      await refreshSocialStatus();
      _socialSseSubscription?.cancel();
      socialIsConnected.value = false;
    } catch (e) {
      socialError.value = 'Failed to cancel social import job: $e';
    } finally {
      socialIsLoading.value = false;
    }
  }

  void resetSocialImportState() {
    _socialSseSubscription?.cancel();
    socialJobId.value = '';
    socialJob.value = null;
    socialError.value = '';
    socialIsLoading.value = false;
    socialIsConnected.value = false;
    socialLastEventId.value = -1;
  }

  void _applySocialJob(SocialImportJobData job) {
    socialJob.value = job;
    socialError.value = (job.errorMessage ?? '').trim();
    if (job.isTerminal) {
      socialIsConnected.value = false;
      _socialSseSubscription?.cancel();
    }
  }

  void _subscribeToSocialEvents(String jobId, {int? lastEventId}) {
    _socialSseSubscription?.cancel();
    _socialSseSubscription = _socialRepo
        .subscribeToEvents(jobId, lastEventId: lastEventId)
        .listen(
          (event) {
            socialIsConnected.value = true;
            if (event.id != null) {
              socialLastEventId.value = event.id!;
            }
            if (event.type == 'heartbeat' || event.type == 'connected') {
              return;
            }
            unawaited(refreshSocialStatus());
          },
          onError: (e) {
            socialIsConnected.value = false;
            if (kDebugMode) {
              print('Social import SSE error: $e');
            }
            _pollSocialStatus(jobId);
          },
          onDone: () {
            socialIsConnected.value = false;
          },
        );
  }

  Future<void> _pollSocialStatus(String id) async {
    if (id.isEmpty || id != socialJobId.value) return;
    try {
      final job = await _socialRepo.getStatus(id);
      _applySocialJob(job);
      if (!job.isTerminal && !socialIsConnected.value) {
        await Future.delayed(const Duration(seconds: 2));
        if (!socialIsConnected.value) {
          await _pollSocialStatus(id);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Social import status poll error: $e');
      }
    }
  }

  void _listenForSocialOAuthCallbacks() {
    _socialOAuthLinkSubscription?.cancel();
    _socialOAuthLinkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handlePotentialSocialOAuthUri(uri);
      },
      onError: (e) {
        if (kDebugMode) {
          print('Social OAuth link stream error: $e');
        }
      },
    );

    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handlePotentialSocialOAuthUri(uri);
      }
    });
  }

  Future<void> _handlePotentialSocialOAuthUri(Uri uri) async {
    if (uri.scheme != 'fitcheck.ai' || uri.host != 'social-import-callback') {
      return;
    }

    final callbackJobId = uri.queryParameters['job_id'];
    if (callbackJobId != null && callbackJobId.isNotEmpty) {
      if (socialJobId.value.isNotEmpty && callbackJobId != socialJobId.value) {
        return;
      }
      socialJobId.value = callbackJobId;
    }

    final callbackStatus = (uri.queryParameters['status'] ?? '').toLowerCase();
    final callbackMessage =
        uri.queryParameters['message'] ??
        'Social account authorization failed.';

    if (callbackStatus == 'success') {
      await refreshSocialStatus();
      if (socialJobId.value.isNotEmpty &&
          socialJob.value != null &&
          !socialJob.value!.isTerminal) {
        _subscribeToSocialEvents(
          socialJobId.value,
          lastEventId: socialLastEventId.value > 0
              ? socialLastEventId.value
              : null,
        );
      }
      Get.snackbar(
        'Social connected',
        callbackMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    socialError.value = callbackMessage;
    await refreshSocialStatus();
    Get.snackbar(
      'Social connection failed',
      callbackMessage,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Start the batch extraction process
  Future<void> startExtraction() async {
    if (selectedImages.isEmpty) {
      error.value = 'No images selected';
      return;
    }

    try {
      error.value = '';
      jobStatus.value = BatchJobStatus.uploading;
      uploadProgress.value = 0.0;

      // Compress and encode images
      final imageInputs = <BatchImageInput>[];
      for (var i = 0; i < selectedImages.length; i++) {
        final image = selectedImages[i];

        // Update image status
        _updateImageStatus(image.id, BatchImageStatus.uploading);

        final base64 = await ImageUtils.compressAndEncode(File(image.filePath));

        if (base64 == null) {
          _updateImageStatus(
            image.id,
            BatchImageStatus.failed,
            error: 'Failed to process image',
          );
          continue;
        }

        imageInputs.add(
          BatchImageInput(imageId: image.id, imageBase64: base64),
        );

        // Update progress
        uploadProgress.value = (i + 1) / selectedImages.length;
      }

      if (imageInputs.isEmpty) {
        error.value = 'Failed to process any images';
        jobStatus.value = BatchJobStatus.failed;
        return;
      }

      // Start batch extraction
      final response = await _batchRepo.startBatchExtraction(
        images: imageInputs,
        autoGenerate: true,
        generationBatchSize: generationBatchSize,
      );

      jobId.value = response.jobId;

      // Subscribe to SSE events
      _subscribeToEvents(response.jobId);
    } catch (e) {
      error.value = 'Failed to start extraction: $e';
      jobStatus.value = BatchJobStatus.failed;
    }
  }

  /// Subscribe to SSE events for the job
  void _subscribeToEvents(String id) {
    _sseSubscription?.cancel();
    _sseSubscription = _batchRepo
        .subscribeToEvents(id)
        .listen(
          _handleSSEEvent,
          onError: (e) {
            if (kDebugMode) {
              print('SSE error: $e');
            }
            // Try to recover by polling status
            _pollJobStatus(id);
          },
          onDone: () {
            if (kDebugMode) {
              print('SSE stream completed');
            }
          },
        );
  }

  /// Handle incoming SSE events
  void _handleSSEEvent(SSEEvent event) {
    if (kDebugMode) {
      print('SSE Event: ${event.type} - ${event.data}');
    }

    switch (event.type) {
      case 'connected':
        // Connection established
        break;

      case 'heartbeat':
        // Keep-alive, ignore
        break;

      case 'extraction_started':
        jobStatus.value = BatchJobStatus.extracting;
        break;

      case 'image_extraction_complete':
        _handleImageExtractionComplete(event.data);
        break;

      case 'image_extraction_failed':
        _handleImageExtractionFailed(event.data);
        break;

      case 'all_extractions_complete':
        // All images processed, moving to generation
        break;

      case 'generation_started':
        jobStatus.value = BatchJobStatus.generating;
        totalItems.value =
            (event.data?['total_items'] as num?)?.toInt() ??
            extractedItems.length;
        totalBatches.value =
            (event.data?['total_batches'] as num?)?.toInt() ??
            (extractedItems.isEmpty
                ? 0
                : (extractedItems.length / generationBatchSize).ceil());
        for (var i = 0; i < selectedImages.length; i++) {
          if (selectedImages[i].status != BatchImageStatus.failed) {
            selectedImages[i] = selectedImages[i].copyWith(
              status: BatchImageStatus.generating,
            );
          }
        }
        break;

      case 'batch_generation_started':
        currentBatch.value =
            (event.data?['batch_number'] as num?)?.toInt() ?? 0;
        break;

      case 'item_generation_complete':
        _handleItemGenerationComplete(event.data);
        break;

      case 'item_generation_failed':
        _handleItemGenerationFailed(event.data);
        break;

      case 'batch_generation_complete':
        // Current batch done
        break;

      case 'all_generations_complete':
        // All items generated
        break;

      case 'job_complete':
        final finalItems = event.data?['items'];
        if (finalItems is List) {
          final parsed = finalItems
              .whereType<Map<String, dynamic>>()
              .map(BatchExtractedItem.fromJson)
              .toList();
          extractedItems.assignAll(parsed);
          totalItems.value = parsed.length;
          generatedCount.value = parsed
              .where((item) => item.status == BatchItemStatus.generated)
              .length;
        }
        for (var i = 0; i < selectedImages.length; i++) {
          if (selectedImages[i].status != BatchImageStatus.failed) {
            selectedImages[i] = selectedImages[i].copyWith(
              status: BatchImageStatus.generated,
            );
          }
        }
        jobStatus.value = BatchJobStatus.complete;
        _sseSubscription?.cancel();
        break;

      case 'job_failed':
        error.value = event.data?['error'] ?? 'Extraction failed';
        jobStatus.value = BatchJobStatus.failed;
        _sseSubscription?.cancel();
        break;

      case 'job_cancelled':
        jobStatus.value = BatchJobStatus.cancelled;
        _sseSubscription?.cancel();
        break;

      case 'error':
        error.value = event.data?['message'] ?? 'Unknown error';
        break;
    }
  }

  void _handleImageExtractionComplete(Map<String, dynamic>? data) {
    if (data == null) return;

    final imageId = data['image_id'] as String?;
    if (imageId == null) return;

    _updateImageStatus(imageId, BatchImageStatus.extracted);
    extractedCount.value =
        (data['completed_count'] as num?)?.toInt() ??
        (extractedCount.value + 1);

    // Parse extracted items
    final items = _batchRepo.parseExtractedItems(data, imageId);
    for (final item in items) {
      extractedItems.add(item);
    }

    // Also update the image with extracted items
    final imageIndex = selectedImages.indexWhere((img) => img.id == imageId);
    if (imageIndex >= 0) {
      selectedImages[imageIndex] = selectedImages[imageIndex].copyWith(
        extractedItems: items,
      );
    }
  }

  void _handleImageExtractionFailed(Map<String, dynamic>? data) {
    if (data == null) return;

    final imageId = data['image_id'] as String?;
    final errorMsg = data['error'] as String?;

    if (imageId != null) {
      _updateImageStatus(
        imageId,
        BatchImageStatus.failed,
        error: errorMsg ?? 'Extraction failed',
      );
    }
    failedCount.value =
        (data['failed_count'] as num?)?.toInt() ?? (failedCount.value + 1);
  }

  void _handleItemGenerationComplete(Map<String, dynamic>? data) {
    if (data == null) return;

    final itemId = data['temp_id'] as String?;
    final generatedBase64 = data['generated_image_base64']?.toString();

    if (itemId == null) return;

    final itemIndex = extractedItems.indexWhere((item) => item.id == itemId);
    if (itemIndex >= 0) {
      extractedItems[itemIndex] = extractedItems[itemIndex].copyWith(
        status: BatchItemStatus.generated,
        generatedImageBase64: generatedBase64,
        generatedImageUrl: generatedBase64 != null && generatedBase64.isNotEmpty
            ? 'data:image/png;base64,$generatedBase64'
            : extractedItems[itemIndex].generatedImageUrl,
      );
    }
    generatedCount.value =
        (data['completed_count'] as num?)?.toInt() ??
        (generatedCount.value + 1);
  }

  void _handleItemGenerationFailed(Map<String, dynamic>? data) {
    if (data == null) return;

    final itemId = data['temp_id'] as String?;
    final errorMsg = data['error'] as String?;

    if (itemId == null) return;

    final itemIndex = extractedItems.indexWhere((item) => item.id == itemId);
    if (itemIndex >= 0) {
      extractedItems[itemIndex] = extractedItems[itemIndex].copyWith(
        status: BatchItemStatus.failed,
        error: errorMsg,
      );
    }
  }

  void _updateImageStatus(
    String imageId,
    BatchImageStatus status, {
    String? error,
  }) {
    final index = selectedImages.indexWhere((img) => img.id == imageId);
    if (index >= 0) {
      selectedImages[index] = selectedImages[index].copyWith(
        status: status,
        error: error,
      );
    }
  }

  /// Fallback polling for job status
  Future<void> _pollJobStatus(String id) async {
    try {
      final status = await _batchRepo.getJobStatus(id);

      // Update state from polled status
      extractedCount.value = status.extractedCount;
      generatedCount.value = status.generatedCount;
      failedCount.value = status.failedCount + status.generationFailedCount;
      currentBatch.value = status.currentBatch;
      totalBatches.value = status.totalBatches;
      totalItems.value = status.detectedItems?.length ?? extractedItems.length;

      // Update detected items if available
      if (status.detectedItems != null) {
        extractedItems.assignAll(status.detectedItems!);
      }

      // Update job status
      switch (status.status) {
        case 'pending':
        case 'extracting':
          jobStatus.value = BatchJobStatus.extracting;
          // Continue polling
          await Future.delayed(const Duration(seconds: 2));
          _pollJobStatus(id);
          break;
        case 'generating':
          jobStatus.value = BatchJobStatus.generating;
          await Future.delayed(const Duration(seconds: 2));
          _pollJobStatus(id);
          break;
        case 'completed':
          jobStatus.value = BatchJobStatus.complete;
          break;
        case 'failed':
          error.value = status.error ?? 'Extraction failed';
          jobStatus.value = BatchJobStatus.failed;
          break;
        case 'cancelled':
          jobStatus.value = BatchJobStatus.cancelled;
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Poll status error: $e');
      }
    }
  }

  /// Cancel the current extraction job
  Future<void> cancelExtraction() async {
    if (jobId.value.isEmpty) return;

    try {
      await _batchRepo.cancelJob(jobId.value);
      jobStatus.value = BatchJobStatus.cancelled;
      _sseSubscription?.cancel();
    } catch (e) {
      error.value = 'Failed to cancel: $e';
    }
  }

  /// Toggle selection of an extracted item
  void toggleItemSelection(String itemId) {
    final index = extractedItems.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      final nextValue = !extractedItems[index].isSelected;
      extractedItems[index] = extractedItems[index].copyWith(
        isSelected: nextValue,
        includeInWardrobe: nextValue,
      );
    }
  }

  /// Select all extracted items
  void selectAllItems() {
    for (var i = 0; i < extractedItems.length; i++) {
      if (!extractedItems[i].isSelected) {
        extractedItems[i] = extractedItems[i].copyWith(
          isSelected: true,
          includeInWardrobe: true,
        );
      }
    }
  }

  /// Deselect all extracted items
  void deselectAllItems() {
    for (var i = 0; i < extractedItems.length; i++) {
      if (extractedItems[i].isSelected) {
        extractedItems[i] = extractedItems[i].copyWith(
          isSelected: false,
          includeInWardrobe: false,
        );
      }
    }
  }

  /// Toggle include/exclude for a single item while keeping selection aligned.
  void toggleItemInclude(String itemId) {
    final index = extractedItems.indexWhere((item) => item.id == itemId);
    if (index < 0) return;

    final nextValue = !extractedItems[index].includeInWardrobe;
    extractedItems[index] = extractedItems[index].copyWith(
      includeInWardrobe: nextValue,
      isSelected: nextValue,
    );
  }

  /// Include/exclude all items for a specific person group.
  void setPersonInclusion(String personId, bool include) {
    for (var i = 0; i < extractedItems.length; i++) {
      if ((extractedItems[i].personId ?? 'unassigned') == personId) {
        extractedItems[i] = extractedItems[i].copyWith(
          includeInWardrobe: include,
          isSelected: include,
        );
      }
    }
  }

  /// Update an extracted item's details
  void updateItem(String itemId, BatchExtractedItem updatedItem) {
    final index = extractedItems.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      extractedItems[index] = updatedItem;
    }
  }

  /// Toggle one apply-to-all use-case value.
  void toggleUseCase(String useCase) {
    final normalized = UseCases.normalize(useCase);
    if (normalized.isEmpty) return;
    if (selectedUseCases.contains(normalized)) {
      selectedUseCases.remove(normalized);
    } else {
      selectedUseCases.add(normalized);
    }
    selectedUseCases.refresh();
  }

  /// Add one use-case tag without toggling.
  void addUseCase(String useCase) {
    final normalized = UseCases.normalize(useCase);
    if (normalized.isEmpty || selectedUseCases.contains(normalized)) return;
    selectedUseCases.add(normalized);
    selectedUseCases.refresh();
  }

  /// Remove one use-case tag.
  void removeUseCase(String useCase) {
    final normalized = UseCases.normalize(useCase);
    if (!selectedUseCases.contains(normalized)) return;
    selectedUseCases.remove(normalized);
    selectedUseCases.refresh();
  }

  /// Set the apply-to-all use-case value directly (single active value).
  void setUseCaseFilter(String value) {
    final normalized = UseCases.normalize(value);
    selectedUseCases.clear();
    if (normalized.isNotEmpty) {
      selectedUseCases.add(normalized);
    }
    selectedUseCases.refresh();
  }

  /// Save selected items to wardrobe
  Future<List<ItemModel>> saveSelectedItems() async {
    final selected = extractedItems
        .where(
          (item) =>
              item.isSelected &&
              item.includeInWardrobe &&
              item.status == BatchItemStatus.generated,
        )
        .toList();
    if (selected.isEmpty) {
      error.value = 'No items selected';
      return [];
    }

    final savedItems = <ItemModel>[];
    error.value = '';

    for (final item in selected) {
      try {
        final request = CreateItemRequest(
          name: item.name.isNotEmpty
              ? item.name
              : (item.subCategory ?? item.category.name),
          category: item.category,
          colors: item.colors,
          material: item.material,
          pattern: item.pattern,
          description: item.description,
          condition: domain.Condition.clean,
          occasionTags: selectedUseCases.isEmpty
              ? null
              : UseCases.normalizeList(selectedUseCases),
        );

        final created = await _itemRepo.createItem(request);

        final generatedBase64 =
            item.generatedImageBase64 ??
            item.generatedImageUrl?.replaceFirst(
              RegExp(r'^data:image/\w+;base64,', caseSensitive: false),
              '',
            );

        if (generatedBase64 != null && generatedBase64.isNotEmpty) {
          await _itemRepo.uploadImageFromBase64(created.id, generatedBase64);
        } else {
          final sourceImage = selectedImages.firstWhereOrNull(
            (img) => img.id == item.sourceImageId,
          );
          if (sourceImage != null) {
            await _itemRepo.uploadImages(created.id, [
              File(sourceImage.filePath),
            ]);
          }
        }

        savedItems.add(await _itemRepo.getItem(created.id));
      } catch (e) {
        if (kDebugMode) {
          print('Failed to save item ${item.name}: $e');
        }
      }
    }

    // Notify WardrobeController for immediate UI update
    if (savedItems.isNotEmpty && Get.isRegistered<WardrobeController>()) {
      Get.find<WardrobeController>().addItems(savedItems);
    }

    return savedItems;
  }

  /// Reset the controller state
  void reset() {
    _sseSubscription?.cancel();
    resetSocialImportState();
    selectedImages.clear();
    extractedItems.clear();
    jobStatus.value = BatchJobStatus.idle;
    jobId.value = '';
    error.value = '';
    uploadProgress.value = 0.0;
    extractedCount.value = 0;
    generatedCount.value = 0;
    failedCount.value = 0;
    currentBatch.value = 0;
    totalBatches.value = 0;
    totalItems.value = 0;
    remainingSlots.value = maxImages;
    selectedUseCases.clear();
    inputMode.value = BatchInputMode.upload;
  }
}

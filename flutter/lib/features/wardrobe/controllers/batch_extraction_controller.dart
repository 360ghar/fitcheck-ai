import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/sse_service.dart';
import '../../../core/utils/image_utils.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart' as domain;
import '../models/batch_extraction_models.dart';
import '../models/item_model.dart';
import '../repositories/batch_extraction_repository.dart';
import '../repositories/item_repository.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

  // Constants
  static const int maxImages = 50;
  static const int generationBatchSize = 5;

  // Selected images
  final RxList<BatchImage> selectedImages = <BatchImage>[].obs;
  final RxInt remainingSlots = maxImages.obs;

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

  // SSE subscription
  StreamSubscription? _sseSubscription;

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
  int get selectedItemCount =>
      extractedItems.where((item) => item.isSelected).length;

  @override
  void onClose() {
    _sseSubscription?.cancel();
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

        final base64 = await ImageUtils.compressAndEncode(
          File(image.filePath),
        );

        if (base64 == null) {
          _updateImageStatus(
            image.id,
            BatchImageStatus.failed,
            error: 'Failed to process image',
          );
          continue;
        }

        imageInputs.add(BatchImageInput(
          id: image.id,
          imageBase64: base64,
        ));

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
    _sseSubscription = _batchRepo.subscribeToEvents(id).listen(
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
        totalItems.value = extractedItems.length;
        totalBatches.value =
            (extractedItems.length / generationBatchSize).ceil();
        break;

      case 'batch_generation_started':
        currentBatch.value = event.data?['batch_index'] ?? 0;
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
    extractedCount.value++;

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
    failedCount.value++;
  }

  void _handleItemGenerationComplete(Map<String, dynamic>? data) {
    if (data == null) return;

    final itemId = data['item_id'] as String?;
    final imageUrl = data['image_url'] as String?;

    if (itemId == null) return;

    final itemIndex = extractedItems.indexWhere((item) => item.id == itemId);
    if (itemIndex >= 0) {
      extractedItems[itemIndex] = extractedItems[itemIndex].copyWith(
        status: BatchItemStatus.generated,
        generatedImageUrl: imageUrl,
      );
    }
    generatedCount.value++;
  }

  void _handleItemGenerationFailed(Map<String, dynamic>? data) {
    if (data == null) return;

    final itemId = data['item_id'] as String?;
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
      failedCount.value = status.failedCount;
      currentBatch.value = status.currentBatch;
      totalBatches.value = status.totalBatches;

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
      extractedItems[index] = extractedItems[index].copyWith(
        isSelected: !extractedItems[index].isSelected,
      );
    }
  }

  /// Select all extracted items
  void selectAllItems() {
    for (var i = 0; i < extractedItems.length; i++) {
      if (!extractedItems[i].isSelected) {
        extractedItems[i] = extractedItems[i].copyWith(isSelected: true);
      }
    }
  }

  /// Deselect all extracted items
  void deselectAllItems() {
    for (var i = 0; i < extractedItems.length; i++) {
      if (extractedItems[i].isSelected) {
        extractedItems[i] = extractedItems[i].copyWith(isSelected: false);
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

  /// Save selected items to wardrobe
  Future<List<ItemModel>> saveSelectedItems() async {
    final selected = extractedItems.where((item) => item.isSelected).toList();
    if (selected.isEmpty) {
      error.value = 'No items selected';
      return [];
    }

    final savedItems = <ItemModel>[];
    error.value = '';

    for (final item in selected) {
      try {
        final request = CreateItemRequest(
          name: item.name,
          category: item.category,
          colors: item.colors,
          material: item.material,
          pattern: item.pattern,
          description: item.description,
          condition: domain.Condition.clean,
        );

        // If we have a source image, create with image
        final sourceImage = selectedImages.firstWhereOrNull(
          (img) => img.id == item.sourceImageId,
        );

        ItemModel created;
        if (sourceImage != null) {
          created = await _itemRepo.createItemWithImage(
            image: File(sourceImage.filePath),
            request: request,
          );
        } else {
          created = await _itemRepo.createItem(request);
        }

        savedItems.add(created);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to save item ${item.name}: $e');
        }
      }
    }

    return savedItems;
  }

  /// Reset the controller state
  void reset() {
    _sseSubscription?.cancel();
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
  }
}

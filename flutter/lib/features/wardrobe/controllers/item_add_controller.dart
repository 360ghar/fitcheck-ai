import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/constants/use_cases.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart' as app_condition;
import '../models/batch_extraction_models.dart';
import '../models/item_model.dart';
import '../repositories/item_repository.dart';
import 'wardrobe_controller.dart';

/// Controller for item add page
/// Handles image processing, AI extraction, product image generation, and item creation
class ItemAddController extends GetxController {
  final ItemRepository _itemRepository = ItemRepository();

  // Reactive state
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isProcessing = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isGeneratingImages = false.obs;
  final Rx<SyncExtractionResponse?> extractionResult =
      Rx<SyncExtractionResponse?>(null);
  final RxList<DetectedItemDataWithImage> generatedItems =
      <DetectedItemDataWithImage>[].obs;
  final RxDouble generationProgress = 0.0.obs;
  final RxString currentGenerationStatus = ''.obs;
  final RxBool showManualEntry = false.obs;
  final RxList<ItemModel> createdItems = <ItemModel>[].obs;
  final RxString error = ''.obs;
  final RxSet<String> selectedUseCases = <String>{}.obs;

  // Async extraction state (Phase 2)
  StreamSubscription<SSEEvent>? _sseSubscription;
  String? _currentJobId;
  final RxString currentPhase =
      ''.obs; // upload, analyzing, extracting, generating
  final RxDouble phaseProgress = 0.0.obs; // 0-100%
  final RxInt estimatedTimeRemaining = 0.obs; // seconds
  final RxInt currentGeneratingIndex = 0.obs;
  final RxString currentGeneratingItemName = ''.obs;
  final RxMap<String, String> itemGenerationStatus = <String, String>{}
      .obs; // itemId -> status (pending, generating, complete, failed)
  final RxBool isCachedResult =
      false.obs; // Phase 3: Indicates if results came from cache
  final Map<String, DetectedItemData> _extractedItemsByTempId =
      <String, DetectedItemData>{};

  int get includedGeneratedCount =>
      generatedItems.where((item) => item.includeInWardrobe).length;

  /// Process image with async extraction and SSE progress updates (Phase 2)
  /// Uses new /api/v1/ai/single-extract endpoint with real-time streaming
  /// Supports intelligent caching - detects and displays cached results (Phase 3)
  Future<void> processImage(File image) async {
    selectedImage.value = image;
    isProcessing.value = true;
    error.value = '';
    generatedItems.clear();
    generationProgress.value = 0;
    currentGenerationStatus.value = '';
    currentPhase.value = 'upload';
    phaseProgress.value = 0;
    estimatedTimeRemaining.value = 60; // Initial estimate
    itemGenerationStatus.clear();
    isCachedResult.value = false;
    currentGeneratingIndex.value = 0;
    currentGeneratingItemName.value = '';
    _extractedItemsByTempId.clear();

    try {
      // Start async extraction job
      final job = await _itemRepository.extractItemsFromImageAsync(image);
      _currentJobId = job.jobId;

      // Check if result is cached (indicated by message)
      if (job.message?.contains('cached') == true) {
        isCachedResult.value = true;
        currentPhase.value = 'complete';
        phaseProgress.value = 100;
        currentGenerationStatus.value = 'Items detected (cached)';

        // Show success message with cache indicator
        Get.snackbar(
          'Items Detected!',
          'Loaded from cache ⚡',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.flash_on, color: Colors.white),
        );
      }

      // Subscribe to SSE events for real-time progress
      _sseSubscription = _itemRepository
          .subscribeSingleExtractionEvents(job.jobId)
          .listen(
            _handleSSEEvent,
            onError: _handleSSEError,
            onDone: () {
              debugPrint('SSE stream closed');
            },
            cancelOnError: false,
          );
    } catch (e) {
      isProcessing.value = false;
      _handleExtractionError(e);
    }
  }

  /// Handle SSE events from extraction pipeline
  void _handleSSEEvent(SSEEvent event) {
    debugPrint('SSE Event: ${event.type}');
    final data = event.data ?? <String, dynamic>{};

    switch (event.type) {
      case 'connected':
        currentPhase.value = 'connected';
        phaseProgress.value = 5;
        break;

      case 'extraction_started':
        currentPhase.value = 'analyzing';
        phaseProgress.value = 10;
        estimatedTimeRemaining.value = 45;
        currentGenerationStatus.value = 'Analyzing your photo...';
        break;

      case 'image_extraction_complete':
        currentPhase.value = 'extracting';
        phaseProgress.value = 60;
        estimatedTimeRemaining.value = 30;
        currentGenerationStatus.value = 'Items detected!';

        // Parse extracted items and initialize status tracking by temp_id.
        final rawItems = data['items'];
        if (rawItems is List) {
          for (final raw in rawItems) {
            if (raw is! Map<String, dynamic>) continue;
            final item = DetectedItemData.fromJson(raw);
            _extractedItemsByTempId[item.tempId] = item;
            itemGenerationStatus[item.tempId] = 'pending';
          }
        }
        break;

      case 'image_extraction_failed':
        isProcessing.value = false;
        _handleExtractionError(Exception(data['error'] ?? 'Extraction failed'));
        break;

      case 'generation_started':
        currentPhase.value = 'generating';
        phaseProgress.value = 65;
        estimatedTimeRemaining.value = 25;
        currentGenerationStatus.value = 'Generating product images...';
        isGeneratingImages.value = true;
        break;

      case 'item_generation_complete':
        final tempId = data['temp_id']?.toString();
        final eventTotalItems = (data['total_items'] as num?)?.toInt();
        final completedCountFromEvent = (data['completed_count'] as num?)
            ?.toInt();

        if (tempId != null && tempId.isNotEmpty) {
          itemGenerationStatus[tempId] = 'complete';
        }

        final fallbackTotal = itemGenerationStatus.isNotEmpty
            ? itemGenerationStatus.length
            : 1;
        final totalItems = (eventTotalItems != null && eventTotalItems > 0)
            ? eventTotalItems
            : fallbackTotal;
        final completedCount =
            completedCountFromEvent ??
            itemGenerationStatus.values
                .where((status) => status == 'complete')
                .length;

        final clampedCompleted = completedCount.clamp(0, totalItems).toInt();
        currentGeneratingIndex.value = clampedCompleted;
        currentGeneratingItemName.value = _resolveItemName(
          tempId,
          clampedCompleted,
        );

        // Update progress based on completed items.
        phaseProgress.value = 65 + (30 * clampedCompleted / totalItems);
        final remaining = totalItems - clampedCompleted;
        estimatedTimeRemaining.value = remaining > 0 ? remaining * 5 : 0;

        final generatedItem = _buildGeneratedItemFromEvent(data);
        if (generatedItem != null) {
          _upsertGeneratedItem(generatedItem);
        }
        break;

      case 'item_generation_failed':
        final tempId = data['temp_id']?.toString();
        if (tempId != null && tempId.isNotEmpty) {
          itemGenerationStatus[tempId] = 'failed';
        }
        break;

      case 'job_complete':
        final parsedItems = _parseFinalItems(data);
        if (parsedItems.isNotEmpty) {
          generatedItems.assignAll(parsedItems);
          itemGenerationStatus.clear();
          for (final item in parsedItems) {
            final hasGeneratedImage =
                item.generatedImageUrl != null &&
                item.generatedImageUrl!.isNotEmpty;
            itemGenerationStatus[item.tempId] = item.generationError != null
                ? 'failed'
                : (hasGeneratedImage ? 'complete' : 'pending');
          }
        }

        currentPhase.value = 'complete';
        phaseProgress.value = 100;
        estimatedTimeRemaining.value = 0;
        currentGenerationStatus.value = 'Complete!';
        isProcessing.value = false;
        isGeneratingImages.value = false;

        // Show success message
        final successfulItems = generatedItems
            .where((item) => item.generatedImageUrl != null)
            .length;
        if (successfulItems > 0) {
          Get.snackbar(
            'Success',
            '$successfulItems item${successfulItems > 1 ? 's' : ''} ready to add',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          );
        } else if (generatedItems.isEmpty) {
          Get.snackbar(
            'No Items Detected',
            'Try a clearer photo or enter details manually',
            snackPosition: SnackPosition.TOP,
          );
        }

        _cleanupSSE();
        break;

      case 'job_failed':
        isProcessing.value = false;
        isGeneratingImages.value = false;
        _handleExtractionError(Exception(data['error'] ?? 'Job failed'));
        _cleanupSSE();
        break;

      case 'job_cancelled':
        isProcessing.value = false;
        isGeneratingImages.value = false;
        currentGenerationStatus.value = 'Cancelled';
        _cleanupSSE();
        break;

      case 'heartbeat':
        // Keep-alive, no action needed
        break;
    }
  }

  String _resolveItemName(String? tempId, int fallbackIndex) {
    final item = tempId != null ? _extractedItemsByTempId[tempId] : null;
    final candidate = item?.subCategory ?? item?.category;
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }
    return fallbackIndex > 0 ? 'Item $fallbackIndex' : 'Item';
  }

  String? _toDataUrl(String? imageUrl, String? base64Data) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return imageUrl;
    }
    if (base64Data != null && base64Data.isNotEmpty) {
      return 'data:image/png;base64,$base64Data';
    }
    return null;
  }

  DetectedItemDataWithImage? _buildGeneratedItemFromEvent(
    Map<String, dynamic> data,
  ) {
    final tempId = data['temp_id']?.toString();
    if (tempId == null || tempId.isEmpty) {
      return null;
    }

    final source = _extractedItemsByTempId[tempId];
    if (source == null) {
      return null;
    }

    final generatedImageUrl = _toDataUrl(
      data['generated_image_url']?.toString(),
      data['generated_image_base64']?.toString(),
    );

    return DetectedItemDataWithImage(
      tempId: source.tempId,
      category: source.category,
      subCategory: source.subCategory,
      colors: source.colors,
      material: source.material,
      pattern: source.pattern,
      brand: source.brand,
      confidence: source.confidence,
      detailedDescription: source.detailedDescription,
      personId: source.personId,
      personLabel: source.personLabel,
      isCurrentUserPerson: source.isCurrentUserPerson,
      includeInWardrobe: source.includeInWardrobe,
      status: 'generated',
      generatedImageUrl: generatedImageUrl,
      name: source.subCategory ?? source.category,
    );
  }

  List<DetectedItemDataWithImage> _parseFinalItems(Map<String, dynamic> data) {
    final rawItems = data['items'];
    if (rawItems is! List) {
      return <DetectedItemDataWithImage>[];
    }

    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(DetectedItemDataWithImage.fromJson)
        .toList();
  }

  void _upsertGeneratedItem(DetectedItemDataWithImage item) {
    final index = generatedItems.indexWhere(
      (existing) => existing.tempId == item.tempId,
    );
    if (index >= 0) {
      generatedItems[index] = item;
    } else {
      generatedItems.add(item);
    }
  }

  /// Handle SSE stream errors
  void _handleSSEError(dynamic error) {
    debugPrint('SSE Error: $error');
    isProcessing.value = false;
    isGeneratingImages.value = false;

    Get.snackbar(
      'Connection Error',
      'Lost connection to server. Please try again.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
    );

    _cleanupSSE();
  }

  /// Handle extraction errors with categorization (Phase 1)
  void _handleExtractionError(dynamic e) {
    final errorMsg = e.toString().replaceAll('Exception: ', '');
    error.value = errorMsg;

    // Categorize error and show actionable dialog
    if (errorMsg.contains('timeout') || errorMsg.contains('connection')) {
      // Network timeout
      Get.defaultDialog(
        title: 'Network Timeout',
        middleText:
            'The connection timed out. Please check your internet and try again.',
        textConfirm: 'Retry',
        textCancel: 'Cancel',
        onConfirm: () {
          Get.back();
          if (selectedImage.value != null) {
            processImage(selectedImage.value!);
          }
        },
      );
    } else if (errorMsg.contains('rate limit') ||
        errorMsg.contains('limit exceeded')) {
      // Rate limit exceeded
      Get.defaultDialog(
        title: 'Daily Limit Reached',
        middleText:
            'You\'ve reached your daily extraction limit. Upgrade to Pro for more.',
        textConfirm: 'View Plans',
        textCancel: 'Cancel',
        onConfirm: () {
          Get.back();
          Get.toNamed('/subscription'); // Navigate to subscription page
        },
      );
    } else if (errorMsg.contains('no items') ||
        errorMsg.contains('not detected')) {
      // No items detected
      Get.defaultDialog(
        title: 'No Items Found',
        middleText:
            'We couldn\'t detect any clothing items in this photo. Try a different photo or enter manually.',
        textConfirm: 'Try Different Photo',
        textCancel: 'Enter Manually',
        onConfirm: () {
          Get.back();
          reset();
        },
        onCancel: () {
          proceedToManualEntry();
        },
      );
    } else if (errorMsg.contains('validation') ||
        errorMsg.contains('bounding_box') ||
        errorMsg.contains('AI service')) {
      // AI service unavailable or busy
      Get.defaultDialog(
        title: 'AI Service Unavailable',
        middleText:
            'The AI service is temporarily unavailable. You can enter your item details manually.',
        textConfirm: 'Enter Manually',
        textCancel: 'Cancel',
        onConfirm: () {
          Get.back();
          proceedToManualEntry();
        },
      );
    } else {
      // Generic error
      Get.snackbar(
        'Error',
        'Failed to analyze image. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
      );
    }
  }

  /// Cancel the current extraction job
  Future<void> cancelExtraction() async {
    if (_currentJobId == null) return;

    try {
      await _itemRepository.cancelSingleExtraction(_currentJobId!);
      isProcessing.value = false;
      isGeneratingImages.value = false;
      currentGenerationStatus.value = 'Cancelled';
      _cleanupSSE();
    } catch (e) {
      debugPrint('Failed to cancel extraction: $e');
    }
  }

  /// Cleanup SSE subscription
  void _cleanupSSE() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
    _currentJobId = null;
  }

  /// Generate product images for all detected items
  /// This creates isolated catalog-style images of each clothing item
  Future<void> _generateProductImages(List<DetectedItemData> items) async {
    if (items.isEmpty) return;

    isGeneratingImages.value = true;
    generatedItems.clear();
    generationProgress.value = 0;
    currentGenerationStatus.value = 'Generating product images...';

    try {
      final results = await _itemRepository.generateProductImagesForItems(
        items,
      );
      generatedItems.value = results;
      generationProgress.value = 1.0;
      currentGenerationStatus.value = 'Complete!';

      // Count successful vs failed generations
      final successful = results
          .where((r) => r.generatedImageUrl != null)
          .length;
      final failed = results.where((r) => r.generationError != null).length;

      if (failed > 0) {
        Get.snackbar(
          'Generation Complete',
          '$successful of ${items.length} images generated. $failed failed.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      currentGenerationStatus.value = 'Generation failed';
      Get.snackbar(
        'Generation Failed',
        'Could not generate product images. You can still save items with the original image.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
      );
    } finally {
      isGeneratingImages.value = false;
    }
  }

  /// Save extracted items to wardrobe
  /// Uses generated product images if available, otherwise uses original image
  Future<void> saveExtractedItems(List<DetectedItemData> items) async {
    if (selectedImage.value == null) return;

    final includedItems = items
        .where((item) => item.includeInWardrobe)
        .toList();

    // If we have generated images, use those instead
    if (generatedItems.isNotEmpty) {
      await saveGeneratedItems();
      return;
    }

    // Fallback to original behavior if no generated images
    isSaving.value = true;
    error.value = '';

    try {
      int savedCount = 0;
      for (final item in includedItems) {
        try {
          // Map DetectedItemData to CreateItemRequest
          final request = CreateItemRequest(
            name: item.subCategory ?? item.category,
            category: Category.fromString(item.category),
            colors: item.colors,
            material: item.material,
            pattern: item.pattern,
            description: item.detailedDescription,
            condition: app_condition.Condition.clean,
            occasionTags: selectedUseCases.isEmpty
                ? null
                : UseCases.normalizeList(selectedUseCases),
          );

          final created = await _itemRepository.createItemWithImage(
            image: selectedImage.value!,
            request: request,
          );

          createdItems.add(created);
          savedCount++;
        } catch (e) {
          // Log error but continue with next item
          debugPrint('Failed to save item ${item.category}: $e');
        }
      }

      isSaving.value = false;

      if (savedCount > 0) {
        // Notify WardrobeController for immediate UI update
        if (Get.isRegistered<WardrobeController>()) {
          Get.find<WardrobeController>().addItems(createdItems.toList());
        }
        Get.back(); // Close item add page
        Get.snackbar(
          'Success',
          '$savedCount of ${includedItems.length} item(s) added to your wardrobe',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        );
      } else {
        Get.snackbar(
          'Failed',
          'Could not save items. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      isSaving.value = false;
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
      );
    }
  }

  /// Save items with their generated product images
  /// Uses generated product images if available, otherwise uses original image
  Future<void> saveGeneratedItems() async {
    isSaving.value = true;
    error.value = '';

    try {
      final itemsToSave = generatedItems
          .where((item) => item.includeInWardrobe)
          .toList();

      int savedCount = 0;
      for (final itemWithImage in itemsToSave) {
        try {
          // Skip items that don't have a generated image
          if (itemWithImage.generatedImageUrl == null) {
            continue;
          }

          // Map DetectedItemDataWithImage to CreateItemRequest
          final request = CreateItemRequest(
            name:
                itemWithImage.name ??
                itemWithImage.subCategory ??
                itemWithImage.category,
            category: Category.fromString(itemWithImage.category),
            colors: itemWithImage.colors,
            material: itemWithImage.material,
            pattern: itemWithImage.pattern,
            description: itemWithImage.detailedDescription,
            condition: app_condition.Condition.clean,
            occasionTags: selectedUseCases.isEmpty
                ? null
                : UseCases.normalizeList(selectedUseCases),
          );

          // Create item first (without image - we'll upload the generated one separately)
          final created = await _itemRepository.createItem(request);

          // Upload the generated product image
          // Convert data URL back to base64 for upload (handle different image formats)
          final dataUrlRegex = RegExp(
            r'^data:image/\w+;base64,',
            caseSensitive: false,
          );
          final base64Data = itemWithImage.generatedImageUrl!.replaceFirst(
            dataUrlRegex,
            '',
          );
          await _itemRepository.uploadImageFromBase64(created.id, base64Data);

          // Fetch the complete item with images
          final finalItem = await _itemRepository.getItem(created.id);
          createdItems.add(finalItem);
          savedCount++;
        } catch (e) {
          // Log error but continue with next item
          debugPrint(
            'Failed to save generated item ${itemWithImage.category}: $e',
          );
        }
      }

      isSaving.value = false;

      if (savedCount > 0) {
        // Notify WardrobeController for immediate UI update
        if (Get.isRegistered<WardrobeController>()) {
          Get.find<WardrobeController>().addItems(createdItems.toList());
        }
        Get.back(); // Close item add page
        Get.snackbar(
          'Success',
          '$savedCount of ${itemsToSave.length} item(s) added to your wardrobe',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        );
      } else {
        Get.snackbar(
          'Failed',
          'Could not save items. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      isSaving.value = false;
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
      );
    }
  }

  /// Toggle include/exclude for one generated item.
  void toggleGeneratedItemInclude(String tempId) {
    final index = generatedItems.indexWhere((item) => item.tempId == tempId);
    if (index < 0) return;

    final nextValue = !generatedItems[index].includeInWardrobe;
    generatedItems[index] = generatedItems[index].copyWith(
      includeInWardrobe: nextValue,
    );
  }

  /// Include/exclude all generated items for one detected person.
  void setGeneratedPersonInclusion(String personId, bool include) {
    for (var i = 0; i < generatedItems.length; i++) {
      final key = generatedItems[i].personId ?? 'unassigned';
      if (key == personId) {
        generatedItems[i] = generatedItems[i].copyWith(
          includeInWardrobe: include,
        );
      }
    }
  }

  /// Toggle one use-case tag in the apply-to-all selection.
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

  /// Set the entire apply-to-all use-case selection.
  void setUseCases(Iterable<String> useCases) {
    selectedUseCases
      ..clear()
      ..addAll(UseCases.normalizeList(useCases));
    selectedUseCases.refresh();
  }

  /// Proceed to manual entry (user skipped AI or extraction had no results)
  void proceedToManualEntry() {
    showManualEntry.value = true;
  }

  /// Reset state
  void reset() {
    _cleanupSSE();
    selectedImage.value = null;
    isProcessing.value = false;
    isSaving.value = false;
    isGeneratingImages.value = false;
    extractionResult.value = null;
    generatedItems.clear();
    generationProgress.value = 0;
    currentGenerationStatus.value = '';
    showManualEntry.value = false;
    error.value = '';
    selectedUseCases.clear();
    currentPhase.value = '';
    phaseProgress.value = 0;
    estimatedTimeRemaining.value = 0;
    currentGeneratingIndex.value = 0;
    currentGeneratingItemName.value = '';
    itemGenerationStatus.clear();
    _extractedItemsByTempId.clear();
  }

  @override
  void onClose() {
    _cleanupSSE();
    super.onClose();
  }
}

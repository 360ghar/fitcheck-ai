import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart' as app_condition;
import '../models/item_model.dart';
import '../repositories/item_repository.dart';

/// Controller for item add page
/// Handles image processing, AI extraction, product image generation, and item creation
class ItemAddController extends GetxController {
  final ItemRepository _itemRepository = ItemRepository();

  // Reactive state
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isProcessing = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isGeneratingImages = false.obs;
  final Rx<SyncExtractionResponse?> extractionResult = Rx<SyncExtractionResponse?>(null);
  final RxList<DetectedItemDataWithImage> generatedItems = <DetectedItemDataWithImage>[].obs;
  final RxDouble generationProgress = 0.0.obs;
  final RxString currentGenerationStatus = ''.obs;
  final RxBool showManualEntry = false.obs;
  final RxList<ItemModel> createdItems = <ItemModel>[].obs;
  final RxString error = ''.obs;

  /// Process image for AI extraction (SYNCHRONOUS - no polling!)
  /// Backend returns items immediately from /api/v1/ai/extract-items
  Future<void> processImage(File image) async {
    selectedImage.value = image;
    isProcessing.value = true;
    error.value = '';
    generatedItems.clear();
    generationProgress.value = 0;
    currentGenerationStatus.value = '';

    try {
      // Synchronous call - returns immediately with results
      final response = await _itemRepository.extractItemsFromImage(image);
      extractionResult.value = response;
      isProcessing.value = false;

      if (response.items.isEmpty) {
        // No items detected - show manual entry option
        Get.snackbar(
          'No Items Detected',
          'Try a clearer photo or enter details manually',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        // Automatically generate product images for detected items
        await _generateProductImages(response.items);
      }
    } catch (e) {
      isProcessing.value = false;

      // Check if it's the backend validation error (bounding box issue)
      final errorMsg = e.toString();
      if (errorMsg.contains('validation errors') || errorMsg.contains('bounding_box')) {
        // Backend AI bug - show friendly message and offer manual entry
        Get.defaultDialog(
          title: 'AI Service Busy',
          middleText: 'The AI analysis service is experiencing issues. You can enter your item details manually.',
          textConfirm: 'Enter Manually',
          textCancel: 'Cancel',
          onConfirm: () {
            proceedToManualEntry();
          },
        );
      } else {
        error.value = errorMsg.replaceAll('Exception: ', '');
        Get.snackbar(
          'Error',
          'Failed to analyze image. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
        );
      }
    }
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
      final results = await _itemRepository.generateProductImagesForItems(items);
      generatedItems.value = results;
      generationProgress.value = 1.0;
      currentGenerationStatus.value = 'Complete!';

      // Count successful vs failed generations
      final successful = results.where((r) => r.generatedImageUrl != null).length;
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
      for (final item in items) {
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
          );

          final created = await _itemRepository.createItemWithImage(
            image: selectedImage.value!,
            request: request,
          );

          createdItems.add(created);
          savedCount++;
        } catch (e) {
          // Continue with next item even if one fails
        }
      }

      isSaving.value = false;

      if (savedCount > 0) {
        Get.back(); // Close item add page
        Get.snackbar(
          'Success',
          '$savedCount of ${items.length} item(s) added to your wardrobe',
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
      int savedCount = 0;
      for (final itemWithImage in generatedItems) {
        try {
          // Skip items that don't have a generated image
          if (itemWithImage.generatedImageUrl == null) {
            continue;
          }

          // Map DetectedItemDataWithImage to CreateItemRequest
          final request = CreateItemRequest(
            name: itemWithImage.name ?? itemWithImage.subCategory ?? itemWithImage.category,
            category: Category.fromString(itemWithImage.category),
            colors: itemWithImage.colors,
            material: itemWithImage.material,
            pattern: itemWithImage.pattern,
            description: itemWithImage.detailedDescription,
            condition: app_condition.Condition.clean,
          );

          // Create item first (without image - we'll upload the generated one separately)
          final created = await _itemRepository.createItem(request);

          // Upload the generated product image
          // Convert data URL back to base64 for upload
          final base64Data = itemWithImage.generatedImageUrl!.replaceFirst('data:image/png;base64,', '');
          await _itemRepository.uploadImageFromBase64(created.id, base64Data);

          // Fetch the complete item with images
          final finalItem = await _itemRepository.getItem(created.id);
          createdItems.add(finalItem);
          savedCount++;
        } catch (e) {
          // Continue with next item even if one fails
        }
      }

      isSaving.value = false;

      if (savedCount > 0) {
        Get.back(); // Close item add page
        Get.snackbar(
          'Success',
          '$savedCount of ${generatedItems.length} item(s) added to your wardrobe',
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

  /// Proceed to manual entry (user skipped AI or extraction had no results)
  void proceedToManualEntry() {
    showManualEntry.value = true;
  }

  /// Reset state
  void reset() {
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
  }
}

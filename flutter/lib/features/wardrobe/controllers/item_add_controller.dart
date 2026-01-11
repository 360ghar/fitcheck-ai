import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/enums/condition.dart' as app_condition;
import '../models/item_model.dart';
import '../repositories/item_repository.dart';

/// Controller for item add page
/// Handles image processing, AI extraction, and item creation
class ItemAddController extends GetxController {
  final ItemRepository _itemRepository = ItemRepository();

  // Reactive state
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isProcessing = false.obs;
  final Rx<ExtractionResponse?> extractionResult = Rx<ExtractionResponse?>(null);
  final RxBool showManualEntry = false.obs;
  final RxList<ItemModel> createdItems = <ItemModel>[].obs;
  final RxString error = ''.obs;

  // Polling timer for extraction status
  Timer? _pollingTimer;

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  /// Process image for AI extraction
  Future<void> processImage(File image) async {
    selectedImage.value = image;
    isProcessing.value = true;
    error.value = '';

    try {
      // Start AI extraction
      final response = await _itemRepository.extractItemsFromImage(image);
      extractionResult.value = response;

      // If status is processing, poll for completion
      if (response.status == 'processing' || response.status == 'pending') {
        _pollExtractionStatus(response.id);
      } else if (response.status == 'completed' && response.items != null) {
        isProcessing.value = false;
      } else if (response.status == 'failed') {
        isProcessing.value = false;
        error.value = response.error ?? 'Extraction failed';
        Get.snackbar(
          'Extraction Failed',
          error.value,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      isProcessing.value = false;
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Poll extraction status until completion
  void _pollExtractionStatus(String generationId) async {
    _pollingTimer?.cancel();
    var attempts = 0;
    const maxAttempts = 60; // ~2 minutes
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        attempts++;
        if (attempts >= maxAttempts) {
          timer.cancel();
          isProcessing.value = false;
          error.value = 'Extraction is taking longer than expected';
          Get.snackbar(
            'Taking Too Long',
            error.value,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
        final status = await _itemRepository.getGenerationStatus(generationId);
        extractionResult.value = status;

        if (status.status == 'completed') {
          timer.cancel();
          isProcessing.value = false;
        } else if (status.status == 'failed') {
          timer.cancel();
          isProcessing.value = false;
          error.value = status.error ?? 'Extraction failed';
          Get.snackbar(
            'Extraction Failed',
            error.value,
            snackPosition: SnackPosition.TOP,
          );
        }
      } catch (e) {
        timer.cancel();
        isProcessing.value = false;
      }
    });
  }

  /// Save extracted items to wardrobe
  Future<void> saveExtractedItems(List<ExtractedItem> items) async {
    if (selectedImage.value == null) return;

    try {
      for (final item in items) {
        final request = CreateItemRequest(
          name: item.name,
          category: item.category,
          colors: item.colors,
          material: item.material,
          pattern: item.pattern,
          description: item.description,
          condition: app_condition.Condition.clean,
        );

        final created = await _itemRepository.createItemWithImage(
          image: selectedImage.value!,
          request: request,
        );

        createdItems.add(created);
      }

      Get.back(); // Close item add page
      Get.snackbar(
        'Success',
        '${items.length} item(s) added to your wardrobe',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
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
    extractionResult.value = null;
    showManualEntry.value = false;
    error.value = '';
    _pollingTimer?.cancel();
  }
}

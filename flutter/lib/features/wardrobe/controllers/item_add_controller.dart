import 'dart:io';
import 'package:get/get.dart';
import '../../../domain/enums/condition.dart' as app_condition;
import '../models/item_model.dart';
import '../repositories/item_repository.dart';
import '../utils/extraction_image_utils.dart';
import 'wardrobe_controller.dart';

/// Controller for item add page
/// Handles image processing, AI extraction, and item creation
class ItemAddController extends GetxController {
  final ItemRepository _itemRepository = ItemRepository();

  // Reactive state
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isProcessing = false.obs;
  final Rx<ExtractionResponse?> extractionResult = Rx<ExtractionResponse?>(null);
  final RxBool showManualEntry = false.obs;
  final RxBool isSaving = false.obs;
  final RxList<ItemModel> createdItems = <ItemModel>[].obs;
  final RxString error = ''.obs;


  @override
  void onClose() {
    super.onClose();
  }

  /// Process image for AI extraction
  Future<void> processImage(File image) async {
    selectedImage.value = image;
    isProcessing.value = true;
    error.value = '';

    try {
      // Start AI extraction - backend returns results synchronously
      final response = await _itemRepository.extractItemsFromImage(image);
      extractionResult.value = response;
      extractionResult.refresh(); // Force reactivity for complex object

      // Backend extraction is synchronous, so we always get the result immediately
      isProcessing.value = false;

      // Check if extraction returned any items
      if (response.items == null || response.items!.isEmpty) {
        // No items detected - show manual entry option
        Get.snackbar(
          'No Items Detected',
          'AI could not detect items. You can add them manually.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isProcessing.value = false;
      extractionResult.value = null; // Clear on error
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Crop image for a specific item using its bounding box
  /// Returns original image if no bounding box is available
  Future<File> _cropImageForItem(File originalImage, ExtractedItem item, int index) async {
    if (item.boundingBox == null || item.boundingBox!.isEmpty) {
      return originalImage;
    }

    try {
      final croppedFile = await ExtractionImageUtils.cropToTempFile(
        originalImage,
        item.boundingBox,
        filenameSuffix: '${DateTime.now().millisecondsSinceEpoch}_$index',
      );
      if (croppedFile == null) {
        return originalImage;
      }

      return croppedFile;
    } catch (e) {
      return originalImage;
    }
  }

  /// Save extracted items to wardrobe
  /// Each item gets its own cropped image based on bounding box
  Future<void> saveExtractedItems(List<ExtractedItem> items) async {
    if (selectedImage.value == null || items.isEmpty) return;
    if (isSaving.value) return;

    isSaving.value = true;
    error.value = '';

    try {
      final futures = <Future<ItemModel?>>[];
      for (int i = 0; i < items.length; i++) {
        futures.add(_createItemFromExtraction(items[i], i));
      }

      final results = await Future.wait(futures, eagerError: false);
      final created = results.whereType<ItemModel>().toList();
      createdItems.assignAll(created);

      if (created.isEmpty) {
        Get.snackbar(
          'Error',
          'Unable to save items. Please try again.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      if (Get.isRegistered<WardrobeController>()) {
        Get.find<WardrobeController>().addItems(created);
      }

      Get.back(); // Close item add page

      final failedCount = items.length - created.length;
      final message = failedCount > 0
          ? 'Added ${created.length} of ${items.length} items. ${failedCount} failed.'
          : '${created.length} item(s) added to your wardrobe';

      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<ItemModel?> _createItemFromExtraction(
    ExtractedItem item,
    int index,
  ) async {
    try {
      final croppedImage =
          await _cropImageForItem(selectedImage.value!, item, index);
      final request = CreateItemRequest(
        name: item.name,
        category: item.category,
        colors: item.colors,
        material: item.material,
        pattern: item.pattern,
        description: item.description,
        condition: app_condition.Condition.clean,
      );

      return await _itemRepository.createItemWithImage(
        image: croppedImage,
        request: request,
      );
    } catch (e) {
      return null;
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
    isSaving.value = false;
    error.value = '';
  }
}


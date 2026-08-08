import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/enums/style.dart';
import '../../../domain/enums/season.dart';
import '../models/outfit_model.dart';
import '../../wardrobe/models/item_model.dart';
import '../repositories/outfit_repository.dart';
import '../../wardrobe/repositories/item_repository.dart';
import '../../wardrobe/controllers/wardrobe_controller.dart';
import 'outfit_list_controller.dart';
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

/// Controller for outfit builder
/// Manages outfit creation, item selection, and AI generation
class OutfitBuilderController extends GetxController {
  final OutfitRepository _outfitRepository;
  final ItemRepository _itemRepository;

  /// Both repositories are injectable so unit tests can drive the save-time
  /// image-upload strategy without hitting the real API. Default to live
  /// repositories in production.
  OutfitBuilderController({
    OutfitRepository? outfitRepository,
    ItemRepository? itemRepository,
  }) : _outfitRepository = outfitRepository ?? OutfitRepository(),
       _itemRepository = itemRepository ?? ItemRepository();

  // Worker for cleanup
  Worker? _wardrobeItemsWorker;

  // Reactive state
  final RxList<ItemModel> availableItems = <ItemModel>[].obs;
  final RxList<OutfitBuilderItem> selectedItems = <OutfitBuilderItem>[].obs;
  final RxString name = ''.obs;
  final RxString description = ''.obs;
  final Rx<Style> selectedStyle = Style.casual.obs;
  final Rx<Season> selectedSeason = Season.allSeason.obs;
  final RxSet<String> tags = <String>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  final RxBool isSaving = false.obs;
  final RxString generatedImageUrl = ''.obs;
  final RxString error = ''.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString categoryFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAvailableItems();
  }

  Future<void> _loadAvailableItems() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    // Try to sync with WardrobeController for real-time updates
    if (Get.isRegistered<WardrobeController>()) {
      final wardrobeController = Get.find<WardrobeController>();

      // Use wardrobe's items directly. Safe to write synchronously: the
      // settleBuildPhase above already put us outside the build phase.
      availableItems.value = wardrobeController.items.toList();

      // Listen for changes to wardrobe items. The wardrobe controller is kept
      // alive by the shell IndexedStack and can emit during a
      // build/layout/paint phase, so the write is deferred in that case.
      // See [afterBuildPhase].
      _wardrobeItemsWorker = ever(wardrobeController.items, (items) {
        final updated = items.toList();
        afterBuildPhase(() {
          if (!isClosed) availableItems.value = updated;
        });
      });

      // If wardrobe is empty, load independently as fallback
      if (availableItems.isEmpty) {
        await _loadItemsFromRepository();
      }
    } else {
      // Fallback: load independently
      await _loadItemsFromRepository();
    }
  }

  Future<void> _loadItemsFromRepository() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      isLoading.value = true;
      final response = await _itemRepository.getItems(limit: 100);
      availableItems.value = response.items;
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if item is selected
  bool isItemSelected(String itemId) {
    return selectedItems.any((oi) => oi.item.id == itemId);
  }

  /// Toggle item selection (add if not selected, remove if selected)
  void toggleItem(ItemModel item) {
    if (isItemSelected(item.id)) {
      removeItemByItemId(item.id);
    } else {
      addItem(item);
    }
  }

  /// Add item to outfit
  void addItem(ItemModel item) {
    if (selectedItems.any((oi) => oi.item.id == item.id)) return;

    final outfitItem = OutfitBuilderItem(
      item: item,
      id: '${item.id}-${DateTime.now().millisecondsSinceEpoch}',
      position: Offset(
        50 + selectedItems.length * 30.0,
        50 + selectedItems.length * 30.0,
      ),
      layer: selectedItems.length,
      isVisible: true,
    );
    selectedItems.add(outfitItem);
  }

  /// Remove item from outfit by outfit builder item id
  void removeItem(String id) {
    selectedItems.removeWhere((oi) => oi.id == id);
    _recalculateLayers();
  }

  /// Remove item from outfit by original item id
  void removeItemByItemId(String itemId) {
    selectedItems.removeWhere((oi) => oi.item.id == itemId);
    _recalculateLayers();
  }

  /// Toggle item visibility
  void toggleVisibility(String id) {
    final index = selectedItems.indexWhere((oi) => oi.id == id);
    if (index != -1) {
      selectedItems[index] = selectedItems[index].copyWith(
        isVisible: !selectedItems[index].isVisible,
      );
      selectedItems.refresh();
    }
  }

  /// Update item position
  void updateItemPosition(String id, Offset position) {
    final index = selectedItems.indexWhere((oi) => oi.id == id);
    if (index != -1) {
      selectedItems[index] = selectedItems[index].copyWith(position: position);
      selectedItems.refresh();
    }
  }

  /// Move item layer
  void moveLayer(String id, bool up) {
    final index = selectedItems.indexWhere((oi) => oi.id == id);
    if (index == -1) return;

    final item = selectedItems[index];
    final newLayer = up ? item.layer + 1 : item.layer - 1;
    if (newLayer < 0 || newLayer >= selectedItems.length) return;

    final swapIndex = selectedItems.indexWhere((oi) => oi.layer == newLayer);
    if (swapIndex != -1) {
      selectedItems[swapIndex] = selectedItems[swapIndex].copyWith(layer: item.layer);
    }
    selectedItems[index] = item.copyWith(layer: newLayer);
    selectedItems.refresh();
  }

  void _recalculateLayers() {
    for (var i = 0; i < selectedItems.length; i++) {
      selectedItems[i] = selectedItems[i].copyWith(layer: i);
    }
    selectedItems.refresh();
  }

  /// Get filtered items (includes selected items so they can show selection state)
  List<ItemModel> get filteredItems {
    return availableItems.where((item) {
      // Category filter
      if (categoryFilter.value != 'all' &&
          item.category.name != categoryFilter.value) {
        return false;
      }

      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!item.name.toLowerCase().contains(query) &&
            !(item.brand?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Generate AI outfit visualization
  Future<void> generateAIOutfit() async {
    if (selectedItems.isEmpty) {
      ErrorHandler.showValidation('Please add items first', title: 'Error');
      return;
    }

    isGenerating.value = true;
    error.value = '';

    try {
      final visibleItems = selectedItems
          .where((oi) => oi.isVisible)
          .map((oi) => AIOutfitItem(
                itemId: oi.item.id,
                name: oi.item.name,
                category: oi.item.category.name,
                colors: oi.item.colors,
                brand: oi.item.brand,
                material: oi.item.material,
                pattern: oi.item.pattern,
              ).toJson())
          .toList();

      final result = await _outfitRepository.generateOutfitVisualization(
        visibleItems,
        style: selectedStyle.value.name,
        background: 'studio white',
      );

      generatedImageUrl.value =
          result.imageUrl ?? 'data:image/png;base64,${result.imageBase64}';

      ErrorHandler.showSuccess('Outfit visualization generated', title: 'Success');
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value, title: 'Error');
    } finally {
      isGenerating.value = false;
    }
  }

  /// Save outfit
  Future<void> saveOutfit() async {
    if (name.value.trim().isEmpty) {
      ErrorHandler.showValidation('Please enter an outfit name', title: 'Error');
      return;
    }

    if (selectedItems.isEmpty) {
      ErrorHandler.showValidation('Please add at least one item', title: 'Error');
      return;
    }

    isSaving.value = true;

    try {
      final request = CreateOutfitRequest(
        name: name.value.trim(),
        description: description.value.trim().isEmpty
            ? null
            : description.value.trim(),
        itemIds: selectedItems.map((oi) => oi.item.id).toList(),
        style: selectedStyle.value,
        season: selectedSeason.value,
        tags: tags.isEmpty ? [] : tags.toList(),
      );

      final outfit = await _outfitRepository.createOutfit(request);

      // Keep the outfits list in sync so the new outfit appears in the tab
      // without a manual pull-to-refresh.
      if (Get.isRegistered<OutfitListController>()) {
        Get.find<OutfitListController>().addOutfit(outfit);
      }

      // Upload generated image if available (automatic save like web
      // version). The AI service returns the visualization either as a
      // base64 data URI (default) or, when save_to_storage is enabled, as a
      // presigned URL — handle both:
      //  1. Data-URI: strip the prefix and upload the embedded bytes.
      //  2. Real URL: download the bytes and re-upload (mirrors the item
      //     save chain).
      // Upload failures must not fail the outfit save itself; the image is
      // still recoverable from the detail page re-mint fallback.
      var imageUploaded = false;
      final generatedUrl = generatedImageUrl.value;
      if (generatedUrl.startsWith('data:image/')) {
        final base64Data = generatedUrl.split(',').last;
        try {
          imageUploaded =
              await _outfitRepository.uploadOutfitImageFromBase64(
                outfit.id,
                base64Data,
                isPrimary: true,
                pose: 'front',
              ) !=
              null;
        } catch (e) {
          // Log error but don't fail the outfit save
          debugPrint('Error uploading generated image: $e');
        }
      } else if (generatedUrl.isNotEmpty) {
        // Post-generate-outfit state when the backend saved the visualization
        // to storage: only the presigned URL remains, so download and
        // re-upload the bytes.
        try {
          imageUploaded =
              await _outfitRepository.uploadOutfitImageFromUrl(
                outfit.id,
                generatedUrl,
                isPrimary: true,
                pose: 'front',
              ) !=
              null;
        } catch (e) {
          // Log error but don't fail the outfit save
          debugPrint('Error uploading generated image from URL: $e');
        }
      }

      if (!imageUploaded && generatedUrl.isNotEmpty) {
        ErrorHandler.reportError(
          StateError('Outfit image upload failed'),
          'saveOutfit: outfit ${outfit.id} ("${name.value.trim()}") was '
          'created but its generated visualization never made it to storage',
        );
      }

      Get.back(result: outfit);
      ErrorHandler.showSuccess('Outfit saved successfully', title: 'Success');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
    } finally {
      isSaving.value = false;
    }
  }

  /// Clear selection
  void clearSelection() {
    selectedItems.clear();
    name.value = '';
    description.value = '';
    selectedStyle.value = Style.casual;
    selectedSeason.value = Season.allSeason;
    tags.clear();
    generatedImageUrl.value = '';
    error.value = '';
  }

  @override
  void onClose() {
    _wardrobeItemsWorker?.dispose();
    clearSelection();
    super.onClose();
  }
}

/// Outfit builder item with position and layer info
class OutfitBuilderItem {
  final ItemModel item;
  final String id;
  final Offset position;
  final int layer;
  final bool isVisible;

  OutfitBuilderItem({
    required this.item,
    required this.id,
    required this.position,
    required this.layer,
    required this.isVisible,
  });

  OutfitBuilderItem copyWith({
    ItemModel? item,
    String? id,
    Offset? position,
    int? layer,
    bool? isVisible,
  }) {
    return OutfitBuilderItem(
      item: item ?? this.item,
      id: id ?? this.id,
      position: position ?? this.position,
      layer: layer ?? this.layer,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// AI outfit item for generation request
class AIOutfitItem {
  /// Wardrobe item id. The backend resolves this item's stored image
  /// server-side and sends it to the image model as a garment reference, so the
  /// generated outfit reproduces the real garment instead of inventing a
  /// lookalike from the text attributes below.
  final String itemId;
  final String name;
  final String category;
  final List<String>? colors;
  final String? brand;
  final String? material;
  final String? pattern;

  AIOutfitItem({
    required this.itemId,
    required this.name,
    required this.category,
    this.colors,
    this.brand,
    this.material,
    this.pattern,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'name': name,
      'category': category,
      // Omit rather than send null: OutfitItemInput.colors is List[str] with a
      // default factory, so an explicit null would 422.
      if (colors != null) 'colors': colors,
      'brand': brand,
      'material': material,
      'pattern': pattern,
    };
  }
}

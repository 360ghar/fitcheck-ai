import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/enums/style.dart';
import '../../../domain/enums/season.dart';
import '../models/outfit_model.dart';
import '../../wardrobe/models/item_model.dart';
import '../repositories/outfit_repository.dart';
import '../../wardrobe/repositories/item_repository.dart';

/// Controller for outfit builder
/// Manages outfit creation, item selection, and AI generation
class OutfitBuilderController extends GetxController {
  final OutfitRepository _outfitRepository = OutfitRepository();
  final ItemRepository _itemRepository = ItemRepository();

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
    try {
      isLoading.value = true;
      final response = await _itemRepository.getItems(limit: 100);
      availableItems.value = response.items;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
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
      Get.snackbar('Error', 'Please add items first');
      return;
    }

    isGenerating.value = true;
    error.value = '';

    try {
      final visibleItems = selectedItems
          .where((oi) => oi.isVisible)
          .map((oi) => AIOutfitItem(
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

      Get.snackbar('Success', 'Outfit visualization generated');
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', error.value);
    } finally {
      isGenerating.value = false;
    }
  }

  /// Save outfit
  Future<void> saveOutfit() async {
    if (name.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter an outfit name');
      return;
    }

    if (selectedItems.isEmpty) {
      Get.snackbar('Error', 'Please add at least one item');
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

      // Upload generated image if available (automatic save like web version)
      if (generatedImageUrl.value.isNotEmpty) {
        try {
          await _outfitRepository.uploadOutfitImageFromBase64(
            outfit.id,
            generatedImageUrl.value,
            isPrimary: true,
            pose: 'front',
          );
        } catch (e) {
          // Log error but don't fail the outfit save
          debugPrint('Error uploading generated image: $e');
        }
      }

      Get.back(result: outfit);
      Get.snackbar('Success', 'Outfit saved successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
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
  final String name;
  final String category;
  final List<String>? colors;
  final String? brand;
  final String? material;
  final String? pattern;

  AIOutfitItem({
    required this.name,
    required this.category,
    this.colors,
    this.brand,
    this.material,
    this.pattern,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'colors': colors,
      'brand': brand,
      'material': material,
      'pattern': pattern,
    };
  }
}

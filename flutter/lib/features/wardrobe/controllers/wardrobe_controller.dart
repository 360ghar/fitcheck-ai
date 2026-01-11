import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/enums/category.dart';
import '../../../../domain/enums/condition.dart' as domain;
import '../models/item_model.dart';
import '../repositories/item_repository.dart';

/// Wardrobe controller
class WardrobeController extends GetxController {
  final ItemRepository _itemRepository = ItemRepository();

  // Workers for cleanup
  final List<Worker> _workers = [];

  // Reactive state
  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxList<ItemModel> filteredItems = <ItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;
  final Rx<ItemModel?> selectedItem = Rx<ItemModel?>(null);
  final RxSet<String> selectedIds = <String>{}.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxSet<Category> selectedCategories = <Category>{}.obs;
  final RxSet<domain.Condition> selectedConditions = <domain.Condition>{}.obs;
  final RxSet<String> selectedColors = <String>{}.obs;
  final RxString sortType = 'newest'.obs;
  final RxString viewMode = 'grid'.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxInt totalItems = 0.obs;

  // Getters
  bool get hasError => error.value.isNotEmpty;
  bool get isSelectionActive => selectedIds.isNotEmpty;
  int get selectedCount => selectedIds.length;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
    _setupFilters();
  }

  @override
  void onClose() {
    // Clean up all workers to prevent memory leaks
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.onClose();
  }

  void _setupFilters() {
    // Debounce search query to avoid excessive filtering on every keystroke
    _workers.add(
      debounce(
        searchQuery,
        (_) => applyFilters(),
        time: const Duration(milliseconds: 300),
      ),
    );

    // Other filters apply immediately (they're not changed rapidly like search)
    _workers.addAll([
      ever(selectedCategories, (_) => applyFilters()),
      ever(selectedConditions, (_) => applyFilters()),
      ever(selectedColors, (_) => applyFilters()),
      ever(sortType, (_) => applyFilters()),
    ]);
  }

  /// Fetch items from server
  Future<void> fetchItems({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      items.clear();
    }

    if (isLoadingMore.value) return;

    try {
      if (refresh) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      error.value = '';

      final response = await _itemRepository.getItems(
        page: currentPage.value,
        limit: 20,
      );

      if (refresh) {
        items.clear();
      }

      items.addAll(response.items);
      totalItems.value = response.total;
      hasMore.value = response.hasMore;
      currentPage.value++;

      applyFilters();
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Apply filters and sort
  void applyFilters() {
    filteredItems.value = items.where((item) {
      // Search query filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!item.name.toLowerCase().contains(query) &&
            !(item.brand?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Category filter
      if (selectedCategories.isNotEmpty &&
          !selectedCategories.contains(item.category)) {
        return false;
      }

      // Condition filter
      if (selectedConditions.isNotEmpty &&
          !selectedConditions.contains(item.condition)) {
        return false;
      }

      // Color filter
      if (selectedColors.isNotEmpty) {
        final colors = item.colors ?? const <String>[];
        if (colors.isEmpty ||
            !selectedColors.any((c) => colors.contains(c))) {
          return false;
        }
      }

      return true;
    }).toList();

    _sortItems();
  }

  void _sortItems() {
    switch (sortType.value) {
      case 'newest':
        filteredItems.sort((a, b) =>
            (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        break;
      case 'oldest':
        filteredItems.sort((a, b) =>
            (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
        break;
      case 'name':
        filteredItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'most_worn':
        filteredItems.sort((a, b) => b.wornCount.compareTo(a.wornCount));
        break;
      case 'favorite':
        // Sort favorites first, then non-favorites
        filteredItems.sort((a, b) {
          if (a.isFavorite == b.isFavorite) {
            return (b.createdAt ?? DateTime(0))
                .compareTo(a.createdAt ?? DateTime(0));
          }
          return a.isFavorite ? -1 : 1;
        });
        break;
    }
  }

  /// Select/deselect item
  void toggleItemSelection(ItemModel item) {
    if (selectedIds.contains(item.id)) {
      selectedIds.remove(item.id);
    } else {
      selectedIds.add(item.id);
    }
  }

  /// Clear selection
  void clearSelection() {
    selectedIds.clear();
  }

  /// Select all filtered items
  void selectAllVisible() {
    for (final item in filteredItems) {
      selectedIds.add(item.id);
    }
  }

  /// Set selected item
  void setSelectedItem(ItemModel? item) {
    selectedItem.value = item;
  }

  /// Toggle category filter
  void toggleCategoryFilter(Category category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }

  /// Toggle condition filter
  void toggleConditionFilter(domain.Condition condition) {
    if (selectedConditions.contains(condition)) {
      selectedConditions.remove(condition);
    } else {
      selectedConditions.add(condition);
    }
  }

  /// Toggle color filter
  void toggleColorFilter(String color) {
    if (selectedColors.contains(color)) {
      selectedColors.remove(color);
    } else {
      selectedColors.add(color);
    }
  }

  /// Clear all filters
  void clearAllFilters() {
    searchQuery.value = '';
    selectedCategories.clear();
    selectedConditions.clear();
    selectedColors.clear();
    sortType.value = 'newest';
  }

  /// Set view mode
  void setViewMode(String mode) {
    viewMode.value = mode;
  }

  /// Set sort type
  void setSortType(String type) {
    sortType.value = type;
  }

  /// Toggle item favorite
  Future<void> toggleFavorite(String itemId) async {
    try {
      final updatedItem = await _itemRepository.toggleFavorite(itemId);

      // Update in lists
      final index = items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        items[index] = updatedItem;
      }

      final filteredIndex = filteredItems.indexWhere((item) => item.id == itemId);
      if (filteredIndex != -1) {
        filteredItems[filteredIndex] = updatedItem;
      }

      if (selectedItem.value?.id == itemId) {
        selectedItem.value = updatedItem;
      }

      Get.snackbar(
        '',
        updatedItem.isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Mark item as worn
  Future<void> markAsWorn(String itemId) async {
    try {
      final updatedItem = await _itemRepository.markAsWorn(itemId);

      // Update in lists
      final index = items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        items[index] = updatedItem;
      }

      final filteredIndex = filteredItems.indexWhere((item) => item.id == itemId);
      if (filteredIndex != -1) {
        filteredItems[filteredIndex] = updatedItem;
      }

      if (selectedItem.value?.id == itemId) {
        selectedItem.value = updatedItem;
      }

      Get.snackbar(
        'Great choice!',
        'Item marked as worn',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Delete item
  Future<void> deleteItem(String itemId) async {
    try {
      await _itemRepository.deleteItem(itemId);

      items.removeWhere((item) => item.id == itemId);
      applyFilters();

      if (selectedItem.value?.id == itemId) {
        selectedItem.value = null;
      }

      Get.snackbar(
        'Deleted',
        'Item removed from wardrobe',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Batch delete selected items
  Future<void> batchDeleteSelected() async {
    if (selectedIds.isEmpty) return;

    try {
      await _itemRepository.batchDeleteItems(selectedIds.toList());

      items.removeWhere((item) => selectedIds.contains(item.id));
      clearSelection();
      applyFilters();

      Get.snackbar(
        'Deleted',
        '${selectedIds.length} items removed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Clear error
  void clearError() {
    error.value = '';
  }
}

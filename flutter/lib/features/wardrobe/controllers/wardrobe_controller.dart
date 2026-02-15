import 'package:get/get.dart';
import '../../../../domain/constants/use_cases.dart';
import '../../../../domain/enums/category.dart';
import '../../../../domain/enums/condition.dart' as domain;
import '../../../app/routes/app_routes.dart';
import '../models/item_model.dart';
import '../repositories/item_repository.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/network_service.dart'
    show RetryHelper, NetworkService;

/// Wardrobe controller
class WardrobeController extends GetxController {
  final ItemRepository _itemRepository = ItemRepository();
  final NetworkService _networkService = Get.find<NetworkService>();

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
  final RxBool isOffline = false.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxSet<Category> selectedCategories = <Category>{}.obs;
  final RxSet<domain.Condition> selectedConditions = <domain.Condition>{}.obs;
  final RxSet<String> selectedColors = <String>{}.obs;
  final RxString selectedOccasion = ''.obs;
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

  // Action-specific loading states (per-item)
  final RxMap<String, bool> isDeletingMap = <String, bool>{}.obs;
  final RxMap<String, bool> isFavoritingMap = <String, bool>{}.obs;
  final RxMap<String, bool> isMarkingWornMap = <String, bool>{}.obs;
  final RxBool isBatchDeleting = false.obs;

  // Loading state helpers
  bool isDeleting(String id) => isDeletingMap[id] ?? false;
  bool isFavoriting(String id) => isFavoritingMap[id] ?? false;
  bool isMarkingWorn(String id) => isMarkingWornMap[id] ?? false;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
    _setupFilters();
    _setupNetworkMonitoring();
    _setupRouteListener();
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
    // Debounce all filter changes to avoid excessive API calls
    _workers.add(
      debounce(
        searchQuery,
        (_) => fetchItems(refresh: true),
        time: const Duration(milliseconds: 500),
      ),
    );

    // Other filters trigger refetch with debounce
    _workers.addAll([
      debounce(
        selectedCategories,
        (_) => fetchItems(refresh: true),
        time: const Duration(milliseconds: 100),
      ),
      debounce(
        selectedConditions,
        (_) => fetchItems(refresh: true),
        time: const Duration(milliseconds: 100),
      ),
      debounce(
        selectedColors,
        (_) => fetchItems(refresh: true),
        time: const Duration(milliseconds: 100),
      ),
      debounce(
        selectedOccasion,
        (_) => fetchItems(refresh: true),
        time: const Duration(milliseconds: 100),
      ),
      debounce(
        sortType,
        (_) => fetchItems(refresh: true),
        time: const Duration(milliseconds: 100),
      ),
    ]);
  }

  /// Fetch items from server with filters
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

      // Build filter parameters for server-side filtering
      final response = await RetryHelper.execute(
        operation: () => _itemRepository.getItems(
          page: currentPage.value,
          limit: 20,
          search: searchQuery.value.isEmpty ? null : searchQuery.value,
          categories: selectedCategories.isEmpty
              ? null
              : selectedCategories.map((c) => c.name.toLowerCase()).toList(),
          colors: selectedColors.isEmpty ? null : selectedColors.toList(),
          occasion: selectedOccasion.value.isEmpty
              ? null
              : UseCases.normalize(selectedOccasion.value),
          conditions: selectedConditions.isEmpty
              ? null
              : selectedConditions.map((c) => c.name.toLowerCase()).toList(),
          sortBy: _mapSortTypeToApi(sortType.value),
          sortOrder: _getSortOrder(sortType.value),
        ),
        maxAttempts: 3,
      );

      if (refresh) {
        items.clear();
      }

      items.addAll(response.items);
      totalItems.value = response.total;
      hasMore.value = response.hasMore;
      currentPage.value++;

      // Server-side filtering - no client-side filtering needed
      filteredItems.value = items.toList();
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', error.value, snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Map sort type to API sort_by parameter
  String _mapSortTypeToApi(String sortType) {
    switch (sortType) {
      case 'newest':
      case 'oldest':
        return 'created_at';
      case 'name':
        return 'name';
      case 'most_worn':
        return 'worn_count';
      case 'favorite':
        return 'is_favorite';
      default:
        return 'created_at';
    }
  }

  /// Get sort order based on sort type
  String _getSortOrder(String sortType) {
    switch (sortType) {
      case 'oldest':
        return 'asc';
      default:
        return 'desc';
    }
  }

  /// Apply filters - triggers server refetch with current filters
  void applyFilters() {
    fetchItems(refresh: true);
  }

  /// Select/deselect item
  void toggleItemSelection(ItemModel item) {
    HapticService.selectionClick();
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

  /// Set use-case filter (single value).
  void setOccasionFilter(String value) {
    selectedOccasion.value = UseCases.normalize(value);
  }

  /// Clear all filters
  void clearAllFilters() {
    searchQuery.value = '';
    selectedCategories.clear();
    selectedConditions.clear();
    selectedColors.clear();
    selectedOccasion.value = '';
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
    HapticService.favorite();
    isFavoritingMap[itemId] = true;
    try {
      final updatedItem = await _itemRepository.toggleFavorite(itemId);

      // Update in lists
      final index = items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        items[index] = updatedItem;
      }

      final filteredIndex = filteredItems.indexWhere(
        (item) => item.id == itemId,
      );
      if (filteredIndex != -1) {
        filteredItems[filteredIndex] = updatedItem;
      }

      if (selectedItem.value?.id == itemId) {
        selectedItem.value = updatedItem;
      }

      Get.snackbar(
        '',
        updatedItem.isFavorite
            ? 'Added to Favorites'
            : 'Removed from Favorites',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isFavoritingMap.remove(itemId);
    }
  }

  /// Mark item as worn
  Future<void> markAsWorn(String itemId) async {
    HapticService.lightImpact();
    isMarkingWornMap[itemId] = true;
    try {
      final updatedItem = await _itemRepository.markAsWorn(itemId);

      // Update in lists
      final index = items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        items[index] = updatedItem;
      }

      final filteredIndex = filteredItems.indexWhere(
        (item) => item.id == itemId,
      );
      if (filteredIndex != -1) {
        filteredItems[filteredIndex] = updatedItem;
      }

      if (selectedItem.value?.id == itemId) {
        selectedItem.value = updatedItem;
      }

      Get.snackbar(
        'Great choice!',
        'Item marked as worn',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isMarkingWornMap.remove(itemId);
    }
  }

  /// Delete item
  Future<void> deleteItem(String itemId) async {
    HapticService.delete();
    isDeletingMap[itemId] = true;
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
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    } finally {
      isDeletingMap.remove(itemId);
    }
  }

  /// Batch delete selected items
  Future<void> batchDeleteSelected() async {
    if (selectedIds.isEmpty) return;

    isBatchDeleting.value = true;
    final count = selectedIds.length;
    try {
      await _itemRepository.batchDeleteItems(selectedIds.toList());

      items.removeWhere((item) => selectedIds.contains(item.id));
      clearSelection();
      applyFilters();

      Get.snackbar(
        'Deleted',
        '$count items removed',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    } finally {
      isBatchDeleting.value = false;
    }
  }

  /// Clear error
  void clearError() {
    error.value = '';
  }

  // ============================================================
  // Direct sync methods for cross-controller communication
  // ============================================================

  /// Add a newly created item to the list (for immediate UI update)
  /// Called by ItemAddController, BatchExtractionController after creating items
  void addItem(ItemModel item) {
    items.insert(0, item);
    filteredItems.insert(0, item);
    totalItems.value++;
  }

  /// Add multiple newly created items to the list
  /// Called by BatchExtractionController after batch saving items
  void addItems(List<ItemModel> newItems) {
    if (newItems.isEmpty) return;
    items.insertAll(0, newItems);
    filteredItems.insertAll(0, newItems);
    totalItems.value += newItems.length;
  }

  /// Update an existing item in the list (for immediate UI update)
  /// Called by ItemDetailController after updating an item
  void updateItem(ItemModel updatedItem) {
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
    }

    final filteredIndex = filteredItems.indexWhere(
      (item) => item.id == updatedItem.id,
    );
    if (filteredIndex != -1) {
      filteredItems[filteredIndex] = updatedItem;
    }

    if (selectedItem.value?.id == updatedItem.id) {
      selectedItem.value = updatedItem;
    }
  }

  /// Remove an item from local state (without API call)
  /// Used for immediate UI update when item is deleted elsewhere
  void removeItemFromState(String itemId) {
    items.removeWhere((item) => item.id == itemId);
    filteredItems.removeWhere((item) => item.id == itemId);
    selectedIds.remove(itemId);
    if (selectedItem.value?.id == itemId) {
      selectedItem.value = null;
    }
    if (totalItems.value > 0) {
      totalItems.value--;
    }
  }

  /// Setup network monitoring
  void _setupNetworkMonitoring() {
    // Update offline state based on network connectivity
    _workers.add(
      ever(_networkService.isConnected, (connected) {
        isOffline.value = !connected;
        if (connected && items.isEmpty && !isLoading.value) {
          // Network recovered and we have no items, try fetching
          fetchItems();
        }
      }),
    );

    // Initial state
    isOffline.value = !_networkService.isConnected.value;
  }

  /// Setup route listener to refresh when returning to this page
  void _setupRouteListener() {
    // Track previous route to detect when we're coming back from item add/edit
    String? previousRoute;
    bool shouldRefreshOnWardrobe = false;

    _workers.add(
      ever(Get.routing.obs, (routing) {
        final currentRoute = Get.currentRoute;

        // Mark that we should refresh when we come back to wardrobe
        // after being on item add, batch add, or item edit pages
        if (previousRoute != null &&
            (previousRoute == Routes.wardrobeAdd ||
                previousRoute == Routes.wardrobeBatchAdd ||
                previousRoute == Routes.wardrobeBatchReview ||
                previousRoute == Routes.wardrobeBatchProgress ||
                previousRoute?.startsWith(Routes.wardrobeItemEdit) == true ||
                previousRoute == Routes.outfitBuilder)) {
          shouldRefreshOnWardrobe = true;
        }

        // When navigating to wardrobe/home and we marked that we should refresh
        if ((currentRoute == Routes.wardrobe || currentRoute == Routes.home) &&
            shouldRefreshOnWardrobe) {
          shouldRefreshOnWardrobe = false;
          // Give UI time to settle before refreshing
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!isLoading.value && !isLoadingMore.value) {
              fetchItems(refresh: true);
            }
          });
        }

        previousRoute = currentRoute;
      }),
    );
  }
}

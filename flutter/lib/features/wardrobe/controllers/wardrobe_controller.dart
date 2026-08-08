import 'package:get/get.dart';
import '../../../../domain/constants/use_cases.dart';
import '../../../../domain/enums/category.dart';
import '../../../../domain/enums/condition.dart' as domain;
import '../models/item_model.dart';
import '../repositories/item_repository.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/network_service.dart'
    show RetryHelper, NetworkService;
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

/// Wardrobe controller
class WardrobeController extends GetxController {
  final ItemRepository _itemRepository;
  final NetworkService _networkService;

  /// Both [itemRepository] and [networkService] are injectable for unit tests.
  /// Default to live implementations in production.
  WardrobeController({
    ItemRepository? itemRepository,
    NetworkService? networkService,
  }) : _itemRepository = itemRepository ?? ItemRepository(),
       _networkService = networkService ?? Get.find<NetworkService>();

  // Workers for cleanup
  final List<Worker> _workers = [];
  int _fetchGeneration = 0;

  // Reactive state
  final RxList<ItemModel> items = <ItemModel>[].obs;
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

  // Single-item fetch state (deep links, items beyond the loaded page)
  final RxBool isFetchingItem = false.obs;
  final RxString itemFetchError = ''.obs;

  // Getters
  bool get hasError => error.value.isNotEmpty;
  bool get isSelectionActive => selectedIds.isNotEmpty;
  int get selectedCount => selectedIds.length;

  /// The list shown to the user. Filtering is server-side, so this is the
  /// single item list — kept as a named getter for view compatibility.
  List<ItemModel> get filteredItems => items;

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
  }

  @override
  void onClose() {
    _fetchGeneration++;
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
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;

    if (!_networkService.isConnected.value) {
      // Invalidate any in-flight fetch so stale results for the previous
      // filters cannot populate the new filter state after reconnect.
      _fetchGeneration++;
      isLoading.value = false;
      isLoadingMore.value = false;
      isOffline.value = true;
      error.value = 'You are offline. Reconnect to refresh your wardrobe.';
      return;
    }

    if (refresh) {
      _fetchGeneration++;
      currentPage.value = 1;
      hasMore.value = true;
      items.clear();
    } else {
      if (isLoadingMore.value) return;
      _fetchGeneration++;
    }
    final requestGeneration = _fetchGeneration;
    final requestPage = currentPage.value;
    final requestSearch = searchQuery.value.isEmpty ? null : searchQuery.value;
    final requestCategories = selectedCategories.isEmpty
        ? null
        : selectedCategories.map((c) => c.name.toLowerCase()).toList();
    final requestColors = selectedColors.isEmpty
        ? null
        : selectedColors.toList();
    final requestOccasion = selectedOccasion.value.isEmpty
        ? null
        : UseCases.normalize(selectedOccasion.value);
    final requestConditions = selectedConditions.isEmpty
        ? null
        : selectedConditions.map((c) => c.name.toLowerCase()).toList();
    final requestSortType = sortType.value;

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
          page: requestPage,
          limit: 20,
          search: requestSearch,
          categories: requestCategories,
          colors: requestColors,
          occasion: requestOccasion,
          conditions: requestConditions,
          sortBy: _mapSortTypeToApi(requestSortType),
          sortOrder: _getSortOrder(requestSortType),
        ),
        maxAttempts: 3,
      );

      if (requestGeneration != _fetchGeneration || isClosed) return;

      if (refresh) {
        items.clear();
      }

      items.addAll(response.items);
      totalItems.value = response.total;
      hasMore.value = response.hasMore;
      currentPage.value++;
    } catch (e) {
      if (requestGeneration != _fetchGeneration || isClosed) return;
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value, title: 'Error');
    } finally {
      if (requestGeneration == _fetchGeneration) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  /// Fetch a single item from the server.
  ///
  /// Returns the cached item when it is already on the loaded page; otherwise
  /// fetches it and merges it into [items]. Used by [ItemDetailPage] so a deep
  /// link to an item on a later page does not strand the user on an infinite
  /// shimmer.
  Future<ItemModel?> fetchItemById(String itemId) async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return null;

    final cached = items.firstWhereOrNull((item) => item.id == itemId);
    if (cached != null) return cached;

    isFetchingItem.value = true;
    itemFetchError.value = '';
    try {
      final item = await _itemRepository.getItem(itemId);
      if (isClosed) return null;
      final index = items.indexWhere((existing) => existing.id == itemId);
      if (index == -1) {
        items.add(item);
      } else {
        items[index] = item;
      }
      return item;
    } catch (e) {
      if (isClosed) return null;
      itemFetchError.value = ErrorHandler.extractMessage(e);
      return null;
    } finally {
      if (!isClosed) isFetchingItem.value = false;
    }
  }

  /// Refresh a single item from the server and replace the cached entry.
  ///
  /// The API serves short-lived presigned image URLs (1h TTL) materialized
  /// at the last fetch, so a detail page opened later must re-fetch instead
  /// of rendering the cached model blind. Errors are swallowed — the cached
  /// model stays on screen — but surfaced through the standard error
  /// snackbar.
  Future<void> refreshItemById(String itemId) async {
    try {
      final item = await _itemRepository.getItem(itemId);
      if (isClosed) return;
      final index = items.indexWhere((existing) => existing.id == itemId);
      if (index == -1) {
        items.add(item);
      } else {
        items[index] = item;
      }
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e));
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

      // Update in list
      final index = items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        items[index] = updatedItem;
      }

      if (selectedItem.value?.id == itemId) {
        selectedItem.value = updatedItem;
      }

      ErrorHandler.showInfo(
        updatedItem.isFavorite
            ? 'Added to Favorites'
            : 'Removed from Favorites',
      );
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
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

      // Update in list
      final index = items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        items[index] = updatedItem;
      }

      if (selectedItem.value?.id == itemId) {
        selectedItem.value = updatedItem;
      }

      ErrorHandler.showInfo('Item marked as worn', title: 'Great choice!');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
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

      ErrorHandler.showSuccess('Item removed from your closet', title: 'Deleted');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
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

      ErrorHandler.showSuccess('$count items removed from your closet', title: 'Deleted');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
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
    totalItems.value++;
  }

  /// Add multiple newly created items to the list
  /// Called by BatchExtractionController after batch saving items
  void addItems(List<ItemModel> newItems) {
    if (newItems.isEmpty) return;
    items.insertAll(0, newItems);
    totalItems.value += newItems.length;
  }

  /// Update an existing item in the list (for immediate UI update)
  /// Called by ItemDetailController after updating an item
  void updateItem(ItemModel updatedItem) {
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
    }

    if (selectedItem.value?.id == updatedItem.id) {
      selectedItem.value = updatedItem;
    }
  }

  /// Remove an item from local state (without API call)
  /// Used for immediate UI update when item is deleted elsewhere
  void removeItemFromState(String itemId) {
    items.removeWhere((item) => item.id == itemId);
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
    // Update offline state based on network connectivity. No frame guard needed
    // here: connectivity_plus delivers on the event loop, never inside a build.
    _workers.add(
      ever(_networkService.isConnected, (connected) {
        isOffline.value = !connected;
        if (connected && items.isEmpty && !isLoading.value) {
          // Network recovered and we have no items, try fetching
          fetchItems();
        }
      }),
    );

    // Initial state. This one *does* run from onInit, which can be mid-frame,
    // and isOffline is read by mounted Obx widgets in the shell's wardrobe tab.
    // See [afterBuildPhase].
    afterBuildPhase(() {
      if (!isClosed) isOffline.value = !_networkService.isConnected.value;
    });
  }

  /// Setup route listener to refresh when returning to this page
}

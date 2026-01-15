import 'package:get/get.dart';
import '../../../../domain/enums/style.dart';
import '../../../../domain/enums/season.dart';
import '../../../core/services/notification_service.dart';
import '../models/outfit_model.dart';
import '../repositories/outfit_repository.dart';

/// Controller for outfit list, filtering, and pagination
/// Focused responsibility: Managing the outfit list and filters
class OutfitListController extends GetxController {
  final OutfitRepository _repository = OutfitRepository();

  // Workers for cleanup
  final List<Worker> _workers = [];

  // List state
  final RxList<OutfitModel> outfits = <OutfitModel>[].obs;
  final RxList<OutfitModel> filteredOutfits = <OutfitModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;
  final Rx<OutfitModel?> selectedOutfit = Rx<OutfitModel?>(null);
  final RxSet<String> selectedIds = <String>{}.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxSet<Style> selectedStyles = <Style>{}.obs;
  final RxSet<Season> selectedSeasons = <Season>{}.obs;
  final RxBool favoritesOnly = false.obs;
  final RxBool draftsOnly = false.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxInt totalOutfits = 0.obs;

  // Action-specific loading states (per-item)
  final RxMap<String, bool> isDeletingMap = <String, bool>{}.obs;
  final RxMap<String, bool> isFavoritingMap = <String, bool>{}.obs;
  final RxMap<String, bool> isMarkingWornMap = <String, bool>{}.obs;
  final RxMap<String, bool> isDuplicatingMap = <String, bool>{}.obs;

  // Single outfit fetch state
  final RxBool isFetchingSingle = false.obs;
  final RxString singleFetchError = ''.obs;

  // Wear history state
  final RxMap<String, List<WearHistoryEntry>> wearHistoryCache = <String, List<WearHistoryEntry>>{}.obs;
  final RxBool isLoadingWearHistory = false.obs;

  // Getters
  bool get hasError => error.value.isNotEmpty;
  bool get isSelectionActive => selectedIds.isNotEmpty;
  int get selectedCount => selectedIds.length;

  // Loading state helpers
  bool isDeleting(String id) => isDeletingMap[id] ?? false;
  bool isFavoriting(String id) => isFavoritingMap[id] ?? false;
  bool isMarkingWorn(String id) => isMarkingWornMap[id] ?? false;
  bool isDuplicating(String id) => isDuplicatingMap[id] ?? false;

  @override
  void onInit() {
    super.onInit();
    fetchOutfits();
    _setupFilters();
  }

  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.onClose();
  }

  void _setupFilters() {
    _workers.addAll([
      ever(searchQuery, (_) => applyFilters()),
      ever(selectedStyles, (_) => applyFilters()),
      ever(selectedSeasons, (_) => applyFilters()),
      ever(favoritesOnly, (_) => applyFilters()),
      ever(draftsOnly, (_) => applyFilters()),
    ]);
  }

  /// Fetch outfits from server
  Future<void> fetchOutfits({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      outfits.clear();
    }

    if (isLoadingMore.value) return;

    try {
      if (refresh) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      error.value = '';

      final response = await _repository.getOutfits(
        page: currentPage.value,
        limit: 20,
      );

      if (refresh) {
        outfits.clear();
      }

      outfits.addAll(response.outfits);
      totalOutfits.value = response.total;
      hasMore.value = response.hasMore;
      currentPage.value++;

      applyFilters();
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      NotificationService.instance.showError(error.value);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Fetch single outfit by ID from API
  Future<OutfitModel?> fetchOutfitById(String outfitId) async {
    // Check cache first
    final cached = outfits.firstWhereOrNull((o) => o.id == outfitId);
    if (cached != null) {
      return cached;
    }

    isFetchingSingle.value = true;
    singleFetchError.value = '';

    try {
      final outfit = await _repository.getOutfit(outfitId);

      // Add to cache
      final existingIndex = outfits.indexWhere((o) => o.id == outfitId);
      if (existingIndex == -1) {
        outfits.add(outfit);
      } else {
        outfits[existingIndex] = outfit;
      }
      applyFilters();

      return outfit;
    } catch (e) {
      singleFetchError.value = e.toString().replaceAll('Exception: ', '');
      NotificationService.instance.showError(singleFetchError.value);
      return null;
    } finally {
      isFetchingSingle.value = false;
    }
  }

  /// Refresh single outfit by ID
  Future<void> refreshOutfitById(String outfitId) async {
    try {
      final outfit = await _repository.getOutfit(outfitId);
      _updateOutfitInLists(outfitId, outfit);
    } catch (e) {
      NotificationService.instance.showError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Fetch wear history for an outfit
  Future<List<WearHistoryEntry>> fetchWearHistory(String outfitId) async {
    // Return cached if available
    if (wearHistoryCache.containsKey(outfitId)) {
      return wearHistoryCache[outfitId]!;
    }

    isLoadingWearHistory.value = true;
    try {
      final history = await _repository.getWearHistory(outfitId);
      wearHistoryCache[outfitId] = history;
      return history;
    } catch (e) {
      NotificationService.instance.showError(
        e.toString().replaceAll('Exception: ', ''),
      );
      return [];
    } finally {
      isLoadingWearHistory.value = false;
    }
  }

  /// Apply filters to the outfit list
  void applyFilters() {
    filteredOutfits.value = outfits.where((outfit) {
      // Search query filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!outfit.name.toLowerCase().contains(query) &&
            !(outfit.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Style filter
      if (selectedStyles.isNotEmpty &&
          (outfit.style == null || !selectedStyles.contains(outfit.style))) {
        return false;
      }

      // Season filter
      if (selectedSeasons.isNotEmpty &&
          (outfit.season == null || !selectedSeasons.contains(outfit.season))) {
        return false;
      }

      // Favorites filter
      if (favoritesOnly.value && !outfit.isFavorite) {
        return false;
      }

      // Drafts filter
      if (draftsOnly.value && !outfit.isDraft) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Set selected outfit for detail view
  void setSelectedOutfit(OutfitModel? outfit) {
    selectedOutfit.value = outfit;
  }

  /// Toggle selection for multi-select mode
  void toggleSelection(String outfitId) {
    if (selectedIds.contains(outfitId)) {
      selectedIds.remove(outfitId);
    } else {
      selectedIds.add(outfitId);
    }
  }

  /// Clear all selections
  void clearSelection() {
    selectedIds.clear();
  }

  /// Toggle outfit favorite
  Future<void> toggleFavorite(String outfitId) async {
    isFavoritingMap[outfitId] = true;
    try {
      final updatedOutfit = await _repository.toggleFavorite(outfitId);
      _updateOutfitInLists(outfitId, updatedOutfit);

      NotificationService.instance.showMessage(
        updatedOutfit.isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
      );
    } catch (e) {
      NotificationService.instance.showError(
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isFavoritingMap.remove(outfitId);
    }
  }

  /// Mark outfit as worn
  Future<void> markAsWorn(String outfitId) async {
    isMarkingWornMap[outfitId] = true;
    try {
      final updatedOutfit = await _repository.markAsWorn(outfitId);
      _updateOutfitInLists(outfitId, updatedOutfit);

      // Add to local wear history cache
      final now = DateTime.now();
      final entry = WearHistoryEntry(
        id: 'local-${now.millisecondsSinceEpoch}',
        outfitId: outfitId,
        wornAt: now,
      );
      if (wearHistoryCache.containsKey(outfitId)) {
        wearHistoryCache[outfitId] = [entry, ...wearHistoryCache[outfitId]!];
      } else {
        wearHistoryCache[outfitId] = [entry];
      }

      NotificationService.instance.showSuccess(
        'Marked as worn',
        title: 'Great outfit!',
      );
    } catch (e) {
      NotificationService.instance.showError(
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isMarkingWornMap.remove(outfitId);
    }
  }

  /// Delete outfit
  Future<void> deleteOutfit(String outfitId) async {
    isDeletingMap[outfitId] = true;
    try {
      await _repository.deleteOutfit(outfitId);

      outfits.removeWhere((outfit) => outfit.id == outfitId);
      applyFilters();

      if (selectedOutfit.value?.id == outfitId) {
        selectedOutfit.value = null;
      }

      NotificationService.instance.showSuccess('Outfit removed', title: 'Deleted');
    } catch (e) {
      NotificationService.instance.showError(
        e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    } finally {
      isDeletingMap.remove(outfitId);
    }
  }

  /// Duplicate outfit
  Future<void> duplicateOutfit(String outfitId) async {
    isDuplicatingMap[outfitId] = true;
    try {
      final duplicated = await _repository.duplicateOutfit(outfitId);
      outfits.insert(0, duplicated);
      applyFilters();

      NotificationService.instance.showSuccess(
        'Outfit duplicated successfully',
        title: 'Duplicated',
      );
    } catch (e) {
      NotificationService.instance.showError(
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isDuplicatingMap.remove(outfitId);
    }
  }

  /// Update outfit in list
  Future<void> updateOutfit(String outfitId, UpdateOutfitRequest request) async {
    try {
      final updatedOutfit = await _repository.updateOutfit(outfitId, request);
      _updateOutfitInLists(outfitId, updatedOutfit);

      NotificationService.instance.showSuccess(
        'Outfit updated successfully',
        title: 'Updated',
      );
    } catch (e) {
      NotificationService.instance.showError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Add newly created outfit to list
  void addOutfit(OutfitModel outfit) {
    final index = outfits.indexWhere((o) => o.id == outfit.id);
    if (index == -1) {
      outfits.insert(0, outfit);
      totalOutfits.value += 1;
    } else {
      outfits[index] = outfit;
    }
    applyFilters();
  }

  /// Clear filters
  void clearAllFilters() {
    searchQuery.value = '';
    selectedStyles.clear();
    selectedSeasons.clear();
    favoritesOnly.value = false;
    draftsOnly.value = false;
  }

  /// Clear error
  void clearError() {
    error.value = '';
  }

  void _updateOutfitInLists(String outfitId, OutfitModel updatedOutfit) {
    final index = outfits.indexWhere((o) => o.id == outfitId);
    if (index != -1) {
      outfits[index] = updatedOutfit;
    }

    final filteredIndex = filteredOutfits.indexWhere((o) => o.id == outfitId);
    if (filteredIndex != -1) {
      filteredOutfits[filteredIndex] = updatedOutfit;
    }

    if (selectedOutfit.value?.id == outfitId) {
      selectedOutfit.value = updatedOutfit;
    }
  }
}

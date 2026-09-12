import 'package:get/get.dart';
import '../../../../domain/enums/style.dart';
import '../../../../domain/enums/season.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/network_service.dart'
    show RetryHelper, NetworkService;
import '../models/outfit_model.dart';
import '../repositories/outfit_repository.dart';
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

/// Controller for outfit list, filtering, and pagination
/// Focused responsibility: Managing the outfit list and filters
class OutfitListController extends GetxController {
  final OutfitRepository _repository;
  final NetworkService _networkService;
  int _fetchGeneration = 0;
  (String, String, String, bool, bool) _loadedFilters = (
    '',
    '',
    '',
    false,
    false,
  );

  /// [networkService] is injectable for unit tests.
  OutfitListController({
    NetworkService? networkService,
    OutfitRepository? repository,
  }) : _repository = repository ?? OutfitRepository(),
       _networkService = networkService ?? Get.find<NetworkService>();

  // Workers for cleanup
  final List<Worker> _workers = [];

  // List state
  final RxList<OutfitModel> outfits = <OutfitModel>[].obs;
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
  final RxMap<String, List<WearHistoryEntry>> wearHistoryCache =
      <String, List<WearHistoryEntry>>{}.obs;
  final RxBool isLoadingWearHistory = false.obs;

  /// Outfit IDs whose most recent wear-history fetch failed.
  ///
  /// Chosen over caching an empty-with-TTL result: empty history is a real,
  /// cacheable outcome ([] is stored on success), so a separate failure
  /// marker keeps those two states distinct and needs no expiry hook. The
  /// detail page consults this before rescheduling a fetch — otherwise a
  /// persistent failure loops forever (page rebuilds -> history still empty
  /// -> schedule fetch -> fails -> repeat).
  final Set<String> _wearHistoryFailed = <String>{};

  bool isWearHistoryFailed(String outfitId) =>
      _wearHistoryFailed.contains(outfitId);

  // Offline state
  final RxBool isOffline = false.obs;

  // Getters
  bool get hasError => error.value.isNotEmpty;
  bool get isSelectionActive => selectedIds.isNotEmpty;
  int get selectedCount => selectedIds.length;

  /// The list shown to the user. Filtering is server-side, so this is the
  /// single outfit list — kept as a named getter for view compatibility.
  List<OutfitModel> get filteredOutfits => outfits;

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
    _setupNetworkMonitoring();
  }

  @override
  void onClose() {
    _fetchGeneration++;
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.onClose();
  }

  void _setupFilters() {
    // Debounce all filter changes to avoid excessive API calls
    _workers.addAll([
      debounce(
        searchQuery,
        (_) => fetchOutfits(refresh: true),
        time: const Duration(milliseconds: 500),
      ),
      debounce(
        selectedStyles,
        (_) => fetchOutfits(refresh: true),
        time: const Duration(milliseconds: 100),
      ),
      debounce(
        selectedSeasons,
        (_) => fetchOutfits(refresh: true),
        time: const Duration(milliseconds: 100),
      ),
      debounce(
        favoritesOnly,
        (_) => fetchOutfits(refresh: true),
        time: const Duration(milliseconds: 100),
      ),
      debounce(
        draftsOnly,
        (_) => fetchOutfits(refresh: true),
        time: const Duration(milliseconds: 100),
      ),
    ]);
  }

  /// Fetch outfits from server with filters
  Future<void> fetchOutfits({bool refresh = false}) async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;

    if (!_networkService.isConnected.value) {
      // Invalidate any in-flight fetch so stale results for the previous
      // filters cannot populate the new filter state after reconnect.
      _fetchGeneration++;
      isLoading.value = false;
      isLoadingMore.value = false;
      isOffline.value = true;
      error.value = 'You are offline. Reconnect to refresh your outfits.';
      return;
    }

    // A scroll notification must not start another request during a fetch.
    if (!refresh && (isLoadingMore.value || isLoading.value)) return;
    final requestSearch = searchQuery.value.isEmpty ? null : searchQuery.value;
    final requestStyles = selectedStyles.isEmpty
        ? null
        : selectedStyles.map((s) => s.name.toLowerCase()).toList();
    final requestSeasons = selectedSeasons.isEmpty
        ? null
        : selectedSeasons.map((s) => s.name.toLowerCase()).toList();
    final requestFavoritesOnly = favoritesOnly.value ? true : null;
    final requestDraftsOnly = draftsOnly.value ? true : null;
    final requestFilters = (
      requestSearch ?? '',
      requestStyles?.join(',') ?? '',
      requestSeasons?.join(',') ?? '',
      requestFavoritesOnly == true,
      requestDraftsOnly == true,
    );
    // A failed filter refresh retains the old list and its cursor. Scrolling
    // must retry the new filters from page 1, not append to that old list.
    final replace = refresh || requestFilters != _loadedFilters;
    final requestGeneration = ++_fetchGeneration;
    final requestPage = replace ? 1 : currentPage.value;

    try {
      if (replace) {
        isLoading.value = true;
        if (requestFilters != _loadedFilters) {
          // The grid still shows a list loaded under different filters, and a
          // fully-exhausted one has hasMore == false. Re-arm paging so a
          // failed filter fetch can be retried from page 1 by scrolling.
          hasMore.value = true;
        }
      } else {
        isLoadingMore.value = true;
      }
      error.value = '';

      // Build filter parameters for server-side filtering
      final response = await RetryHelper.execute(
        operation: () => _repository.getOutfits(
          page: requestPage,
          limit: 20,
          search: requestSearch,
          styles: requestStyles,
          seasons: requestSeasons,
          favoritesOnly: requestFavoritesOnly,
          draftsOnly: requestDraftsOnly,
        ),
        maxAttempts: 3,
      );

      if (requestGeneration != _fetchGeneration || isClosed) return;

      // Refresh swaps atomically: the previous list stays visible during the
      // fetch and is replaced only once the new page has actually loaded, so
      // a failed refresh never blanks the grid. Initial load / load-more
      // append instead of clearing.
      if (replace) {
        outfits
          ..clear()
          ..addAll(response.outfits);
      } else {
        outfits.addAll(response.outfits);
      }
      _loadedFilters = requestFilters;
      totalOutfits.value = response.total;
      hasMore.value = response.hasMore;
      currentPage.value = requestPage + 1;
    } catch (e) {
      if (requestGeneration != _fetchGeneration || isClosed) return;
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value);
    } finally {
      if (requestGeneration == _fetchGeneration) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  /// Fetch single outfit by ID from API
  Future<OutfitModel?> fetchOutfitById(String outfitId) async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return null;
    // Check cache first
    final cached = outfits.firstWhereOrNull((o) => o.id == outfitId);
    if (cached != null) {
      return cached;
    }

    isFetchingSingle.value = true;
    singleFetchError.value = '';

    try {
      final outfit = await _repository.getOutfit(outfitId);

      // Add to cache — but NOT into the paged list while a server-side
      // filter is active (A10b-09): the grid would show an outfit that
      // violates the active favorites/search/styles filter.
      final hasServerFilters =
          favoritesOnly.value ||
          draftsOnly.value ||
          searchQuery.value.isNotEmpty ||
          selectedStyles.isNotEmpty ||
          selectedSeasons.isNotEmpty;
      if (!hasServerFilters) {
        final existingIndex = outfits.indexWhere((o) => o.id == outfitId);
        if (existingIndex == -1) {
          outfits.add(outfit);
        } else {
          outfits[existingIndex] = outfit;
        }
      }

      return outfit;
    } catch (e) {
      singleFetchError.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(singleFetchError.value);
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
      ErrorHandler.showError(ErrorHandler.extractMessage(e));
    }
  }

  /// Fetch wear history for an outfit.
  ///
  /// Returns the cached list on success (possibly empty), or `null` when the
  /// fetch failed — callers can then distinguish "no history yet" from
  /// "couldn't load history" and offer a retry.
  Future<List<WearHistoryEntry>?> fetchWearHistory(String outfitId) async {
    // Return cached if available; a prior success clears any failure marker.
    if (wearHistoryCache.containsKey(outfitId)) {
      _wearHistoryFailed.remove(outfitId);
      return wearHistoryCache[outfitId]!;
    }

    isLoadingWearHistory.value = true;
    try {
      final history = await _repository.getWearHistory(outfitId);
      wearHistoryCache[outfitId] = history;
      _wearHistoryFailed.remove(outfitId);
      return history;
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e));
      // Record the failure so view-layer auto-fetch loops stop rescheduling
      // for this outfit; cleared on a later successful fetch or retry.
      _wearHistoryFailed.add(outfitId);
      return null;
    } finally {
      isLoadingWearHistory.value = false;
    }
  }

  /// Explicit retry for a previously failed wear-history fetch. Deliberately
  /// the same call as [fetchWearHistory]; kept as an intent point so future
  /// retry logic (backoff, telemetry) has one place to live.
  Future<List<WearHistoryEntry>?> retryWearHistory(String outfitId) =>
      fetchWearHistory(outfitId);

  /// Apply filters - triggers server refetch with current filters
  void applyFilters() {
    fetchOutfits(refresh: true);
  }

  /// Set selected outfit for detail view
  void setSelectedOutfit(OutfitModel? outfit) {
    selectedOutfit.value = outfit;
  }

  /// Toggle selection for multi-select mode
  void toggleSelection(String outfitId) {
    HapticService.selectionClick();
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
    HapticService.favorite();
    isFavoritingMap[outfitId] = true;
    try {
      final updatedOutfit = await _repository.toggleFavorite(outfitId);
      _updateOutfitInLists(outfitId, updatedOutfit);

      NotificationService.instance.showMessage(
        updatedOutfit.isFavorite
            ? 'Added to Favorites'
            : 'Removed from Favorites',
      );
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e));
    } finally {
      isFavoritingMap.remove(outfitId);
    }
  }

  /// Mark outfit as worn
  Future<void> markAsWorn(String outfitId) async {
    HapticService.lightImpact();
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
      // A successful wear action proves the history endpoint works; release
      // a stale failure marker so the detail page renders the entry instead
      // of a permanent "Couldn't load" retry card.
      _wearHistoryFailed.remove(outfitId);

      NotificationService.instance.showSuccess(
        'Marked as worn',
        title: 'Great outfit!',
      );
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e));
    } finally {
      isMarkingWornMap.remove(outfitId);
    }
  }

  /// Delete outfit
  Future<void> deleteOutfit(String outfitId) async {
    HapticService.delete();
    isDeletingMap[outfitId] = true;
    try {
      await _repository.deleteOutfit(outfitId);

      outfits.removeWhere((outfit) => outfit.id == outfitId);

      if (selectedOutfit.value?.id == outfitId) {
        selectedOutfit.value = null;
      }

      NotificationService.instance.showSuccess(
        'Outfit removed',
        title: 'Deleted',
      );
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e));
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

      NotificationService.instance.showSuccess(
        'Outfit duplicated successfully',
        title: 'Duplicated',
      );
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e));
    } finally {
      isDuplicatingMap.remove(outfitId);
    }
  }

  /// Update outfit in list
  Future<void> updateOutfit(
    String outfitId,
    UpdateOutfitRequest request,
  ) async {
    try {
      final updatedOutfit = await _repository.updateOutfit(outfitId, request);
      _updateOutfitInLists(outfitId, updatedOutfit);

      NotificationService.instance.showSuccess(
        'Outfit updated successfully',
        title: 'Updated',
      );
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e));
    }
  }

  /// Add newly created outfit to list
  void addOutfit(OutfitModel outfit) {
    outfits.insert(0, outfit);
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

    if (selectedOutfit.value?.id == outfitId) {
      selectedOutfit.value = updatedOutfit;
    }
  }

  /// Setup network monitoring
  void _setupNetworkMonitoring() {
    // Update offline state based on network connectivity. No frame guard needed
    // here: connectivity_plus delivers on the event loop, never inside a build.
    _workers.add(
      ever(_networkService.isConnected, (connected) {
        isOffline.value = !connected;
        if (connected && outfits.isEmpty && !isLoading.value) {
          // Network recovered and we have no outfits, try fetching
          fetchOutfits();
        }
      }),
    );

    // Initial state. This one *does* run from onInit, which can be mid-frame,
    // and isOffline is read by mounted Obx widgets in the shell's outfits tab.
    // See [afterBuildPhase].
    afterBuildPhase(() {
      if (!isClosed) isOffline.value = !_networkService.isConnected.value;
    });
  }

  /// Setup route listener to refresh when returning to this page
}

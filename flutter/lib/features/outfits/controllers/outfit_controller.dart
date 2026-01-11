import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/enums/style.dart';
import '../../../../domain/enums/season.dart';
import '../models/outfit_model.dart';
import '../repositories/outfit_repository.dart';

/// Outfits controller
class OutfitsController extends GetxController {
  final OutfitRepository _outfitRepository = OutfitRepository();

  // Workers for cleanup
  final List<Worker> _workers = [];

  // Reactive state
  final RxList<OutfitModel> outfits = <OutfitModel>[].obs;
  final RxList<OutfitModel> filteredOutfits = <OutfitModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = RxString('');
  final Rx<OutfitModel?> selectedOutfit = Rx<OutfitModel?>(null);
  final RxSet<String> selectedIds = <String>{}.obs;

  // Creation state
  final RxList<String> selectedItemIds = <String>[].obs;
  final RxBool isCreating = false.obs;
  final RxString name = ''.obs;
  final RxString description = ''.obs;
  final Rx<Style?> selectedStyle = Rx<Style?>(null);
  final Rx<Season?> selectedSeason = Rx<Season?>(null);
  final RxString occasion = ''.obs;
  final RxList<String> tags = <String>[].obs;

  // Generation state
  final RxBool isGenerating = false.obs;
  final RxString generationStatus = ''.obs;
  final RxDouble generationProgress = 0.0.obs;
  final Rx<String?> generatedImageUrl = Rx<String?>(null);

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

  // Getters
  bool get hasError => error.value.isNotEmpty;
  bool get isSelectionActive => selectedIds.isNotEmpty;
  int get selectedCount => selectedIds.length;

  @override
  void onInit() {
    super.onInit();
    fetchOutfits();
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
    // Store workers for cleanup
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

      final response = await _outfitRepository.getOutfits(
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

  /// Apply filters
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

  /// Set selected outfit
  void setSelectedOutfit(OutfitModel? outfit) {
    selectedOutfit.value = outfit;
  }

  /// Add/remove item from creation
  void toggleItemForOutfit(String itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
    }
  }

  /// Clear creation state
  void clearCreationState() {
    selectedItemIds.clear();
    name.value = '';
    description.value = '';
    selectedStyle.value = null;
    selectedSeason.value = null;
    occasion.value = '';
    tags.clear();
    isCreating.value = false;
  }

  /// Create outfit
  Future<void> createOutfit() async {
    if (selectedItemIds.isEmpty) {
      Get.snackbar(
        'No Items',
        'Please select at least one item for your outfit',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (name.value.isEmpty) {
      Get.snackbar(
        'No Name',
        'Please give your outfit a name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isCreating.value = true;
      error.value = '';

      final request = CreateOutfitRequest(
        name: name.value,
        description: description.value.isEmpty ? null : description.value,
        itemIds: selectedItemIds.toList(),
        style: selectedStyle.value,
        season: selectedSeason.value,
        occasion: occasion.value.isEmpty ? null : occasion.value,
        tags: tags.isEmpty ? null : tags.toList(),
      );

      final newOutfit = await _outfitRepository.createOutfit(request);

      outfits.insert(0, newOutfit);
      applyFilters();
      clearCreationState();

      Get.back();
      Get.snackbar(
        'Outfit Created',
        'Your outfit has been saved',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCreating.value = false;
    }
  }

  /// Update outfit
  Future<void> updateOutfit(String outfitId, UpdateOutfitRequest request) async {
    try {
      final updatedOutfit = await _outfitRepository.updateOutfit(outfitId, request);

      // Update in lists
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

      Get.snackbar(
        'Updated',
        'Outfit updated successfully',
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

  /// Delete outfit
  Future<void> deleteOutfit(String outfitId) async {
    try {
      await _outfitRepository.deleteOutfit(outfitId);

      outfits.removeWhere((outfit) => outfit.id == outfitId);
      applyFilters();

      if (selectedOutfit.value?.id == outfitId) {
        selectedOutfit.value = null;
      }

      Get.snackbar(
        'Deleted',
        'Outfit removed',
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

  /// Toggle outfit favorite
  Future<void> toggleFavorite(String outfitId) async {
    try {
      final updatedOutfit = await _outfitRepository.toggleFavorite(outfitId);

      // Update in lists
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

      Get.snackbar(
        '',
        updatedOutfit.isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
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

  /// Mark outfit as worn
  Future<void> markAsWorn(String outfitId) async {
    try {
      final updatedOutfit = await _outfitRepository.markAsWorn(outfitId);

      // Update in lists
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

      Get.snackbar(
        'Great outfit!',
        'Marked as worn',
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

  /// Duplicate outfit
  Future<void> duplicateOutfit(String outfitId) async {
    try {
      final duplicated = await _outfitRepository.duplicateOutfit(outfitId);
      outfits.insert(0, duplicated);
      applyFilters();

      Get.snackbar(
        'Duplicated',
        'Outfit duplicated successfully',
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

  /// Generate AI visualization
  Future<void> generateVisualization(
    String outfitId, {
    String? pose,
    String? lighting,
    String? bodyProfileId,
  }) async {
    try {
      isGenerating.value = true;
      generationProgress.value = 0.0;
      generationStatus.value = 'Initializing...';
      generatedImageUrl.value = null;

      // Get the outfit
      final outfit = outfits.firstWhereOrNull((o) => o.id == outfitId);
      if (outfit == null) {
        throw Exception('Outfit not found');
      }

      // Convert itemIds to list of maps
      final itemsData = outfit.itemIds.map((id) => {'id': id}).toList();

      final result = await _outfitRepository.generateOutfitVisualization(
        itemsData,
        style: pose,
        background: lighting,
      );

      if (result.status == 'failed') {
        isGenerating.value = false;
        Get.snackbar(
          'Generation Failed',
          result.error ?? 'An error occurred',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (result.status == 'completed' &&
          (result.imageUrl != null || result.imageBase64 != null)) {
        generatedImageUrl.value = result.imageUrl ??
            (result.imageBase64 != null
                ? 'data:image/png;base64,${result.imageBase64}'
                : null);
        isGenerating.value = false;
        Get.snackbar(
          'Complete!',
          'Your outfit has been generated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
        );
        return;
      }

      // Poll for status (for tracked generations)
      await _pollGenerationStatus(result.id);
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      isGenerating.value = false;
      Get.snackbar(
        'Generation Failed',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _pollGenerationStatus(String taskId) async {
    const maxAttempts = 120; // 2 minutes
    var attempts = 0;

    await Future.doWhile(() async {
      attempts++;

      if (attempts >= maxAttempts) {
        isGenerating.value = false;
        Get.snackbar(
          'Timeout',
          'Generation is taking longer than expected',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await Future.delayed(const Duration(seconds: 1));

      try {
        final status = await _outfitRepository.getGenerationStatus(taskId);
        generationProgress.value = status.progress ?? 0.0;
        generationStatus.value = status.message ?? 'Processing...';

        if (status.status == 'completed') {
          generatedImageUrl.value = status.imageUrl;
          isGenerating.value = false;

          // Refresh outfits to get the updated image
          await fetchOutfits(refresh: true);

          Get.snackbar(
            'Complete!',
            'Your outfit has been generated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade900,
          );
          return false;
        }

        if (status.status == 'failed') {
          isGenerating.value = false;
          Get.snackbar(
            'Generation Failed',
            status.error ?? 'An error occurred',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }

        return true; // Continue polling
      } catch (e) {
        isGenerating.value = false;
        return false;
      }
    });
  }

  /// Share outfit
  Future<void> shareOutfit(String outfitId) async {
    try {
      final shareUrl = await _outfitRepository.shareOutfit(outfitId);

      await Get.dialog(
        AlertDialog(
          title: const Text('Outfit Shared'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text('Your outfit is now publicly available'),
              const SizedBox(height: 16),
              SelectableText(shareUrl),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
}

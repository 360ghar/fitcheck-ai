import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/style.dart';
import '../../wardrobe/models/item_model.dart';
import '../../wardrobe/repositories/item_repository.dart';
import '../repositories/recommendations_repository.dart';

/// Recommendations controller
/// Manages all recommendation tabs and data
class RecommendationsController extends GetxController with GetTickerProviderStateMixin {
  final RecommendationsRepository _recommendationsRepository = RecommendationsRepository();
  final ItemRepository _itemRepository = ItemRepository();

  // Tab controller
  late TabController tabController;

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isLoadingItems = false.obs;
  final RxBool isLoadingMatches = false.obs;
  final RxBool isLoadingCompleteLooks = false.obs;
  final RxBool isLoadingWeather = false.obs;
  final RxBool isLoadingShopping = false.obs;
  final RxString itemsError = ''.obs;
  final RxString matchesError = ''.obs;
  final RxString completeLookError = ''.obs;
  final RxString weatherError = ''.obs;
  final RxString shoppingError = ''.obs;

  // Find Matches Tab
  final RxList<ItemModel> selectedItems = <ItemModel>[].obs;
  final RxList<Map<String, dynamic>> matchingItems = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> completeLooks = <Map<String, dynamic>>[].obs;
  final RxString matchesSearchQuery = ''.obs;
  final RxString matchesCategoryFilter = 'all'.obs;

  final Rx<Style?> completeLookStyle = Rx<Style?>(null);

  // Weather Tab
  final RxString weatherLocation = ''.obs;
  final Rx<Map<String, dynamic>?> weatherData = Rx<Map<String, dynamic>?>(null);
  final RxList<String> preferredCategories = <String>[].obs;
  final RxList<ItemModel> weatherRecommendations = <ItemModel>[].obs;

  // Shopping Tab
  final RxString shoppingCategory = 'all'.obs;
  final RxString shoppingStyle = 'all'.obs;
  final RxDouble shoppingBudget = 100.0.obs;
  final RxList<Map<String, dynamic>> shoppingRecommendations = <Map<String, dynamic>>[].obs;

  // Available items for selection
  final RxList<ItemModel> availableItems = <ItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    completeLookStyle.value = Style.casual;
    _loadAvailableItems();
    _loadUserLocation();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> _loadAvailableItems() async {
    isLoadingItems.value = true;
    itemsError.value = '';
    try {
      final response = await _itemRepository.getItems(limit: 100);
      availableItems.value = response.items;
    } catch (e) {
      itemsError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoadingItems.value = false;
    }
  }

  Future<void> _loadUserLocation() async {
    // Try to get user's saved location from settings
    weatherLocation.value = 'San Francisco'; // Default
  }

  /// Toggle item selection for matching
  void toggleItemSelection(ItemModel item) {
    if (selectedItems.any((i) => i.id == item.id)) {
      selectedItems.removeWhere((i) => i.id == item.id);
    } else {
      if (selectedItems.length >= 3) {
        Get.snackbar(
          'Maximum Reached',
          'You can select up to 3 items for matching',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      selectedItems.add(item);
    }
    _findMatches();
  }

  /// Find matching items
  Future<void> _findMatches() async {
    if (selectedItems.isEmpty) {
      matchingItems.clear();
      completeLooks.clear();
      return;
    }

    isLoading.value = true;
    isLoadingMatches.value = true;
    matchesError.value = '';
    try {
      final result = await _recommendationsRepository.findMatchingItems(
        selectedItems.map((i) => i.id).toList(),
      );

      final matches = (result['matches'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      matchingItems.value = matches.map(_normalizeMatch).toList();

      final looks = (result['complete_looks'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      completeLooks.value = _normalizeCompleteLooks(looks);
      if (completeLooks.isEmpty) {
        final fallback = generateCompleteLook();
        if (fallback.isNotEmpty) {
          completeLooks.value = [
            {
              'items': fallback,
              'description': 'Quick picks from your wardrobe',
              'match_score': 75,
            },
          ];
        }
      }
    } catch (e) {
      matchesError.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', matchesError.value);
    } finally {
      isLoading.value = false;
      isLoadingMatches.value = false;
    }
  }

  /// Get filtered matching items
  List<Map<String, dynamic>> get filteredMatchingItems {
    return matchingItems.where((item) {
      if (matchesSearchQuery.value.isNotEmpty) {
        final query = matchesSearchQuery.value.toLowerCase();
        final name = item['name']?.toString().toLowerCase() ?? '';
        final brand = item['brand']?.toString().toLowerCase() ?? '';
        if (!name.contains(query) && !brand.contains(query)) return false;
      }
      if (matchesCategoryFilter.value != 'all') {
        if (item['category']?.toString() != matchesCategoryFilter.value) return false;
      }
      return true;
    }).toList();
  }

  /// Fetch weather recommendations
  Future<void> fetchWeatherRecommendations() async {
    if (weatherLocation.value.isEmpty) return;

    isLoading.value = true;
    isLoadingWeather.value = true;
    weatherError.value = '';
    weatherRecommendations.clear();
    preferredCategories.clear();

    try {
      final result = await _recommendationsRepository.getWeatherRecommendations(
        location: weatherLocation.value,
      );

      final condition = result['weather_state'] ?? result['condition'];
      weatherData.value = {
        ...result,
        if (condition != null) 'condition': condition,
      };

      // Parse weather data
      final temperature = result['temperature'] as num? ?? 70;

      // Determine preferred categories based on weather
      final recommended = (result['preferred_categories'] as List?)
          ?.map((e) => e.toString())
          .toList();
      if (recommended != null && recommended.isNotEmpty) {
        preferredCategories.value = recommended;
      } else if (temperature < 50) {
        preferredCategories.value = ['outerwear', 'tops', 'bottoms'];
      } else if (temperature < 70) {
        preferredCategories.value = ['tops', 'bottoms', 'outerwear'];
      } else if (temperature < 85) {
        preferredCategories.value = ['tops', 'bottoms', 'shoes', 'accessories'];
      } else {
        preferredCategories.value = ['tops', 'bottoms', 'shoes', 'activewear'];
      }

      // Get items from preferred categories
      if (availableItems.isNotEmpty) {
        weatherRecommendations.value = availableItems.where((item) {
          return preferredCategories.contains(item.category.name);
        }).take(10).toList();
      }
    } catch (e) {
      weatherError.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', weatherError.value);
    } finally {
      isLoading.value = false;
      isLoadingWeather.value = false;
    }
  }

  /// Fetch shopping recommendations
  Future<void> fetchShoppingRecommendations() async {
    isLoading.value = true;
    isLoadingShopping.value = true;
    shoppingError.value = '';
    shoppingRecommendations.clear();

    try {
      final result = await _recommendationsRepository.getShoppingRecommendations(
        category: shoppingCategory.value == 'all' ? null : shoppingCategory.value,
        style: shoppingStyle.value == 'all' ? null : shoppingStyle.value,
        maxBudget: shoppingBudget.value.toDouble(),
      );

      shoppingRecommendations.value =
          result.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      shoppingError.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', shoppingError.value);
    } finally {
      isLoading.value = false;
      isLoadingShopping.value = false;
    }
  }

  /// Generate complete look (client-side fallback)
  List<ItemModel> generateCompleteLook() {
    if (selectedItems.isEmpty) return [];

    final selectedCategories = selectedItems.map((i) => i.category).toSet();
    final neededCategories = <Category>{};

    // Determine what's needed
    if (!selectedCategories.contains(Category.tops)) {
      neededCategories.add(Category.tops);
    }
    if (!selectedCategories.contains(Category.bottoms)) {
      neededCategories.add(Category.bottoms);
    }
    if (!selectedCategories.contains(Category.shoes)) {
      neededCategories.add(Category.shoes);
    }

    // Find matching items from wardrobe
    final suggestions = <ItemModel>[];
    for (final category in neededCategories) {
      final matches = availableItems.where((i) => i.category == category).toList();
      if (matches.isNotEmpty) {
        suggestions.add(matches.first); // Simple: take first match
      }
    }

    return suggestions;
  }

  Future<void> fetchCompleteLooks() async {
    if (selectedItems.isEmpty) {
      completeLooks.clear();
      return;
    }

    isLoading.value = true;
    isLoadingCompleteLooks.value = true;
    completeLookError.value = '';
    try {
      final result = await _recommendationsRepository.getCompleteLookSuggestions(
        itemIds: selectedItems.map((i) => i.id).toList(),
        style: completeLookStyle.value?.name,
      );
      final looks = (result['complete_looks'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      completeLooks.value = _normalizeCompleteLooks(looks);
    } catch (e) {
      completeLookError.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', completeLookError.value);
    } finally {
      isLoading.value = false;
      isLoadingCompleteLooks.value = false;
    }
  }

  /// Clear selection
  void clearSelection() {
    selectedItems.clear();
    matchingItems.clear();
    completeLooks.clear();
  }

  /// Refresh current tab
  Future<void> refreshCurrentTab() async {
    final tabIndex = tabController.index;
    switch (tabIndex) {
      case 0: // Find Matches
        await _findMatches();
        break;
      case 1: // Complete Look
        await fetchCompleteLooks();
        break;
      case 2: // Weather
        await fetchWeatherRecommendations();
        break;
      case 3: // Shopping
        await fetchShoppingRecommendations();
        break;
    }
  }

  Map<String, dynamic> _normalizeMatch(Map<String, dynamic> match) {
    final item = match['item'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final imageUrl = _extractImageUrl(item);
    final scoreRaw = match['score'];
    final scoreValue = scoreRaw is num ? scoreRaw : num.tryParse(scoreRaw?.toString() ?? '') ?? 0;
    final reasons = match['reasons'] as List?;

    return {
      'name': item['name']?.toString() ?? 'Unknown',
      'brand': item['brand']?.toString(),
      'category': item['category']?.toString(),
      'image_url': imageUrl,
      'score': (scoreValue / 100).clamp(0.0, 1.0),
      'reason': reasons != null && reasons.isNotEmpty ? reasons.first.toString() : null,
    };
  }

  List<Map<String, dynamic>> _normalizeCompleteLooks(List<Map<String, dynamic>> looks) {
    return looks.map((look) {
      final itemsRaw = look['items'];
      final items = itemsRaw is List
          ? itemsRaw
              .whereType<Map<String, dynamic>>()
              .map(ItemModel.fromJson)
              .toList()
          : <ItemModel>[];
      return {
        'items': items,
        'match_score': look['match_score'],
        'description': look['description'],
        'style': look['style'],
        'occasion': look['occasion'],
      };
    }).toList();
  }

  String? _extractImageUrl(Map<String, dynamic> item) {
    final images = item['item_images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map<String, dynamic>) {
        return first['thumbnail_url']?.toString() ?? first['image_url']?.toString();
      }
    }
    return null;
  }
}

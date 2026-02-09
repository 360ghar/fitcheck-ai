import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../../wardrobe/models/item_model.dart';
import '../../wardrobe/repositories/item_repository.dart';
import 'find_matches_controller.dart';
import 'complete_look_controller.dart';
import 'weather_recommendations_controller.dart';
import 'shopping_recommendations_controller.dart';
import 'astrology_recommendations_controller.dart';

/// Recommendations controller - Slim coordinator for tab management
/// Delegates tab-specific logic to focused controllers
class RecommendationsController extends GetxController
    with GetTickerProviderStateMixin {
  final ItemRepository _itemRepository = ItemRepository();

  // Tab controller
  late TabController tabController;

  // Shared state
  final RxBool isLoading = false.obs;
  final RxBool isLoadingItems = false.obs;
  final RxString itemsError = ''.obs;
  final RxList<ItemModel> availableItems = <ItemModel>[].obs;
  final RxList<ItemModel> selectedItems = <ItemModel>[].obs;

  // Tab controllers (lazily accessed)
  FindMatchesController get findMatchesController =>
      Get.find<FindMatchesController>();
  CompleteLookController get completeLookController =>
      Get.find<CompleteLookController>();
  WeatherRecommendationsController get weatherController =>
      Get.find<WeatherRecommendationsController>();
  ShoppingRecommendationsController get shoppingController =>
      Get.find<ShoppingRecommendationsController>();
  AstrologyRecommendationsController get astrologyController =>
      Get.find<AstrologyRecommendationsController>();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    _loadAvailableItems();
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

  /// Toggle item selection for matching
  void toggleItemSelection(ItemModel item) {
    if (selectedItems.any((i) => i.id == item.id)) {
      selectedItems.removeWhere((i) => i.id == item.id);
    } else {
      if (selectedItems.length >= 3) {
        NotificationService.instance.showWarning(
          'You can select up to 3 items for matching',
          title: 'Maximum Reached',
        );
        return;
      }
      selectedItems.add(item);
    }
    // Trigger find matches when selection changes
    _onSelectionChanged();
  }

  void _onSelectionChanged() {
    // Update find matches
    findMatchesController.findMatches(selectedItems);
  }

  /// Get loading state for current tab
  bool get isCurrentTabLoading {
    switch (tabController.index) {
      case 0:
        return findMatchesController.isLoading.value;
      case 1:
        return completeLookController.isLoading.value;
      case 2:
        return weatherController.isLoading.value;
      case 3:
        return astrologyController.isLoading.value;
      case 4:
        return shoppingController.isLoading.value;
      default:
        return false;
    }
  }

  /// Refresh current tab
  Future<void> refreshCurrentTab() async {
    isLoading.value = true;
    try {
      switch (tabController.index) {
        case 0: // Find Matches
          await findMatchesController.findMatches(selectedItems);
          break;
        case 1: // Complete Look
          await completeLookController.fetchCompleteLooks(selectedItems);
          break;
        case 2: // Weather
          await weatherController.fetchRecommendations(availableItems);
          break;
        case 3: // Astrology
          await astrologyController.fetchRecommendations();
          break;
        case 4: // Shopping
          await shoppingController.fetchRecommendations();
          break;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear selection
  void clearSelection() {
    selectedItems.clear();
    findMatchesController.clearResults();
    completeLookController.clearResults();
  }

  // Delegate getters for backward compatibility with views
  RxList<Map<String, dynamic>> get matchingItems =>
      findMatchesController.matchingItems;
  RxList<Map<String, dynamic>> get completeLooks =>
      findMatchesController.completeLooks;
  RxString get matchesSearchQuery => findMatchesController.searchQuery;
  RxString get matchesCategoryFilter => findMatchesController.categoryFilter;
  RxBool get isLoadingMatches => findMatchesController.isLoading;
  RxString get matchesError => findMatchesController.error;

  List<Map<String, dynamic>> get filteredMatchingItems =>
      findMatchesController.filteredMatchingItems;

  // Weather delegates
  RxString get weatherLocation => weatherController.location;
  Rx<Map<String, dynamic>?> get weatherData => weatherController.weatherData;
  RxList<String> get preferredCategories =>
      weatherController.preferredCategories;
  RxList<ItemModel> get weatherRecommendations =>
      weatherController.recommendations;
  RxBool get isLoadingWeather => weatherController.isLoading;
  RxString get weatherError => weatherController.error;

  Future<void> fetchWeatherRecommendations() =>
      weatherController.fetchRecommendations(availableItems);

  // Shopping delegates
  RxString get shoppingCategory => shoppingController.category;
  RxString get shoppingStyle => shoppingController.style;
  RxDouble get shoppingBudget => shoppingController.maxBudget;
  RxList<Map<String, dynamic>> get shoppingRecommendations =>
      shoppingController.recommendations;
  RxBool get isLoadingShopping => shoppingController.isLoading;
  RxString get shoppingError => shoppingController.error;

  Future<void> fetchShoppingRecommendations() =>
      shoppingController.fetchRecommendations();

  // Astrology delegates
  RxString get astrologyMode => astrologyController.mode;
  RxString get astrologyTargetDate => astrologyController.targetDate;
  Rx<Map<String, dynamic>?> get astrologyData => astrologyController.data;
  RxBool get isLoadingAstrology => astrologyController.isLoading;
  RxString get astrologyError => astrologyController.error;

  Future<void> fetchAstrologyRecommendations() =>
      astrologyController.fetchRecommendations();

  // Complete look delegates
  Rx<dynamic> get completeLookStyle => completeLookController.selectedStyle;
  RxBool get isLoadingCompleteLooks => completeLookController.isLoading;
  RxString get completeLookError => completeLookController.error;

  Future<void> fetchCompleteLooks() =>
      completeLookController.fetchCompleteLooks(selectedItems);

  /// Generate complete look (client-side fallback)
  List<ItemModel> generateCompleteLook() {
    return completeLookController.generateCompleteLook(
      selectedItems,
      availableItems,
    );
  }
}

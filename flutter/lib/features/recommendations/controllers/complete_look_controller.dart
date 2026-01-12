import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/style.dart';
import '../../wardrobe/models/item_model.dart';
import '../repositories/recommendations_repository.dart';

/// Controller for Complete Look tab
/// Manages complete outfit look generation
class CompleteLookController extends GetxController {
  final RecommendationsRepository _repository = RecommendationsRepository();

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> completeLooks = <Map<String, dynamic>>[].obs;
  final Rx<Style?> selectedStyle = Rx<Style?>(Style.casual);

  /// Fetch complete look suggestions
  Future<void> fetchCompleteLooks(List<ItemModel> selectedItems) async {
    if (selectedItems.isEmpty) {
      completeLooks.clear();
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      final result = await _repository.getCompleteLookSuggestions(
        itemIds: selectedItems.map((i) => i.id).toList(),
        style: selectedStyle.value?.name,
      );

      final looks = (result['complete_looks'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      completeLooks.value = _normalizeCompleteLooks(looks);

      // If no looks returned, generate fallback
      if (completeLooks.isEmpty) {
        final fallback = _generateCompleteLook(selectedItems, []);
        if (fallback.isNotEmpty) {
          completeLooks.value = [
            {
              'items': fallback,
              'description': 'Suggested items to complete your look',
              'match_score': 70,
            },
          ];
        }
      }
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      NotificationService.instance.showError(error.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Generate complete look from available items (client-side fallback)
  List<ItemModel> generateCompleteLook(
    List<ItemModel> selectedItems,
    List<ItemModel> availableItems,
  ) {
    return _generateCompleteLook(selectedItems, availableItems);
  }

  List<ItemModel> _generateCompleteLook(
    List<ItemModel> selectedItems,
    List<ItemModel> availableItems,
  ) {
    if (selectedItems.isEmpty) return [];

    final selectedCategories = selectedItems.map((i) => i.category).toSet();
    final neededCategories = <Category>{};

    // Determine what's needed for a complete outfit
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
      final matches =
          availableItems.where((i) => i.category == category).toList();
      if (matches.isNotEmpty) {
        suggestions.add(matches.first);
      }
    }

    return suggestions;
  }

  List<Map<String, dynamic>> _normalizeCompleteLooks(
      List<Map<String, dynamic>> looks) {
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

  /// Clear all results
  void clearResults() {
    completeLooks.clear();
    error.value = '';
  }
}

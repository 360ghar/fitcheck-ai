import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../../wardrobe/models/item_model.dart';
import '../repositories/recommendations_repository.dart';
import '../utils/item_json.dart';

/// Controller for Find Matches tab
/// Manages item matching functionality
class FindMatchesController extends GetxController {
  final RecommendationsRepository _repository = RecommendationsRepository();

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> matchingItems = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> completeLooks = <Map<String, dynamic>>[].obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString categoryFilter = 'all'.obs;

  /// Find matching items for selected items
  Future<void> findMatches(List<ItemModel> selectedItems) async {
    if (selectedItems.isEmpty) {
      matchingItems.clear();
      completeLooks.clear();
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      final result = await _repository.findMatchingItems(
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

      // Generate fallback if no complete looks returned
      if (completeLooks.isEmpty) {
        final fallback = _generateFallbackLook(selectedItems);
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
      error.value = e.toString().replaceAll('Exception: ', '');
      NotificationService.instance.showError(error.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Get filtered matching items
  List<Map<String, dynamic>> get filteredMatchingItems {
    return matchingItems.where((item) {
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final name = item['name']?.toString().toLowerCase() ?? '';
        final brand = item['brand']?.toString().toLowerCase() ?? '';
        if (!name.contains(query) && !brand.contains(query)) return false;
      }
      if (categoryFilter.value != 'all') {
        if (item['category']?.toString() != categoryFilter.value) return false;
      }
      return true;
    }).toList();
  }

  /// Clear all results
  void clearResults() {
    matchingItems.clear();
    completeLooks.clear();
    error.value = '';
  }

  Map<String, dynamic> _normalizeMatch(Map<String, dynamic> match) {
    final item = match['item'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final imageUrl = _extractImageUrl(item);
    final scoreRaw = match['score'];
    final scoreValue = scoreRaw is num
        ? scoreRaw
        : num.tryParse(scoreRaw?.toString() ?? '') ?? 0;
    final reasons = match['reasons'] as List?;

    return {
      'name': item['name']?.toString() ?? 'Unknown',
      'brand': item['brand']?.toString(),
      'category': item['category']?.toString(),
      'image_url': imageUrl,
      'score': (scoreValue / 100).clamp(0.0, 1.0),
      'reason': reasons != null && reasons.isNotEmpty
          ? reasons.first.toString()
          : null,
    };
  }

  List<Map<String, dynamic>> _normalizeCompleteLooks(
      List<Map<String, dynamic>> looks) {
    return looks.map((look) {
      final itemsRaw = look['items'];
      final items = itemsRaw is List
          ? itemsRaw
              .whereType<Map>()
              .map((e) => itemModelFromRecommendationJson(
                    Map<String, dynamic>.from(e),
                  ))
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
    // Prefer nested images (post-normalize `images` or raw `item_images`)
    for (final key in ['images', 'item_images']) {
      final images = item[key];
      if (images is List && images.isNotEmpty) {
        // Prefer primary when present
        Map<String, dynamic>? primary;
        for (final entry in images) {
          if (entry is Map && entry['is_primary'] == true) {
            primary = Map<String, dynamic>.from(entry);
            break;
          }
        }
        final first = primary ??
            (images.first is Map
                ? Map<String, dynamic>.from(images.first as Map)
                : null);
        if (first != null) {
          final url = first['thumbnail_url']?.toString() ??
              first['image_url']?.toString() ??
              first['url']?.toString();
          if (url != null && url.isNotEmpty) return url;
        }
      }
    }
    // Flat convenience field from recommendations API
    final flat = item['image_url']?.toString();
    if (flat != null && flat.isNotEmpty) return flat;
    return null;
  }

  List<ItemModel> _generateFallbackLook(List<ItemModel> selectedItems) {
    // This is a simple fallback - in production, you'd use the availableItems
    return [];
  }
}

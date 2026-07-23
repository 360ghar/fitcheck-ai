import 'package:get/get.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/notification_service.dart';
import '../repositories/recommendations_repository.dart';

/// Controller for Shopping Recommendations tab
/// Manages shopping suggestions based on wardrobe gaps
class ShoppingRecommendationsController extends GetxController {
  final RecommendationsRepository _repository = RecommendationsRepository();

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> recommendations =
      <Map<String, dynamic>>[].obs;

  // Filters
  final RxString category = 'all'.obs;
  final RxString style = 'all'.obs;
  final RxDouble maxBudget = 100.0.obs;

  /// Fetch shopping recommendations
  Future<void> fetchRecommendations() async {
    isLoading.value = true;
    error.value = '';
    recommendations.clear();

    AnalyticsService.instance.track(
      'shopping_recommendations_requested',
      properties: {
        'category': category.value,
        'style': style.value,
        'max_budget': maxBudget.value,
        'source': 'flutter_app',
      },
    );

    try {
      final result = await _repository.getShoppingRecommendations(
        category: category.value == 'all' ? null : category.value,
        style: style.value == 'all' ? null : style.value,
        maxBudget: maxBudget.value,
      );

      recommendations.value =
          result.whereType<Map<String, dynamic>>().toList();
      AnalyticsService.instance.track(
        'shopping_recommendations_loaded',
        properties: {
          'recommendation_count': recommendations.length,
          'category': category.value,
          'source': 'flutter_app',
        },
      );
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      AnalyticsService.instance.track(
        'shopping_recommendations_failed',
        properties: {
          'error_message': error.value,
          'source': 'flutter_app',
        },
      );
      NotificationService.instance.showError(error.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Update category filter and refresh
  void updateCategory(String newCategory) {
    category.value = newCategory;
    fetchRecommendations();
  }

  /// Update style filter and refresh
  void updateStyle(String newStyle) {
    style.value = newStyle;
    fetchRecommendations();
  }

  /// Update budget and refresh
  void updateBudget(double newBudget) {
    maxBudget.value = newBudget;
    fetchRecommendations();
  }

  /// Clear results
  void clearResults() {
    recommendations.clear();
    error.value = '';
  }
}

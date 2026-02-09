import 'package:get/get.dart';
import '../controllers/recommendations_controller.dart';
import '../controllers/find_matches_controller.dart';
import '../controllers/complete_look_controller.dart';
import '../controllers/weather_recommendations_controller.dart';
import '../controllers/shopping_recommendations_controller.dart';
import '../controllers/astrology_recommendations_controller.dart';

/// Recommendations binding - provides recommendation-related controllers
/// Uses standardized lazy loading with fenix for automatic recreation
class RecommendationsBinding extends Bindings {
  @override
  void dependencies() {
    // Tab-specific controllers (must be registered before main controller)
    Get.lazyPut<FindMatchesController>(
      () => FindMatchesController(),
      fenix: true,
    );

    Get.lazyPut<CompleteLookController>(
      () => CompleteLookController(),
      fenix: true,
    );

    Get.lazyPut<WeatherRecommendationsController>(
      () => WeatherRecommendationsController(),
      fenix: true,
    );

    Get.lazyPut<ShoppingRecommendationsController>(
      () => ShoppingRecommendationsController(),
      fenix: true,
    );

    Get.lazyPut<AstrologyRecommendationsController>(
      () => AstrologyRecommendationsController(),
      fenix: true,
    );

    // Main coordinator controller
    Get.lazyPut<RecommendationsController>(
      () => RecommendationsController(),
      fenix: true,
    );
  }
}

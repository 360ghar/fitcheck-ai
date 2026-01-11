import 'package:get/get.dart';
import '../controllers/recommendations_controller.dart';

/// Recommendations binding
class RecommendationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecommendationsController>(() => RecommendationsController());
  }
}

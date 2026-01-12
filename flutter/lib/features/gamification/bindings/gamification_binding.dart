import 'package:get/get.dart';
import '../controllers/gamification_controller.dart';

/// Gamification binding - provides gamification controller
/// Uses standardized lazy loading with fenix for automatic recreation
class GamificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GamificationController>(
      () => GamificationController(),
      fenix: true,
    );
  }
}

import 'package:get/get.dart';
import '../../features/wardrobe/controllers/wardrobe_controller.dart';

/// Wardrobe binding - provides required controllers
/// Uses standardized lazy loading with fenix for automatic recreation
class WardrobeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WardrobeController>(
      () => WardrobeController(),
      fenix: true,
    );
  }
}

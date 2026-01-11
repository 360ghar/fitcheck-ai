import 'package:get/get.dart';
import '../../features/wardrobe/controllers/wardrobe_controller.dart';
// AuthController is already registered in InitialBinding - no need to re-register

/// Wardrobe binding - provides required controllers
class WardrobeBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load WardrobeController
    // Note: AuthController is already registered globally in InitialBinding
    if (!Get.isRegistered<WardrobeController>()) {
      Get.lazyPut<WardrobeController>(() => WardrobeController());
    }
  }
}

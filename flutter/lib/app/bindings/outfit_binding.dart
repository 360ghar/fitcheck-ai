import 'package:get/get.dart';
import '../../features/outfits/controllers/outfit_controller.dart';
// AuthController is already registered in InitialBinding - no need to re-register

/// Outfit binding - provides required controllers
class OutfitBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load OutfitsController
    // Note: AuthController is already registered globally in InitialBinding
    if (!Get.isRegistered<OutfitsController>()) {
      Get.lazyPut<OutfitsController>(() => OutfitsController());
    }
  }
}

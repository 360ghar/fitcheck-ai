import 'package:get/get.dart';
import '../controllers/main_shell_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../wardrobe/controllers/wardrobe_controller.dart';
import '../../outfits/controllers/outfit_list_controller.dart';
import '../../outfits/controllers/outfit_creation_controller.dart';
import '../../outfits/controllers/outfit_generation_controller.dart';
import '../../tryon/controllers/tryon_controller.dart';
import '../../settings/controllers/settings_controller.dart';

/// Binding for MainShellPage - initializes shell and all tab controllers
class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    // Shell controller (permanent - stays in memory while shell is active)
    Get.put<MainShellController>(MainShellController(), permanent: true);

    // Dashboard tab controllers
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);

    // Wardrobe tab
    Get.lazyPut<WardrobeController>(() => WardrobeController(), fenix: true);

    // Outfits tab
    Get.lazyPut<OutfitListController>(() => OutfitListController(), fenix: true);
    Get.lazyPut<OutfitCreationController>(() => OutfitCreationController(), fenix: true);
    Get.lazyPut<OutfitGenerationController>(() => OutfitGenerationController(), fenix: true);

    // Try-On tab
    Get.lazyPut<TryOnController>(() => TryOnController(), fenix: true);
  }
}

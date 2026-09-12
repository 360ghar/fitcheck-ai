import 'package:get/get.dart';
import '../controllers/main_shell_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../wardrobe/controllers/wardrobe_controller.dart';
import '../../outfits/controllers/outfit_list_controller.dart';
import '../../outfits/controllers/outfit_generation_controller.dart';
import '../../photoshoot/controllers/photoshoot_controller.dart';
import '../../tryon/controllers/tryon_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../../gifts/controllers/gift_controller.dart';

/// Binding for MainShellPage - initializes shell and all tab controllers
class MainShellBinding extends Bindings {
  MainShellBinding({this.initialTab = 0, this.initialStudioTool = 0});

  final int initialTab;
  final int initialStudioTool;

  @override
  void dependencies() {
    // Shell controller (permanent - stays in memory while shell is active)
    if (!Get.isRegistered<MainShellController>()) {
      Get.put<MainShellController>(
        MainShellController(
          initialTab: initialTab,
          initialStudioTool: initialStudioTool,
        ),
        permanent: true,
      );
    }

    // Dashboard tab controllers
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<GiftController>(() => GiftController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    if (!Get.isRegistered<SubscriptionController>()) {
      Get.put<SubscriptionController>(SubscriptionController());
    }

    // Wardrobe tab
    Get.lazyPut<WardrobeController>(() => WardrobeController(), fenix: true);

    // Outfits tab
    Get.lazyPut<OutfitListController>(
      () => OutfitListController(),
      fenix: true,
    );
    Get.lazyPut<OutfitGenerationController>(
      () => OutfitGenerationController(),
      fenix: true,
    );

    // Studio tools initialize only when first opened.
    Get.lazyPut<PhotoshootController>(
      () => PhotoshootController(),
      fenix: true,
    );

    // Both Studio tools stay registered while the shell is active.
    Get.lazyPut<TryOnController>(() => TryOnController(), fenix: true);
  }
}

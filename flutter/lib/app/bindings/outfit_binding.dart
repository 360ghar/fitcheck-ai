import 'package:get/get.dart';
import '../../features/outfits/controllers/outfit_list_controller.dart';
import '../../features/outfits/controllers/outfit_creation_controller.dart';
import '../../features/outfits/controllers/outfit_generation_controller.dart';

/// Outfit binding - provides outfit-related controllers
/// Uses standardized lazy loading with fenix for automatic recreation
class OutfitBinding extends Bindings {
  @override
  void dependencies() {
    // List controller - manages outfit list, filters, pagination
    Get.lazyPut<OutfitListController>(
      () => OutfitListController(),
      fenix: true,
    );

    // Creation controller - manages outfit creation form
    Get.lazyPut<OutfitCreationController>(
      () => OutfitCreationController(),
      fenix: true,
    );

    // Generation controller - manages AI visualization generation
    Get.lazyPut<OutfitGenerationController>(
      () => OutfitGenerationController(),
      fenix: true,
    );
  }
}

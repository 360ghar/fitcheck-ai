import 'package:get/get.dart';
import '../../features/settings/controllers/ai_settings_controller.dart';

/// AI Settings binding - provides AI settings controller
/// Uses standardized lazy loading with fenix for automatic recreation
class AiSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiSettingsController>(
      () => AiSettingsController(),
      fenix: true,
    );
  }
}

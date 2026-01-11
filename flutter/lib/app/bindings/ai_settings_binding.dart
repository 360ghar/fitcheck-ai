import 'package:get/get.dart';
import '../../features/settings/controllers/ai_settings_controller.dart';

class AiSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AiSettingsController());
  }
}

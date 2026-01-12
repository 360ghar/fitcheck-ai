import 'package:get/get.dart';
import '../../features/settings/controllers/settings_controller.dart';

/// Settings binding - provides settings controller
/// Uses standardized lazy loading with fenix for automatic recreation
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
      fenix: true,
    );
  }
}

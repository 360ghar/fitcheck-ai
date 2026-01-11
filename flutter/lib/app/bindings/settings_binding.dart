import 'package:get/get.dart';
import '../../features/settings/controllers/settings_controller.dart';

/// Settings binding - registers SettingsController
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Register SettingsController immediately (not lazy) so Get.find() works in the page
    Get.put(SettingsController());
  }
}

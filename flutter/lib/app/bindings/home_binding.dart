import 'package:get/get.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/settings/controllers/settings_controller.dart';

/// Home binding - ensures required controllers are available for DashboardPage and ProfilePage
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // DashboardController - used by both DashboardPage and ProfilePage
    // Always use lazyPut to register when first accessed
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);

    // SettingsController - used by ProfilePage
    // Always use lazyPut to register when first accessed
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
  }
}

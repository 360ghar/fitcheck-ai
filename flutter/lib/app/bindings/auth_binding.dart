import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';

/// Auth binding - provides auth controller to auth screens
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }
  }
}

import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';

/// Auth binding - provides auth controller to auth screens
/// Uses standardized lazy loading with fenix for automatic recreation
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );
  }
}

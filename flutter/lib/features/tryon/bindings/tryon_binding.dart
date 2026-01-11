import 'package:get/get.dart';
import '../controllers/tryon_controller.dart';

/// Try-On binding - provides try-on controller
/// Uses standardized lazy loading with fenix for automatic recreation
class TryOnBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TryOnController>(
      () => TryOnController(),
      fenix: true,
    );
  }
}

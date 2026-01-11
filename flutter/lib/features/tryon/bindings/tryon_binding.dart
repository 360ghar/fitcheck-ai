import 'package:get/get.dart';
import '../controllers/tryon_controller.dart';

/// Try-On binding
class TryOnBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TryOnController>(() => TryOnController());
  }
}

import 'package:get/get.dart';

import '../controllers/gift_controller.dart';

class GiftBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GiftController>()) {
      Get.lazyPut<GiftController>(() => GiftController(), fenix: true);
    }
  }
}

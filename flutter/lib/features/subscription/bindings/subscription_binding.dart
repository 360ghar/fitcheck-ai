import 'package:get/get.dart';
import '../controllers/subscription_controller.dart';

/// Binding for subscription feature
class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionController>(() => SubscriptionController());
  }
}

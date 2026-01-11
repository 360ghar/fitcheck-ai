import 'package:get/get.dart';
import '../../features/calendar/controllers/calendar_controller.dart';

/// Calendar binding - provides calendar controller
/// Uses standardized lazy loading with fenix for automatic recreation
class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalendarController>(
      () => CalendarController(),
      fenix: true,
    );
  }
}

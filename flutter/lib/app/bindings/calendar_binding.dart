import 'package:get/get.dart';
import '../../features/calendar/controllers/calendar_controller.dart';

/// Calendar binding - registers CalendarController
class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    // Register CalendarController immediately (not lazy) so Get.find() works in the page
    Get.put(CalendarController());
  }
}

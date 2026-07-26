import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../repositories/recommendations_repository.dart';

/// Controller for Astrology recommendations tab
class AstrologyRecommendationsController extends GetxController {
  final RecommendationsRepository _repository = RecommendationsRepository();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString mode = 'daily'.obs;
  // Seeded at construction rather than in onInit. This controller is first
  // resolved from inside an Obx (astrology_tab), so an onInit write landed
  // mid-frame and had to be deferred to a post-frame callback — which meant a
  // fetch racing that callback saw an empty date and returned silently, with
  // no spinner and no message. Nothing is subscribed at construction time, so
  // a field initializer is safe and removes the race instead of timing around it.
  final RxString targetDate =
      DateTime.now().toIso8601String().split('T').first.obs; // YYYY-MM-DD
  final Rx<Map<String, dynamic>?> data = Rx<Map<String, dynamic>?>(null);

  Future<void> fetchRecommendations() async {
    if (targetDate.value.isEmpty) {
      error.value = 'Pick a date to get your reading.';
      return;
    }

    isLoading.value = true;
    error.value = '';
    try {
      final result = await _repository.getAstrologyRecommendations(
        targetDate: targetDate.value,
        mode: mode.value,
      );
      data.value = result;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      NotificationService.instance.showError(error.value);
    } finally {
      isLoading.value = false;
    }
  }

  void setMode(String value) {
    mode.value = value;
  }

  void setTargetDate(String value) {
    targetDate.value = value;
  }

  void clearResults() {
    data.value = null;
    error.value = '';
  }
}

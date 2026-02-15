import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../repositories/recommendations_repository.dart';

/// Controller for Astrology recommendations tab
class AstrologyRecommendationsController extends GetxController {
  final RecommendationsRepository _repository = RecommendationsRepository();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString mode = 'daily'.obs;
  final RxString targetDate = ''.obs; // YYYY-MM-DD
  final Rx<Map<String, dynamic>?> data = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    targetDate.value = DateTime.now().toIso8601String().split('T').first;
  }

  Future<void> fetchRecommendations() async {
    if (targetDate.value.isEmpty) return;

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

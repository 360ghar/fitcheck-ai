import 'package:get/get.dart';
import '../models/dashboard_models.dart';
import '../repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();

  final Rxn<DashboardData> dashboard = Rxn<DashboardData>();
  final Rxn<StreakData> streak = Rxn<StreakData>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard({bool showLoader = true}) async {
    if (showLoader) {
      isLoading.value = true;
    }
    error.value = '';

    try {
      final results = await Future.wait([
        _repository.fetchDashboard(),
        _repository.fetchStreak(),
      ]);
      dashboard.value = results[0] as DashboardData;
      streak.value = results[1] as StreakData;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

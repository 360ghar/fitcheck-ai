import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard_models.dart';
import '../repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();

  static const String _referralBannerDismissedKey = 'referral_banner_dismissed_at';
  static const int _weekInMs = 7 * 24 * 60 * 60 * 1000;

  final Rxn<DashboardData> dashboard = Rxn<DashboardData>();
  final Rxn<StreakData> streak = Rxn<StreakData>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool referralBannerDismissed = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBannerDismissalState();
    fetchDashboard();
  }

  Future<void> _loadBannerDismissalState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedAt = prefs.getInt(_referralBannerDismissedKey);
      if (dismissedAt != null) {
        final weekAgo = DateTime.now().millisecondsSinceEpoch - _weekInMs;
        referralBannerDismissed.value = dismissedAt > weekAgo;
      }
    } catch (e) {
      // Ignore errors loading dismissal state
    }
  }

  Future<void> dismissReferralBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_referralBannerDismissedKey, DateTime.now().millisecondsSinceEpoch);
      referralBannerDismissed.value = true;
    } catch (e) {
      // Ignore errors saving dismissal state
    }
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

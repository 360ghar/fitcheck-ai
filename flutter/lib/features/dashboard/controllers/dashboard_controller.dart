import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/dashboard_models.dart';
import '../repositories/dashboard_repository.dart';
import '../../../core/services/persistence_service.dart';
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();
  PersistenceService get _persistence =>
      Get.isRegistered<PersistenceService>()
          ? Get.find<PersistenceService>()
          : PersistenceService();

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
      final dismissedAt = await _persistence.getInt(_referralBannerDismissedKey);
      if (dismissedAt != null) {
        final weekAgo = DateTime.now().millisecondsSinceEpoch - _weekInMs;
        referralBannerDismissed.value = dismissedAt > weekAgo;
      }
    } catch (e) {
      debugPrint('Failed to load banner dismissal state: $e');
    }
  }

  Future<void> dismissReferralBanner() async {
    try {
      await _persistence.setInt(_referralBannerDismissedKey, DateTime.now().millisecondsSinceEpoch);
      referralBannerDismissed.value = true;
    } catch (e) {
      debugPrint('Failed to save banner dismissal state: $e');
    }
  }

  Future<void> fetchDashboard({bool showLoader = true}) async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
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
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value, title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }
}

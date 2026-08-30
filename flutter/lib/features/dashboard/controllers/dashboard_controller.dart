import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/dashboard_models.dart';
import '../repositories/dashboard_repository.dart';
import '../../../core/services/persistence_service.dart';
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository;
  PersistenceService get _persistence => Get.isRegistered<PersistenceService>()
      ? Get.find<PersistenceService>()
      : PersistenceService();

  static const String _referralBannerDismissedKey =
      'referral_banner_dismissed_at';
  static const int _weekInMs = 7 * 24 * 60 * 60 * 1000;

  final Rxn<DashboardData> dashboard = Rxn<DashboardData>();
  final Rxn<StreakData> streak = Rxn<StreakData>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool referralBannerDismissed = false.obs;

  /// In-flight fetch, for single-flight de-duplication. Rapid pull-to-refresh
  /// used to race two fetches where the OLDER response could land after the
  /// newer one and overwrite fresh data with stale data.
  Future<void>? _fetchFuture;

  DashboardController({DashboardRepository? repository})
    : _repository = repository ?? DashboardRepository();

  @override
  void onInit() {
    super.onInit();
    _loadBannerDismissalState();
    fetchDashboard();
  }

  Future<void> _loadBannerDismissalState() async {
    try {
      final dismissedAt = await _persistence.getInt(
        _referralBannerDismissedKey,
      );
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
      await _persistence.setInt(
        _referralBannerDismissedKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      referralBannerDismissed.value = true;
    } catch (e) {
      debugPrint('Failed to save banner dismissal state: $e');
    }
  }

  Future<void> fetchDashboard({bool showLoader = true}) async {
    // Single-flight: join the in-flight fetch instead of starting a second
    // one, so two overlapping fetches can never interleave and let the older
    // response land last.
    final existing = _fetchFuture;
    if (existing != null) {
      await existing;
      return;
    }
    try {
      final future = _doFetchDashboard(showLoader: showLoader);
      _fetchFuture = future;
      await future;
    } finally {
      _fetchFuture = null;
    }
  }

  Future<void> _doFetchDashboard({bool showLoader = true}) async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    if (showLoader) {
      isLoading.value = true;
    }
    error.value = '';

    try {
      // The dashboard is the primary surface; streak is optional enrichment.
      // Start both requests concurrently (latency is the max of the two, not
      // the sum) and attach the streak error handler immediately so an early
      // gamification failure is never reported as an unhandled async error.
      final dashboardFuture = _repository.fetchDashboard();
      final streakFuture = _repository.fetchStreak().then<StreakData?>(
        (data) => data,
        onError: (Object e) {
          debugPrint('Failed to load optional dashboard streak: $e');
          return null;
        },
      );

      try {
        dashboard.value = await dashboardFuture;
      } catch (e) {
        error.value = ErrorHandler.extractMessage(e);
        ErrorHandler.showError(error.value, title: 'Error');
        return;
      }

      streak.value = await streakFuture;
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value, title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }
}

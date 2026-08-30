import 'package:get/get.dart';
import '../models/gamification_model.dart';
import '../repositories/gamification_repository.dart';
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

/// Gamification controller
/// Handles streaks, achievements, and leaderboard
class GamificationController extends GetxController {
  final GamificationRepository _repository = GamificationRepository();

  final Rx<StreakModel?> streak = Rx<StreakModel?>(null);
  final RxList<AchievementModel> achievements = <AchievementModel>[].obs;
  final RxList<LeaderboardEntry> leaderboard = <LeaderboardEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  bool get hasError => error.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    isLoading.value = true;
    error.value = '';
    await Future.wait([
      fetchStreak(),
      fetchAchievements(),
      fetchLeaderboard(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchStreak() async {
    try {
      streak.value = await _repository.getStreak();
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      // Sibling controllers report to telemetry; without this the gamification
      // feature was Sentry-blind on API failures.
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    }
  }

  Future<void> fetchAchievements() async {
    try {
      achievements.value = await _repository.getAchievements();
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    }
  }

  Future<void> fetchLeaderboard() async {
    try {
      leaderboard.value = await _repository.getLeaderboard();
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    }
  }
}

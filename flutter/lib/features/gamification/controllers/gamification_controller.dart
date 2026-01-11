import 'package:get/get.dart';
import '../models/gamification_model.dart';
import '../repositories/gamification_repository.dart';

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
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> fetchAchievements() async {
    try {
      achievements.value = await _repository.getAchievements();
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> fetchLeaderboard() async {
    try {
      leaderboard.value = await _repository.getLeaderboard();
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    }
  }
}

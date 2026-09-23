import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gamification_model.dart';
import '../repositories/gamification_repository.dart';

final gamificationRepositoryProvider = Provider<GamificationRepository>(
  (ref) => GamificationRepository(),
);

// Three independent requests: one failing section never hides the others.

final streakProvider = FutureProvider.autoDispose<StreakModel>(
  (ref) => ref.read(gamificationRepositoryProvider).getStreak(),
);

final achievementsProvider = FutureProvider.autoDispose<List<AchievementModel>>(
  (ref) => ref.read(gamificationRepositoryProvider).getAchievements(),
);

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>(
  (ref) => ref.read(gamificationRepositoryProvider).getLeaderboard(),
);

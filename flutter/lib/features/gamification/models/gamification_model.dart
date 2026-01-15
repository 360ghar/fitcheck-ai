import 'package:freezed_annotation/freezed_annotation.dart';

part 'gamification_model.freezed.dart';
part 'gamification_model.g.dart';

/// Streak model
@freezed
abstract class StreakModel with _$StreakModel {
  const factory StreakModel({
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    int? nextMilestone,
    @JsonKey(name: 'last_active_at') DateTime? lastActiveAt,
  }) = _StreakModel;

  factory StreakModel.fromJson(Map<String, dynamic> json) =>
      _$StreakModelFromJson(json);
}

/// Achievement model
@freezed
abstract class AchievementModel with _$AchievementModel {
  const factory AchievementModel({
    required String id,
    required String name,
    String? description,
    String? iconName,
    @Default(0) int progress,
    @Default(1) int target,
    @Default(false) bool isUnlocked,
    @JsonKey(name: 'unlocked_at') DateTime? unlockedAt,
  }) = _AchievementModel;

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);
}

/// Leaderboard entry model
@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String userId,
    required String username,
    required int points,
    String? avatarUrl,
    @Default(0) int rank,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}

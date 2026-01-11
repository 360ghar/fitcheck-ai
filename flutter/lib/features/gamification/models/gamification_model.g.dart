// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreakModelImpl _$$StreakModelImplFromJson(Map<String, dynamic> json) =>
    _$StreakModelImpl(
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      nextMilestone: (json['nextMilestone'] as num?)?.toInt(),
      lastActiveAt: json['last_active_at'] == null
          ? null
          : DateTime.parse(json['last_active_at'] as String),
    );

Map<String, dynamic> _$$StreakModelImplToJson(_$StreakModelImpl instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'nextMilestone': instance.nextMilestone,
      'last_active_at': instance.lastActiveAt?.toIso8601String(),
    };

_$AchievementModelImpl _$$AchievementModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AchievementModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconName: json['iconName'] as String?,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 1,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] == null
          ? null
          : DateTime.parse(json['unlocked_at'] as String),
    );

Map<String, dynamic> _$$AchievementModelImplToJson(
        _$AchievementModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconName': instance.iconName,
      'progress': instance.progress,
      'target': instance.target,
      'isUnlocked': instance.isUnlocked,
      'unlocked_at': instance.unlockedAt?.toIso8601String(),
    };

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$LeaderboardEntryImpl(
      userId: json['userId'] as String,
      username: json['username'] as String,
      points: (json['points'] as num).toInt(),
      avatarUrl: json['avatarUrl'] as String?,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
        _$LeaderboardEntryImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'points': instance.points,
      'avatarUrl': instance.avatarUrl,
      'rank': instance.rank,
    };

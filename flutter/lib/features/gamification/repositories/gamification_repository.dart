import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../models/gamification_model.dart';

/// Gamification repository
class GamificationRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get user's streak
  Future<StreakModel> getStreak() async {
    try {
      final response = await _apiClient.get('${ApiConstants.gamification}/streak');
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final next = data['next_milestone'] as Map<String, dynamic>?;
      return StreakModel(
        currentStreak: _toInt(data['current_streak']),
        longestStreak: _toInt(data['longest_streak']),
        nextMilestone: _toInt(next?['days']),
        lastActiveAt: _parseDate(data['last_planned']),
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get achievements
  Future<List<AchievementModel>> getAchievements() async {
    try {
      final response = await _apiClient.get('${ApiConstants.gamification}/achievements');
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final available = (data['available'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];
      final earned = (data['earned'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];
      final earnedById = <String, Map<String, dynamic>>{};

      for (final row in earned) {
        final id = (row['achievement_id'] ?? row['id'])?.toString();
        if (id != null && id.isNotEmpty) {
          earnedById[id] = row;
        }
      }

      if (available.isEmpty && earned.isNotEmpty) {
        return earned.map((row) {
          final id = (row['achievement_id'] ?? row['id'] ?? '').toString();
          return AchievementModel(
            id: id,
            name: row['name']?.toString() ?? 'Achievement',
            description: row['description']?.toString(),
            iconName: row['icon_name']?.toString(),
            progress: _toInt(row['progress']),
            target: _toInt(row['target'], fallback: 1),
            isUnlocked: true,
            unlockedAt: _parseDate(row['earned_at']),
          );
        }).toList();
      }

      return available.map((item) {
        final id = item['id']?.toString() ?? '';
        final earnedRow = earnedById[id];
        final isUnlocked = earnedRow != null;
        return AchievementModel(
          id: id,
          name: item['name']?.toString() ?? 'Achievement',
          description: item['description']?.toString(),
          iconName: _iconForAchievement(id),
          progress: _toInt(earnedRow?['progress'], fallback: isUnlocked ? 1 : 0),
          target: _toInt(item['target'], fallback: 1),
          isUnlocked: isUnlocked,
          unlockedAt: _parseDate(earnedRow?['earned_at']),
        );
      }).toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final response = await _apiClient.get('${ApiConstants.gamification}/leaderboard');
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final entries = (data['entries'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];
      return entries.map((entry) {
        return LeaderboardEntry(
          userId: entry['user_id']?.toString() ?? '',
          username: entry['username']?.toString() ?? 'User',
          points: _toInt(entry['total_points'] ?? entry['points']),
          avatarUrl: entry['avatar_url']?.toString(),
          rank: _toInt(entry['rank'], fallback: 0),
        );
      }).toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _iconForAchievement(String id) {
    switch (id) {
      case 'first_upload':
        return 'photo_camera';
      case 'first_outfit':
        return 'checkroom';
      case 'streak_7':
        return 'local_fire_department';
      default:
        return 'emoji_events';
    }
  }

}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/gamification_model.dart';
import '../controllers/gamification_controller.dart';

/// Gamification Page
/// Shows streaks, achievements, and leaderboard
class GamificationPage extends StatelessWidget {
  const GamificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final GamificationController controller = Get.find<GamificationController>();
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => controller.refreshAll(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gamification',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                      ),
                      IconButton(
                        onPressed: () => controller.refreshAll(),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacing24),

                  Obx(() {
                    if (!controller.hasError) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        AppGlassCard(
                          padding: const EdgeInsets.all(AppConstants.spacing16),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: tokens.textMuted),
                              const SizedBox(width: AppConstants.spacing12),
                              Expanded(
                                child: Text(
                                  controller.error.value,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: tokens.textPrimary,
                                      ),
                                ),
                              ),
                              TextButton(
                                onPressed: controller.refreshAll,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing24),
                      ],
                    );
                  }),

                  // Streak section
                  Obx(() => _buildStreakSection(context, controller, tokens)),

                  const SizedBox(height: AppConstants.spacing24),

                  // Achievements section
                  _buildAchievementsSection(context, controller, tokens),

                  const SizedBox(height: AppConstants.spacing24),

                  // Leaderboard section
                  _buildLeaderboardSection(context, controller, tokens),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentIndex),
    );
  }

  Widget _buildStreakSection(BuildContext context, GamificationController controller, AppUiTokens tokens) {
    final streak = controller.streak.value;
    if (streak == null) {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return AppGlassCard(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Center(
          child: Text(
            'No streak data yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.textMuted,
                ),
          ),
        ),
      );
    }

    final currentStreak = streak.currentStreak;
    final longestStreak = streak.longestStreak;
    final nextMilestone = streak.nextMilestone ?? 30;
    final progress = (currentStreak / nextMilestone).clamp(0.0, 1.0);

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade400,
                      Colors.orange.shade600,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$currentStreak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Streak',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      'Longest: $longestStreak days',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.local_fire_department,
                color: Colors.orange.shade600,
                size: 32,
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing16),

          // Progress to next milestone
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress to $nextMilestone days',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.brandColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radius8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: tokens.cardColor.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.brandColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, GamificationController controller, AppUiTokens tokens) {
    final achievements = controller.achievements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
            ),
            Obx(() => Text(
                  '${achievements.where((a) => a.isUnlocked).length} / ${achievements.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                )),
          ],
        ),

        const SizedBox(height: AppConstants.spacing12),

        Obx(() {
          if (achievements.isEmpty) {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return AppGlassCard(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              child: Center(
                child: Text(
                  'No achievements yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppConstants.spacing12,
              crossAxisSpacing: AppConstants.spacing12,
              childAspectRatio: 1,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementCard(context, achievement, tokens);
            },
          );
        }),
      ],
    );
  }

  Widget _buildAchievementCard(BuildContext context, AchievementModel achievement, AppUiTokens tokens) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? tokens.brandColor.withOpacity(0.1) : tokens.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(
          color: isUnlocked ? tokens.brandColor : tokens.cardBorderColor,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? _getIconForAchievement(achievement.iconName) : Icons.lock,
            color: isUnlocked ? tokens.brandColor : tokens.textMuted,
            size: 32,
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            achievement.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${achievement.progress}/${achievement.target}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.textMuted,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardSection(BuildContext context, GamificationController controller, AppUiTokens tokens) {
    final leaderboard = controller.leaderboard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leaderboard',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
        ),

        const SizedBox(height: AppConstants.spacing12),

        Obx(() {
          if (leaderboard.isEmpty) {
            return AppGlassCard(
              padding: const EdgeInsets.all(AppConstants.spacing32),
              child: Center(
                child: Text(
                  'No leaderboard data yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              ),
            );
          }

          return AppGlassCard(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length > 10 ? 10 : leaderboard.length,
              separatorBuilder: (context, index) => Divider(
                color: tokens.cardBorderColor,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                final rank = index + 1;
                return _buildLeaderboardItem(context, entry, rank, tokens);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, LeaderboardEntry entry, int rank, AppUiTokens tokens) {
    final isTop3 = rank <= 3;
    final rankColor = isTop3
        ? [Colors.amber, Colors.grey, Colors.brown][rank - 1]
        : tokens.textMuted;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing8,
      ),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: rankColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              color: rankColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          if (entry.avatarUrl != null)
            CircleAvatar(
              backgroundImage: NetworkImage(entry.avatarUrl!),
              radius: 16,
            )
          else
            CircleAvatar(
              backgroundColor: tokens.brandColor,
              radius: 16,
              child: Text(
                entry.username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: AppConstants.spacing12),
          Text(
            entry.username,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing12,
          vertical: AppConstants.spacing6,
        ),
        decoration: BoxDecoration(
          color: tokens.brandColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radius16),
        ),
        child: Text(
          '${entry.points} pts',
          style: TextStyle(
            color: tokens.brandColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  IconData _getIconForAchievement(String? iconName) {
    switch (iconName) {
      case 'checkroom':
        return Icons.checkroom;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'style':
        return Icons.style;
      default:
        return Icons.military_tech;
    }
  }
}

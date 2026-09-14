import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/constants/app_constants.dart';
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
    final GamificationController controller =
        Get.find<GamificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your progress'),
        actions: [
          IconButton(
            tooltip: 'Refresh progress',
            onPressed: controller.refreshAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => controller.refreshAll(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() {
                    if (!controller.hasError) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        AppErrorBanner(message: controller.error.value),
                        TextButton(
                          onPressed: controller.refreshAll,
                          child: const Text('Retry'),
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
    );
  }

  Widget _buildStreakSection(
    BuildContext context,
    GamificationController controller,
    AppUiTokens tokens,
  ) {
    final streak = controller.streak.value;
    if (streak == null) {
      if (controller.isLoading.value) {
        return const ShimmerCard(height: 140);
      }
      return AppGlassCard(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Center(
          child: Text(
            'No streak data yet',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
          ),
        ),
      );
    }

    final currentStreak = streak.currentStreak;
    final longestStreak = streak.longestStreak;
    // Null means the backend has no further milestone (streak past max):
    // hide the progress block instead of fabricating a default target.
    final nextMilestone = streak.nextMilestone;
    final progress = nextMilestone == null
        ? null
        : (currentStreak / nextMilestone).clamp(0.0, 1.0).toDouble();

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Current streak',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$currentStreak days',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: tokens.brandColor),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Longest: $longestStreak days',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
            ),
          ),

          const SizedBox(height: AppConstants.spacing16),

          // Progress to next milestone. Hidden entirely when the backend
          // reports none (streak past the max milestone) — a fabricated
          // default target used to mislabel long streaks.
          if (nextMilestone != null && progress != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      'Progress to $nextMilestone days',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
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
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    semanticsLabel: 'Progress to next streak milestone',
                    valueColor: AlwaysStoppedAnimation<Color>(
                      tokens.brandColor,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(
    BuildContext context,
    GamificationController controller,
    AppUiTokens tokens,
  ) {
    final achievements = controller.achievements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
            Obx(
              () => Text(
                '${achievements.where((a) => a.isUnlocked).length} / ${achievements.length}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.spacing12),

        Obx(() {
          if (achievements.isEmpty) {
            if (controller.isLoading.value) {
              return ShimmerGridLoaderBox(
                crossAxisCount: 3,
                itemCount: 6,
                childAspectRatio: 1,
              );
            }
            return AppGlassCard(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              child: Center(
                child: Text(
                  'No achievements yet',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
              final columns = largeText
                  ? 1
                  : constraints.maxWidth < 500
                  ? 2
                  : 3;
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final achievement in achievements)
                    SizedBox(
                      width: width,
                      child: _buildAchievementCard(
                        context,
                        achievement,
                        tokens,
                      ),
                    ),
                ],
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    AchievementModel achievement,
    AppUiTokens tokens,
  ) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? tokens.brandColor.withValues(alpha: 0.1)
            : tokens.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(
          color: isUnlocked ? tokens.brandColor : tokens.cardBorderColor,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked
                ? _getIconForAchievement(achievement.iconName)
                : Icons.lock,
            color: isUnlocked ? tokens.brandColor : tokens.textMuted,
            size: 32,
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            achievement.name,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${achievement.progress}/${achievement.target}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardSection(
    BuildContext context,
    GamificationController controller,
    AppUiTokens tokens,
  ) {
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
                ),
              ),
            );
          }

          return AppGlassCard(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length > 10 ? 10 : leaderboard.length,
              separatorBuilder: (context, index) =>
                  Divider(color: tokens.cardBorderColor, height: 1),
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                // Backend-computed global rank wins; index+1 is the fallback
                // for entries missing a rank (ties/ordering drift otherwise
                // mislabels medals).
                final rank = entry.rank > 0 ? entry.rank : index + 1;
                return _buildLeaderboardItem(context, entry, rank, tokens);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    LeaderboardEntry entry,
    int rank,
    AppUiTokens tokens,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: entry.avatarUrl == null
                ? Text(_initialFor(entry.username))
                : ClipOval(
                    child: AppNetworkImage(
                      entry.avatarUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          Text(_initialFor(entry.username)),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rank $rank · ${entry.points} points',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// First character for an avatar initial; '?' when the name is empty.
  String _initialFor(String username) =>
      username.isEmpty ? '?' : username[0].toUpperCase();

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

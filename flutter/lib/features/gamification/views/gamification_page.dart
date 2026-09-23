import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/gamification_model.dart';
import '../providers/gamification_providers.dart';

/// Streak, achievements and the leaderboard.
class GamificationPage extends ConsumerWidget {
  const GamificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final achievements = ref.watch(achievementsProvider);
    final leaderboard = ref.watch(leaderboardProvider);

    Future<void> refreshAll() => Future.wait([
      ref.refresh(streakProvider.future),
      ref.refresh(achievementsProvider.future),
      ref.refresh(leaderboardProvider.future),
    ]).then<void>((_) {}, onError: (_) {});

    final sections = [streak, achievements, leaderboard];
    final nothingLoaded = sections.every(
      (s) => !s.hasValue && s.hasError && !s.isLoading,
    );

    return PaperStockScope(
      stock: PaperStockId.marigold,
      child: Scaffold(
        appBar: AppBar(title: const Text('Rewards')),
        body: AppPageBackground(
          child: RefreshIndicator(
            onRefresh: refreshAll,
            child: nothingLoaded
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      AppErrorState(error: streak.error, onRetry: refreshAll),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppConstants.spacing16,
                      AppConstants.spacing8,
                      AppConstants.spacing16,
                      AppConstants.spacing32 +
                          MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      _StreakCard(
                        streak: streak,
                        onRetry: () => ref.invalidate(streakProvider),
                      ),
                      const SizedBox(height: AppConstants.spacing32),
                      _Achievements(
                        achievements: achievements,
                        onRetry: () => ref.invalidate(achievementsProvider),
                      ),
                      const SizedBox(height: AppConstants.spacing32),
                      _Leaderboard(
                        leaderboard: leaderboard,
                        onRetry: () => ref.invalidate(leaderboardProvider),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// A section's banner when its refresh failed, or when it has nothing.
Widget? _sectionError(AsyncValue<Object?> value, VoidCallback onRetry) =>
    value.hasError && !value.isLoading
    ? AppErrorBanner(error: value.error, onRetry: onRetry)
    : null;

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing4,
        0,
        AppConstants.spacing4,
        AppConstants.spacing12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(title, style: text.headlineSmall)),
          if (trailing != null)
            Text(
              trailing!,
              style: text.bodyMedium?.copyWith(
                color: PaperTokens.of(context).textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak, required this.onRetry});

  final AsyncValue<StreakModel> streak;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final value = streak.value;
    final error = _sectionError(streak, onRetry);
    if (value == null) {
      return error ??
          const SkeletonPulse(
            child: SkeletonBox(
              height: 148,
              borderRadius: AppConstants.radius12,
            ),
          );
    }

    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final next = value.nextMilestone;
    final progress = next == null || next <= 0
        ? null
        : (value.currentStreak / next).clamp(0.0, 1.0);
    final daysLeft = next == null ? 0 : next - value.currentStreak;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?error,
        PaperSurface(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${value.currentStreak}',
                    style: text.displayMedium?.copyWith(height: 1),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.spacing4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'day streak',
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Best ${value.longestStreak} days',
                            style: text.bodyMedium?.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // No milestone left (past the last one): no bar, not a guess.
              if (progress != null) ...[
                const SizedBox(height: AppConstants.spacing20),
                Text(
                  daysLeft <= 0
                      ? 'You reached $next days'
                      : '$daysLeft more ${daysLeft == 1 ? 'day' : 'days'} '
                            'to $next',
                  style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
                ),
                const SizedBox(height: AppConstants.spacing8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radius8),
                  child: LinearProgressIndicator(value: progress, minHeight: 8),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Achievements extends StatelessWidget {
  const _Achievements({required this.achievements, required this.onRetry});

  final AsyncValue<List<AchievementModel>> achievements;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final value = achievements.value;
    final error = _sectionError(achievements, onRetry);
    final unlocked = value?.where((a) => a.isUnlocked).length ?? 0;

    final Widget body;
    if (value == null) {
      body =
          error ??
          const SkeletonGridLoaderBox(
            crossAxisCount: 3,
            itemCount: 6,
            childAspectRatio: 0.85,
          );
    } else if (value.isEmpty) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A retained empty list can still carry a failed refresh: show it.
          ?error,
          const AppEmptyState(
            scene: PaperScenes.outfits,
            title: 'No achievements yet',
            message: 'Add pieces and plan outfits to earn your first.',
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?error,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppConstants.spacing12,
              crossAxisSpacing: AppConstants.spacing12,
              childAspectRatio: 0.85,
            ),
            itemCount: value.length,
            itemBuilder: (context, i) => _AchievementTile(value[i]),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          'Achievements',
          trailing: value == null || value.isEmpty
              ? null
              : '$unlocked of ${value.length}',
        ),
        body,
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile(this.achievement);

  final AchievementModel achievement;

  static IconData _icon(String? name) => switch (name) {
    'checkroom' => Icons.checkroom_outlined,
    'star' => Icons.star_outline_rounded,
    'favorite' => Icons.favorite_outline_rounded,
    'emoji_events' => Icons.emoji_events_outlined,
    'local_fire_department' => Icons.local_fire_department_outlined,
    'calendar_today' => Icons.calendar_today_outlined,
    'photo_camera' => Icons.photo_camera_outlined,
    'style' => Icons.style_outlined,
    _ => Icons.military_tech_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final unlocked = achievement.isUnlocked;
    return Semantics(
      label:
          '${achievement.name}, '
          '${unlocked ? 'earned' : 'locked, ${achievement.progress} of ${achievement.target}'}',
      excludeSemantics: true,
      child: PaperSurface(
        lift: unlocked ? 1 : 0,
        color: unlocked ? null : tokens.stock.sunk,
        grain: unlocked,
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing8,
          AppConstants.spacing12,
          AppConstants.spacing8,
          AppConstants.spacing8,
        ),
        child: Column(
          children: [
            Icon(
              unlocked
                  ? _icon(achievement.iconName)
                  : Icons.lock_outline_rounded,
              size: 32,
              color: unlocked ? tokens.stock.accent : tokens.textMuted,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Expanded(
              child: Text(
                achievement.name,
                style: text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: unlocked ? tokens.textPrimary : tokens.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              unlocked
                  ? 'Earned'
                  : '${achievement.progress} of ${achievement.target}',
              style: text.labelSmall?.copyWith(color: tokens.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.leaderboard, required this.onRetry});

  final AsyncValue<List<LeaderboardEntry>> leaderboard;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final value = leaderboard.value;
    final error = _sectionError(leaderboard, onRetry);

    final Widget body;
    // Loading is checked before empty: an unloaded board is not an empty one.
    if (value == null) {
      body =
          error ??
          const SkeletonPulse(
            child: SkeletonBox(
              height: 220,
              borderRadius: AppConstants.radius12,
            ),
          );
    } else if (value.isEmpty) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A retained empty list can still carry a failed refresh: show it.
          ?error,
          const AppEmptyState(
            scene: PaperScenes.home,
            title: 'No one on the board yet',
            message: 'Plan outfits to earn points and show up here.',
          ),
        ],
      );
    } else {
      final top = value.take(10).toList();
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?error,
          PaperSurface(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacing4,
            ),
            child: Column(
              children: [
                for (final (i, entry) in top.indexed) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: AppConstants.spacing16,
                      endIndent: AppConstants.spacing16,
                    ),
                  // The server's rank wins; the position is a fallback.
                  _LeaderRow(
                    entry: entry,
                    rank: entry.rank > 0 ? entry.rank : i + 1,
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [const _SectionTitle('Leaderboard'), body],
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.entry, required this.rank});

  final LeaderboardEntry entry;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final initial = Text(
      entry.username.isEmpty ? '?' : entry.username[0].toUpperCase(),
      style: TextStyle(
        color: tokens.stock.accent,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
    final url = entry.avatarUrl;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$rank',
              style: text.headlineSmall?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          CircleAvatar(
            radius: 18,
            backgroundColor: tokens.stock.tint,
            child: url != null && url.isNotEmpty
                ? ClipOval(
                    child: AppNetworkImage(
                      url,
                      width: 36,
                      height: 36,
                      cacheWidth: 108,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Center(child: initial),
                    ),
                  )
                : initial,
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Text(
              entry.username,
              style: text.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppConstants.spacing8),
          Text(
            '${entry.points} pts',
            style: text.labelLarge?.copyWith(color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/widgets/app_ui.dart';
import '../../outfits/providers/outfit_providers.dart';
import '../../wardrobe/providers/wardrobe_providers.dart';
import '../models/dashboard_models.dart';

/// Closet totals as three large figures. An empty closet shows an invitation
/// to add the first piece instead of a row of zeros.
class SnapshotCard extends ConsumerWidget {
  const SnapshotCard({super.key, required this.stats, this.streak});

  final DashboardStats stats;
  final StreakData? streak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    if (stats.totalItems == 0) {
      return PaperSurface(
        stock: PaperStockId.moss,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PaperScene(preset: PaperScenes.closet, height: 120),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.dashboardStartClosetTitle, style: text.headlineSmall),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    l10n.dashboardStartClosetBody,
                    style: text.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  ElevatedButton.icon(
                    onPressed: () => context.push(Routes.wardrobeAdd),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 20),
                    label: Text(l10n.wardrobeAddFirst),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final streak = this.streak;
    return PaperSurface(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppConstants.spacing8,
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Figure(
                value: stats.totalItems,
                label: l10n.dashboardPieces,
                note: l10n.dashboardAddedThisMonth(stats.itemsAddedThisMonth),
                onTap: () => context.go(Routes.wardrobe),
              ),
              _Figure(
                value: stats.totalOutfits,
                label: l10n.dashboardOutfits,
                note: l10n.dashboardAddedThisMonth(
                  stats.outfitsCreatedThisMonth,
                ),
                onTap: () => context.go(Routes.outfits),
              ),
              _Figure(
                value: streak?.currentStreak,
                label: l10n.dashboardDayStreak,
                note: streak == null
                    ? ''
                    : l10n.dashboardBestStreak(streak.longestStreak),
                onTap: () => context.push(Routes.gamification),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing8),
          Wrap(
            children: [
              TextButton.icon(
                onPressed: () {
                  context.go(Routes.wardrobe);
                  ref
                      .read(wardrobeFiltersProvider.notifier)
                      .setFavoritesOnly(true);
                },
                icon: const Icon(Icons.favorite_border_rounded, size: 18),
                label: Text(l10n.dashboardFavourites(stats.favoriteItemsCount)),
              ),
              TextButton.icon(
                onPressed: () {
                  context.go(Routes.outfits);
                  ref.read(outfitFiltersProvider.notifier).setFavoritesOnly(true);
                },
                icon: const Icon(Icons.bookmark_border_rounded, size: 18),
                label: Text(
                  l10n.dashboardSavedOutfits(stats.favoriteOutfitsCount),
                ),
              ),
            ],
          ),
          if (stats.mostWornItem case final worn?)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppConstants.spacing12,
                0,
                AppConstants.spacing12,
                AppConstants.spacing8,
              ),
              child: Text(
                l10n.dashboardMostWorn(worn.name, worn.timesWorn),
                style: text.bodySmall?.copyWith(color: tokens.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.value,
    required this.label,
    required this.note,
    required this.onTap,
  });

  final int? value;
  final String label;
  final String note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Semantics(
        button: true,
        // The figure and its label are two nodes on screen but one fact to a
        // screen reader. `value` is null while the streak is still loading.
        label: value == null ? label : '${value!} $label',
        excludeSemantics: true,
        // excludeSemantics drops the InkWell's tap action: without this the
        // node is announced as a button screen readers cannot activate.
        onTap: onTap,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing8,
              vertical: AppConstants.spacing4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paperFigure(value),
                  style: text.displaySmall?.copyWith(fontSize: 34),
                ),
                Text(label, style: text.labelLarge),
                if (note.isNotEmpty)
                  Text(
                    note,
                    style: text.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

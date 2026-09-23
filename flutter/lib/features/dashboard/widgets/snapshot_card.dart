import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
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
                  Text('Start your closet', style: text.headlineSmall),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    'Photograph a few pieces. We tag them for you.',
                    style: text.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  ElevatedButton.icon(
                    onPressed: () => context.push(Routes.wardrobeAdd),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 20),
                    label: const Text('Add your first piece'),
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
      padding: const EdgeInsets.fromLTRB(
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
                label: 'pieces',
                note: '+${stats.itemsAddedThisMonth} this month',
                onTap: () => context.go(Routes.wardrobe),
              ),
              _Figure(
                value: stats.totalOutfits,
                label: 'outfits',
                note: '+${stats.outfitsCreatedThisMonth} this month',
                onTap: () => context.go(Routes.outfits),
              ),
              _Figure(
                value: streak?.currentStreak,
                label: 'day streak',
                note: streak == null ? '' : 'Best ${streak.longestStreak}',
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
                label: Text('${stats.favoriteItemsCount} favourites'),
              ),
              TextButton.icon(
                onPressed: () {
                  context.go(Routes.outfits);
                  ref.read(outfitFiltersProvider.notifier).setFavoritesOnly(true);
                },
                icon: const Icon(Icons.bookmark_border_rounded, size: 18),
                label: Text('${stats.favoriteOutfitsCount} saved outfits'),
              ),
            ],
          ),
          if (stats.mostWornItem case final worn?)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacing12,
                0,
                AppConstants.spacing12,
                AppConstants.spacing8,
              ),
              child: Text(
                'Most worn: ${worn.name}, ${worn.timesWorn} times',
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
        label: '${value ?? 'No'} $label',
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

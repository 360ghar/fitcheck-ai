import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_ui.dart';
import '../../outfits/controllers/outfit_list_controller.dart';
import '../../shell/controllers/main_shell_controller.dart';
import '../../wardrobe/controllers/wardrobe_controller.dart';
import '../controllers/dashboard_controller.dart';

/// Real wardrobe totals with direct links to the corresponding collections.
class SnapshotCard extends StatelessWidget {
  const SnapshotCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Obx(() {
      final stats = controller.dashboard.value?.statistics;
      final streak = controller.streak.value;
      final metrics = [
        (
          'Pieces',
          stats?.totalItems,
          stats == null
              ? 'Loading'
              : '+${stats.itemsAddedThisMonth} this month',
          () => Get.find<MainShellController>().changeTab(1),
        ),
        (
          'Outfits',
          stats?.totalOutfits,
          stats == null
              ? 'Loading'
              : '+${stats.outfitsCreatedThisMonth} this month',
          () => Get.find<MainShellController>().changeTab(2),
        ),
        (
          'Day streak',
          streak?.currentStreak,
          streak == null
              ? 'Not available'
              : 'Best ${streak.longestStreak} days',
          () => Get.toNamed(Routes.gamification),
        ),
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            title: 'Your wardrobe, in focus',
            trailing: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          const Divider(),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = MediaQuery.textScalerOf(context).scale(14) > 20
                  ? 1
                  : 3;
              return Wrap(
                children: [
                  for (final metric in metrics)
                    SizedBox(
                      width: constraints.maxWidth / columns,
                      child: InkWell(
                        onTap: metric.$4,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                metric.$2?.toString() ?? '—',
                                style: text.displaySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(metric.$1, style: text.labelLarge),
                              const SizedBox(height: 4),
                              Text(
                                metric.$3,
                                style: text.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Get.find<MainShellController>().changeTab(1);
                  Get.find<WardrobeController>().favoritesOnly.value = true;
                },
                icon: const Icon(Icons.favorite_border, size: 18),
                label: Text(
                  '${stats?.favoriteItemsCount ?? '—'} '
                  '${stats?.favoriteItemsCount == 1 ? 'favourite' : 'favourites'}',
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Get.find<MainShellController>().changeTab(2);
                  Get.find<OutfitListController>().favoritesOnly.value = true;
                },
                icon: const Icon(Icons.bookmark_border, size: 18),
                label: Text(
                  '${stats?.favoriteOutfitsCount ?? '—'} favourite outfits',
                ),
              ),
            ],
          ),
          if (stats?.mostWornItem != null) ...[
            const SizedBox(height: 12),
            Text(
              'Most worn: ${stats!.mostWornItem!.name} · ${stats.mostWornItem!.timesWorn} wears',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../outfits/controllers/outfit_list_controller.dart';
import '../../shell/controllers/main_shell_controller.dart';
import '../../wardrobe/controllers/wardrobe_controller.dart';
import '../controllers/dashboard_controller.dart';

/// Wardrobe Snapshot card showing key metrics
class SnapshotCard extends StatelessWidget {
  const SnapshotCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final tokens = AppUiTokens.of(context);

    return Obx(() {
      final stats = controller.dashboard.value?.statistics;
      final streak = controller.streak.value;

      final itemsCount = _formatCount(stats?.totalItems);
      final outfitsCount = _formatCount(stats?.totalOutfits);
      final streakCount = _formatCount(streak?.currentStreak);

      return AppGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: 'Wardrobe Snapshot',
              subtitle: 'This month at a glance',
              trailing: controller.isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Items',
                    value: itemsCount,
                    footnote: stats == null
                        ? 'Loading'
                        : '+${stats.itemsAddedThisMonth} this month',
                    icon: Icons.checkroom,
                    accent: const Color(0xFF3B82F6),
                    onTap: () {
                      final shellController = Get.find<MainShellController>();
                      shellController.changeTab(2); // wardrobe tab
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: _MetricTile(
                    label: 'Outfits',
                    value: outfitsCount,
                    footnote: stats == null
                        ? 'Loading'
                        : '+${stats.outfitsCreatedThisMonth} this month',
                    icon: Icons.auto_awesome,
                    accent: const Color(0xFFEC4899),
                    onTap: () {
                      final shellController = Get.find<MainShellController>();
                      shellController.changeTab(3); // outfits tab
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: _MetricTile(
                    label: 'Streak',
                    value: streakCount,
                    footnote: streak == null
                        ? 'Loading'
                        : 'Best ${streak.longestStreak} days',
                    icon: Icons.local_fire_department,
                    accent: const Color(0xFFF59E0B),
                    onTap: () => Get.toNamed(Routes.gamification),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Wrap(
              spacing: AppConstants.spacing8,
              runSpacing: AppConstants.spacing8,
              children: [
                _StatPill(
                  label: 'Favorites',
                  value: _formatCount(stats?.favoriteItemsCount),
                  icon: Icons.favorite_border,
                  onTap: () {
                    final shellController = Get.find<MainShellController>();
                    final wardrobeController = Get.find<WardrobeController>();
                    shellController.changeTab(2); // wardrobe tab
                    wardrobeController.sortType.value = 'favorite';
                  },
                ),
                _StatPill(
                  label: 'Saved outfits',
                  value: _formatCount(stats?.favoriteOutfitsCount),
                  icon: Icons.bookmark_border,
                  onTap: () {
                    final shellController = Get.find<MainShellController>();
                    final outfitController = Get.find<OutfitListController>();
                    shellController.changeTab(3); // outfits tab
                    if (!outfitController.favoritesOnly.value) {
                      outfitController.favoritesOnly.value = true;
                    }
                  },
                ),
              ],
            ),
            if (stats?.mostWornItem != null) ...[
              const SizedBox(height: AppConstants.spacing12),
              Text(
                'Most worn: ${stats!.mostWornItem!.name} - ${stats.mostWornItem!.timesWorn} wears',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            ],
          ],
        ),
      );
    });
  }

  String _formatCount(int? value) {
    if (value == null) return '--';
    return value.toString();
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String footnote;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.footnote,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radius16),
          border: Border.all(color: tokens.cardBorderColor),
          color: tokens.cardColor.withOpacity(0.75),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacing8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              footnote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing12,
          vertical: AppConstants.spacing8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radius24),
          color: tokens.cardColor.withOpacity(0.6),
          border: Border.all(color: tokens.cardBorderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: tokens.textSecondary),
            const SizedBox(width: AppConstants.spacing8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
            ),
            const SizedBox(width: AppConstants.spacing4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

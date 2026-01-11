import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../app/routes/app_routes.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);

    final destinations = [
      _MoreDestination(
        icon: Icons.recommend,
        title: 'For You',
        subtitle: 'AI recommendations and looks',
        route: Routes.recommendations,
      ),
      _MoreDestination(
        icon: Icons.calendar_today,
        title: 'Calendar',
        subtitle: 'Plan outfits and track wear',
        route: Routes.calendar,
      ),
      _MoreDestination(
        icon: Icons.emoji_events,
        title: 'Rewards',
        subtitle: 'Streaks, achievements, leaderboard',
        route: Routes.gamification,
      ),
      _MoreDestination(
        icon: Icons.person,
        title: 'Profile',
        subtitle: 'Account, body profiles, preferences',
        route: Routes.profile,
      ),
      _MoreDestination(
        icon: Icons.settings,
        title: 'Settings',
        subtitle: 'Notifications, privacy, app preferences',
        route: Routes.settings,
      ),
    ];

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            itemCount: destinations.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacing12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacing4),
                  child: Text(
                    'More',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                  ),
                );
              }

              final destination = destinations[index - 1];
              return AppGlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing16,
                  vertical: AppConstants.spacing12,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tokens.brandColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppConstants.radius12),
                    ),
                    child: Icon(destination.icon, color: tokens.brandColor),
                  ),
                  title: Text(
                    destination.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                  ),
                  subtitle: Text(
                    destination.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.offAllNamed(destination.route),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentIndex),
    );
  }
}

class _MoreDestination {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _MoreDestination({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

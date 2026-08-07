import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/widgets/app_version_label.dart';
import '../../../app/routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../settings/models/user_preferences_model.dart';

/// Profile hub without Scaffold wrapper. Serves both the "More" tab in
/// MainShellPage and the pushed `/profile` route (via ProfilePage).
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final dashboardController = Get.find<DashboardController>();
    final settingsController = Get.find<SettingsController>();

    return AppPageBackground(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => dashboardController.fetchDashboard(showLoader: false),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spacing16,
                    AppConstants.spacing16,
                    AppConstants.spacing16,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIdentityCard(context, authController),
                      const SizedBox(height: AppConstants.spacing12),
                      _buildStatsStrip(context, dashboardController),
                      const SizedBox(height: AppConstants.spacing20),
                      AppSectionHeader(
                        title: 'Explore',
                        subtitle: 'Try things on, plan, and get rewarded',
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      _buildExploreCard(context),
                      const SizedBox(height: AppConstants.spacing20),
                      AppSectionHeader(
                        title: 'Account',
                        subtitle: 'Your body profiles, plan, and preferences',
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      _buildAccountCard(context, settingsController),
                      const SizedBox(height: AppConstants.spacing20),
                      AppSectionHeader(
                        title: 'Support',
                        subtitle: 'Help, feedback, and sign out',
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      _buildSupportCard(context, authController),
                      // Clears the floating bottom navigation bar.
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Avatar + name + email. The whole card taps through to Edit Profile,
  /// so there is no separate edit button or "Edit Profile" menu row.
  Widget _buildIdentityCard(BuildContext context, AuthController authController) {
    final tokens = AppUiTokens.of(context);

    return AppGlassCard(
      padding: const EdgeInsets.all(0),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        onTap: () => Get.toNamed(Routes.profileEdit),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Obx(() {
            final user = authController.user.value;

            return Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tokens.brandColor,
                        tokens.brandColor.withValues(alpha: 0.6),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: user?.avatarUrl != null
                      ? ClipOval(
                          child: AppNetworkImage(
                            user!.avatarUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) {
                              return _buildAvatarInitials(context, user);
                            },
                          ),
                        )
                      : _buildAvatarInitials(context, user),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Guest',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: tokens.textSecondary),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAvatarInitials(BuildContext context, UserModel? user) {
    final initials = user?.fullName
            ?.split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase() ??
        (user?.email.isNotEmpty == true
            ? user!.email.substring(0, 1).toUpperCase()
            : null) ??
        'U';

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Three tappable stats on one row. Vertical tiles so they fit 3-across
  /// on a 360px phone without wrapping.
  Widget _buildStatsStrip(
    BuildContext context,
    DashboardController dashboardController,
  ) {
    final tokens = AppUiTokens.of(context);

    return Obx(() {
      final stats = dashboardController.dashboard.value?.statistics;
      final streak = dashboardController.streak.value;

      return AppGlassCard(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    context,
                    label: 'Items',
                    value: _formatCount(stats?.totalItems),
                    accent: const Color(0xFF3B82F6),
                    route: Routes.wardrobeStats,
                  ),
                ),
                Expanded(
                  child: _buildStatTile(
                    context,
                    label: 'Outfits',
                    value: _formatCount(stats?.totalOutfits),
                    accent: const Color(0xFFEC4899),
                    route: Routes.outfitCollections,
                  ),
                ),
                Expanded(
                  child: _buildStatTile(
                    context,
                    label: 'Streak',
                    value: _formatCount(streak?.currentStreak),
                    accent: const Color(0xFFF59E0B),
                    route: Routes.gamification,
                  ),
                ),
              ],
            ),
            if (stats?.mostWornItem != null) ...[
              const SizedBox(height: AppConstants.spacing12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing16,
                ),
                child: Text(
                  'Most worn: ${stats!.mostWornItem!.name} - ${stats.mostWornItem!.timesWorn} wears',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String label,
    required String value,
    required Color accent,
    required String route,
  }) {
    final tokens = AppUiTokens.of(context);

    return Semantics(
      label: '$label $value',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        onTap: () => Get.toNamed(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
              ),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreCard(BuildContext context) {
    return AppGlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.accessibility_new,
            title: 'Try-On',
            onTap: () => Get.toNamed(Routes.tryOn),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.recommend,
            title: 'For You',
            onTap: () => Get.toNamed(Routes.recommendations),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.calendar_today,
            title: 'Calendar',
            onTap: () => Get.toNamed(Routes.calendar),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.emoji_events,
            title: 'Rewards',
            onTap: () => Get.toNamed(Routes.gamification),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return AppGlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.straighten,
            title: 'Body Profiles',
            onTap: () => Get.toNamed(Routes.bodyProfiles),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.workspace_premium,
            title: 'Plan & Billing',
            onTap: () => Get.toNamed(Routes.subscription),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.card_giftcard,
            title: 'Invite Friends',
            onTap: () => Get.toNamed(Routes.referral),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            trailing: Obx(() {
              final mode = settingsController.preferences.value?.themeMode;
              final isDark = mode == AppThemeMode.dark
                  ? true
                  : mode == AppThemeMode.light
                      ? false
                      : Theme.of(context).brightness == Brightness.dark;

              return Switch(
                value: isDark,
                onChanged: (value) {
                  settingsController.updateThemeMode(
                    value ? AppThemeMode.dark : AppThemeMode.light,
                  );
                },
              );
            }),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, AuthController authController) {
    final tokens = AppUiTokens.of(context);

    return AppGlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () => Get.toNamed(Routes.help),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.rate_review_outlined,
            title: 'Send Feedback',
            onTap: () => Get.toNamed(Routes.feedback),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.shield_outlined,
            title: 'Privacy & Terms',
            onTap: () => Get.toNamed(Routes.legal),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'About',
            onTap: () => _showAboutDialog(context),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            titleColor: Theme.of(context).colorScheme.error,
            iconColor: Theme.of(context).colorScheme.error,
            onTap: () => _showLogoutDialog(context, authController),
            trailing: Icon(
              Icons.chevron_right,
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? titleColor,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final tokens = AppUiTokens.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacing12,
          horizontal: AppConstants.spacing12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? tokens.textSecondary,
            ),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: titleColor ?? tokens.textPrimary,
                    ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(
                Icons.chevron_right,
                color: tokens.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Divider(
      height: 1,
      color: tokens.cardBorderColor,
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('About Fit Check AI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.checkroom_outlined,
              size: 64,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: AppConstants.spacing16),
            const Text(
              'Fit Check AI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            AppVersionLabel(
              prefix: 'Version ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacing24),
            const Text(
              'AI-Powered Wardrobe & Outfit Manager',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      Obx(() => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: authController.isLoggingOut.value ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: authController.isLoggingOut.value
                ? null
                : () => authController.logout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: authController.isLoggingOut.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Logout'),
          ),
        ],
      )),
      barrierDismissible: false,
    );
  }

  String _formatCount(int? value) {
    if (value == null) return '--';
    return value.toString();
  }
}

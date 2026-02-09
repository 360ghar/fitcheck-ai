import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../app/routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../settings/models/user_preferences_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final dashboardController = Get.find<DashboardController>();
    final settingsController = Get.find<SettingsController>();
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      body: AppPageBackground(
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
                    AppConstants.spacing12,
                    AppConstants.spacing16,
                    AppConstants.spacing8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Profile',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => Get.toNamed(Routes.settings),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(context, authController),
                      const SizedBox(height: AppConstants.spacing20),
                      _buildStatsCard(context, dashboardController),
                      const SizedBox(height: AppConstants.spacing24),
                      AppSectionHeader(
                        title: 'Preferences',
                        subtitle: 'Shape your style experience',
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      _buildPreferencesCard(context, authController),
                      const SizedBox(height: AppConstants.spacing24),
                      AppSectionHeader(
                        title: 'App Settings',
                        subtitle: 'Notifications and appearance',
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      _buildAppSettingsCard(context, settingsController),
                      const SizedBox(height: AppConstants.spacing24),
                      AppSectionHeader(
                        title: 'Support',
                        subtitle: 'Help, about, and sign out',
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      _buildSupportCard(context, authController),
                      const SizedBox(height: AppConstants.spacing32),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentIndex),
    );
  }

  Widget _buildProfileCard(BuildContext context, AuthController authController) {
    final tokens = AppUiTokens.of(context);

    return AppGlassCard(
      child: Obx(() {
        final user = authController.user.value;

        return Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tokens.brandColor,
                        tokens.brandColor.withOpacity(0.6),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: user?.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            user!.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildAvatarInitials(context, user);
                            },
                          ),
                        )
                      : _buildAvatarInitials(context, user),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spacing6),
                    decoration: BoxDecoration(
                      color: tokens.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.cardBorderColor),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: tokens.textSecondary,
                    ),
                  ),
                ),
              ],
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
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Get.toNamed(Routes.profileEdit),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAvatarInitials(BuildContext context, dynamic user) {
    final initials = user?.fullName
            ?.split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase() ??
        (user?.email?.isNotEmpty == true
            ? user!.email.substring(0, 1).toUpperCase()
            : null) ??
        'U';

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, DashboardController dashboardController) {
    final tokens = AppUiTokens.of(context);

    return Obx(() {
      final stats = dashboardController.dashboard.value?.statistics;
      final streak = dashboardController.streak.value;

      return AppGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: 'Your Progress',
              subtitle: 'Live stats from your wardrobe',
            ),
            const SizedBox(height: AppConstants.spacing16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 680 ? 3 : 2;
                final cardWidth = (constraints.maxWidth -
                        (columns - 1) * AppConstants.spacing12) /
                    columns;

                return Wrap(
                  spacing: AppConstants.spacing12,
                  runSpacing: AppConstants.spacing12,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _buildMiniStat(
                        context,
                        label: 'Items',
                        value: _formatCount(stats?.totalItems),
                        icon: Icons.checkroom,
                        accent: const Color(0xFF3B82F6),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _buildMiniStat(
                        context,
                        label: 'Outfits',
                        value: _formatCount(stats?.totalOutfits),
                        icon: Icons.auto_awesome,
                        accent: const Color(0xFFEC4899),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _buildMiniStat(
                        context,
                        label: 'Streak',
                        value: _formatCount(streak?.currentStreak),
                        icon: Icons.local_fire_department,
                        accent: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                );
              },
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

  Widget _buildMiniStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    final tokens = AppUiTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: tokens.cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppConstants.radius12),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context, AuthController authController) {
    return AppGlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.person,
            title: 'Edit Profile',
            onTap: () => Get.toNamed(Routes.profileEdit),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.palette,
            title: 'Style Preferences',
            onTap: () => Get.toNamed(Routes.settings),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.accessibility_new,
            title: 'Body Profiles',
            onTap: () => Get.toNamed(Routes.bodyProfiles),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return AppGlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Toggle notifications
              },
            ),
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
            Text(
              'Version 1.0.0',
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

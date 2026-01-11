import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../app/routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController dashboardController = Get.find<DashboardController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => dashboardController.fetchDashboard(showLoader: false),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spacing16,
                    AppConstants.spacing8,
                    AppConstants.spacing16,
                    AppConstants.spacing32,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Obx(() => dashboardController.error.value.isNotEmpty
                          ? _buildErrorBanner()
                          : const SizedBox.shrink()),
                      Obx(() => dashboardController.error.value.isNotEmpty
                          ? const SizedBox(height: AppConstants.spacing16)
                          : const SizedBox.shrink()),
                      _buildSnapshotCard(),
                      const SizedBox(height: AppConstants.spacing16),
                      _buildQuickActions(),
                      const SizedBox(height: AppConstants.spacing16),
                      _buildSuggestions(),
                      const SizedBox(height: AppConstants.spacing16),
                      _buildActivityFeed(),
                    ]),
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

  Widget _buildHeader() {
    final tokens = AppUiTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing12,
        AppConstants.spacing16,
        AppConstants.spacing12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getGreeting()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Obx(() => Text(
                      authController.user.value?.fullName ??
                          authController.user.value?.email.split('@')[0] ??
                          'Welcome',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: tokens.textPrimary,
                          ),
                    )),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  'Your AI wardrobe, tuned for today.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.profile),
            child: Obx(() => CircleAvatar(
                  radius: 22,
                  backgroundColor: tokens.brandColor.withOpacity(0.15),
                  backgroundImage: authController.user.value?.avatarUrl != null
                      ? NetworkImage(authController.user.value!.avatarUrl!)
                      : null,
                  child: authController.user.value?.avatarUrl == null
                      ? Text(
                          authController.user.value?.fullName
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                              authController.user.value?.email
                                      .substring(0, 1)
                                      .toUpperCase() ??
                                  'U',
                          style: TextStyle(
                            color: tokens.brandColor,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    final tokens = AppUiTokens.of(context);

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: tokens.brandColor),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Obx(() => Text(
                  dashboardController.error.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                      ),
                )),
          ),
          TextButton(
            onPressed: () => dashboardController.fetchDashboard(showLoader: false),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotCard() {
    final tokens = AppUiTokens.of(context);

    return Obx(() {
      final stats = dashboardController.dashboard.value?.statistics;
      final streak = dashboardController.streak.value;

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
              trailing: dashboardController.isLoading.value
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
                  child: _buildMetricTile(
                    label: 'Items',
                    value: itemsCount,
                    footnote: stats == null
                        ? 'Loading'
                        : '+${stats.itemsAddedThisMonth} this month',
                    icon: Icons.checkroom,
                    accent: const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Outfits',
                    value: outfitsCount,
                    footnote: stats == null
                        ? 'Loading'
                        : '+${stats.outfitsCreatedThisMonth} this month',
                    icon: Icons.auto_awesome,
                    accent: const Color(0xFFEC4899),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Streak',
                    value: streakCount,
                    footnote: streak == null
                        ? 'Loading'
                        : 'Best ${streak.longestStreak} days',
                    icon: Icons.local_fire_department,
                    accent: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Wrap(
              spacing: AppConstants.spacing8,
              runSpacing: AppConstants.spacing8,
              children: [
                _buildStatPill(
                  label: 'Favorites',
                  value: _formatCount(stats?.favoriteItemsCount),
                  icon: Icons.favorite_border,
                ),
                _buildStatPill(
                  label: 'Saved outfits',
                  value: _formatCount(stats?.favoriteOutfitsCount),
                  icon: Icons.bookmark_border,
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

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String footnote,
    required IconData icon,
    required Color accent,
  }) {
    final tokens = AppUiTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        border: Border.all(color: tokens.cardBorderColor),
        color: tokens.cardColor.withOpacity(0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Icon on left, count on right
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
          // Bottom: Name/Label
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
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final tokens = AppUiTokens.of(context);

    return Container(
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
    );
  }

  Widget _buildQuickActions() {
    final tokens = AppUiTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Quick Actions',
          subtitle: 'Jump back into your wardrobe',
        ),
        const SizedBox(height: AppConstants.spacing12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 680
                    ? 3
                    : 2;
            final cardWidth = (constraints.maxWidth -
                    (columns - 1) * AppConstants.spacing12) /
                columns;

            return Wrap(
              spacing: AppConstants.spacing12,
              runSpacing: AppConstants.spacing12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildActionCard(
                    title: 'Add Item',
                    subtitle: 'Capture new pieces',
                    icon: Icons.add,
                    gradient: LinearGradient(
                      colors: [
                        tokens.brandColor,
                        tokens.brandColor.withOpacity(0.7),
                      ],
                    ),
                    onTap: () => Get.toNamed(Routes.wardrobeAdd),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildActionCard(
                    title: 'Create Outfit',
                    subtitle: 'Mix and match looks',
                    icon: Icons.auto_awesome,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF111827),
                        tokens.cardColor,
                      ],
                    ),
                    onTap: () => Get.toNamed(Routes.outfits),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildActionCard(
                    title: 'For You',
                    subtitle: 'Personalized picks',
                    icon: Icons.explore,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0EA5E9),
                        Color(0xFF14B8A6),
                      ],
                    ),
                    onTap: () => Get.toNamed(Routes.recommendations),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildActionCard(
                    title: 'Plan Calendar',
                    subtitle: 'Outfits ahead of time',
                    icon: Icons.calendar_today,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0F172A),
                        tokens.cardColor.withOpacity(0.8),
                      ],
                    ),
                    onTap: () => Get.toNamed(Routes.calendar),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppConstants.radius16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Obx(() {
      final suggestions = dashboardController.dashboard.value?.suggestions;
      final weather = suggestions?.weatherBased;
      final outfit = suggestions?.outfitOfTheDay;
      final tokens = AppUiTokens.of(context);

      return AppGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: 'Today\'s Suggestions',
              subtitle: 'AI-curated styling ideas',
            ),
            const SizedBox(height: AppConstants.spacing12),
            if (weather == null && outfit == null)
              Text(
                'No suggestions yet. Add more outfits to unlock daily ideas.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            if (weather != null) ...[
              _buildWeatherSuggestion(weather),
              if (outfit != null) const SizedBox(height: AppConstants.spacing12),
            ],
            if (outfit != null) _buildOutfitSuggestion(outfit),
          ],
        ),
      );
    });
  }

  Widget _buildWeatherSuggestion(DashboardWeatherSuggestion weather) {
    final tokens = AppUiTokens.of(context);
    final tempLabel = weather.temperature == null
        ? 'Weather'
        : '${weather.temperature!.toStringAsFixed(1)} deg C';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        color: tokens.cardColor.withOpacity(0.65),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.brandColor.withOpacity(0.15),
            ),
            child: Icon(Icons.wb_sunny_rounded, color: tokens.brandColor),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tempLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  weather.recommendation ?? 'Style smart for the day ahead.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitSuggestion(DashboardOutfitOfTheDay outfit) {
    final tokens = AppUiTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        color: tokens.cardColor.withOpacity(0.65),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            child: Container(
              width: 64,
              height: 64,
              color: tokens.cardBorderColor.withOpacity(0.2),
              child: outfit.imageUrl == null
                  ? Icon(Icons.image, color: tokens.textMuted)
                  : CachedNetworkImage(
                      imageUrl: outfit.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: tokens.cardBorderColor.withOpacity(0.2),
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.image, color: tokens.textMuted),
                    ),
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outfit of the day',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  outfit.name ?? 'Fresh look ready',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed(Routes.outfits),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    return Obx(() {
      final activities = dashboardController.dashboard.value?.recentActivity ?? [];
      final tokens = AppUiTokens.of(context);

      return AppGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: 'Recent Activity',
              subtitle: 'Your latest style moments',
              trailing: TextButton(
                onPressed: () => Get.toNamed(Routes.outfits),
                child: const Text('See all'),
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            if (activities.isEmpty)
              Text(
                'Start adding items or outfits to see activity here.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            if (activities.isNotEmpty)
              Column(
                children: activities
                    .map((activity) => _buildActivityRow(activity))
                    .toList(),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildActivityRow(DashboardActivity activity) {
    final tokens = AppUiTokens.of(context);
    final icon = _activityIcon(activity.type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.brandColor.withOpacity(0.12),
            ),
            child: Icon(icon, size: 18, color: tokens.brandColor),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(activity.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _activityIcon(String type) {
    switch (type) {
      case 'outfit_created':
        return Icons.auto_awesome;
      case 'item_created':
      default:
        return Icons.checkroom;
    }
  }

  String _formatCount(int? value) {
    if (value == null) return '--';
    return value.toString();
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final local = timestamp.toLocal();
    return '${local.month}/${local.day}';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

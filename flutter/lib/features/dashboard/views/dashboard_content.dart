import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../app/routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/referral_promo_banner.dart';
import '../widgets/snapshot_card.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/suggestions_section.dart';
import '../widgets/activity_feed.dart';

/// Dashboard content without Scaffold wrapper (for IndexedStack in MainShellPage)
class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final DashboardController dashboardController = Get.find<DashboardController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return AppPageBackground(
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
                sliver: Obx(() {
                  // Show skeleton loaders when loading and no data
                  if (dashboardController.isLoading.value &&
                      dashboardController.dashboard.value == null) {
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        const ShimmerProfileHeader(),
                        const SizedBox(height: AppConstants.spacing16),
                        const ShimmerStatsRow(itemCount: 3),
                        const SizedBox(height: AppConstants.spacing16),
                        const ShimmerCard(height: 120),
                        const SizedBox(height: AppConstants.spacing16),
                        const ShimmerCard(height: 100),
                        const SizedBox(height: AppConstants.spacing16),
                        const ShimmerListLoader(itemCount: 3),
                      ]),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Consolidated error section
                      if (dashboardController.error.value.isNotEmpty)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildErrorBanner(),
                            const SizedBox(height: AppConstants.spacing16),
                          ],
                        ),
                      // Referral promo banner
                      _buildReferralBanner(),
                      const SnapshotCard(),
                      const SizedBox(height: AppConstants.spacing16),
                      const QuickActionsSection(),
                      const SizedBox(height: AppConstants.spacing16),
                      const SuggestionsSection(),
                      const SizedBox(height: AppConstants.spacing16),
                      const ActivityFeed(),
                    ]),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
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
                // User info wrapped in single Obx for efficiency
                Obx(() {
                  final user = authController.user.value;
                  return Text(
                    user?.fullName ?? user?.email.split('@')[0] ?? 'Welcome',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                  );
                }),
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
            // Avatar wrapped in single Obx
            child: Obx(() {
              final user = authController.user.value;
              return CircleAvatar(
                radius: 22,
                backgroundColor: tokens.brandColor.withOpacity(0.15),
                backgroundImage:
                    user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                child: user?.avatarUrl == null
                    ? Text(
                        (user?.fullName?.isNotEmpty == true
                                ? user!.fullName!.substring(0, 1).toUpperCase()
                                : null) ??
                            (user?.email?.isNotEmpty == true
                                ? user!.email.substring(0, 1).toUpperCase()
                                : null) ??
                            'U',
                        style: TextStyle(
                          color: tokens.brandColor,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    final tokens = AppUiTokens.of(context);
    // Note: This is called inside an Obx, so error.value is already reactive
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: tokens.brandColor),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Text(
              dashboardController.error.value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textSecondary,
                  ),
            ),
          ),
          TextButton(
            onPressed: () => dashboardController.fetchDashboard(showLoader: false),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralBanner() {
    if (!Get.isRegistered<SubscriptionController>()) {
      return const SizedBox.shrink();
    }

    final subController = Get.find<SubscriptionController>();
    final shouldShow = !dashboardController.referralBannerDismissed.value ||
        subController.isNearLimit;

    if (!shouldShow) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReferralPromoBanner(
          isUrgent: subController.isNearLimit,
          onDismiss: () => dashboardController.dismissReferralBanner(),
          onCopyLink: () => subController.copyReferralLink(),
          onShare: () => subController.shareReferralLink(),
        ),
        const SizedBox(height: AppConstants.spacing16),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

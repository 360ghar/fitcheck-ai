import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/config/env_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../gifts/models/gift_models.dart';
import '../../gifts/providers/gift_providers.dart';
import '../../gifts/views/widgets/gift_priority_banner.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/activity_feed.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/referral_promo_banner.dart';
import '../widgets/snapshot_card.dart';
import '../widgets/suggestions_section.dart';

/// Home tab: greeting over a paper landscape, closet totals, shortcuts and
/// today's suggestions.
class DashboardContent extends ConsumerStatefulWidget {
  const DashboardContent({super.key});

  @override
  ConsumerState<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<DashboardContent> {
  Future<void> _refresh() async {
    await Future.wait([
      ref.read(dashboardProvider.notifier).refresh(),
      if (EnvConfig.giftVouchersEnabled)
        ref.read(giftProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider);
    return AppPageBackground(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SafeArea(bottom: false, child: _header())),
            const SliverToBoxAdapter(
              child: PaperScene(preset: PaperScenes.home, height: 150),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacing16,
                AppConstants.spacing8,
                AppConstants.spacing16,
                AppConstants.spacing32,
              ),
              sliver: SliverToBoxAdapter(child: _body(dashboard)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(AsyncValue<DashboardSnapshot> dashboard) {
    const gap = SizedBox(height: AppConstants.spacing16);
    final referralDismissed =
        ref.watch(referralBannerDismissedProvider).value ?? true;
    final snapshot = dashboard.value;
    if (snapshot == null) {
      if (dashboard.hasError) {
        return AppErrorState(
          error: dashboard.error,
          onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
        );
      }
      return const SkeletonPulse(
        child: Column(
          children: [
            SkeletonBox(height: 132, borderRadius: AppConstants.radius12),
            gap,
            Row(
              children: [
                Expanded(child: SkeletonBox(height: 104)),
                SizedBox(width: AppConstants.spacing12),
                Expanded(child: SkeletonBox(height: 104)),
              ],
            ),
            gap,
            SkeletonBox(height: 120, borderRadius: AppConstants.radius12),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (dashboard.hasError) ...[
          AppErrorBanner(
            error: dashboard.error,
            onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
          ),
          const SizedBox(height: AppConstants.spacing8),
        ],
        _buildPromotionBanner(referralDismissed),
        SnapshotCard(stats: snapshot.data.statistics, streak: snapshot.streak),
        gap,
        const QuickActionsSection(),
        gap,
        SuggestionsSection(suggestions: snapshot.data.suggestions),
        if (snapshot.data.suggestions.weatherBased != null ||
            snapshot.data.suggestions.outfitOfTheDay != null)
          gap,
        ActivityFeed(activities: snapshot.data.recentActivity),
      ],
    );
  }

  Widget _header() {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final user = ref.watch(authProvider.select((s) => s.user));
    final name = user?.fullName?.split(' ').first ??
        user?.email.split('@').first;
    final initial = (name?.isNotEmpty ?? false)
        ? name!.substring(0, 1).toUpperCase()
        : null;
    final avatarUrl = user?.avatarUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing20,
        AppConstants.spacing12,
        AppConstants.spacing12,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getGreeting()}',
                  style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
                ),
                Text(
                  name ?? 'Welcome',
                  style: text.displaySmall?.copyWith(fontSize: 34),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Open profile',
            child: InkResponse(
              // Tab 4 is the profile hub: switch in place.
              onTap: () => context.go(Routes.more),
              radius: 28,
              child: CircleAvatar(
                radius: 24,
                // No disc behind a letter or icon: only a photo is framed.
                backgroundColor: avatarUrl != null && avatarUrl.isNotEmpty
                    ? tokens.stock.tint
                    : Colors.transparent,
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? ClipOval(
                        child: AppNetworkImage(
                          avatarUrl,
                          width: 48,
                          height: 48,
                          cacheWidth: 144,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => _Initial(initial),
                        ),
                      )
                    : _Initial(initial),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralBanner(bool dismissed) {
    // A week-long dismissal holds even for near-limit users, or the dismiss
    // button would be pointless for the banner's main audience. Near-limit
    // only changes the copy.
    if (dismissed) return const SizedBox.shrink();
    final nearLimit =
        ref.watch(subscriptionStatusProvider).value?.isNearLimit ?? false;
    final referral = ref.read(referralCodeProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReferralPromoBanner(
          isUrgent: nearLimit,
          onDismiss: () =>
              ref.read(referralBannerDismissedProvider.notifier).dismiss(),
          onCopyLink: referral.copyLink,
          onShare: referral.share,
        ),
        const SizedBox(height: AppConstants.spacing16),
      ],
    );
  }

  Widget _buildPromotionBanner(bool referralDismissed) {
    if (!EnvConfig.giftVouchersEnabled) {
      return _buildReferralBanner(referralDismissed);
    }

    final gift = ref.watch(giftProvider);
    // Do not briefly surface referral before the first gift lookup resolves.
    // A failed lookup falls back to referral.
    if (!gift.hasValue && !gift.hasError) return const SizedBox.shrink();
    final currentSummary = ref.watch(liveGiftSummaryProvider);

    final incoming = currentSummary?.incomingGift;
    if (incoming != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GiftPriorityBanner(
            priority: GiftDashboardPriority.incoming,
            incoming: incoming,
            incomingCount: currentSummary!.incoming.length,
            onOpen: () => context.push(
              Routes.gifts,
              extra: GiftRouteIntent.claim(incomingVoucherId: incoming.id),
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
        ],
      );
    }

    final allowance = currentSummary?.freeAllowance;
    if (allowance != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GiftPriorityBanner(
            priority: GiftDashboardPriority.complimentary,
            allowance: allowance,
            onOpen: () => context.push(
              Routes.gifts,
              extra: GiftRouteIntent.create(
                durationMonths: allowance.durationMonths,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
        ],
      );
    }

    return _buildReferralBanner(referralDismissed);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _Initial extends StatelessWidget {
  const _Initial(this.letter);

  /// Null before the profile loads: a person icon stands in.
  final String? letter;

  @override
  Widget build(BuildContext context) {
    final color = PaperTokens.of(context).stock.accent;
    final letter = this.letter;
    if (letter == null) {
      return Icon(Icons.person_outline_rounded, color: color, size: 30);
    }
    return Text(
      letter,
      style: Theme.of(
        context,
      ).textTheme.displaySmall?.copyWith(color: color, fontSize: 34),
    );
  }
}

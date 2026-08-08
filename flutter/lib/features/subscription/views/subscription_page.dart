import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/subscription_controller.dart';
import 'widgets/plan_card.dart';
import 'widgets/subscription_disclosure.dart';
import 'widgets/usage_progress.dart';
import 'widgets/referral_share_card.dart';

/// Subscription management page
class SubscriptionPage extends GetView<SubscriptionController> {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription'), elevation: 0),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.subscription.value == null) {
          return Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              children: const [
                ShimmerCard(height: 140),
                SizedBox(height: AppConstants.spacing24),
                ShimmerCard(height: 180),
                SizedBox(height: AppConstants.spacing24),
                ShimmerCard(height: 120),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchSubscription();
            await controller.fetchReferralCode();
            await controller.fetchPlans();
            await controller.fetchReferralStats();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // When the entitlement fetch failed, the plan card would
              // otherwise silently render as "Free". Surface the failure and
              // a retry instead of showing an unknown plan as a real one.
              if (controller.error.value.isNotEmpty &&
                  controller.subscription.value == null) ...[
                _buildLoadErrorCard(context, theme),
                const SizedBox(height: 24),
              ],

              // Current plan card
              _buildCurrentPlanCard(context, theme),
              const SizedBox(height: 24),

              // Usage section
              _buildUsageSection(context, theme),
              const SizedBox(height: 24),

              // Upgrade section - shown to anyone with a higher tier available
              // (Free AND Plus), not just free users, so a Plus subscriber can
              // still reach Pro.
              // Hidden when the paywall is disabled (iOS v1, Guideline 3.1.1).
              if (controller.canUpgrade && controller.showPaywall) ...[
                _buildUpgradeSection(context, theme),
                const SizedBox(height: 24),
              ],

              // Restore Purchases: required on both stores (Apple Guideline
              // 3.1.1 / Play policy), rendered for every mobile user —
              // including Pro subscribers who see no upgrade section.
              // NOT gated on showPaywall: restore is required whenever the
              // IAP plugin ships in the binary, so a PAYWALL_ENABLED=false
              // build would otherwise leave a paying user who reinstalls
              // with no way to recover their subscription.
              if (!kIsWeb) ...[
                _buildRestorePurchasesRow(),
                const SizedBox(height: 8),
              ],

              // Referral section
              _buildReferralSection(context, theme),
              const SizedBox(height: 24),

              // Cancel / manage section (paid users only). Store-billed
              // subscriptions are managed in the store's settings.
              if (controller.isPro && !controller.isCancelled)
                controller.isStoreBilled
                    ? _buildManageSection(context, theme)
                    : _buildCancelSection(context, theme),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoadErrorCard(BuildContext context, ThemeData theme) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Could not load your plan',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.error.value.replaceAll('Exception: ', ''),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: controller.fetchSubscription,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(BuildContext context, ThemeData theme) {
    final sub = controller.subscription.value;

    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                controller.isPro ? Icons.star : Icons.person,
                color: controller.isPro
                    ? Colors.amber
                    : theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Plan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                    Text(
                      controller.planName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isPro)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          if (controller.isCancelled && sub?.currentPeriodEnd != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Subscription ends on ${AppDateUtils.formatDate(sub!.currentPeriodEnd!)}',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (sub?.referralCreditMonths != null &&
              sub!.referralCreditMonths > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${sub.referralCreditMonths} month${sub.referralCreditMonths > 1 ? 's' : ''} of referral credit',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageSection(BuildContext context, ThemeData theme) {
    final usage = controller.usage.value;
    if (usage == null) return const SizedBox.shrink();

    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Usage',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          UsageProgress(
            label: 'Item Extractions',
            current: usage.monthlyExtractions,
            max: usage.monthlyExtractionsLimit,
            icon: Icons.camera_alt,
          ),
          const SizedBox(height: 16),
          UsageProgress(
            label: 'Outfit Visualizations',
            current: usage.monthlyGenerations,
            max: usage.monthlyGenerationsLimit,
            icon: Icons.auto_awesome,
          ),
          if (controller.isNearLimit && controller.canUpgrade) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.showPaywall
                          ? 'You\'re approaching your usage limit. Upgrade for more!'
                          : 'You\'re approaching your monthly limit. It resets at the start of next month.',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpgradeSection(BuildContext context, ThemeData theme) {
    // A Plus subscriber is only offered Pro; a free user sees both tiers.
    // isPro means "on a paid plan" and canUpgrade means "a higher tier
    // exists", so both together identify the middle tier.
    final onPlus = controller.isPro && controller.canUpgrade;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          onPlus ? 'Upgrade your plan' : 'Choose a plan',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          onPlus
              ? 'Same features, higher limits.'
              : 'Plus and Pro unlock the same features — pick the limits you need.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
        ),
        const SizedBox(height: 16),
        // The store rail is not serving products yet (App Store Connect /
        // Play setup incomplete — the definitive zero-products state): say so
        // above the cards instead of letting every Upgrade tap fail with a
        // snackbar. Retry self-heals without an app restart once the store is
        // ready.
        if (!kIsWeb &&
            controller.storeStatus.value != StoreStatus.ready &&
            controller.storeStatus.value != StoreStatus.unknown) ...[
          _buildStoreUnavailableBanner(context, theme),
          const SizedBox(height: 16),
        ],
        // Plus is the recommended entry point, so it renders first.
        if (!onPlus) ...[
          _buildTierRow(
            theme,
            planId: 'plus',
            label: 'Plus',
            fallbackMonthly: 10.0,
            fallbackYearly: 100.0,
            fallbackExtractions: 200,
            fallbackGenerations: 350,
            isRecommended: true,
          ),
          const SizedBox(height: 20),
        ],
        _buildTierRow(
          theme,
          planId: 'pro',
          label: 'Pro',
          fallbackMonthly: 20.0,
          fallbackYearly: 200.0,
          fallbackExtractions: 400,
          fallbackGenerations: 1000,
          isRecommended: onPlus,
        ),
        // Guideline 3.1.2: the purchase screen itself must disclose the
        // auto-renewing terms and link to the EULA and privacy policy.
        // Store rails only — web checkout goes through Stripe, where none of
        // this copy (Apple ID, store cancellation path) applies.
        if (!kIsWeb) ...[
          const SizedBox(height: 20),
          SubscriptionDisclosure(
            priceSummary: _priceSummary(includePlus: !onPlus),
            isApple: controller.iapService.isApple,
            planNames: onPlus ? 'Pro is an auto-renewing subscription'
                : 'Plus and Pro are auto-renewing subscriptions',
          ),
        ],
      ],
    );
  }

  /// Banner shown above the plan cards when the store rail cannot serve the
  /// plans ([StoreStatus.unavailable] / [StoreStatus.notConfigured]).
  ///
  /// Without it, a store that cannot resolve the products (App Store Connect
  /// / Play setup incomplete) renders a paywall whose every Upgrade tap fails
  /// with a snackbar — the "dead CTA" this page was built to eliminate.
  Widget _buildStoreUnavailableBanner(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Upgrades aren\'t available in the store yet. Check back soon.',
              style: TextStyle(color: Colors.amber.shade800, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: controller.isCheckingOut.value
                ? null
                : controller.retryStoreProducts,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Price sentence for the disclosure, preferring the localized store prices
  /// already showing on the cards so the two can never disagree.
  ///
  /// A Plus subscriber is only offered Pro, so quoting Plus prices next to a
  /// single Pro card would disclose terms for something they cannot buy here.
  String _priceSummary({required bool includePlus}) {
    String price(String planType, String fallback) =>
        controller.storePriceFor(planType) ?? fallback;
    final pro = 'Pro is ${price('pro_monthly', '\$20')}/month or '
        '${price('pro_yearly', '\$200')}/year.';
    if (!includePlus) return pro;
    return 'Plus is ${price('plus_monthly', '\$10')}/month or '
        '${price('plus_yearly', '\$100')}/year; $pro';
  }

  /// Restore Purchases button (Apple Guideline 3.1.1 / Play policy).
  ///
  /// Rendered for every mobile user — including Pro subscribers and
  /// cancelled paid users who see no upgrade section — so a reinstall or
  /// store-account change always has a recovery path.
  Widget _buildRestorePurchasesRow() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: controller.isCheckingOut.value
            ? null
            : controller.restorePurchases,
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Restore Purchases'),
      ),
    );
  }

  /// One paid tier: a monthly and a yearly card plus its limits summary.
  /// Prices come from the store product details (localized) on mobile, or
  /// the backend `/plans` response (with configured defaults as fallback)
  /// until those resolve.
  Widget _buildTierRow(
    ThemeData theme, {
    required String planId,
    required String label,
    required double fallbackMonthly,
    required double fallbackYearly,
    required int fallbackExtractions,
    required int fallbackGenerations,
    required bool isRecommended,
  }) {
    final plan = controller.plans.firstWhereOrNull((p) => p.id == planId);

    final monthlyPrice = plan?.priceMonthly ?? fallbackMonthly;
    final yearlyPrice = plan?.priceYearly ?? fallbackYearly;
    final savings = (monthlyPrice * 12 - yearlyPrice).toStringAsFixed(0);
    final extractionsLimit = plan?.monthlyExtractions ?? fallbackExtractions;
    final generationsLimit = plan?.monthlyGenerations ?? fallbackGenerations;

    // Mobile: prefer the localized store price for the exact variant.
    final monthlyPriceText =
        controller.storePriceFor('${planId}_monthly') ??
        '\$${monthlyPrice.toStringAsFixed(0)}';
    final yearlyPriceText =
        controller.storePriceFor('${planId}_yearly') ??
        '\$${yearlyPrice.toStringAsFixed(0)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRecommended) ...[
              const SizedBox(width: 8),
              Text(
                'Most popular',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: PlanCard(
                name: 'Monthly',
                price: monthlyPriceText,
                period: '/month',
                onTap: () => controller.startCheckout('${planId}_monthly'),
                isLoading: controller.isCheckingOutPlan('${planId}_monthly'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PlanCard(
                name: 'Yearly',
                price: yearlyPriceText,
                period: '/year',
                badge: 'Save \$$savings',
                onTap: () => controller.startCheckout('${planId}_yearly'),
                isLoading: controller.isCheckingOutPlan('${planId}_yearly'),
                isHighlighted: isRecommended,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$extractionsLimit extractions, $generationsLimit visualizations, virtual try-on, priority support',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralSection(BuildContext context, ThemeData theme) {
    final code = controller.referralCode.value;
    if (code == null) return const SizedBox.shrink();

    return ReferralShareCard(
      code: code.code,
      shareUrl: code.shareUrl,
      timesUsed: code.timesUsed,
      onCopy: controller.copyReferralLink,
      // Tear-off passes sharePositionOrigin from the Share button (iPad popover).
      onShare: controller.shareReferralLink,
    );
  }

  /// Store-billed subscriptions cannot be cancelled in-app (the store owns
  /// billing); point the user at the store's subscription settings.
  Widget _buildManageSection(BuildContext context, ThemeData theme) {
    final storeName = controller.iapService.isApple ? 'App Store' : 'Play Store';
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Subscription',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This subscription is billed through the $storeName. You can '
            'cancel, change, or manage it in your $storeName account settings.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: controller.openManageSubscription,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Manage in Store'),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelSection(BuildContext context, ThemeData theme) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancel Subscription',
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll retain access until the end of your billing period.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _showCancelDialog(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade300),
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Are you sure you want to cancel? You\'ll retain access until the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.cancelSubscription();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

}

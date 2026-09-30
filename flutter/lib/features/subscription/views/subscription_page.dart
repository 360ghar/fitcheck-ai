import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_ui.dart';
import '../providers/subscription_providers.dart';
import 'widgets/plan_card.dart';
import 'widgets/referral_share_card.dart';
import 'widgets/subscription_disclosure.dart';
import 'widgets/usage_progress.dart';

/// Plan, usage, upgrade options and the referral code.
class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  bool _yearly = false;
  String? _selectedTier;

  Future<void> _refresh() => Future.wait([
    ref.read(subscriptionStatusProvider.notifier).refresh(),
    ref.read(paywallProvider.notifier).loadPlans(),
    ref.read(referralCodeProvider.notifier).refresh(),
  ]);

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(subscriptionStatusProvider);
    // Watching keeps the paywall alive (and the purchase handler attached)
    // exactly as long as this page.
    final paywall = ref.watch(paywallProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;

    final Widget body;
    if (!status.hasValue) {
      body = status.hasError
          ? AppErrorState(
              error: status.error,
              onRetry: () =>
                  ref.read(subscriptionStatusProvider.notifier).refresh(),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(
                AppConstants.spacing16,
                AppConstants.spacing16,
                AppConstants.spacing16,
                AppConstants.spacing16 + bottom,
              ),
              children: const [
                SkeletonPulse(
                  child: Column(
                    children: [
                      SkeletonBox(
                        height: 120,
                        borderRadius: AppConstants.radius12,
                      ),
                      SizedBox(height: AppConstants.spacing16),
                      SkeletonBox(
                        height: 150,
                        borderRadius: AppConstants.radius12,
                      ),
                      SizedBox(height: AppConstants.spacing16),
                      SkeletonBox(
                        height: 260,
                        borderRadius: AppConstants.radius12,
                      ),
                    ],
                  ),
                ),
              ],
            );
    } else {
      final s = status.requireValue;
      const gap = SizedBox(height: AppConstants.spacing20);
      final code = ref.watch(referralCodeProvider).value;
      body = RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppConstants.spacing16,
            AppConstants.spacing8,
            AppConstants.spacing16,
            AppConstants.spacing32 + bottom,
          ),
          children: [
            if (status.hasError)
              AppErrorBanner(
                error: status.error,
                onRetry: () =>
                    ref.read(subscriptionStatusProvider.notifier).refresh(),
              ),
            const SizedBox(height: AppConstants.spacing8),
            _CurrentPlan(status: s),
            if (s.usage != null) ...[gap, _Usage(status: s)],
            // Offered to Free and Plus (a Plus subscriber can still reach
            // Pro). Hidden when the paywall is off (App Review builds).
            if (s.canUpgrade && paywallEnabled) ...[
              gap,
              _upgradeSection(s, paywall),
            ],
            // Restore is required on both stores whenever the purchase
            // plugin ships, for every user, even with the paywall off: a
            // paying user who reinstalls must be able to recover the plan.
            if (!kIsWeb) ...[
              const SizedBox(height: AppConstants.spacing8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  // Flush with the content edge; the 44pt height stays.
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(
                      right: AppConstants.spacing8,
                    ),
                  ),
                  onPressed: paywall.isRestoring || paywall.isCheckingOut
                      ? null
                      : ref.read(paywallProvider.notifier).restorePurchases,
                  icon: paywall.isRestoring
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.restore_rounded, size: 20),
                  label: const Text('Restore purchases'),
                ),
              ),
            ],
            if (code != null) ...[
              gap,
              ReferralShareCard(
                code: code.code,
                timesUsed: code.timesUsed,
                onCopy: ref.read(referralCodeProvider.notifier).copyLink,
                onShare: ref.read(referralCodeProvider.notifier).share,
              ),
            ],
            if (s.isPro && !s.isCancelled) ...[
              gap,
              s.isStoreBilled ? const _ManageInStore() : const _CancelPlan(),
            ],
          ],
        ),
      );
    }

    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(title: const Text('Subscription')),
        body: AppPageBackground(child: body),
      ),
    );
  }

  Widget _upgradeSection(SubscriptionState s, PaywallState paywall) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final notifier = ref.read(paywallProvider.notifier);
    final onPlus = s.onPlus;

    final header = [
      Text(
        onPlus ? 'Upgrade your plan' : 'Choose a plan',
        style: text.headlineSmall,
      ),
      const SizedBox(height: AppConstants.spacing4),
      Text(
        onPlus
            ? 'Same features, higher limits.'
            : 'Plus and Pro have the same features. Pick the limits you need.',
        style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
      ),
    ];

    // Web with Stripe unconfigured: checkout fails closed, so offer the path
    // that works instead of dead buttons.
    if (paywall.webBillingUnavailable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header.first,
          const SizedBox(height: AppConstants.spacing8),
          Text(
            "Online upgrades aren't available yet. A promo or referral code "
            'still unlocks Plus or Pro. Invite friends below to earn free '
            'months.',
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
        ],
      );
    }

    final options = [
      if (!onPlus)
        _option(
          paywall,
          id: 'plus',
          title: 'Plus',
          fallbackMonthly: 10,
          fallbackYearly: 100,
          fallbackExtractions: 200,
          fallbackGenerations: 350,
        ),
      _option(
        paywall,
        id: 'pro',
        title: 'Pro',
        fallbackMonthly: 20,
        fallbackYearly: 200,
        fallbackExtractions: 400,
        fallbackGenerations: 1000,
      ),
    ];
    final selected = options.firstWhere(
      (o) => o.id == _selectedTier,
      orElse: () => options.first,
    );
    final planType = '${selected.id}_${_yearly ? 'yearly' : 'monthly'}';
    final busy = paywall.isCheckingOut || paywall.isRestoring;
    // The store cannot serve the plans yet (the definitive zero-products
    // state, or no product IDs published): say so above the plans instead
    // of letting every Upgrade tap fail. Retry recovers without a restart.
    final storeDown =
        !kIsWeb &&
        (paywall.storeStatus == StoreStatus.unavailable ||
            paywall.storeStatus == StoreStatus.notConfigured);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...header,
        if (paywall.plansError != null) ...[
          const SizedBox(height: AppConstants.spacing8),
          AppErrorBanner(
            message:
                "Couldn't load the latest plans. Prices may be out of date.",
            onRetry: notifier.loadPlans,
          ),
        ],
        if (storeDown) ...[
          const SizedBox(height: AppConstants.spacing12),
          _StoreUnavailable(
            onRetry: paywall.isCheckingOut ? null : notifier.retryStoreProducts,
          ),
        ],
        const SizedBox(height: AppConstants.spacing16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Monthly')),
            ButtonSegment(value: true, label: Text('Yearly')),
          ],
          selected: {_yearly},
          showSelectedIcon: false,
          onSelectionChanged: busy
              ? null
              : (value) => setState(() => _yearly = value.first),
          style: SegmentedButton.styleFrom(
            minimumSize: const Size(0, 44),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(AppConstants.radius12),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        PlanOptions(
          options: options,
          selectedId: selected.id,
          enabled: !busy,
          onSelect: (id) => setState(() => _selectedTier = id),
        ),
        const SizedBox(height: AppConstants.spacing16),
        ElevatedButton(
          onPressed: busy || storeDown
              ? null
              : () => notifier.startCheckout(planType),
          child: paywall.isCheckingOutPlan(planType)
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Upgrade to ${selected.title}'),
        ),
        // Guideline 3.1.2: the purchase screen itself discloses the
        // auto-renewing terms and links the EULA and privacy policy. Store
        // rails only; web checkout discloses on Stripe.
        if (!kIsWeb) ...[
          const SizedBox(height: AppConstants.spacing16),
          SubscriptionDisclosure(
            priceSummary: _priceSummary(paywall, includePlus: !onPlus),
            isApple: ref.read(iapServiceProvider).isApple,
            planNames: onPlus
                ? 'Pro is an auto-renewing subscription'
                : 'Plus and Pro are auto-renewing subscriptions',
          ),
        ],
      ],
    );
  }

  PlanOption _option(
    PaywallState paywall, {
    required String id,
    required String title,
    required double fallbackMonthly,
    required double fallbackYearly,
    required int fallbackExtractions,
    required int fallbackGenerations,
  }) {
    final plan = paywall.plan(id);
    final monthly = plan?.priceMonthly ?? fallbackMonthly;
    final yearly = plan?.priceYearly ?? fallbackYearly;
    final period = _yearly ? 'yearly' : 'monthly';
    // Mobile: the localized store price for the exact variant.
    final price =
        paywall.storePriceFor('${id}_$period') ??
        '\$${(_yearly ? yearly : monthly).toStringAsFixed(0)}';

    String note;
    if (!_yearly) {
      note = 'Billed monthly';
    } else {
      // Compare in the store's currency when both store prices are known,
      // so the saving never mixes currencies.
      final m = paywall.storeProductDetails['${id}_monthly'];
      final y = paywall.storeProductDetails['${id}_yearly'];
      final (save, symbol) = m != null && y != null
          ? (m.rawPrice * 12 - y.rawPrice, y.currencySymbol)
          : (monthly * 12 - yearly, r'$');
      note = save > 0
          ? 'Save $symbol${save.toStringAsFixed(0)} a year'
          : 'Billed yearly';
    }

    return PlanOption(
      id: id,
      title: title,
      price: price,
      period: _yearly ? '/year' : '/month',
      note: note,
      features: [
        '${_count(plan?.monthlyExtractions ?? fallbackExtractions)} item extractions',
        '${_count(plan?.monthlyGenerations ?? fallbackGenerations)} outfit visualizations',
        'Virtual try-on',
        'Priority support',
      ],
    );
  }

  /// 1000 -> 1,000.
  static String _count(int n) => n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  /// Prices for the disclosure, preferring the localized store prices on
  /// the plans so the two never disagree. A Plus subscriber is offered only
  /// Pro, so Plus terms are left out for them.
  String _priceSummary(PaywallState paywall, {required bool includePlus}) {
    String price(String planType, String fallback) =>
        paywall.storePriceFor(planType) ?? fallback;
    final pro =
        'Pro is ${price('pro_monthly', r'$20')} a month or '
        '${price('pro_yearly', r'$200')} a year.';
    if (!includePlus) return pro;
    return 'Plus is ${price('plus_monthly', r'$10')} a month or '
        '${price('plus_yearly', r'$100')} a year; $pro';
  }
}

class _CurrentPlan extends StatelessWidget {
  const _CurrentPlan({required this.status});

  final SubscriptionState status;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final sub = status.subscription;
    final periodEnd = sub.currentPeriodEnd;
    final credit = sub.referralCreditMonths;

    Widget note(IconData icon, Color color, String message) => Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacing12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppConstants.spacing8),
          Expanded(child: Text(message, style: text.bodyMedium)),
        ],
      ),
    );

    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current plan',
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Text(status.planName, style: text.displaySmall)),
              if (status.isPro && !status.isCancelled) ...[
                const SizedBox(width: AppConstants.spacing12),
                // A small ink label, not a badge.
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.textPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing8,
                      vertical: 3,
                    ),
                    child: Text(
                      'Active',
                      style: text.labelMedium?.copyWith(
                        color: tokens.stock.page,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (status.isCancelled && periodEnd != null)
            note(
              Icons.event_busy_outlined,
              tokens.warning,
              'Your plan ends on ${AppDateUtils.formatDate(periodEnd)}.',
            ),
          if (credit > 0)
            note(
              Icons.card_giftcard_outlined,
              tokens.stock.accent,
              '$credit month${credit == 1 ? '' : 's'} of referral credit',
            ),
        ],
      ),
    );
  }
}

class _Usage extends StatelessWidget {
  const _Usage({required this.status});

  final SubscriptionState status;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final usage = status.usage!;
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This month', style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing16),
          UsageProgress(
            label: 'Item extractions',
            current: usage.monthlyExtractions,
            max: usage.monthlyExtractionsLimit,
            icon: Icons.photo_camera_outlined,
          ),
          const SizedBox(height: AppConstants.spacing16),
          UsageProgress(
            label: 'Outfit visualizations',
            current: usage.monthlyGenerations,
            max: usage.monthlyGenerationsLimit,
            icon: Icons.checkroom_outlined,
          ),
          if (status.isNearLimit && status.canUpgrade) ...[
            const SizedBox(height: AppConstants.spacing16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: tokens.warning,
                ),
                const SizedBox(width: AppConstants.spacing8),
                Expanded(
                  child: Text(
                    paywallEnabled
                        ? "You're close to this month's limit. Upgrade for more."
                        : "You're close to this month's limit. It resets at "
                              'the start of next month.',
                    style: text.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StoreUnavailable extends StatelessWidget {
  const _StoreUnavailable({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return PaperSurface(
      lift: 0,
      grain: false,
      color: tokens.stock.tint,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing12,
        AppConstants.spacing4,
        AppConstants.spacing4,
        AppConstants.spacing4,
      ),
      child: Row(
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 20,
            color: tokens.textSecondary,
          ),
          const SizedBox(width: AppConstants.spacing8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacing8,
              ),
              child: Text(
                "Upgrades aren't available in the store yet. Check back soon.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Store-billed plans are changed and cancelled in the store.
class _ManageInStore extends ConsumerWidget {
  const _ManageInStore();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final store = ref.read(iapServiceProvider).isApple
        ? 'App Store'
        : 'Play Store';
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manage your plan', style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'This plan is billed through the $store. Change or cancel it in '
            'your $store account settings.',
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacing8),
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(right: AppConstants.spacing8),
            ),
            onPressed: () =>
                ref.read(subscriptionStatusProvider.notifier).openManage(),
            icon: const Icon(Icons.open_in_new_rounded, size: 20),
            label: Text('Manage in the $store'),
          ),
        ],
      ),
    );
  }
}

class _CancelPlan extends ConsumerWidget {
  const _CancelPlan();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cancel subscription', style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'You keep access until the end of this billing period.',
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacing8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: tokens.error,
              padding: const EdgeInsets.only(right: AppConstants.spacing8),
            ),
            onPressed: () => _confirm(context, ref),
            child: const Text('Cancel subscription'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final tokens = PaperTokens.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel your subscription?'),
        content: const Text(
          'You keep access until the end of this billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep plan'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: tokens.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel plan'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(subscriptionStatusProvider.notifier).cancel();
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/subscription_model.dart';
import '../providers/subscription_providers.dart';
import '../services/trial_eligibility.dart';
import 'widgets/plan_card.dart';
import 'widgets/referral_share_card.dart';
import 'widgets/subscription_disclosure.dart';
import 'widgets/trial_spotlight.dart';
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
    final l10n = context.l10n;
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
            // The offer leads. Everything below it (current plan, usage) is
            // management; the free month is the reason this screen is open,
            // and App Review's 3.1.2 disclosure has to be reachable without
            // scrolling, so it cannot sit under two cards.
            if (s.canUpgrade && paywallEnabled) ...[
              _upgradeSection(s, paywall),
              gap,
            ],
            _CurrentPlan(status: s),
            if (s.usage != null) ...[gap, _Usage(status: s)],
            // Restore is required on both stores whenever the purchase
            // plugin ships, for every user, even with the paywall off: a
            // paying user who reinstalls must be able to recover the plan.
            if (!kIsWeb) ...[
              const SizedBox(height: AppConstants.spacing8),
              Align(
                alignment: AlignmentDirectional.centerStart,
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
                  label: Text(l10n.paywallRestore),
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
        appBar: AppBar(title: Text(l10n.billingTitle)),
        body: AppPageBackground(child: body),
      ),
    );
  }

  Widget _upgradeSection(SubscriptionState s, PaywallState paywall) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final notifier = ref.read(paywallProvider.notifier);
    final onPlus = s.onPlus;

    final header = [
      Text(
        onPlus ? l10n.billingUpgradeHeading : l10n.paywallTitle,
        style: text.headlineSmall,
      ),
      const SizedBox(height: AppConstants.spacing4),
      Text(
        onPlus ? l10n.billingUpgradeOnPlusBody : l10n.billingUpgradeBody,
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
            l10n.billingWebUnavailableBody,
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
        ],
      );
    }

    // The free month is an App Store introductory offer on Pro Monthly.
    // Only StoreKit 2 can say whether this user still has it. Android, the
    // web, and a failed probe all answer `unknown`, which renders the honest
    // non-trial copy: never promise a free month to someone who is about to
    // be charged.
    final trialProductId =
        paywall.storeProducts.productIdFor(
          ref.read(iapServiceProvider).storeName,
          'pro_monthly',
        ) ??
        kProMonthlyProductId;
    final eligibility =
        ref.watch(trialEligibilityProvider(trialProductId)).value ??
        TrialEligibility.unknown;
    final canPromiseFreeMonth = eligibility.canPromiseFreeMonth;

    // Pro Monthly is:
    //  - the price that begins after the trial, and
    //  - the only variant the trial exists on.
    // Prefer the localized store price; fall back to the /plans price.
    final proMonthlyPrice =
        paywall.storePriceFor('pro_monthly') ??
        paywall.storeProductDetails['pro_monthly']?.price ??
        paywall.plan('pro')?.priceMonthly.toString() ??
        r'$20';

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
    // Default to the variant that carries the free month, so a new user who
    // taps the CTA without touching the picker gets what the headline
    // promised. A Plus subscriber can only reach Pro anyway.
    final trialAvailable = canPromiseFreeMonth && !s.isPro;
    final defaultId = trialAvailable && !onPlus ? 'pro' : options.first.id;
    final selected = options.firstWhere(
      (o) => o.id == _selectedTier,
      orElse: () => options.firstWhere(
        (o) => o.id == defaultId,
        orElse: () => options.first,
      ),
    );
    final planType = '${selected.id}_${_yearly ? 'yearly' : 'monthly'}';
    // The trial is one month of Pro. It is not on Plus, not on yearly, and a
    // user who already pays is not a new subscriber (StoreKit would answer
    // ineligible anyway, but never depend on that for copy that promises a
    // free month). The trial copy disappears the moment any of those stops
    // being true, rather than misleading the user into the wrong product.
    final trialHeads = trialAvailable && selected.id == 'pro' && !_yearly;
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
        if (trialHeads) ...[
          TrialSpotlight(priceAfterTrial: proMonthlyPrice),
          const SizedBox(height: AppConstants.spacing12),
        ] else ...[
          ...header,
          if (!kIsWeb && !canPromiseFreeMonth) ...[
            const SizedBox(height: AppConstants.spacing8),
            TrialIneligibleNote(price: proMonthlyPrice),
          ],
          const SizedBox(height: AppConstants.spacing12),
        ],
        // The permanent free tier is the retention story, so it sits with the
        // offer rather than under the plan cards in small print. Hidden from a
        // paying subscriber: for them it would read as a downgrade pitch.
        if (!s.isPro) ...[
          FreeForeverCard(
            monthlyUploads: paywall.plan('free')?.monthlyExtractions ?? 50,
            monthlyOutfits: paywall.plan('free')?.monthlyGenerations ?? 50,
            dailyPhotoshootImages: kFreeDailyPhotoshootImages,
          ),
          const SizedBox(height: AppConstants.spacing20),
        ],
        if (paywall.plansError != null) ...[
          const SizedBox(height: AppConstants.spacing8),
          AppErrorBanner(
            message: l10n.billingPlansStale,
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
          segments: [
            ButtonSegment(value: false, label: Text(l10n.billingMonthly)),
            ButtonSegment(value: true, label: Text(l10n.billingYearly)),
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
              // "Start my free month" only when the free month is the offer
              // actually being bought: Pro Monthly, on iOS, from an
              // eligible user.
              : Text(
                  trialHeads && !storeDown
                      ? l10n.paywallCtaTrial
                      : l10n.paywallCtaUpgrade(selected.title),
                ),
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
                ? l10n.billingDisclosureProRenewing
                : l10n.billingDisclosureBothRenewing,
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
      note = context.l10n.billingBilledMonthly;
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
          : context.l10n.billingBilledYearly;
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
        context.l10n.billingVirtualTryOn,
        context.l10n.billingPrioritySupport,
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
    final l10n = context.l10n;
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
            l10n.billingCurrentPlan,
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
                      l10n.billingActive,
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
    final l10n = context.l10n;
    final usage = status.usage!;
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.billingThisMonth, style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing16),
          UsageProgress(
            label: l10n.billingItemExtractions,
            current: usage.monthlyExtractions,
            max: usage.monthlyExtractionsLimit,
            icon: Icons.photo_camera_outlined,
          ),
          const SizedBox(height: AppConstants.spacing16),
          UsageProgress(
            label: l10n.billingOutfitVisualizations,
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
                        ? l10n.billingNearLimitUpgrade
                        : l10n.billingNearLimitResets,
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
      padding: const EdgeInsetsDirectional.only(
        start: AppConstants.spacing12,
        top: AppConstants.spacing4,
        end: AppConstants.spacing4,
        bottom: AppConstants.spacing4,
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
                context.l10n.billingStoreUnavailable,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(context.l10n.actionRetry),
          ),
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
          Text(context.l10n.billingManageHeading, style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            context.l10n.billingBilledThroughStore(store),
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacing8),
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsetsDirectional.only(
                end: AppConstants.spacing8,
              ),
            ),
            onPressed: () =>
                ref.read(subscriptionStatusProvider.notifier).openManage(),
            icon: const Icon(Icons.open_in_new_rounded, size: 20),
            label: Text(context.l10n.billingManageInStore(store)),
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
    final l10n = context.l10n;
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.billingCancelPlan, style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            l10n.billingCancelKeepsAccess,
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacing8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: tokens.error,
              padding: const EdgeInsetsDirectional.only(
                end: AppConstants.spacing8,
              ),
            ),
            onPressed: () => _confirm(context, ref),
            child: Text(l10n.billingCancelPlan),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final tokens = PaperTokens.of(context);
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.billingCancelConfirmTitle),
        content: Text(l10n.billingCancelKeepsAccess),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.billingKeepPlan),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: tokens.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.billingCancelPlanAction),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(subscriptionStatusProvider.notifier).cancel();
    }
  }
}

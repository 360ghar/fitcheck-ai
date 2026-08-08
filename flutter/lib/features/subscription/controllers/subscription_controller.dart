import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/env_config.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/error_handler.dart';
import '../models/subscription_model.dart';
import '../repositories/subscription_repository.dart';
import '../services/iap_service.dart';
import '../../../core/utils/frame_safe.dart';

/// Whether the store rail is serving products right now.
///
/// Drives the paywall banner and fail-fast checkout so a store that cannot
/// resolve the plan products (App Store Connect / Play setup incomplete, or a
/// transient failure) is never presented as ready with dead Upgrade buttons.
enum StoreStatus {
  /// No store query has completed yet (page still loading).
  unknown,
  /// The store resolved the plan's products (localized prices available).
  ready,
  /// The backend published no store product IDs for this rail.
  notConfigured,
  /// The store query failed, or the store answered with zero products.
  unavailable,
}

/// Controller for subscription and referral state.
///
/// Purchase routing (App Store Guideline 3.1.1 compliance):
/// - iOS / Android: purchases go through the store (StoreKit / Play Billing)
///   and are verified by the backend. Stripe checkout is NEVER opened from a
///   mobile build.
/// - Web: Stripe checkout remains the purchase rail.
class SubscriptionController extends GetxController {
  SubscriptionController({
    IapService? iapService,
    SubscriptionRepository? repository,
    String? Function()? currentUserId,
  })  : iapService = iapService ?? IapService(),
        _repository = repository ?? SubscriptionRepository(),
        _currentUserId = currentUserId ?? _defaultCurrentUserId;

  final SubscriptionRepository _repository;
  final IapService iapService;

  /// The signed-in user's ID, attached to store purchases as Apple's
  /// appAccountToken. Injectable so tests need no Supabase session.
  final String? Function() _currentUserId;

  /// Resolves the user ID without assuming SupabaseService is registered —
  /// widget tests build this controller with no app bindings at all, and a
  /// missing session must degrade to "no token", never throw mid-purchase.
  static String? _defaultCurrentUserId() {
    try {
      if (!Get.isRegistered<SupabaseService>()) return null;
      return Get.find<SupabaseService>().currentUserId;
    } catch (_) {
      return null;
    }
  }

  // Observable state
  final Rx<SubscriptionModel?> subscription = Rx<SubscriptionModel?>(null);
  final Rx<UsageLimitsModel?> usage = Rx<UsageLimitsModel?>(null);
  final Rx<ReferralCodeModel?> referralCode = Rx<ReferralCodeModel?>(null);
  final Rx<ReferralStatsModel?> referralStats = Rx<ReferralStatsModel?>(null);
  final RxList<PlanDetailsModel> plans = <PlanDetailsModel>[].obs;
  final Rx<StoreProductsModel> storeProducts = Rx<StoreProductsModel>(StoreProductsModel());
  /// Whether the store rail is currently serving products (see [StoreStatus]).
  /// Set by [refreshStoreProducts]; the paywall banner and fail-fast checkout
  /// read it so a store that cannot serve the plans is never presented as
  /// ready.
  final Rx<StoreStatus> storeStatus = Rx<StoreStatus>(StoreStatus.unknown);
  /// Store product details (localized prices) keyed by plan type
  /// (e.g. `plus_monthly`). `refreshStoreProducts` populates this on page
  /// load and `_startStorePurchase` reads it cache-first at checkout.
  final RxMap<String, ProductDetails> storeProductDetails = <String, ProductDetails>{}.obs;
  /// Product IDs the store answered for but did not recognize. Non-empty means
  /// a store-side setup problem (product missing in App Store Connect / Play,
  /// agreements unsigned, wrong bundle namespace) — the paywall would
  /// otherwise just render without prices and say nothing.
  final RxList<String> missingStoreProductIds = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCheckingOut = false.obs;
  /// The plan variant currently launching a store checkout ('' when none).
  /// Drives the per-card loading state so only the tapped plan card spins
  /// instead of every card in the tier.
  final RxString checkingOutPlanType = ''.obs;
  final RxBool isLoadingReferral = false.obs;
  final RxString error = ''.obs;
  final RxString referralError = ''.obs;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  // Computed properties
  bool get isPro {
    final plan = subscription.value?.planType;
    // An unknown plan (fetch failed / still pending) must not be treated as
    // paid, or the page would show pricing and a "Cancel subscription"
    // section for a user whose entitlement is unknown.
    return plan != null && plan != PlanType.free;
  }
  bool get isCancelled => subscription.value?.cancelAtPeriodEnd ?? false;

  /// Whether this subscription is billed through a store (App Store or Play)
  /// rather than Stripe web checkout. Store-billed subscriptions are managed
  /// in the store's subscription settings, not in-app.
  bool get isStoreBilled {
    final provider = subscription.value?.billingProvider;
    return provider == 'apple' || provider == 'google';
  }

  /// Whether a higher tier exists to upsell (Free and Plus users).
  ///
  /// Distinct from [isPro]: a Plus subscriber is entitled to every paid
  /// feature but can still move up to Pro, so an upgrade CTA gated on
  /// `!isPro` would leave them with no way to do it.
  bool get canUpgrade {
    final plan = subscription.value?.planType;
    if (plan == null) return false; // entitlement unknown (fetch failed / pending)
    return plan != PlanType.proMonthly && plan != PlanType.proYearly;
  }

  /// Whether monetization CTAs (paywall, purchase flow) may render.
  /// OFF only when the build is compiled with PAYWALL_ENABLED=false
  /// (e.g. App Review builds that must not surface monetization).
  bool get showPaywall => EnvConfig.paywallEnabled;

  String get planName {
    switch (subscription.value?.planType) {
      case PlanType.plusMonthly:
        return 'Plus Monthly';
      case PlanType.plusYearly:
        return 'Plus Yearly';
      case PlanType.proMonthly:
        return 'Pro Monthly';
      case PlanType.proYearly:
        return 'Pro Yearly';
      case PlanType.free:
      default:
        return 'Free';
    }
  }

  double get extractionsPercentage {
    final u = usage.value;
    if (u == null || u.monthlyExtractionsLimit == 0) return 0;
    return (u.monthlyExtractions / u.monthlyExtractionsLimit).clamp(0.0, 1.0);
  }

  double get generationsPercentage {
    final u = usage.value;
    if (u == null || u.monthlyGenerationsLimit == 0) return 0;
    return (u.monthlyGenerations / u.monthlyGenerationsLimit).clamp(0.0, 1.0);
  }

  bool get isNearLimit =>
      extractionsPercentage > 0.8 || generationsPercentage > 0.8;

  /// Localized store price for a plan type ("plus_monthly", ...), or null
  /// when the store product details have not loaded yet.
  String? storePriceFor(String planType) => storeProductDetails[planType]?.price;

  /// Whether a checkout is in flight for exactly [planType]; drives the
  /// per-card loading state so only the tapped card shows a spinner.
  bool isCheckingOutPlan(String planType) =>
      checkingOutPlanType.value == planType;

  @override
  void onInit() {
    super.onInit();
    attachPurchaseListener();
    fetchSubscription();
    fetchReferralCode();
    fetchReferralStats();
    fetchPlans();
  }

  /// Start listening for store-purchase results.
  ///
  /// Idempotent and public so tests can attach the listener without running
  /// the full onInit data fetch.
  void attachPurchaseListener() {
    if (_purchaseSubscription != null) return;
    // Store-purchase results (purchased / pending / restored / error) arrive
    // on this stream after buyNonConsumable / restorePurchases.
    _purchaseSubscription = iapService.purchaseStream.listen(
      (updates) {
        for (final details in updates) {
          _handlePurchaseUpdate(details);
        }
      },
    );
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    super.onClose();
  }

  /// Fetch subscription and usage data
  Future<void> fetchSubscription() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    isLoading.value = true;
    error.value = '';
    try {
      final data = await _repository.getSubscription();
      subscription.value = data.subscription;
      usage.value = data.usage;
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch usage only
  Future<void> fetchUsage() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      usage.value = await _repository.getUsage();
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    }
  }

  /// Fetch available plans + store product IDs
  Future<void> fetchPlans() async {
    try {
      final result = await _repository.getPlans();
      plans.assignAll(result.plans);
      storeProducts.value = result.storeProducts;
      // Kick off the store product query for localized prices (mobile only).
      unawaited(refreshStoreProducts());
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    }
  }

  /// Query the store for product details (localized prices) of all variants.
  ///
  /// Also derives [storeStatus]: the single source of truth for whether the
  /// store rail is ready. Only the definitive zero-products failure
  /// (`storekit_no_response`, or a success with zero products) is
  /// [StoreStatus.unavailable] — that state persists until the store side is
  /// fixed, so the paywall says so instead of letting every Upgrade tap fail.
  /// Other failures (transient network / store server errors) leave the
  /// status [StoreStatus.unknown] so the checkout path can retry on its own.
  Future<void> refreshStoreProducts() async {
    if (!iapService.isStoreBillingAvailable) return;
    try {
      const planTypes = [
        'plus_monthly', 'plus_yearly', 'pro_monthly', 'pro_yearly',
      ];
      final ids = <String>{};
      // Reverse lookup from store product ID back to plan type so the map
      // is keyed by plan type (what storePriceFor / the UI asks for), not
      // by the store's product ID (e.g. "com.fitcheckaiapp...plus.monthly").
      final planTypeById = <String, String>{};
      for (final planType in planTypes) {
        final id = storeProducts.value.productIdFor(
          iapService.storeName,
          planType,
        );
        if (id != null) {
          ids.add(id);
          planTypeById[id] = planType;
        }
      }
      if (ids.isEmpty) {
        // The backend published no store product IDs: the rail is not wired
        // up (fail-closed by design — see config_health.py's contract).
        storeStatus.value = StoreStatus.notConfigured;
        return;
      }
      final query = await iapService.fetchProducts(ids);
      storeProductDetails
        ..clear()
        ..addEntries(
          query.products.map((d) => MapEntry(planTypeById[d.id] ?? d.id, d)),
        );
      missingStoreProductIds.assignAll(query.notFoundIds);
      // Zero products resolved: the store answered and does not serve this
      // rail yet (products not created / still under review / agreements
      // unsigned). That is persistent until the store side is fixed — never
      // advertise upgrades as ready in this state.
      storeStatus.value = query.products.isEmpty
          ? StoreStatus.unavailable
          : StoreStatus.ready;
      if (query.notFoundIds.isNotEmpty) {
        // The store answered successfully and did not recognize these IDs.
        // Silently ignoring it renders a paywall with no prices and no
        // explanation, which is the single most common sandbox / App Review
        // setup failure (product not created, agreements unsigned, wrong
        // bundle namespace). Report it; the user still sees /plans prices.
        ErrorHandler.reportError(
          StateError(
            'Store did not recognize product IDs: '
            '${query.notFoundIds.join(', ')}',
          ),
          'Store product IDs not found (${iapService.storeName})',
        );
      }
    } catch (e, stackTrace) {
      // Prices fall back to the /plans response; a failed store query must
      // not block the page. Only the definitive zero-products failure
      // (`storekit_no_response` — the store answered and resolved none of
      // the IDs) marks the rail unavailable, because that state persists
      // until the store side is fixed: the banner shows and checkout fails
      // fast with the accurate message. Any other failure (transient
      // network / App Store server error) leaves the status unknown so a
      // later Upgrade tap re-queries with its own retries and gets the
      // accurate "couldn't be reached" message instead of a misleading
      // "not available yet" banner. An already-unavailable rail stays
      // unavailable across a transient retry — the underlying state
      // (products not served) has not changed.
      final wasDefinitivelyUnavailable =
          storeStatus.value == StoreStatus.unavailable;
      storeStatus.value =
          (e is IapException && e.errorCode == 'storekit_no_response') ||
                  wasDefinitivelyUnavailable
              ? StoreStatus.unavailable
              : StoreStatus.unknown;
      ErrorHandler.reportError(e, 'Store product query failed', stackTrace: stackTrace);
    }
  }

  /// Re-query the store from the paywall banner.
  ///
  /// Self-heals without an app restart once the store starts serving the
  /// products (e.g. the App Store Connect setup completes while the app stays
  /// open): prices appear and Upgrade taps work again.
  Future<void> retryStoreProducts() async {
    await refreshStoreProducts();
    if (storeStatus.value == StoreStatus.ready) {
      ErrorHandler.showSuccess(
        'Store prices are now available. You can upgrade.',
        title: 'Store ready',
      );
    }
  }

  /// Fetch referral code (API always creates one if missing)
  Future<void> fetchReferralCode() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    isLoadingReferral.value = true;
    referralError.value = '';
    try {
      referralCode.value = await _repository.getReferralCode();
    } catch (e, stackTrace) {
      referralError.value = ErrorHandler.extractMessage(e);
      // Auth race (401 before token ready) is common on cold start — surface for retry
      ErrorHandler.reportError(e, referralError.value, stackTrace: stackTrace);
    } finally {
      isLoadingReferral.value = false;
    }
  }

  /// Fetch referral stats
  Future<void> fetchReferralStats() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      referralStats.value = await _repository.getReferralStats();
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
    }
  }

  // =========================================================================
  // Purchasing
  // =========================================================================

  /// Start checkout for a plan type ("plus_monthly", "pro_yearly", ...).
  ///
  /// Mobile: store purchase via StoreKit / Play Billing (the backend
  /// verifies the transaction before granting entitlement).
  /// Web: Stripe checkout (unchanged).
  Future<void> startCheckout(String planType) async {
    // Hard guard: never surface a purchase flow when the paywall is disabled
    // (e.g. App Review builds). Prevents a stray call during review.
    if (!showPaywall) return;
    // Re-entry guard: a checkout is already in flight (per-card loading via
    // checkingOutPlanType still shows which plan is spinning); ignore taps on
    // other cards so two store flows can never launch concurrently.
    if (isCheckingOut.value) return;
    isCheckingOut.value = true;
    checkingOutPlanType.value = planType;
    error.value = '';
    try {
      if (kIsWeb) {
        await _startStripeCheckout(planType);
      } else {
        await _startStorePurchase(planType);
      }
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      // Unexpected failure: report AND surface it. Checkout failures used to
      // only set [error], which this page renders nowhere when the
      // subscription loaded, so a failed purchase looked like a dead button.
      // Pass the exception (not [error.value]) so Sentry captures the real
      // object — e.g. `IapException.details` keeps the raw store
      // (`storekit_no_response`) payload — while the user sees only
      // [extractMessage]'s friendly text either way.
      ErrorHandler.showError(
        e,
        title: 'Purchase failed',
        stackTrace: stackTrace,
      );
    } finally {
      isCheckingOut.value = false;
      checkingOutPlanType.value = '';
    }
  }

  Future<void> _startStorePurchase(String planType) async {
    if (!iapService.isStoreBillingAvailable) {
      error.value = 'In-app purchases are not available on this device.';
      ErrorHandler.showValidation(error.value, title: 'Purchase unavailable');
      return;
    }
    final productId = storeProducts.value.productIdFor(
      iapService.storeName,
      planType,
    );
    if (productId == null) {
      error.value = 'This plan is not available for purchase yet.';
      ErrorHandler.showValidation(error.value, title: 'Purchase unavailable');
      return;
    }
    if (storeStatus.value == StoreStatus.unavailable) {
      // The page-load store query already failed (or the store answered with
      // zero products) this session; re-querying here can only repeat the
      // same failure after its retry delay. Fail fast with the accurate
      // message — the paywall banner's Retry is the recovery path.
      error.value = kPlanNotAvailableInStoreMessage;
      ErrorHandler.showValidation(error.value, title: 'Purchase unavailable');
      return;
    }
    // Prefer the page-load cache: `refreshStoreProducts` already resolved and
    // cached ProductDetails for this plan type, so a transient storekit error
    // at checkout can no longer hard-fail when valid details are on hand.
    // Only query the store on a cache miss. StoreKit re-resolves the live
    // localized price at the native purchase sheet, so the cached details are
    // safe to buy with.
    ProductDetails? product = storeProductDetails[planType];
    if (product == null) {
      final query = await iapService.fetchProducts({productId});
      if (query.isEmpty) {
        error.value = 'This plan is not available in the store yet.';
        ErrorHandler.showValidation(error.value, title: 'Purchase unavailable');
        return;
      }
      product = query.products.first;
    }
    final started = await iapService.startPurchase(
      product,
      appAccountToken: _currentUserId(),
    );
    if (!started) {
      error.value = 'The purchase could not be started. Please try again.';
      ErrorHandler.showValidation(error.value, title: 'Purchase unavailable');
    }
    // The purchase result arrives on the purchase stream.
  }

  Future<void> _startStripeCheckout(String planType) async {
    final session = await _repository.createCheckoutSession(
      planType: planType,
    );
    if (session.updated) {
      // Paid-plan changes are applied directly to the existing Stripe
      // subscription. Refresh local entitlements instead of opening a
      // checkout URL that the backend deliberately did not return.
      await fetchSubscription();
      return;
    }
    final checkoutUrl = session.checkoutUrl;
    if (checkoutUrl == null || checkoutUrl.isEmpty) {
      error.value = 'Checkout did not return a payment link';
      ErrorHandler.showValidation(error.value, title: 'Purchase unavailable');
      return;
    }
    final url = Uri.parse(checkoutUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      error.value = 'Could not open checkout page';
      ErrorHandler.showValidation(error.value, title: 'Purchase unavailable');
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails details) async {
    switch (details.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _registerStorePurchase(
          details,
          restored: details.status == PurchaseStatus.restored,
        );
      case PurchaseStatus.pending:
        // Ask to Buy / parental approval. The user has not been charged yet.
        ErrorHandler.showSuccess(
          'Your purchase is pending approval. You\'ll get access as soon as it\'s approved.',
          title: 'Purchase pending',
        );
      case PurchaseStatus.error:
        // The plugin's error message is a raw platform string (e.g. an
        // "IAPError(code: ..., message: ...)" dump) that must never reach
        // the user. Surface a stable friendly message and keep the raw
        // error flowing to Sentry via the IapException details.
        error.value = 'The purchase failed. Please try again.';
        ErrorHandler.showError(
          IapException(
            message: error.value,
            errorCode: details.error?.code,
            details: details.error?.toString(),
          ),
          title: 'Purchase failed',
        );
      case PurchaseStatus.canceled:
        break; // User dismissed the sheet; nothing to do.
    }
  }

  Future<void> _registerStorePurchase(
    PurchaseDetails details, {
    required bool restored,
  }) async {
    final transactionId = iapService.transactionIdFor(details);
    if (transactionId == null || transactionId.isEmpty) {
      error.value = 'The purchase did not include a verifiable transaction ID.';
      ErrorHandler.showError(error.value, title: 'Purchase error');
      return;
    }
    try {
      final sub = await _repository.registerIapTransaction(
        store: iapService.storeName,
        transactionId: transactionId,
        productId: details.productID,
      );
      subscription.value = sub;
      // Only complete (deliver) the purchase after the backend verified it;
      // otherwise the store would consider it delivered despite no
      // entitlement.
      await iapService.complete(details);
      await fetchUsage();
      ErrorHandler.showSuccess(
        restored
            ? 'Your purchases have been restored.'
            : 'Your subscription is active. Welcome!',
        title: restored ? 'Restored' : 'Subscription active',
      );
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
      // Do NOT complete the purchase: the store keeps it pending and
      // redelivers it (or the backend webhook reconciles it server-side).
      ErrorHandler.showError(
        'We couldn\'t verify your purchase with the store right now. '
        'It will be picked up automatically; you won\'t be charged twice.',
        title: 'Verification pending',
      );
    }
  }

  /// Restore purchases from the store (App Store / Play settings change or
  /// reinstall). Restored transactions arrive on the purchase stream.
  Future<void> restorePurchases() async {
    if (!iapService.isStoreBillingAvailable) return;
    isCheckingOut.value = true;
    error.value = '';
    try {
      await iapService.restorePurchases();
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
      ErrorHandler.showError('Could not restore purchases.', title: 'Restore failed');
    } finally {
      isCheckingOut.value = false;
    }
  }

  /// Open the platform's subscription management surface.
  ///
  /// iOS: App Store subscriptions settings; Android: Play Store
  /// subscriptions; web: Stripe billing portal.
  Future<void> openManageSubscription() async {
    if (kIsWeb) {
      try {
        final portalUrl = await _repository.createPortalSession();
        if (portalUrl.isEmpty) {
          error.value = 'Could not open billing management.';
          ErrorHandler.showValidation(error.value, title: 'Could not open');
          return;
        }
        await _launchUrl(Uri.parse(portalUrl));
      } catch (e, stackTrace) {
        error.value = ErrorHandler.extractMessage(e);
        ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
      }
      return;
    }
    final url = iapService.isApple
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse('https://play.google.com/store/account/subscriptions');
    await _launchUrl(url);
  }

  Future<void> _launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      error.value = 'Could not open the link.';
      // Same silent-dead-button class as checkout: surface instead of
      // leaving the tap looking like it did nothing (e.g. simulator
      // without the App Store / Play Store).
      ErrorHandler.showValidation(error.value, title: 'Could not open');
    }
  }

  /// Cancel subscription (Stripe-billed rows only; store-billed
  /// subscriptions are managed in the store).
  Future<void> cancelSubscription() async {
    if (isStoreBilled) {
      ErrorHandler.showError(
        'This subscription is billed through the store. Manage it in your store account settings.',
        title: 'Manage in store',
      );
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      await _repository.cancelSubscription();
      await fetchSubscription();
      ErrorHandler.showSuccess('Subscription cancelled. You\'ll retain access until period end.', title: 'Success');
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
      ErrorHandler.showError('Failed to cancel subscription', title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }

  /// Copy referral link to clipboard
  Future<void> copyReferralLink() async {
    if (referralCode.value == null) {
      await fetchReferralCode();
    }
    final code = referralCode.value;
    if (code == null) {
      ErrorHandler.showError(referralError.value.isNotEmpty
            ? referralError.value
            : 'Could not load your referral link. Try again.', title: 'Error');
      return;
    }
    await Clipboard.setData(ClipboardData(text: code.shareUrl));
    ErrorHandler.showSuccess('Referral link copied to clipboard', title: 'Copied');
  }

  /// Share referral link via the platform share sheet.
  /// [sharePositionOrigin] is required on iPad for the popover.
  Future<void> shareReferralLink({Rect? sharePositionOrigin}) async {
    if (referralCode.value == null) {
      await fetchReferralCode();
    }
    final code = referralCode.value;
    if (code == null) {
      ErrorHandler.showError(referralError.value.isNotEmpty
            ? referralError.value
            : 'Could not load your referral link. Try again.', title: 'Error');
      return;
    }
    try {
      await Share.share(
        'Join FitCheck AI and get 1 month of Pro free! ${code.shareUrl}',
        subject: 'Try FitCheck AI',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      // Fall back to clipboard so the user still gets a working path
      try {
        await Clipboard.setData(ClipboardData(text: code.shareUrl));
        ErrorHandler.showError('Share sheet failed — link copied to clipboard instead.', title: 'Link copied');
      } catch (_) {
        ErrorHandler.showValidation('Please copy the link instead.', title: 'Share failed');
      }
    }
  }
}

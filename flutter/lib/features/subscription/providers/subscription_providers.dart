import '../../../core/providers.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/env_config.dart';
import '../../../core/utils/error_handler.dart';
import '../models/subscription_model.dart';
import '../repositories/subscription_repository.dart';
import '../services/iap_service.dart';
import '../services/purchase_recovery_service.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepository(),
);

/// The app-lifetime purchase service. `main` reads it at app start, so it
/// owns the store stream and drains unfinished purchases with no page open.
final purchaseRecoveryServiceProvider = Provider<PurchaseRecoveryService>((
  ref,
) {
  final service = PurchaseRecoveryService(
    repository: ref.read(subscriptionRepositoryProvider),
  )..start();
  ref.onDispose(service.dispose);
  return service;
});

/// The store wrapper the recovery service verifies with.
final iapServiceProvider = Provider<IapService>(
  (ref) => ref.watch(purchaseRecoveryServiceProvider).iapService,
);

/// Whether monetization (paywall, purchase flow) may render. Off only in
/// builds compiled with PAYWALL_ENABLED=false (App Review builds).
bool get paywallEnabled => EnvConfig.paywallEnabled;

// ---------------------------------------------------------------------------
// Subscription status (plan + usage)
// ---------------------------------------------------------------------------

/// The signed-in user's plan and usage.
@immutable
class SubscriptionState {
  const SubscriptionState({required this.subscription, this.usage});

  final SubscriptionModel subscription;
  final UsageLimitsModel? usage;

  PlanType get planType => subscription.planType;

  /// On a paid plan (Plus or Pro). Entitlement follows the plan type, which
  /// the backend serves as free for refunded rows.
  bool get isPro => planType != PlanType.free;

  bool get isCancelled => subscription.cancelAtPeriodEnd;

  /// Billed through the App Store or Play, so managed in the store.
  bool get isStoreBilled =>
      subscription.billingProvider == 'apple' ||
      subscription.billingProvider == 'google';

  /// A higher tier exists (Free and Plus). A Plus subscriber is paid
  /// ([isPro]) and can still move up to Pro.
  bool get canUpgrade =>
      planType != PlanType.proMonthly && planType != PlanType.proYearly;

  /// Plus with a higher tier left: the only tier offered is Pro.
  bool get onPlus => isPro && canUpgrade;

  String get planName => switch (planType) {
    PlanType.plusMonthly => 'Plus monthly',
    PlanType.plusYearly => 'Plus yearly',
    PlanType.proMonthly => 'Pro monthly',
    PlanType.proYearly => 'Pro yearly',
    PlanType.free => 'Free',
  };

  double get extractionsShare {
    final u = usage;
    if (u == null || u.monthlyExtractionsLimit == 0) return 0;
    return (u.monthlyExtractions / u.monthlyExtractionsLimit).clamp(0.0, 1.0);
  }

  double get generationsShare {
    final u = usage;
    if (u == null || u.monthlyGenerationsLimit == 0) return 0;
    return (u.monthlyGenerations / u.monthlyGenerationsLimit).clamp(0.0, 1.0);
  }

  bool get isNearLimit => extractionsShare > 0.8 || generationsShare > 0.8;
}

/// Plan and usage. Alive for the session: the home banner reads it. It
/// fetches only `/subscription`; plans and store products belong to
/// [paywallProvider].
final subscriptionStatusProvider =
    AsyncNotifierProvider<SubscriptionStatusNotifier, SubscriptionState>(
      SubscriptionStatusNotifier.new,
    );

class SubscriptionStatusNotifier extends AsyncNotifier<SubscriptionState> {
  SubscriptionRepository get _repository =>
      ref.read(subscriptionRepositoryProvider);

  @override
  Future<SubscriptionState> build() {
    ref.watch(sessionUserIdProvider);
    return _load();
  }

  Future<SubscriptionState> _load() async {
    final data = await _repository.getSubscription();
    return SubscriptionState(
      subscription: data.subscription,
      usage: data.usage,
    );
  }

  /// Reloads and keeps the current plan on screen while it runs.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Applies the entitlement a verified purchase returned, then refreshes
  /// usage (the new plan's limits). A usage failure keeps the new plan.
  Future<void> applyVerified(SubscriptionModel subscription) async {
    state = AsyncData(
      SubscriptionState(subscription: subscription, usage: state.value?.usage),
    );
    try {
      final usage = await _repository.getUsage();
      if (!ref.mounted) return;
      state = AsyncData(
        SubscriptionState(
          subscription: state.value?.subscription ?? subscription,
          usage: usage,
        ),
      );
    } catch (e, stackTrace) {
      ErrorHandler.reportError(
        e,
        'Usage refresh failed',
        stackTrace: stackTrace,
      );
    }
  }

  /// Cancels a Stripe-billed plan at period end. Store-billed plans are
  /// managed in the store. Returns true on success.
  Future<bool> cancel() async {
    final current = state.value;
    if (current == null) return false;
    if (current.isStoreBilled) {
      ErrorHandler.showValidation(
        'This plan is billed through the store. Manage it in your store '
        'account settings.',
        title: 'Manage in the store',
      );
      return false;
    }
    try {
      await _repository.cancelSubscription();
      await refresh();
      ErrorHandler.showSuccess(
        'Your plan stays active until the end of this billing period.',
        title: 'Subscription cancelled',
      );
      return true;
    } catch (e, stackTrace) {
      ErrorHandler.showError(
        e,
        title: 'Could not cancel',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Opens the platform's subscription settings: the App Store or Play on
  /// mobile, the Stripe billing portal on web.
  Future<void> openManage() async {
    if (kIsWeb) {
      try {
        final portalUrl = await _repository.createPortalSession();
        if (portalUrl.isEmpty) {
          ErrorHandler.showValidation(
            'Could not open billing management.',
            title: 'Could not open',
          );
          return;
        }
        await _openExternal(Uri.parse(portalUrl));
      } catch (e, stackTrace) {
        ErrorHandler.showError(
          e,
          title: 'Could not open',
          stackTrace: stackTrace,
        );
      }
      return;
    }
    final url = ref.read(iapServiceProvider).isApple
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse('https://play.google.com/store/account/subscriptions');
    await _openExternal(url);
  }
}

/// Opens [url] outside the app, or says why it could not (for example a
/// simulator without the App Store).
Future<void> _openExternal(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    ErrorHandler.showValidation(
      'Could not open the link.',
      title: 'Could not open',
    );
  }
}

// ---------------------------------------------------------------------------
// Referrals
// ---------------------------------------------------------------------------

/// The user's referral code. The API creates one on first read, so nothing
/// reads this until a screen shows the code or the user shares it.
final referralCodeProvider =
    AsyncNotifierProvider<ReferralCodeNotifier, ReferralCodeModel>(
      ReferralCodeNotifier.new,
    );

class ReferralCodeNotifier extends AsyncNotifier<ReferralCodeModel> {
  @override
  Future<ReferralCodeModel> build() {
    ref.watch(sessionUserIdProvider);
    return ref.read(subscriptionRepositoryProvider).getReferralCode();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(subscriptionRepositoryProvider).getReferralCode(),
    );
  }

  /// The code, loading it first if needed. Shows the error and returns null
  /// when it cannot load.
  Future<ReferralCodeModel?> _ensure() async {
    if (!state.hasValue) {
      if (state.isLoading) {
        await future.then<void>((_) {}, onError: (Object _) {});
      } else {
        await refresh();
      }
    }
    final code = state.value;
    if (code == null) {
      ErrorHandler.showError(
        state.error ?? 'Could not load your referral link. Try again.',
        title: 'Could not load your link',
      );
    }
    return code;
  }

  Future<void> copyLink() async {
    final code = await _ensure();
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code.shareUrl));
    ErrorHandler.showSuccess('Referral link copied.', title: 'Copied');
  }

  /// Opens the share sheet. [sharePositionOrigin] anchors the iPad popover.
  /// Falls back to the clipboard when the sheet fails.
  Future<void> share({Rect? sharePositionOrigin}) async {
    final code = await _ensure();
    if (code == null) return;
    try {
      await Share.share(
        'Join FitCheck AI and we both get a month of Pro. ${code.shareUrl}',
        subject: 'Try FitCheck AI',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (_) {
      try {
        await Clipboard.setData(ClipboardData(text: code.shareUrl));
        ErrorHandler.showInfo(
          'Sharing is not available, so we copied the link.',
          title: 'Link copied',
        );
      } catch (_) {
        ErrorHandler.showValidation(
          'Copy the link from the referral page instead.',
          title: 'Could not share',
        );
      }
    }
  }
}

/// Referral totals, for the referral page only.
final referralStatsProvider = FutureProvider.autoDispose<ReferralStatsModel>(
  (ref) => ref.read(subscriptionRepositoryProvider).getReferralStats(),
);

// ---------------------------------------------------------------------------
// Paywall (plans, store products, purchases)
// ---------------------------------------------------------------------------

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

const _plansUnset = Object();

@immutable
class PaywallState {
  const PaywallState({
    this.plans,
    this.plansError,
    this.storeStatus = StoreStatus.unknown,
    this.storeProductDetails = const {},
    this.missingStoreProductIds = const [],
    this.checkingOutPlanType,
    this.isRestoring = false,
  });

  /// The `/plans` response; null while it loads or after it failed.
  final PlansResponse? plans;

  /// Why `/plans` failed, for a banner with retry.
  final Object? plansError;

  final StoreStatus storeStatus;

  /// Store product details (localized prices) keyed by plan type
  /// (`plus_monthly`, ...).
  final Map<String, ProductDetails> storeProductDetails;

  /// Product IDs the store answered for but did not recognize: a store-side
  /// setup problem, reported to telemetry.
  final List<String> missingStoreProductIds;

  /// The plan type whose store checkout is starting, or null.
  final String? checkingOutPlanType;

  /// A restore is in flight. Its results arrive later on the purchase
  /// stream, so this clears there (or on a safety timeout).
  final bool isRestoring;

  StoreProductsModel get storeProducts =>
      plans?.storeProducts ?? const StoreProductsModel();

  bool get isCheckingOut => checkingOutPlanType != null;

  bool isCheckingOutPlan(String planType) => checkingOutPlanType == planType;

  /// Localized store price for a plan type, or null before it loads.
  String? storePriceFor(String planType) =>
      storeProductDetails[planType]?.price;

  /// Web with Stripe unconfigured (`billing_configured: false`): checkout
  /// fails closed server-side, so the paywall must not offer it.
  bool get webBillingUnavailable =>
      kIsWeb && !(plans?.billingConfigured ?? false);

  PlanDetailsModel? plan(String id) {
    for (final p in plans?.plans ?? const <PlanDetailsModel>[]) {
      if (p.id == id) return p;
    }
    return null;
  }

  PaywallState copyWith({
    PlansResponse? plans,
    Object? plansError = _plansUnset,
    StoreStatus? storeStatus,
    Map<String, ProductDetails>? storeProductDetails,
    List<String>? missingStoreProductIds,
    Object? checkingOutPlanType = _plansUnset,
    bool? isRestoring,
  }) => PaywallState(
    plans: plans ?? this.plans,
    plansError: identical(plansError, _plansUnset)
        ? this.plansError
        : plansError,
    storeStatus: storeStatus ?? this.storeStatus,
    storeProductDetails: storeProductDetails ?? this.storeProductDetails,
    missingStoreProductIds:
        missingStoreProductIds ?? this.missingStoreProductIds,
    checkingOutPlanType: identical(checkingOutPlanType, _plansUnset)
        ? this.checkingOutPlanType
        : checkingOutPlanType as String?,
    isRestoring: isRestoring ?? this.isRestoring,
  );
}

/// The open paywall. Alive only while the subscription page is: it loads
/// plans and store products, and while alive it is the purchase stream's
/// page handler. On dispose the stream goes back to
/// [PurchaseRecoveryService]'s background drain.
///
/// Purchase routing (App Store Guideline 3.1.1): iOS and Android buy through
/// the store and the backend verifies every transaction. Stripe checkout
/// opens only on web.
final paywallProvider =
    NotifierProvider.autoDispose<PaywallNotifier, PaywallState>(
      PaywallNotifier.new,
    );

class PaywallNotifier extends Notifier<PaywallState> {
  Timer? _restoreTimeout;
  Future<void>? _storeQuery;

  PurchaseRecoveryService get _recovery =>
      ref.read(purchaseRecoveryServiceProvider);
  IapService get _iap => _recovery.iapService;
  SubscriptionRepository get _repository =>
      ref.read(subscriptionRepositoryProvider);

  @override
  PaywallState build() {
    final recovery = _recovery;
    // Verification still runs through the service's single
    // verifyAndComplete path, whose claim set stops any transaction from
    // being processed twice.
    recovery.activatePageHandler(_onStoreUpdates);
    ref.onDispose(() {
      recovery.deactivatePageHandler();
      _restoreTimeout?.cancel();
    });
    unawaited(loadPlans());
    return const PaywallState();
  }

  /// Loads `/plans`, then the store products for their localized prices.
  Future<void> loadPlans() async {
    try {
      final plans = await _repository.getPlans();
      if (!ref.mounted) return;
      state = state.copyWith(plans: plans, plansError: null);
    } catch (e, stackTrace) {
      ErrorHandler.reportError(e, 'Plans load failed', stackTrace: stackTrace);
      if (ref.mounted) state = state.copyWith(plansError: e);
      return;
    }
    await refreshStoreProducts();
  }

  /// Queries the store for product details (localized prices) and derives
  /// [PaywallState.storeStatus].
  ///
  /// Only the definitive zero-products failure (`storekit_no_response`, or a
  /// success with zero products) is [StoreStatus.unavailable]; that state
  /// lasts until the store side is fixed. Other failures (network, store
  /// server) leave the status unknown so checkout retries on its own.
  ///
  /// Single-flight: page load and the banner's Retry can overlap, and a
  /// stale slow response landing last would flip a ready rail back to
  /// unavailable.
  Future<void> refreshStoreProducts() async {
    if (!_iap.isStoreBillingAvailable) return;
    final inFlight = _storeQuery;
    if (inFlight != null) return inFlight;
    final query = _queryStoreProducts();
    _storeQuery = query;
    try {
      await query;
    } finally {
      if (identical(_storeQuery, query)) _storeQuery = null;
    }
  }

  Future<void> _queryStoreProducts() async {
    const planTypes = [
      'plus_monthly',
      'plus_yearly',
      'pro_monthly',
      'pro_yearly',
    ];
    try {
      // Key the result by plan type (what the UI asks for), not by the
      // store's product ID.
      final planTypeById = <String, String>{};
      for (final planType in planTypes) {
        final id = state.storeProducts.productIdFor(_iap.storeName, planType);
        if (id != null) planTypeById[id] = planType;
      }
      if (planTypeById.isEmpty) {
        // The backend published no store product IDs: the rail is not wired
        // up (fail-closed by design).
        state = state.copyWith(storeStatus: StoreStatus.notConfigured);
        return;
      }
      final query = await _iap.fetchProducts(planTypeById.keys.toSet());
      if (!ref.mounted) return;
      state = state.copyWith(
        storeProductDetails: {
          for (final d in query.products) planTypeById[d.id] ?? d.id: d,
        },
        missingStoreProductIds: query.notFoundIds.toList(),
        // Zero products: the store answered and does not serve this rail
        // yet. Never advertise upgrades as ready in this state.
        storeStatus: query.products.isEmpty
            ? StoreStatus.unavailable
            : StoreStatus.ready,
      );
      if (query.notFoundIds.isNotEmpty) {
        // The most common sandbox / App Review setup failure (product not
        // created, agreements unsigned, wrong bundle namespace). The user
        // still sees the /plans prices.
        ErrorHandler.reportError(
          StateError(
            'Store did not recognize product IDs: '
            '${query.notFoundIds.join(', ')}',
          ),
          'Store product IDs not found (${_iap.storeName})',
        );
      }
    } catch (e, stackTrace) {
      // Prices fall back to /plans. An already-unavailable rail stays
      // unavailable across a transient retry: the products are still not
      // served.
      if (!ref.mounted) return;
      final definitive =
          (e is IapException && e.errorCode == 'storekit_no_response') ||
          state.storeStatus == StoreStatus.unavailable;
      state = state.copyWith(
        storeStatus: definitive ? StoreStatus.unavailable : StoreStatus.unknown,
      );
      ErrorHandler.reportError(
        e,
        'Store product query failed',
        stackTrace: stackTrace,
      );
    }
  }

  /// Re-queries the store from the banner. Recovers without an app restart
  /// once the store starts serving the products.
  Future<void> retryStoreProducts() async {
    await refreshStoreProducts();
    if (ref.mounted && state.storeStatus == StoreStatus.ready) {
      ErrorHandler.showSuccess(
        'Store prices are available. You can upgrade now.',
        title: 'Store ready',
      );
    }
  }

  /// Starts checkout for a plan type (`plus_monthly`, `pro_yearly`, ...):
  /// the store on mobile, Stripe on web.
  Future<void> startCheckout(String planType) async {
    // Never surface a purchase flow when the paywall is off.
    if (!paywallEnabled) return;
    // One store flow at a time, and never beside a restore.
    if (state.isCheckingOut || state.isRestoring) return;
    state = state.copyWith(checkingOutPlanType: planType);
    try {
      if (kIsWeb) {
        await _startStripeCheckout(planType);
      } else {
        await _startStorePurchase(planType);
      }
    } catch (e, stackTrace) {
      // Sentry gets the real object (IapException.details keeps the raw
      // store payload); the user sees only the friendly message.
      ErrorHandler.showError(
        e,
        title: 'Purchase failed',
        stackTrace: stackTrace,
      );
    } finally {
      if (ref.mounted) state = state.copyWith(checkingOutPlanType: null);
    }
  }

  void _unavailable(String message) =>
      ErrorHandler.showValidation(message, title: 'Purchase unavailable');

  Future<void> _startStorePurchase(String planType) async {
    if (!_iap.isStoreBillingAvailable) {
      return _unavailable('In-app purchases are not available on this device.');
    }
    final productId = state.storeProducts.productIdFor(
      _iap.storeName,
      planType,
    );
    if (productId == null) {
      return _unavailable('This plan is not available for purchase yet.');
    }
    if (state.storeStatus == StoreStatus.unavailable) {
      // The page-load query already failed this session; a re-query can only
      // repeat it after its retry delay. The banner's Retry is the recovery.
      return _unavailable(kPlanNotAvailableInStoreMessage);
    }
    // Prefer the page-load cache so a transient store error at the tap
    // cannot fail a purchase with valid details on hand. StoreKit re-resolves
    // the live price at the native sheet.
    var product = state.storeProductDetails[planType];
    if (product == null) {
      final query = await _iap.fetchProducts({productId});
      if (query.isEmpty) return _unavailable(kPlanNotAvailableInStoreMessage);
      product = query.products.first;
    }
    final started = await _iap.startPurchase(
      product,
      appAccountToken: _recovery.currentUserId,
    );
    if (!started) {
      _unavailable('The purchase could not start. Try again.');
    }
    // The result arrives on the purchase stream.
  }

  Future<void> _startStripeCheckout(String planType) async {
    final session = await _repository.createCheckoutSession(planType: planType);
    if (session.updated) {
      // The backend changed the existing Stripe plan in place.
      await ref.read(subscriptionStatusProvider.notifier).refresh();
      return;
    }
    final checkoutUrl = session.checkoutUrl;
    if (checkoutUrl == null || checkoutUrl.isEmpty) {
      return _unavailable('Checkout did not return a payment link.');
    }
    await _openExternal(Uri.parse(checkoutUrl));
  }

  void _onStoreUpdates(List<PurchaseDetails> updates) {
    for (final details in updates) {
      try {
        unawaited(
          _handlePurchaseUpdate(details).catchError((Object e, StackTrace s) {
            ErrorHandler.reportError(
              e,
              'Purchase update handler failed',
              stackTrace: s,
            );
          }),
        );
      } catch (e, stackTrace) {
        // A throw must never orphan the rest of the batch or the handler.
        ErrorHandler.reportError(
          e,
          'Purchase update handler threw',
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails details) async {
    switch (details.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final restored = details.status == PurchaseStatus.restored;
        if (restored) {
          // Release the Restore button before the slow backend check.
          _restoreTimeout?.cancel();
          if (ref.mounted) state = state.copyWith(isRestoring: false);
        }
        await _verify(details, restored: restored);
      case PurchaseStatus.pending:
        // Ask to Buy / parental approval. No charge yet.
        ErrorHandler.showSuccess(
          "Your purchase is waiting for approval. You'll get access as soon "
          "as it's approved.",
          title: 'Purchase pending',
        );
      case PurchaseStatus.error:
        // The plugin's message is a raw platform dump; the user gets a stable
        // sentence and Sentry gets the details.
        ErrorHandler.showError(
          IapException(
            message: 'The purchase failed. Try again.',
            errorCode: details.error?.code,
            details: details.error?.toString(),
          ),
          title: 'Purchase failed',
        );
      case PurchaseStatus.canceled:
        break;
    }
  }

  /// Verifies one transaction through the app-wide recovery service and maps
  /// the outcome to the plan and a toast.
  Future<void> _verify(
    PurchaseDetails details, {
    required bool restored,
  }) async {
    // Read now: the page may close while the backend verifies, and the
    // session-wide plan must still update.
    final status = ref.read(subscriptionStatusProvider.notifier);
    final result = await _recovery.verifyAndComplete(
      details,
      restored: restored,
      interactive: true,
    );
    switch (result.outcome) {
      case PurchaseVerificationOutcome.verified:
        final subscription = result.subscription;
        if (subscription != null) await status.applyVerified(subscription);
        ErrorHandler.showSuccess(
          restored
              ? 'Your purchases are restored.'
              : 'Your subscription is active. Welcome.',
          title: restored ? 'Restored' : 'Subscription active',
        );
      case PurchaseVerificationOutcome.duplicate:
        // Already verified elsewhere. A second toast reads as a second charge.
        break;
      case PurchaseVerificationOutcome.noSession:
        ErrorHandler.showValidation(
          'Sign in to finish your purchase.',
          title: 'Sign in required',
        );
      case PurchaseVerificationOutcome.invalidTransaction:
        ErrorHandler.showError(
          result.message ??
              'The purchase did not include a verifiable transaction ID.',
          title: 'Purchase error',
        );
      case PurchaseVerificationOutcome.transientFailure:
        // Not completed; the claim is released and the recovery service
        // drains the redelivery after this page closes.
        ErrorHandler.showValidation(
          "We couldn't verify your purchase with the store right now. It "
          "will finish automatically, and you won't be charged twice.",
          title: 'Verification pending',
        );
      case PurchaseVerificationOutcome.terminalFailure:
        // Rejected for good: redelivery cannot fix it, support can.
        ErrorHandler.showValidation(
          kPurchaseNotAppliedMessage,
          title: 'Purchase not applied',
        );
    }
  }

  /// Asks the store to redeliver past purchases (Apple 3.1.1, Play policy).
  /// Restored transactions arrive on the purchase stream.
  Future<void> restorePurchases() async {
    if (!_iap.isStoreBillingAvailable) return;
    if (state.isRestoring || state.isCheckingOut) return;
    state = state.copyWith(isRestoring: true);
    // No synchronous completion: if the store never emits (sandbox hang),
    // release the button after 15 seconds.
    _restoreTimeout = Timer(const Duration(seconds: 15), () {
      if (ref.mounted) state = state.copyWith(isRestoring: false);
    });
    try {
      await _iap.restorePurchases();
    } catch (e, stackTrace) {
      _restoreTimeout?.cancel();
      if (ref.mounted) state = state.copyWith(isRestoring: false);
      // One report: showError reports the exception it shows.
      ErrorHandler.showError(
        IapException(
          message: 'Could not restore purchases. Try again.',
          details: e.toString(),
        ),
        title: 'Restore failed',
        stackTrace: stackTrace,
      );
    }
  }
}

import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/error_handler.dart';
import '../repositories/subscription_repository.dart';
import '../models/subscription_model.dart';
import 'iap_service.dart';

/// User-visible message for a TERMINAL verification failure: the backend
/// rejected the transaction itself (unknown product, transaction already
/// linked to another account, store credentials unconfigured). The store's
/// automatic redelivery can never fix these, so the UI must stop promising
/// "picked up automatically" and point at the only real path: support.
const String kPurchaseNotAppliedMessage =
    'Your purchase could not be applied to your account. Please contact '
    'support — do not purchase again.';

/// How a purchase-verification attempt ended. The page controller maps these
/// to page state and toasts; the background drain maps them to telemetry and
/// (rarely) a snackbar.
enum PurchaseVerificationOutcome {
  /// Backend verified the transaction and the purchase was completed with
  /// the store. [PurchaseVerificationResult.subscription] carries the new
  /// entitlement.
  verified,

  /// The backend could not be reached or failed transiently (network drop,
  /// 5xx, 401 token race, 429). The purchase stays uncompleted so the store
  /// redelivers it; the app-lifetime drain retries automatically.
  transientFailure,

  /// The backend permanently rejected the transaction (4xx validation) —
  /// redelivery can never succeed. The purchase is NOT completed; the user
  /// must contact support.
  terminalFailure,

  /// Another path (background drain or an earlier delivery) already claimed
  /// this transaction. Nothing to do.
  duplicate,

  /// No signed-in user on a background drain: no backend call is made and
  /// the purchase stays unfinished for the post-login drain.
  noSession,

  /// The purchase carried no verifiable transaction ID.
  invalidTransaction,
}

/// Result of one verification attempt (see [PurchaseRecoveryService
/// .verifyAndComplete]).
class PurchaseVerificationResult {
  const PurchaseVerificationResult({
    required this.outcome,
    this.subscription,
    this.message,
  });

  final PurchaseVerificationOutcome outcome;

  /// The refreshed entitlement when [outcome] is
  /// [PurchaseVerificationOutcome.verified].
  final SubscriptionModel? subscription;

  /// Raw user-displayable failure detail (backend message) when the outcome
  /// is a failure; a diagnostic ID for duplicate/noSession.
  final String? message;
}

/// App-lifetime owner of the in_app_purchase stream.
///
/// Why this exists: [SubscriptionController] used to be the ONLY listener,
/// and it lives only while the paywall page is open. A purchase whose
/// backend verification failed (network drop at the wrong moment) stayed
/// unfinished with nothing draining it until the user happened to reopen the
/// page — while the store considered the user charged. This service attaches
/// the plugin stream at bootstrap and drains purchased/restored updates with
/// no page open, so recovery no longer depends on navigation.
///
/// Ownership model (no duplicated verification logic):
/// - The plugin stream is subscribed to HERE and only here, for the whole
///   app session.
/// - While the paywall page is open ([activatePageHandler]), every raw
///   update batch is forwarded to the page so pending/error toasts and the
///   restore spinner stay page-driven; the page routes verification back
///   through [verifyAndComplete].
/// - With no page open, this service verifies/completes updates itself via
///   the same [verifyAndComplete] — silently for transient failures, with an
///   accurate snackbar for success or terminal rejection.
/// - [verifyAndComplete] claims each transaction ID in an app-wide set, so a
///   transaction can never be verified, completed, or celebrated twice no
///   matter which path delivers it (page + background overlap, store
///   redeliveries, iOS upgrade batches).
///
/// Registered permanently in InitialBinding (same lifecycle as
/// [SupabaseService]) — Get.put inside InitialBinding survives route
/// disposal, which is exactly what makes the recovery app-lifetime.
class PurchaseRecoveryService extends GetxService {
  PurchaseRecoveryService({
    IapService? iapService,
    SubscriptionRepository? repository,
    RxBool? isAuthenticated,
    String? Function()? currentUserId,
  }) : _iapOverride = iapService,
       _repositoryOverride = repository,
       _isAuthenticatedOverride = isAuthenticated,
       _currentUserId = currentUserId ?? _defaultCurrentUserId;

  final IapService? _iapOverride;
  final SubscriptionRepository? _repositoryOverride;
  final RxBool? _isAuthenticatedOverride;

  /// Resolves the signed-in user ID without assuming SupabaseService is
  /// registered — widget tests build the service with no app bindings, and a
  /// missing session must degrade to "signed out", never throw mid-drain.
  static String? _defaultCurrentUserId() {
    try {
      if (!Get.isRegistered<SupabaseService>()) return null;
      return Get.find<SupabaseService>().currentUserId;
    } catch (_) {
      return null;
    }
  }

  /// Resolved lazily so tests (and web builds) can construct the service
  /// without touching the platform plugin singleton.
  late final IapService iapService = _iapOverride ?? IapService();

  SubscriptionRepository get _repository =>
      _repositoryOverride ?? SubscriptionRepository();

  /// Auth flag observed for bootstrap attach / login re-drain. Defaults to
  /// SupabaseService's flag when available; null (no reactivity) in tests
  /// that construct the service standalone — per-update session gating still
  /// guards every backend call.
  RxBool? get _authFlag =>
      _isAuthenticatedOverride ??
      (Get.isRegistered<SupabaseService>()
          ? Get.find<SupabaseService>().isAuthenticated
          : null);

  final String? Function() _currentUserId;

  StreamSubscription<List<PurchaseDetails>>? _streamSubscription;
  Worker? _authWorker;

  /// The paywall page's handler while the page is open; null when closed.
  void Function(List<PurchaseDetails> updates)? _pageHandler;

  /// Transaction IDs already claimed for verification (in flight or
  /// completed) by ANY path — the single app-wide dedupe authority. Entries
  /// are released when verification fails transiently so the store's
  /// redelivery can retry, and deliberately kept for completed transactions
  /// (a later restore must not re-celebrate them) and for terminal
  /// rejections (redelivery can never succeed; the next app start verifies
  /// once more and re-informs the user honestly).
  final Set<String> _claimedTransactionIds = <String>{};

  /// Bootstrap: attach when a session already exists, and react to login so
  /// a purchase stranded before sign-in still drains. Only runs for the
  /// binding-registered instance (a page-constructed fallback never calls
  /// this; the page attaches it explicitly).
  @override
  void onInit() {
    super.onInit();
    final auth = _authFlag;
    if (auth == null) return;
    // Attach only with a live session (a redelivery arriving signed-out
    // could not be verified anyway); attach + drain on every login.
    if (auth.value) _attachStream();
    _authWorker = ever<bool>(auth, _onAuthChanged);
  }

  /// The plugin stream is attached HERE and only here for the whole app
  /// session. Idempotent.
  void _attachStream() {
    if (_streamSubscription != null) return;
    if (!iapService.isStoreBillingAvailable) return;
    // onError keeps the subscription alive: a plugin-emitted stream error
    // (StoreKit2 Transaction.updates can emit them) must never leave
    // unfinished transactions with no listener — the store would keep
    // redelivering them to a dead stream until a full app restart.
    _streamSubscription = iapService.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object e) {
        ErrorHandler.reportError(e, 'Store purchase stream error (recovery)');
      },
    );
  }

  /// Attach immediately regardless of auth state. Used by the paywall page
  /// on open (its user is signed in by definition); the per-update session
  /// gate in [verifyAndComplete] keeps an attached-but-signed-out stream
  /// inert, so attaching early is always safe.
  void ensureStreamAttached() => _attachStream();

  /// Stop listening (sign-out). Unfinished purchases stay with the store and
  /// drain on the next login.
  void detachStream() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  /// Register the paywall page as the active UI handler. While set, raw
  /// update batches are forwarded instead of drained here. The page handler
  /// must route verification through [verifyAndComplete] — its claim set is
  /// what prevents double-processing across both paths.
  void activatePageHandler(void Function(List<PurchaseDetails> updates) handler) {
    _pageHandler = handler;
    ensureStreamAttached();
  }

  /// Hand the stream back to the background drain (page closed).
  void deactivatePageHandler() {
    _pageHandler = null;
  }

  void _onAuthChanged(bool authenticated) {
    if (authenticated) {
      _attachStream();
      unawaited(_drainOnLogin());
    } else {
      // Signed out: stop handling updates and forget claims — a different
      // account signing in later may legitimately verify the same store
      // transaction (e.g. a family device).
      detachStream();
      _claimedTransactionIds.clear();
    }
  }

  /// After sign-in, ask the store to redeliver everything unfinished: a
  /// purchase whose verification failed mid-login, or a subscription bought
  /// on another device. Results arrive on the already-attached stream.
  Future<void> _drainOnLogin() async {
    if (!iapService.isStoreBillingAvailable) return;
    if (_currentUserId() == null) return;
    try {
      await iapService.restorePurchases();
    } catch (e, stackTrace) {
      // Best-effort: the stream still redelivers Android-pending purchases
      // at the next app start even when this restore call fails.
      ErrorHandler.reportError(
        e,
        'Purchase recovery drain on login failed',
        stackTrace: stackTrace,
      );
    }
  }

  void _onPurchaseUpdates(List<PurchaseDetails> updates) {
    final handler = _pageHandler;
    if (handler != null) {
      // Paywall open: it owns pending/error toasts and the restore spinner,
      // so hand the raw batch over untouched.
      handler(updates);
      return;
    }
    // No page: drain silently.
    for (final details in updates) {
      switch (details.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          unawaited(
            _drainInBackground(
              details,
              restored: details.status == PurchaseStatus.restored,
            ),
          );
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          break; // Ask-to-buy / dismissed sheet: nothing to recover here.
        case PurchaseStatus.error:
          // The purchase flow failed with no page to show it; telemetry only
          // — the store does not keep errored purchases pending.
          ErrorHandler.reportError(
            details.error ?? StateError('purchase update error'),
            'Store purchase failed with no page open',
          );
      }
    }
  }

  /// Background drain of one purchased/restored update with no page open.
  Future<void> _drainInBackground(
    PurchaseDetails details, {
    required bool restored,
  }) async {
    final result = await verifyAndComplete(details, restored: restored);
    switch (result.outcome) {
      case PurchaseVerificationOutcome.verified:
        // Surface the win: this toast may be the ONLY confirmation the user
        // ever sees for the recovered purchase.
        ErrorHandler.showSuccess(
          'Your subscription is active.',
          title: 'Purchase complete',
        );
      case PurchaseVerificationOutcome.terminalFailure:
        // The user is charged and NOT entitled; they must hear it.
        ErrorHandler.showError(
          kPurchaseNotAppliedMessage,
          title: 'Purchase not applied',
        );
      case PurchaseVerificationOutcome.transientFailure:
      case PurchaseVerificationOutcome.duplicate:
      case PurchaseVerificationOutcome.noSession:
      case PurchaseVerificationOutcome.invalidTransaction:
        // Already reported inside [verifyAndComplete]; the transaction stays
        // unfinished and is retried by the next redelivery / login drain.
        break;
    }
  }

  /// Verify one purchase with the backend and, on success, complete it with
  /// the store. The SINGLE verification path for the whole app — the paywall
  /// page and the background drain both call this, which is what makes the
  /// claim dedupe and the terminal/transient classification universal.
  ///
  /// [interactive] mirrors "the user is watching": the page passes true and
  /// keeps its historical behavior (verification proceeds even with a stale
  /// session — the API client surfaces the auth failure), while a signed-out
  /// background drain makes NO backend call and leaves the purchase for the
  /// post-login drain.
  Future<PurchaseVerificationResult> verifyAndComplete(
    PurchaseDetails details, {
    required bool restored,
    bool interactive = false,
  }) async {
    final transactionId = iapService.transactionIdFor(details);
    if (transactionId == null || transactionId.isEmpty) {
      return const PurchaseVerificationResult(
        outcome: PurchaseVerificationOutcome.invalidTransaction,
        message: 'The purchase did not include a verifiable transaction ID.',
      );
    }
    // One app-wide claim per transaction: whichever path gets here first —
    // the open page or the background drain — processes it; the other sees
    // the claim and skips. Store redeliveries, restore overlaps, and iOS
    // upgrade batches are deduped by the same set.
    if (!_claimedTransactionIds.add(transactionId)) {
      return PurchaseVerificationResult(
        outcome: PurchaseVerificationOutcome.duplicate,
        message: transactionId,
      );
    }
    // Background drains never call the backend signed out: the purchase
    // stays unfinished (the store redelivers it) and drains after login.
    if (!interactive && _currentUserId() == null) {
      _claimedTransactionIds.remove(transactionId);
      ErrorHandler.reportError(
        StateError('purchase update while signed out'),
        'Skipping purchase verification: no signed-in user',
      );
      return PurchaseVerificationResult(
        outcome: PurchaseVerificationOutcome.noSession,
        message: transactionId,
      );
    }
    try {
      final subscription = await _repository.registerIapTransaction(
        store: iapService.storeName,
        transactionId: transactionId,
        productId: details.productID,
      );
      // Only complete (deliver) the purchase after the backend verified it;
      // otherwise the store would consider it delivered despite no
      // entitlement. The claim is kept for the session so a later restore of
      // the same transaction cannot re-celebrate it.
      await iapService.complete(details);
      return PurchaseVerificationResult(
        outcome: PurchaseVerificationOutcome.verified,
        subscription: subscription,
      );
    } catch (e, stackTrace) {
      final terminal = isTerminalVerificationError(e);
      if (!terminal) {
        // Transient: release the claim so the store's redelivery can retry.
        _claimedTransactionIds.remove(transactionId);
      }
      // Terminal: keep the claim so this session never re-processes (nor
      // re-alarms about) a permanently-rejected transaction.
      ErrorHandler.reportError(
        e,
        'IAP verification failed (${terminal ? 'terminal' : 'transient'})',
        stackTrace: stackTrace,
      );
      return PurchaseVerificationResult(
        outcome: terminal
            ? PurchaseVerificationOutcome.terminalFailure
            : PurchaseVerificationOutcome.transientFailure,
        message: ErrorHandler.extractMessage(e),
      );
    }
  }

  /// Whether a verification failure is PERMANENT: the backend rejected the
  /// transaction itself (unknown product, already linked to another account,
  /// store credentials unconfigured), so automatic redelivery can never
  /// succeed and the UI must stop promising "picked up automatically".
  ///
  /// 4xx validation statuses are terminal; 401 (expired access token — a
  /// refresh + redelivery passes) and 429 (rate limit — a later retry
  /// passes) stay transient, as do all network failures, timeouts, and 5xx.
  static bool isTerminalVerificationError(Object error) {
    final code = error is AppException ? error.statusCode : null;
    if (code == null) return false;
    return code >= 400 && code < 500 && code != 401 && code != 429;
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    detachStream();
    deactivatePageHandler();
    super.onClose();
  }
}

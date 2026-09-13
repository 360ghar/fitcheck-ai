import 'dart:async';

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/features/subscription/models/subscription_model.dart';
import 'package:fitcheck_ai/features/subscription/repositories/subscription_repository.dart';
import 'package:fitcheck_ai/features/subscription/services/iap_service.dart';
import 'package:fitcheck_ai/features/subscription/services/purchase_recovery_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Fake IAP gateway with manually pumped purchase events (same pattern as
/// the controller tests' FakeIapService).
class FakeIapService extends IapService {
  FakeIapService({
    bool storeBillingAvailable = true,
    String storeName = 'google',
  }) : _storeBillingAvailable = storeBillingAvailable,
       _storeName = storeName;

  final bool _storeBillingAvailable;
  final String _storeName;
  final _streamController = StreamController<List<PurchaseDetails>>.broadcast();
  int restoreCalls = 0;
  int completeCalls = 0;

  @override
  bool get isStoreBillingAvailable => _storeBillingAvailable;

  @override
  bool get isApple => _storeName == 'apple';

  @override
  String get storeName => _storeName;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _streamController.stream;

  @override
  Future<IapProductQuery> fetchProducts(
    Set<String> productIds, {
    int maxRetries = 2,
  }) async {
    return const IapProductQuery(products: [], notFoundIds: {});
  }

  @override
  Future<bool> startPurchase(
    ProductDetails product, {
    String? appAccountToken,
  }) async {
    return true;
  }

  @override
  Future<void> restorePurchases() async {
    restoreCalls++;
  }

  @override
  Future<void> complete(PurchaseDetails details) async {
    completeCalls++;
  }

  @override
  String? transactionIdFor(PurchaseDetails details) =>
      details.verificationData.serverVerificationData.isEmpty
      ? details.purchaseID
      : details.verificationData.serverVerificationData;

  void emit(PurchaseDetails details) {
    _streamController.add([details]);
  }

  void emitError(Object error) {
    _streamController.addError(error);
  }

  void dispose() => _streamController.close();
}

/// Fake repository; only the IAP registration path is exercised.
class FakeSubscriptionRepository extends SubscriptionRepository {
  int registerCalls = 0;
  String? lastTransactionId;
  Object? registerError;

  @override
  Future<SubscriptionWithUsage> getSubscription() async {
    return SubscriptionWithUsage(
      subscription: const SubscriptionModel(userId: 'user-1'),
      usage: const UsageLimitsModel(),
    );
  }

  @override
  Future<PlansResponse> getPlans() async => const PlansResponse();

  @override
  Future<ReferralCodeModel> getReferralCode() async =>
      const ReferralCodeModel(code: 'X', shareUrl: 'https://example.com/r/X');

  @override
  Future<ReferralStatsModel> getReferralStats() async =>
      const ReferralStatsModel();

  @override
  Future<SubscriptionModel> registerIapTransaction({
    required String store,
    required String transactionId,
    required String productId,
  }) async {
    registerCalls++;
    lastTransactionId = transactionId;
    final error = registerError;
    if (error != null) throw error;
    return SubscriptionModel(
      userId: 'user-1',
      planType: PlanType.plusMonthly,
      billingProvider: store,
    );
  }

  @override
  Future<CheckoutSessionModel> createCheckoutSession({
    required String planType,
    String? successUrl,
    String? cancelUrl,
  }) async {
    return const CheckoutSessionModel();
  }

  @override
  Future<String> createPortalSession() async => '';

  @override
  Future<bool> redeemReferralCode(String code) async => true;

  @override
  Future<ValidateReferralResponse> validateReferralCode(String code) async {
    return const ValidateReferralResponse();
  }
}

PurchaseDetails _purchase({
  String productId = 'plus_monthly',
  String serverVerificationData = 'token-abc',
  String? purchaseID = 'GPA.1234',
  PurchaseStatus status = PurchaseStatus.purchased,
}) {
  return PurchaseDetails(
    productID: productId,
    purchaseID: purchaseID,
    verificationData: PurchaseVerificationData(
      serverVerificationData: serverVerificationData,
      localVerificationData: '',
      source: 'TestStore',
    ),
    transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
    status: status,
  );
}

String? _signedInUser() => 'user-1';

/// Settles the fire-and-forget background drains (two microtask hops: the
/// stream listener, then the unawaited verify future).
///
/// Plain `test()` bodies only — inside `testWidgets` the fake-async zone
/// never fires `Future.delayed` without a pump; use `await tester.pump()`.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

/// The background drain surfaces verified/terminal outcomes as snackbars,
/// which need a GetMaterialApp overlay — the same shell the controller tests
/// pump before exercising UI-presenting paths.
Future<void> _pumpShell(WidgetTester tester) async {
  await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
  await tester.pump();
}

/// Drains the snackbar queue so no timer outlives the test.
Future<void> _drainSnackbars(WidgetTester tester) async {
  // Let any snackbar fully show and dismiss before closing: a job still
  // queued has no animation controller to close and closeAllSnackbars
  // would throw.
  await tester.pump(const Duration(seconds: 6));
  try {
    Get.closeAllSnackbars();
  } catch (_) {
    // Nothing (or nothing fully shown) to close.
  }
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeIapService iapService;
  late FakeSubscriptionRepository repository;

  setUp(() {
    Get.reset();
    iapService = FakeIapService();
    repository = FakeSubscriptionRepository();
  });

  tearDown(() {
    iapService.dispose();
    Get.reset();
  });

  PurchaseRecoveryService buildService({
    String? Function()? currentUserId = _signedInUser,
    RxBool? isAuthenticated,
  }) {
    return PurchaseRecoveryService(
      iapService: iapService,
      repository: repository,
      isAuthenticated: isAuthenticated,
      currentUserId: currentUserId,
    );
  }

  group('background drain (no page open)', () {
    testWidgets(
      'an unfinished purchase with NO page open is verified and completed',
      (tester) async {
        await _pumpShell(tester);
        final service = buildService();
        service.ensureStreamAttached();

        iapService.emit(_purchase());
        await tester.pump();
        await tester.pump();

        expect(repository.registerCalls, 1);
        expect(repository.lastTransactionId, 'token-abc');
        expect(iapService.completeCalls, 1);
        await _drainSnackbars(tester);
      },
    );

    testWidgets('a transient backend failure leaves the purchase uncompleted', (
      tester,
    ) async {
      await _pumpShell(tester);
      repository.registerError = const NetworkException(
        message: 'network dropped',
      );
      final service = buildService();
      service.ensureStreamAttached();

      iapService.emit(_purchase());
      await tester.pump();
      await tester.pump();

      expect(repository.registerCalls, 1);
      // Never complete a purchase whose verification failed: the store keeps
      // it pending and redelivers it to the still-attached stream.
      expect(iapService.completeCalls, 0);

      // The redelivery retries once the backend recovers, then completes.
      repository.registerError = null;
      iapService.emit(_purchase(purchaseID: 'GPA.redeliver'));
      await tester.pump();
      await tester.pump();

      expect(repository.registerCalls, 2);
      expect(iapService.completeCalls, 1);
      await _drainSnackbars(tester);
    });

    testWidgets('a terminal backend rejection never re-registers this session', (
      tester,
    ) async {
      // Unknown product / already-linked-elsewhere: redelivery can never
      // succeed, so the claim is kept — the store may keep redelivering but
      // the session neither re-verifies nor completes it.
      await _pumpShell(tester);
      repository.registerError = const ValidationException(
        message: 'unknown product',
      );
      final service = buildService();
      service.ensureStreamAttached();

      iapService.emit(_purchase());
      await tester.pump();
      await tester.pump();
      expect(repository.registerCalls, 1);
      expect(iapService.completeCalls, 0);

      repository.registerError = null;
      iapService.emit(_purchase(purchaseID: 'GPA.redeliver'));
      await tester.pump();
      await tester.pump();

      expect(repository.registerCalls, 1);
      expect(iapService.completeCalls, 0);
      await _drainSnackbars(tester);
    });

    testWidgets('a second delivery of the same transaction verifies once', (
      tester,
    ) async {
      await _pumpShell(tester);
      final service = buildService();
      service.ensureStreamAttached();

      iapService.emit(_purchase());
      await tester.pump();
      await tester.pump();
      // A restore overlapping the active entitlement re-emits the same
      // transaction — it must not re-register, re-complete, or re-toast.
      iapService.emit(_purchase(status: PurchaseStatus.restored));
      await tester.pump();
      await tester.pump();

      expect(repository.registerCalls, 1);
      expect(iapService.completeCalls, 1);
      await _drainSnackbars(tester);
    });

    testWidgets('a stream error does not kill the drain', (tester) async {
      await _pumpShell(tester);
      final service = buildService();
      service.ensureStreamAttached();

      iapService.emitError(StateError('storekit blew up'));
      await tester.pump();
      iapService.emit(_purchase());
      await tester.pump();
      await tester.pump();

      expect(repository.registerCalls, 1);
      expect(iapService.completeCalls, 1);
      await _drainSnackbars(tester);
    });

    test('non-store platforms never attach', () async {
      iapService.dispose();
      iapService = FakeIapService(storeBillingAvailable: false);
      final service = buildService();
      service.ensureStreamAttached();

      // No listener: emit goes nowhere (and would throw on a closed
      // controller if one had subscribed).
      iapService.emit(_purchase());
      await _settle();
      await _settle();

      expect(repository.registerCalls, 0);
    });
  });

  group('session gating', () {
    test('logged out: no backend calls and no completion', () async {
      final service = buildService(currentUserId: () => null);
      service.ensureStreamAttached();

      iapService.emit(_purchase());
      await _settle();
      await _settle();

      expect(repository.registerCalls, 0);
      expect(iapService.completeCalls, 0);

      // The claim was released, so a later attempt is not swallowed as a
      // duplicate — but it still must not call the backend while signed out.
      final result = await service.verifyAndComplete(
        _purchase(),
        restored: false,
      );
      expect(result.outcome, PurchaseVerificationOutcome.noSession);
      expect(repository.registerCalls, 0);
    });

    testWidgets(
      'logged out at bootstrap: no attach; login attaches and drains',
      (tester) async {
        // The post-login re-drain toasts on success, so this needs the app
        // shell like the other background-drain tests.
        await _pumpShell(tester);
        final auth = false.obs;
        final service = buildService(isAuthenticated: auth);
        service.onInit();

        // Signed out at cold start: nothing consumes the redelivery.
        iapService.emit(_purchase());
        await tester.pump();
        await tester.pump();
        expect(repository.registerCalls, 0);

        // Login: attach + restore-drain; the next redelivery is processed.
        auth.value = true;
        await tester.pump();
        await tester.pump();
        expect(iapService.restoreCalls, 1);

        iapService.emit(_purchase());
        await tester.pump();
        await tester.pump();
        expect(repository.registerCalls, 1);
        expect(iapService.completeCalls, 1);
        await _drainSnackbars(tester);
      },
    );

    testWidgets('logout detaches the stream and clears the claim set', (
      tester,
    ) async {
      await _pumpShell(tester);
      final auth = true.obs;
      final service = buildService(isAuthenticated: auth);
      service.onInit();

      iapService.emit(_purchase());
      await tester.pump();
      await tester.pump();
      expect(repository.registerCalls, 1);

      auth.value = false;
      await tester.pump();
      await tester.pump();

      // Post-logout redelivery reaches no listener: no verification, no
      // completion, and the next login re-drains it.
      iapService.emit(_purchase(purchaseID: 'GPA.after-logout'));
      await tester.pump();
      await tester.pump();
      expect(repository.registerCalls, 1);
      await _drainSnackbars(tester);
    });
  });

  group('page handoff (paywall open)', () {
    testWidgets('page and service never double-process the same transaction', (
      tester,
    ) async {
      await _pumpShell(tester);
      final service = buildService();
      final pageHandled = <PurchaseDetails>[];
      // Mirrors SubscriptionController: activate a handler that routes
      // purchased/restored updates back through verifyAndComplete.
      service.activatePageHandler((updates) {
        for (final details in updates) {
          if (details.status == PurchaseStatus.purchased ||
              details.status == PurchaseStatus.restored) {
            pageHandled.add(details);
            service.verifyAndComplete(
              details,
              restored: details.status == PurchaseStatus.restored,
              interactive: true,
            );
          }
        }
      });

      // One delivery: exactly one registration, from the page path.
      iapService.emit(_purchase());
      await tester.pump();
      await tester.pump();

      expect(pageHandled, hasLength(1));
      expect(repository.registerCalls, 1);
      expect(iapService.completeCalls, 1);

      // The background path seeing the SAME transaction (e.g. the page
      // closed mid-verify and the store re-emitted) is a no-op duplicate.
      final duplicate = await service.verifyAndComplete(
        _purchase(),
        restored: true,
      );
      expect(duplicate.outcome, PurchaseVerificationOutcome.duplicate);
      expect(repository.registerCalls, 1);
      expect(iapService.completeCalls, 1);

      // Closing the page hands updates back to the background drain.
      service.deactivatePageHandler();
      repository.registerError = null;
      iapService.emit(_purchase(serverVerificationData: 'token-next'));
      await tester.pump();
      await tester.pump();

      expect(pageHandled, hasLength(1));
      expect(repository.registerCalls, 2);
      expect(iapService.completeCalls, 2);
      await _drainSnackbars(tester);
    });

    test('page-open verification keeps its historical no-session behavior', () async {
      // The page path is interactive: it does not pre-gate on the session
      // (the API client surfaces auth failures), matching pre-refactor
      // behavior for a user whose session lapsed mid-checkout.
      final service = buildService(currentUserId: () => null);
      service.activatePageHandler((updates) {});
      final result = await service.verifyAndComplete(
        _purchase(),
        restored: false,
        interactive: true,
      );
      expect(result.outcome, PurchaseVerificationOutcome.verified);
      expect(repository.registerCalls, 1);
    });
  });

  group('terminal vs transient classification', () {
    test('4xx validation rejections are terminal', () {
      expect(
        PurchaseRecoveryService.isTerminalVerificationError(
          const ValidationException(message: 'unknown product'),
        ),
        isTrue,
      );
      expect(
        PurchaseRecoveryService.isTerminalVerificationError(
          const NotFoundException(message: 'product not found'),
        ),
        isTrue,
      );
      // 409-style conflicts (already linked to another account) ride the
      // DioException default branch into NetworkException with a 4xx code.
      expect(
        PurchaseRecoveryService.isTerminalVerificationError(
          const NetworkException(message: 'already used', statusCode: 409),
        ),
        isTrue,
      );
    });

    test('recoverable failures stay transient', () {
      // Expired access token: a refresh + redelivery passes.
      expect(
        PurchaseRecoveryService.isTerminalVerificationError(
          AuthException.unauthorized(),
        ),
        isFalse,
      );
      // Rate limit: a later retry passes.
      expect(
        PurchaseRecoveryService.isTerminalVerificationError(
          RateLimitException.defaultError(),
        ),
        isFalse,
      );
      // 5xx / network / unknown: the drain retries by design.
      expect(
        PurchaseRecoveryService.isTerminalVerificationError(
          ServerException.internalError(),
        ),
        isFalse,
      );
      expect(
        PurchaseRecoveryService.isTerminalVerificationError(
          NetworkException.noConnection(),
        ),
        isFalse,
      );
      expect(
        PurchaseRecoveryService.isTerminalVerificationError(
          Exception('backend down'),
        ),
        isFalse,
      );
    });
  });
}

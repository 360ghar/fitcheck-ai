import 'dart:async';

import 'package:fitcheck_ai/features/subscription/controllers/subscription_controller.dart';
import 'package:fitcheck_ai/features/subscription/models/subscription_model.dart';
import 'package:fitcheck_ai/features/subscription/repositories/subscription_repository.dart';
import 'package:fitcheck_ai/features/subscription/services/iap_service.dart';
import 'package:fitcheck_ai/features/subscription/views/subscription_page.dart';
import 'package:fitcheck_ai/features/subscription/views/widgets/subscription_disclosure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher_platform_interface/link.dart' show LinkDelegate;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Stub for the URL launcher platform channel (unavailable in widget tests).
class FakeUrlLauncherPlatform extends UrlLauncherPlatform {
  FakeUrlLauncherPlatform({this.canLaunchResult = false});

  final bool canLaunchResult;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => canLaunchResult;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async => true;
}

/// Fake IAP gateway with manually pumped purchase events.
class FakeIapService extends IapService {
  FakeIapService({bool storeBillingAvailable = true, String storeName = 'google'})
      : _storeBillingAvailable = storeBillingAvailable,
        _storeName = storeName;

  final bool _storeBillingAvailable;
  final String _storeName;
  final _streamController = StreamController<List<PurchaseDetails>>.broadcast();
  int fetchProductsCalls = 0;
  int startPurchaseCalls = 0;
  int restoreCalls = 0;
  int completeCalls = 0;
  Set<String>? lastQueriedIds;
  /// The appAccountToken the controller attached to the last purchase.
  String? lastAppAccountToken;
  List<ProductDetails> productsToReturn = const [];
  bool startPurchaseResult = true;
  /// When set, fetchProducts throws it instead of returning products (e.g.
  /// the storekit_no_response lookup failure).
  Object? fetchError;
  /// When set, fetchProducts waits on it before returning so tests can
  /// observe the in-flight checkout state.
  Completer<void>? fetchGate;

  @override
  bool get isStoreBillingAvailable => _storeBillingAvailable;

  @override
  bool get isApple => _storeName == 'apple';

  @override
  String get storeName =>
      _storeName; // flutter_test defaults to android; pass 'apple' for iOS tests

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _streamController.stream;

  @override
  Future<IapProductQuery> fetchProducts(
    Set<String> productIds, {
    int maxRetries = 2,
  }) async {
    fetchProductsCalls++;
    lastQueriedIds = productIds;
    final gate = fetchGate;
    if (gate != null) await gate.future;
    final error = fetchError;
    if (error != null) throw error;
    // Mirror the real service: anything the fake was not primed with is
    // reported as unrecognized by the store.
    final found = productsToReturn.map((p) => p.id).toSet();
    return IapProductQuery(
      products: productsToReturn,
      notFoundIds: productIds.difference(found),
    );
  }

  @override
  Future<bool> startPurchase(
    ProductDetails product, {
    String? appAccountToken,
  }) async {
    startPurchaseCalls++;
    lastAppAccountToken = appAccountToken;
    return startPurchaseResult;
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

  void dispose() => _streamController.close();
}

/// Fake repository; only the IAP registration path is exercised.
class FakeSubscriptionRepository extends SubscriptionRepository {
  int registerCalls = 0;
  int checkoutCalls = 0;
  int portalCalls = 0;
  String? lastStore;
  String? lastTransactionId;
  String? lastProductId;
  Object? registerError;
  SubscriptionModel? registerResult;

  // Overrides for the onInit fetches so the widget-level page test runs
  // without touching the real API client.
  /// What [getSubscription] returns; page tests override this to simulate
  /// free / Plus / Pro subscribers.
  SubscriptionModel subscriptionResult = const SubscriptionModel(userId: 'user-1');

  @override
  Future<SubscriptionWithUsage> getSubscription() async {
    return SubscriptionWithUsage(
      subscription: subscriptionResult,
      usage: const UsageLimitsModel(),
    );
  }

  /// What [getPlans] returns; defaults to an unconfigured rail (which the
  /// controller fail-closes on). Tests that need a resolvable store product
  /// set this to a map carrying the plan type they check out.
  PlansResponse plansResponse = const PlansResponse();

  @override
  Future<PlansResponse> getPlans() async => plansResponse;

  @override
  Future<ReferralCodeModel> getReferralCode() async =>
      const ReferralCodeModel(
        code: 'TESTCODE',
        shareUrl: 'https://example.com/r/TESTCODE',
      );

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
    lastStore = store;
    lastTransactionId = transactionId;
    lastProductId = productId;
    final error = registerError;
    if (error != null) throw error;
    return registerResult ??
        SubscriptionModel(
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
    checkoutCalls++;
    return const CheckoutSessionModel();
  }

  @override
  Future<String> createPortalSession() async {
    portalCalls++;
    return '';
  }
}

ProductDetails _product(String id) => ProductDetails(
  id: id,
  title: 'Plus Monthly',
  description: 'Monthly plan',
  price: r'$9.99',
  rawPrice: 9.99,
  currencyCode: 'USD',
);

/// Store-products map with the plan type as the store product ID, so
/// checkout tests resolve a product ID without depending on the backend map.
/// (The controller fail-closes on an unconfigured rail by design — the
/// plan-type fallback was removed after it produced `storekit_no_response`.)
StoreProductsModel _storeProducts({
  String store = 'google',
  String planType = 'plus_monthly',
  String productId = 'plus_monthly',
}) =>
    StoreProductsModel.fromJson({
      store: {planType: productId},
    });

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
    UrlLauncherPlatform.instance = FakeUrlLauncherPlatform();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) async {
    Get.closeAllSnackbars();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  SubscriptionController buildController() {
    final controller = SubscriptionController(
      iapService: iapService,
      repository: repository,
    );
    // Attach the store-purchase listener without running the full onInit
    // data fetch (which would hit the real API client).
    controller.attachPurchaseListener();
    return controller;
  }

  group('SubscriptionController mobile purchases', () {
    testWidgets('startCheckout purchases through the store on mobile', (
      tester,
    ) async {
      await pumpApp(tester);
      iapService.productsToReturn = [_product('plus_monthly')];
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();

      await controller.startCheckout('plus_monthly');

      expect(iapService.fetchProductsCalls, 1);
      expect(iapService.lastQueriedIds, {'plus_monthly'});
      expect(iapService.startPurchaseCalls, 1);
      // The Stripe path must never run on mobile.
      expect(repository.checkoutCalls, 0);
      expect(controller.error.value, isEmpty);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('store purchase result registers with the backend and completes', (
      tester,
    ) async {
      await pumpApp(tester);
      final controller = buildController();
      final purchase = _purchase();

      iapService.emit(purchase);
      await tester.pump();
      await tester.pump();

      expect(repository.registerCalls, 1);
      expect(repository.lastStore, 'google');
      expect(repository.lastTransactionId, 'token-abc');
      expect(repository.lastProductId, 'plus_monthly');
      expect(iapService.completeCalls, 1);
      expect(controller.subscription.value?.billingProvider, 'google');
      expect(controller.subscription.value?.planType, PlanType.plusMonthly);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('registration failure keeps the purchase uncompleted', (
      tester,
    ) async {
      await pumpApp(tester);
      repository.registerError = Exception('verification failed');
      final controller = buildController();

      iapService.emit(_purchase());
      await tester.pump();
      await tester.pump();

      expect(repository.registerCalls, 1);
      // Never complete a purchase whose server verification failed: the
      // store keeps it pending for redelivery.
      expect(iapService.completeCalls, 0);
      expect(controller.error.value, contains('verification failed'));
      await settle(tester);
      controller.onClose();
    });

    testWidgets('pending purchase shows a message without registering', (
      tester,
    ) async {
      await pumpApp(tester);
      final controller = buildController();

      iapService.emit(_purchase(status: PurchaseStatus.pending));
      await tester.pump();
      await tester.pump();

      expect(repository.registerCalls, 0);
      expect(iapService.completeCalls, 0);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('restored purchases register and are completed', (
      tester,
    ) async {
      await pumpApp(tester);
      final controller = buildController();

      iapService.emit(_purchase(status: PurchaseStatus.restored));
      await tester.pump();
      await tester.pump();

      expect(repository.registerCalls, 1);
      expect(iapService.completeCalls, 1);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('restorePurchases asks the store', (tester) async {
      await pumpApp(tester);
      final controller = buildController();

      await controller.restorePurchases();

      expect(iapService.restoreCalls, 1);
      controller.onClose();
    });

    testWidgets('unavailable plan product is surfaced without launching a purchase', (
      tester,
    ) async {
      await pumpApp(tester);
      iapService.productsToReturn = const [];
      final controller = buildController();

      await controller.startCheckout('pro_yearly');
      await tester.pump();

      expect(iapService.startPurchaseCalls, 0);
      expect(controller.error.value, contains('not available'));
      // The Upgrade tap must never look like it did nothing.
      expect(Get.isSnackbarOpen, isTrue);
      // Drain the snackbar animation before the tree is disposed, or its
      // controller leaks into the next test.
      await settle(tester);
      controller.onClose();
    });

    testWidgets('store lookup failure surfaces a friendly message, never the raw StoreKit error', (
      tester,
    ) async {
      await pumpApp(tester);
      // The plugin's storekit_no_response: StoreKit resolved zero products
      // for the requested ID. Regression: the message used to interpolate
      // the raw APError(...) dump into the "Purchase failed" snackbar, and
      // the wording used to promise "try again in a moment" for a state that
      // only clears on the App Store Connect side.
      iapService.fetchError = IapException(
        message: kPlanNotAvailableInStoreMessage,
        errorCode: 'storekit_no_response',
        details: 'IAPError(code: storekit_no_response, source: app_store, '
            'message: StoreKit: Failed to get response from platform., '
            'details: null)',
      );
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();

      await controller.startCheckout('plus_monthly');
      await tester.pump();

      expect(iapService.fetchProductsCalls, 1);
      expect(iapService.startPurchaseCalls, 0);
      // No raw platform dump may reach the user.
      expect(controller.error.value, isNot(contains('APError')));
      expect(controller.error.value, isNot(contains('StoreKit')));
      expect(controller.error.value, contains('not available in the store yet'));
      expect(Get.isSnackbarOpen, isTrue);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('billing unavailable surfaces a snackbar', (tester) async {
      await pumpApp(tester);
      iapService = FakeIapService(storeBillingAvailable: false);
      repository = FakeSubscriptionRepository();
      final controller = buildController();

      await controller.startCheckout('plus_monthly');

      expect(iapService.fetchProductsCalls, 0);
      expect(controller.error.value, contains('not available'));
      expect(Get.isSnackbarOpen, isTrue);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('only the tapped plan card shows the checkout spinner', (
      tester,
    ) async {
      await pumpApp(tester);
      iapService.productsToReturn = [_product('plus_monthly')];
      iapService.fetchGate = Completer<void>();
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();

      final checkout = controller.startCheckout('plus_monthly');
      await tester.pump();

      expect(controller.isCheckingOut.value, isTrue);
      expect(controller.isCheckingOutPlan('plus_monthly'), isTrue);
      expect(controller.isCheckingOutPlan('plus_yearly'), isFalse);

      iapService.fetchGate!.complete();
      await checkout;
      expect(controller.isCheckingOutPlan('plus_monthly'), isFalse);
      expect(controller.isCheckingOut.value, isFalse);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('a second checkout tap is ignored while one is in flight', (
      tester,
    ) async {
      await pumpApp(tester);
      iapService.productsToReturn = [_product('plus_monthly')];
      iapService.fetchGate = Completer<void>();
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();

      final first = controller.startCheckout('plus_monthly');
      await tester.pump();
      // Re-entry guard: a tap on a DIFFERENT card while the first checkout
      // is in flight must not launch a second store flow.
      await controller.startCheckout('pro_yearly');
      await tester.pump();

      expect(iapService.fetchProductsCalls, 1);
      expect(controller.checkingOutPlanType.value, 'plus_monthly');
      expect(controller.isCheckingOutPlan('pro_yearly'), isFalse);

      iapService.fetchGate!.complete();
      await first;
      expect(iapService.startPurchaseCalls, 1);
      expect(controller.isCheckingOut.value, isFalse);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('purchase error surfaces a friendly message, never raw platform text', (
      tester,
    ) async {
      await pumpApp(tester);
      final controller = buildController();

      // The plugin reports purchase failures with a raw platform error dump
      // (IAPError). Regression: the snackbar used to show it verbatim.
      final purchase = _purchase(status: PurchaseStatus.error);
      // `error` is a mutable field on PurchaseDetails (not a ctor param).
      purchase.error = IAPError(
        source: 'app_store',
        code: 'payment_failed',
        message: 'StoreKit: Failed to get response from platform.',
      );
      iapService.emit(purchase);
      await tester.pump();
      await tester.pump();

      expect(repository.registerCalls, 0);
      expect(iapService.completeCalls, 0);
      // User-visible text is the stable friendly message only.
      expect(controller.error.value, contains('Please try again'));
      expect(controller.error.value, isNot(contains('StoreKit')));
      expect(controller.error.value, isNot(contains('IAPError')));
      expect(Get.isSnackbarOpen, isTrue);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('localized store price resolves by plan type for real product IDs', (
      tester,
    ) async {
      await pumpApp(tester);
      // Real store product IDs (e.g. the FitCheck.storekit scheme): the
      // price must still resolve for the plan type the UI asks for.
      final productId = 'com.fitcheckaiapp.fitcheckai.plus.monthly';
      iapService.productsToReturn = [_product(productId)];
      final controller = buildController();
      controller.storeProducts.value = StoreProductsModel.fromJson({
        'google': {'plus_monthly': productId},
      });

      await controller.refreshStoreProducts();

      expect(iapService.lastQueriedIds, {productId});
      expect(controller.storePriceFor('plus_monthly'), r'$9.99');
      controller.onClose();
    });

    testWidgets('store-billed cancel is refused locally', (tester) async {
      await pumpApp(tester);
      final controller = buildController();
      controller.subscription.value = SubscriptionModel(
        userId: 'user-1',
        planType: PlanType.plusMonthly,
        billingProvider: 'apple',
      );

      await controller.cancelSubscription();

      // The store owns billing; nothing may call the Stripe cancel endpoint.
      expect(controller.isStoreBilled, isTrue);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('checkout uses cached product details and skips the store query', (
      tester,
    ) async {
      await pumpApp(tester);
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();
      // Page-load already cached the product; checkout must reuse it instead
      // of re-querying the store. A transient storekit error at the tap used
      // to hard-fail even with valid details on hand.
      controller.storeProductDetails['plus_monthly'] = _product('plus_monthly');
      // Would trip the empty-list branch if the cache were ignored.
      iapService.productsToReturn = const [];

      await controller.startCheckout('plus_monthly');

      expect(iapService.fetchProductsCalls, 0);
      expect(iapService.startPurchaseCalls, 1);
      expect(controller.error.value, isEmpty);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('checkout falls back to the store query when the cache misses', (
      tester,
    ) async {
      await pumpApp(tester);
      iapService.productsToReturn = [_product('plus_monthly')];
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();

      await controller.startCheckout('plus_monthly');

      expect(iapService.fetchProductsCalls, 1);
      expect(iapService.startPurchaseCalls, 1);
      expect(controller.error.value, isEmpty);
      await settle(tester);
      controller.onClose();
    });
  });

  group('SubscriptionController iOS (Apple IAP only)', () {
    testWidgets('iOS startCheckout uses StoreKit and never Stripe checkout', (
      tester,
    ) async {
      await pumpApp(tester);
      iapService = FakeIapService(storeName: 'apple');
      repository = FakeSubscriptionRepository();
      iapService.productsToReturn = [_product('plus_monthly')];
      final controller = buildController();
      controller.storeProducts.value = _storeProducts(store: 'apple');

      await controller.startCheckout('plus_monthly');

      expect(iapService.fetchProductsCalls, 1);
      expect(iapService.startPurchaseCalls, 1);
      // The Stripe checkout path must never run on iOS (Guideline 3.1.1).
      expect(repository.checkoutCalls, 0);

      // A completed StoreKit transaction registers with the backend as Apple.
      iapService.emit(_purchase(
        purchaseID: '100000123456789',
        serverVerificationData: '100000123456789',
      ));
      await tester.pump();
      await tester.pump();

      expect(repository.registerCalls, 1);
      expect(repository.lastStore, 'apple');
      expect(repository.lastTransactionId, '100000123456789');
      expect(iapService.completeCalls, 1);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('iOS manage subscription opens App Store settings, never the Stripe portal', (
      tester,
    ) async {
      await pumpApp(tester);
      iapService = FakeIapService(storeName: 'apple');
      repository = FakeSubscriptionRepository();
      final controller = buildController();
      // Stub the URL launcher so the harness cannot hang on the real
      // platform channel; the App Store URL is not launchable here.
      UrlLauncherPlatform.instance = FakeUrlLauncherPlatform(canLaunchResult: false);

      await controller.openManageSubscription();

      // The Stripe billing portal is web-only. iOS points at App Store
      // subscription settings; the stub cannot launch the URL, so the
      // controller reports that instead of falling through to Stripe.
      expect(repository.portalCalls, 0);
      expect(controller.error.value, contains('Could not open'));
      await settle(tester);
      controller.onClose();
    });
  });

  group('SubscriptionPage upgrade flow', () {
    // End-to-end regression for "clicking Upgrade under a plan does
    // nothing": the real page, the real button, a store that has no
    // products -> the tap must surface a snackbar.
    testWidgets('tapping Upgrade on a plan card shows why the purchase failed', (
      tester,
    ) async {
      // Single GetMaterialApp: mounting a second one (as pumpApp + pumpWidget
      // would) leaves GetX's snackbar overlay pointing at the disposed app.
      iapService.productsToReturn = const [];
      // The backend publishes a resolvable product ID, but the store itself
      // has no products: the tap must surface the store-level message.
      repository.plansResponse = PlansResponse(
        storeProducts: _storeProducts(),
      );
      final controller = SubscriptionController(
        iapService: iapService,
        repository: repository,
      );
      Get.put(controller);
      await tester.pumpWidget(const GetMaterialApp(home: SubscriptionPage()));
      await tester.pumpAndSettle();

      // Free user sees both tiers; the first Upgrade button is Plus Monthly.
      expect(find.text('Upgrade'), findsWidgets);

      final upgradeButton = find.text('Upgrade').first;
      // The plan rows sit below the fold in the test viewport; scroll the
      // tapped card into view so the tap actually lands on the button.
      await tester.ensureVisible(upgradeButton);
      await tester.pumpAndSettle();
      await tester.tap(upgradeButton);
      await tester.pump();

      // The tap must never look like it did nothing.
      expect(iapService.startPurchaseCalls, 0);
      expect(controller.error.value, contains('not available in the store yet'));
      // The snackbar (with its message) is the visible outcome of the tap.
      expect(Get.isSnackbarOpen, isTrue);
      expect(
        find.textContaining('not available in the store yet'),
        findsOneWidget,
      );
      await settle(tester);
    });

    testWidgets('paywall shows a store-unavailable banner whose Retry self-heals', (
      tester,
    ) async {
      // The store answers with zero products (e.g. App Store Connect not
      // serving them yet): the paywall must say so above the cards instead of
      // presenting dead Upgrade buttons, and Retry must recover once the
      // store starts serving products — without an app restart.
      iapService.productsToReturn = const [];
      repository.plansResponse = PlansResponse(
        storeProducts: _storeProducts(),
      );
      final controller = SubscriptionController(
        iapService: iapService,
        repository: repository,
      );
      Get.put(controller);
      await tester.pumpWidget(const GetMaterialApp(home: SubscriptionPage()));
      await tester.pumpAndSettle();

      expect(controller.storeStatus.value, StoreStatus.unavailable);
      final banner = find.textContaining('aren\'t available in the store yet');
      await tester.scrollUntilVisible(
        banner,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(banner, findsOneWidget);

      // Retry: the store now resolves the product; the banner disappears and
      // prices (and the Upgrade flow) come back. Target the banner's
      // TextButton explicitly — the load-error card also uses a "Retry"
      // label (on an OutlinedButton, which would not match).
      iapService.productsToReturn = [_product('plus_monthly')];
      await tester.tap(find.widgetWithText(TextButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(controller.storeStatus.value, StoreStatus.ready);
      expect(find.textContaining('aren\'t available in the store yet'), findsNothing);
      await settle(tester);
    });

    testWidgets('no store banner when the store is ready', (tester) async {
      iapService.productsToReturn = [_product('plus_monthly')];
      repository.plansResponse = PlansResponse(
        storeProducts: _storeProducts(),
      );
      final controller = SubscriptionController(
        iapService: iapService,
        repository: repository,
      );
      Get.put(controller);
      await tester.pumpWidget(const GetMaterialApp(home: SubscriptionPage()));
      await tester.pumpAndSettle();

      expect(controller.storeStatus.value, StoreStatus.ready);
      expect(
        find.textContaining('aren\'t available in the store yet'),
        findsNothing,
      );
      await settle(tester);
    });

    testWidgets('Restore Purchases renders for a Pro subscriber with no upgrade section', (
      tester,
    ) async {
      // Pro users have no higher tier (canUpgrade == false), so the upgrade
      // section — and with it the old restore button — used to disappear.
      // Restore must render independently of the upgrade section.
      repository.subscriptionResult = const SubscriptionModel(
        userId: 'user-1',
        planType: PlanType.proMonthly,
        billingProvider: 'apple',
      );
      final controller = SubscriptionController(
        iapService: iapService,
        repository: repository,
      );
      Get.put(controller);
      await tester.pumpWidget(const GetMaterialApp(home: SubscriptionPage()));
      await tester.pumpAndSettle();

      expect(find.text('Upgrade'), findsNothing);
      expect(find.text('Restore Purchases'), findsOneWidget);
      // The manage section sits at the bottom of the ListView, below the
      // fold in the test viewport; scroll it into view (ListView children
      // build lazily, so it does not exist in the tree until scrolled to).
      await tester.scrollUntilVisible(
        find.text('Manage in Store'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      // Store-billed Pro row still shows the manage entry.
      expect(find.text('Manage in Store'), findsOneWidget);
    });

    testWidgets('a refunded subscription renders as not entitled', (
      tester,
    ) async {
      // The admin "mark IAP transaction refunded" flow writes status=refunded
      // (status-only update). The backend serves plan_type=free for refunded
      // rows, so the client must treat the row as not entitled: the paywall
      // renders and no paid-row manage/cancel section may appear. Parsing the
      // row must not throw (regression: the unknown enum value crashed the
      // subscription page).
      repository.subscriptionResult = const SubscriptionModel(
        userId: 'user-1',
        planType: PlanType.free,
        status: SubscriptionStatus.refunded,
        billingProvider: 'apple',
      );
      final controller = SubscriptionController(
        iapService: iapService,
        repository: repository,
      );
      Get.put(controller);
      await tester.pumpWidget(const GetMaterialApp(home: SubscriptionPage()));
      await tester.pumpAndSettle();

      // Entitlement is derived from plan type, which the backend serves as
      // free for refunded rows.
      expect(controller.isPro, isFalse);
      expect(controller.isCancelled, isFalse);
      expect(controller.planName, 'Free');
      // The paywall (upgrade CTAs) renders for the not-entitled state.
      expect(find.text('Upgrade'), findsWidgets);
    });

    testWidgets('the paywall discloses auto-renewal and links Terms + Privacy', (
      tester,
    ) async {
      // App Store Guideline 3.1.2: the purchase screen itself must state the
      // auto-renewing terms and carry functional Terms of Use / Privacy
      // Policy links. Links at signup or in Settings do not satisfy it.
      repository.plansResponse = PlansResponse(storeProducts: _storeProducts());
      final controller = SubscriptionController(
        iapService: iapService,
        repository: repository,
      );
      Get.put(controller);
      await tester.pumpWidget(const GetMaterialApp(home: SubscriptionPage()));
      await tester.pumpAndSettle();

      final disclosure = find.byType(SubscriptionDisclosure);
      await tester.scrollUntilVisible(
        disclosure,
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Terms of Use'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.textContaining('auto-renewing subscriptions'), findsOneWidget);
      expect(find.textContaining('renews automatically'), findsOneWidget);
      // Price and duration must be on the purchase screen too.
      expect(find.textContaining(r'$10/month'), findsOneWidget);
    });

    testWidgets('a Plus subscriber only sees terms for the plan they can buy', (
      tester,
    ) async {
      // Plus subscribers are offered Pro only, so quoting Plus prices beside a
      // lone Pro card would disclose terms for something not on sale here.
      repository.subscriptionResult = const SubscriptionModel(
        userId: 'user-1',
        planType: PlanType.plusMonthly,
        billingProvider: 'apple',
      );
      repository.plansResponse = PlansResponse(storeProducts: _storeProducts());
      final controller = SubscriptionController(
        iapService: iapService,
        repository: repository,
      );
      Get.put(controller);
      await tester.pumpWidget(const GetMaterialApp(home: SubscriptionPage()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(SubscriptionDisclosure),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.textContaining('Pro is an auto-renewing subscription'),
        findsOneWidget,
      );
      expect(find.textContaining(r'Plus is $10/month'), findsNothing);
      // The links are still required on the purchase screen.
      expect(find.text('Terms of Use'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('the purchase carries the user id as the appAccountToken', (
      tester,
    ) async {
      // Without it, a first purchase whose register call is lost leaves the
      // webhook with no way to resolve the owning user, so the entitlement is
      // never granted.
      await pumpApp(tester);
      iapService.productsToReturn = [_product('plus_monthly')];
      final controller = SubscriptionController(
        iapService: iapService,
        repository: repository,
        currentUserId: () => 'user-uuid-1',
      );
      controller.attachPurchaseListener();
      controller.storeProducts.value = _storeProducts();

      await controller.startCheckout('plus_monthly');

      expect(iapService.startPurchaseCalls, 1);
      expect(iapService.lastAppAccountToken, 'user-uuid-1');
      await settle(tester);
      controller.onClose();
    });
  });

  group('store product diagnostics', () {
    testWidgets('unrecognized product IDs are recorded, not silently dropped', (
      tester,
    ) async {
      // The store answers successfully and simply omits IDs it does not know,
      // so ignoring them made a real setup failure (product not created in
      // App Store Connect, agreements unsigned, wrong bundle namespace) look
      // exactly like success: a paywall with no prices and no explanation.
      await pumpApp(tester);
      iapService.productsToReturn = const [];
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();

      await controller.refreshStoreProducts();

      expect(controller.storePriceFor('plus_monthly'), isNull);
      expect(controller.missingStoreProductIds, ['plus_monthly']);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('a fully resolved store leaves no missing IDs', (tester) async {
      await pumpApp(tester);
      iapService.productsToReturn = [_product('plus_monthly')];
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();

      await controller.refreshStoreProducts();

      expect(controller.missingStoreProductIds, isEmpty);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('store status is notConfigured when the backend publishes no IDs', (
      tester,
    ) async {
      // The default PlansResponse has an all-null store map (fail-closed):
      // nothing is queried and the rail is marked not configured.
      await pumpApp(tester);
      final controller = buildController();

      await controller.refreshStoreProducts();

      expect(controller.storeStatus.value, StoreStatus.notConfigured);
      expect(iapService.fetchProductsCalls, 0);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('store status is ready when products resolve', (tester) async {
      await pumpApp(tester);
      iapService.productsToReturn = [_product('plus_monthly')];
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();

      await controller.refreshStoreProducts();

      expect(controller.storeStatus.value, StoreStatus.ready);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('store status is unavailable when the store answers with zero products', (
      tester,
    ) async {
      await pumpApp(tester);
      iapService.productsToReturn = const [];
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();

      await controller.refreshStoreProducts();

      expect(controller.storeStatus.value, StoreStatus.unavailable);
      expect(controller.missingStoreProductIds, ['plus_monthly']);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('store status is unavailable when the store query fails', (
      tester,
    ) async {
      await pumpApp(tester);
      iapService.fetchError = IapException(
        message: kPlanNotAvailableInStoreMessage,
        errorCode: 'storekit_no_response',
      );
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();

      await controller.refreshStoreProducts();

      expect(controller.storeStatus.value, StoreStatus.unavailable);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('a transient store error keeps the status unknown', (
      tester,
    ) async {
      // Only the definitive zero-products failure (storekit_no_response)
      // marks the rail unavailable. A transient network / store-server error
      // must NOT raise the "not available in the store yet" banner: the
      // checkout path re-queries with its own retries and gets the accurate
      // "couldn't be reached" message.
      await pumpApp(tester);
      iapService.fetchError = IapException(
        message: 'The store couldn\'t be reached for this plan right now. '
            'Please try again in a moment.',
        errorCode: 'storekit2_products_error',
      );
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();

      await controller.refreshStoreProducts();

      expect(controller.storeStatus.value, StoreStatus.unknown);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('a transient retry does not clear an already-unavailable store', (
      tester,
    ) async {
      // Page load: definitive zero-products failure -> unavailable. A later
      // Retry hitting a transient store error must not clear the banner —
      // the underlying state (products not served) has not changed.
      await pumpApp(tester);
      iapService.productsToReturn = const [];
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();
      await controller.refreshStoreProducts();
      expect(controller.storeStatus.value, StoreStatus.unavailable);

      iapService.fetchError = IapException(
        message: 'The store couldn\'t be reached for this plan right now. '
            'Please try again in a moment.',
        errorCode: 'storekit2_products_error',
      );
      await controller.refreshStoreProducts();

      expect(controller.storeStatus.value, StoreStatus.unavailable);
      await settle(tester);
      controller.onClose();
    });

    testWidgets('checkout fails fast when the store already failed this session', (
      tester,
    ) async {
      // The page-load store query failed; re-querying at the tap can only
      // repeat the same failure after its retry delay. The tap must report
      // the accurate message immediately without touching the store again.
      await pumpApp(tester);
      iapService.productsToReturn = const [];
      final controller = buildController();
      controller.storeProducts.value = _storeProducts();
      await controller.refreshStoreProducts();
      expect(controller.storeStatus.value, StoreStatus.unavailable);
      final callsBefore = iapService.fetchProductsCalls;

      await controller.startCheckout('plus_monthly');

      expect(iapService.fetchProductsCalls, callsBefore);
      expect(iapService.startPurchaseCalls, 0);
      expect(controller.error.value, contains('not available in the store yet'));
      expect(Get.isSnackbarOpen, isTrue);
      await settle(tester);
      controller.onClose();
    });
  });
}

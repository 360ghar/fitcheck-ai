import 'dart:async';

import 'package:fitcheck_ai/features/subscription/controllers/subscription_controller.dart';
import 'package:fitcheck_ai/features/subscription/models/subscription_model.dart';
import 'package:fitcheck_ai/features/subscription/repositories/subscription_repository.dart';
import 'package:fitcheck_ai/features/subscription/services/iap_service.dart';
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
  List<ProductDetails> productsToReturn = const [];
  bool startPurchaseResult = true;
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
  Future<List<ProductDetails>> fetchProducts(Set<String> productIds) async {
    fetchProductsCalls++;
    lastQueriedIds = productIds;
    final gate = fetchGate;
    if (gate != null) await gate.future;
    return productsToReturn;
  }

  @override
  Future<bool> startPurchase(ProductDetails product) async {
    startPurchaseCalls++;
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
}

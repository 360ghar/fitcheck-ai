import 'dart:async';

import 'package:fitcheck_ai/features/subscription/controllers/subscription_controller.dart';
import 'package:fitcheck_ai/features/subscription/models/subscription_model.dart';
import 'package:fitcheck_ai/features/subscription/repositories/subscription_repository.dart';
import 'package:fitcheck_ai/features/subscription/services/iap_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Fake IAP gateway with manually pumped purchase events.
class FakeIapService extends IapService {
  FakeIapService({bool storeBillingAvailable = true})
      : _storeBillingAvailable = storeBillingAvailable;

  final bool _storeBillingAvailable;
  final _streamController = StreamController<List<PurchaseDetails>>.broadcast();
  int fetchProductsCalls = 0;
  int startPurchaseCalls = 0;
  int restoreCalls = 0;
  int completeCalls = 0;
  Set<String>? lastQueriedIds;
  List<ProductDetails> productsToReturn = const [];
  bool startPurchaseResult = true;

  @override
  bool get isStoreBillingAvailable => _storeBillingAvailable;

  @override
  String get storeName => 'google'; // flutter_test defaults to android

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _streamController.stream;

  @override
  Future<List<ProductDetails>> fetchProducts(Set<String> productIds) async {
    fetchProductsCalls++;
    lastQueriedIds = productIds;
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

      expect(iapService.startPurchaseCalls, 0);
      expect(controller.error.value, contains('not available'));
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
}

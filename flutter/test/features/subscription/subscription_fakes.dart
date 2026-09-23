import 'dart:async';

import 'package:fitcheck_ai/features/subscription/models/subscription_model.dart';
import 'package:fitcheck_ai/features/subscription/repositories/subscription_repository.dart';
import 'package:fitcheck_ai/features/subscription/services/iap_service.dart';
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

/// Fake store gateway with manually pumped purchase events.
class FakeIapService extends IapService {
  FakeIapService({
    bool storeBillingAvailable = true,
    String storeName = 'google',
  }) : _storeBillingAvailable = storeBillingAvailable,
       _storeName = storeName;

  final bool _storeBillingAvailable;
  final String _storeName;
  final _streamController = StreamController<List<PurchaseDetails>>.broadcast();
  int fetchProductsCalls = 0;
  int startPurchaseCalls = 0;
  int restoreCalls = 0;
  int completeCalls = 0;
  Set<String>? lastQueriedIds;

  /// The account token attached to the last purchase.
  String? lastAppAccountToken;
  List<ProductDetails> productsToReturn = const [];
  bool startPurchaseResult = true;

  /// When set, fetchProducts throws it (for example storekit_no_response).
  Object? fetchError;

  /// When set, fetchProducts waits on it before returning.
  Completer<void>? fetchGate;

  /// When set, restorePurchases waits on it.
  Completer<void>? restoreGate;

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
    fetchProductsCalls++;
    lastQueriedIds = productIds;
    final gate = fetchGate;
    if (gate != null) await gate.future;
    final error = fetchError;
    if (error != null) throw error;
    // Like the real service: anything not primed is unrecognized.
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
    final gate = restoreGate;
    if (gate != null) await gate.future;
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

  void emit(PurchaseDetails details) => _streamController.add([details]);

  /// A plugin-level stream error (StoreKit2 Transaction.updates emits them).
  void emitError(Object error) => _streamController.addError(error);

  void dispose() => _streamController.close();
}

class FakeSubscriptionRepository extends SubscriptionRepository {
  int getSubscriptionCalls = 0;
  int getPlansCalls = 0;
  int getReferralCodeCalls = 0;
  int registerCalls = 0;
  int checkoutCalls = 0;
  int portalCalls = 0;
  int cancelCalls = 0;
  String? lastStore;
  String? lastTransactionId;
  String? lastProductId;
  Object? registerError;
  Object? subscriptionError;
  Object? plansError;
  SubscriptionModel? registerResult;

  /// When set, getSubscription waits on it.
  Completer<void>? subscriptionGate;

  SubscriptionModel subscriptionResult = const SubscriptionModel(
    userId: 'user-1',
  );
  UsageLimitsModel usageResult = const UsageLimitsModel(
    monthlyExtractions: 12,
    monthlyGenerations: 7,
  );
  ReferralStatsModel statsResult = const ReferralStatsModel();

  /// Defaults to an unconfigured rail (the paywall fails closed on it).
  PlansResponse plansResponse = const PlansResponse();

  @override
  Future<SubscriptionWithUsage> getSubscription() async {
    getSubscriptionCalls++;
    final gate = subscriptionGate;
    if (gate != null) await gate.future;
    final error = subscriptionError;
    if (error != null) throw error;
    return SubscriptionWithUsage(
      subscription: subscriptionResult,
      usage: usageResult,
    );
  }

  @override
  Future<UsageLimitsModel> getUsage() async => usageResult;

  @override
  Future<PlansResponse> getPlans() async {
    getPlansCalls++;
    final error = plansError;
    if (error != null) throw error;
    return plansResponse;
  }

  @override
  Future<ReferralCodeModel> getReferralCode() async {
    getReferralCodeCalls++;
    return const ReferralCodeModel(
      code: 'MAYA2026',
      shareUrl: 'https://example.com/r/MAYA2026',
      timesUsed: 3,
    );
  }

  @override
  Future<ReferralStatsModel> getReferralStats() async => statsResult;

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

  @override
  Future<void> cancelSubscription() async {
    cancelCalls++;
  }
}

ProductDetails fakeProduct(String id, {String price = r'$9.99'}) =>
    ProductDetails(
      id: id,
      title: id,
      description: id,
      price: price,
      rawPrice: double.parse(price.replaceAll(RegExp(r'[^0-9.]'), '')),
      currencyCode: 'USD',
      currencySymbol: r'$',
    );

/// A store map with the plan type as the store product ID.
StoreProductsModel fakeStoreProducts({
  String store = 'google',
  Map<String, String> ids = const {'plus_monthly': 'plus_monthly'},
}) => StoreProductsModel.fromJson({store: ids});

PurchaseDetails fakePurchase({
  String productId = 'plus_monthly',
  String serverVerificationData = 'token-abc',
  String? purchaseID = 'GPA.1234',
  PurchaseStatus status = PurchaseStatus.purchased,
}) => PurchaseDetails(
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

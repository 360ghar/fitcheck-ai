import 'package:fitcheck_ai/core/utils/error_handler.dart';
import 'package:fitcheck_ai/features/subscription/services/iap_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

/// Hermetic [InAppPurchasePlatform] stub.
///
/// Must `extend` (not `implements`) the platform interface so
/// `PlatformInterface.verify` accepts it, mirroring how the real StoreKit /
/// Play platforms register themselves.
class FakeInAppPurchasePlatform extends InAppPurchasePlatform {
  FakeInAppPurchasePlatform({required this.response});

  ProductDetailsResponse response;

  /// FIFO one-shot responses returned before [response], so a test can script
  /// "error on call 1, success on call 2" without rebuilding [response].
  final List<ProductDetailsResponse> queuedResponses = [];

  /// Number of times [queryProductDetails] was invoked (retry accounting).
  int queryCalls = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) {
    queryCalls++;
    if (queuedResponses.isNotEmpty) {
      return Future.value(queuedResponses.removeAt(0));
    }
    return Future.value(response);
  }
}

/// The exact platform error the plugin surfaces when StoreKit resolves no
/// product for the requested identifiers (e.g. product not yet created in
/// App Store Connect / not present in the local StoreKit configuration).
IAPError storekitNoResponseError() => IAPError(
  source: 'app_store',
  code: 'storekit_no_response',
  message: 'StoreKit: Failed to get response from platform.',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeInAppPurchasePlatform platform;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    // First `InAppPurchase.instance` access registers the real StoreKit
    // platform implementation (lazily, exactly once). Swap in the hermetic
    // stub afterwards so `queryProductDetails` never touches a real platform
    // channel.
    InAppPurchase.instance;
    platform = FakeInAppPurchasePlatform(
      response: ProductDetailsResponse(
        productDetails: const [],
        notFoundIDs: const [],
      ),
    );
    InAppPurchasePlatform.instance = platform;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('IapService.fetchProducts', () {
    test('maps a storekit_no_response lookup failure to a friendly IapException', () async {
      platform.response = ProductDetailsResponse(
        productDetails: const [],
        notFoundIDs: const ['plus_monthly'],
        error: storekitNoResponseError(),
      );

      final iap = IapService();
      await expectLater(
        iap.fetchProducts({'plus_monthly'}, maxRetries: 1),
        throwsA(
          isA<IapException>()
              .having((e) => e.errorCode, 'errorCode', 'storekit_no_response')
              // The user-visible message must never leak the raw platform
              // error dump.
              .having((e) => e.message, 'message', isNot(contains('APError')))
              .having((e) => e.message, 'message', isNot(contains('StoreKit')))
              // Telemetry keeps the full raw error for diagnosis.
              .having((e) => e.details, 'details', contains('storekit_no_response'))
              .having((e) => e.details, 'details', contains('IAPError'))
              // Enriched with the queried IDs for fast diagnosis.
              .having((e) => e.details, 'details', contains('plus_monthly')),
        ),
      );
      // maxRetries: 1 -> one failure then the final failure (2 calls total).
      expect(platform.queryCalls, 2);
    });

    test('ErrorHandler.extractMessage surfaces only the friendly message', () async {
      platform.response = ProductDetailsResponse(
        productDetails: const [],
        notFoundIDs: const ['plus_monthly'],
        error: storekitNoResponseError(),
      );

      final iap = IapService();
      try {
        await iap.fetchProducts({'plus_monthly'}, maxRetries: 1);
        fail('expected IapException');
      } on IapException catch (e) {
        final visible = ErrorHandler.extractMessage(e);
        expect(visible, e.message);
        expect(visible, isNot(contains('APError')));
        expect(visible, isNot(contains('StoreKit')));
        expect(visible, contains('try again'));
      }
    });

    test('returns product details when the store resolves them', () async {
      platform.response = ProductDetailsResponse(
        productDetails: [
          ProductDetails(
            id: 'com.fitcheckaiapp.fitcheckai.plus.monthly',
            title: 'Plus (Monthly)',
            description: 'Monthly plan',
            price: r'$9.99',
            rawPrice: 9.99,
            currencyCode: 'USD',
          ),
        ],
        notFoundIDs: const [],
      );

      final iap = IapService();
      final query = await iap.fetchProducts({
        'com.fitcheckaiapp.fitcheckai.plus.monthly',
      });

      expect(query.products, hasLength(1));
      expect(
        query.products.single.id,
        'com.fitcheckaiapp.fitcheckai.plus.monthly',
      );
      expect(query.notFoundIds, isEmpty);
      // Success on the first call is never retried.
      expect(platform.queryCalls, 1);
    });

    test('retries then succeeds when the first call errors transiently', () async {
      // Call 1: storekit_no_response (transient). Call 2: the product resolves.
      platform.queuedResponses.add(ProductDetailsResponse(
        productDetails: const [],
        notFoundIDs: const ['com.fitcheckaiapp.fitcheckai.plus.monthly'],
        error: storekitNoResponseError(),
      ));
      platform.response = ProductDetailsResponse(
        productDetails: [
          ProductDetails(
            id: 'com.fitcheckaiapp.fitcheckai.plus.monthly',
            title: 'Plus (Monthly)',
            description: 'Monthly plan',
            price: r'$9.99',
            rawPrice: 9.99,
            currencyCode: 'USD',
          ),
        ],
        notFoundIDs: const [],
      );

      final iap = IapService();
      final query = await iap.fetchProducts({
        'com.fitcheckaiapp.fitcheckai.plus.monthly',
      }, maxRetries: 2);

      expect(query.products, hasLength(1));
      expect(
        query.products.single.id,
        'com.fitcheckaiapp.fitcheckai.plus.monthly',
      );
      // First call errored, second call succeeded.
      expect(platform.queryCalls, 2);
    });

    test('an empty result (genuine missing product) is returned without retrying', () async {
      // No error -> the store answered (with zero products). This must not be
      // retried, so a real "not found" can never be masked as transient.
      platform.response = ProductDetailsResponse(
        productDetails: const [],
        notFoundIDs: const ['com.fitcheckaiapp.fitcheckai.plus.monthly'],
      );

      final iap = IapService();
      final query = await iap.fetchProducts({
        'com.fitcheckaiapp.fitcheckai.plus.monthly',
      });

      expect(query.products, isEmpty);
      // The store answered and did not recognize the ID: this is a setup
      // problem (product missing in App Store Connect / Play, agreements
      // unsigned, wrong bundle namespace), not a transient failure, and the
      // caller must be able to tell the difference.
      expect(query.notFoundIds, {'com.fitcheckaiapp.fitcheckai.plus.monthly'});
      expect(platform.queryCalls, 1);
    });

    test('empty identifier sets never touch the platform', () async {
      final iap = IapService();
      // Even with an erroring stub, an empty set short-circuits to [].
      expect((await iap.fetchProducts({})).products, isEmpty);
      expect(platform.queryCalls, 0);
    });
  });
}

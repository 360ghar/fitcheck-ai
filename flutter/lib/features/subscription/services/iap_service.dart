import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/exceptions/app_exceptions.dart';

/// Result of a store product lookup.
///
/// [notFoundIds] exists because the store reports an unknown product as a
/// silent absence, not an error: it is the difference between "the store is
/// fine and these IDs are wrong" and "the query succeeded". Treated as a
/// diagnostic, never shown to the user.
@immutable
class IapProductQuery {
  const IapProductQuery({required this.products, required this.notFoundIds});

  final List<ProductDetails> products;
  final Set<String> notFoundIds;

  bool get isEmpty => products.isEmpty;
}

/// Thin wrapper around the [InAppPurchase] plugin for subscription billing.
///
/// iOS purchases go through StoreKit, Android through Play Billing (both
/// managed by the plugin). The backend verifies every purchase server-side
/// (`POST /subscription/iap/transaction`) before granting entitlement, so
/// the client never trusts a PurchaseDetails payload on its own.
class IapService {
  IapService({InAppPurchase? purchase}) : _purchaseOverride = purchase;

  final InAppPurchase? _purchaseOverride;

  /// Resolved lazily so tests (and web builds) can construct the service
  /// without touching the platform plugin singleton.
  late final InAppPurchase _purchase = _purchaseOverride ?? InAppPurchase.instance;

  /// Whether store billing applies on this platform (iOS/Android native).
  bool get isStoreBillingAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  bool get isApple =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Store name sent to the backend ("apple" | "google").
  String get storeName => isApple ? 'apple' : 'google';

  /// Purchase results (the plugin delivers them in batches).
  Stream<List<PurchaseDetails>> get purchaseStream => _purchase.purchaseStream;

  /// Query the store for product details (localized prices come from here).
  ///
  /// Retries up to [maxRetries] times on a transient store error before
  /// throwing [IapException]. A genuinely-missing product resolves to an
  /// *empty* list with `response.error == null` (never an error), so retrying
  /// on the error path can never mask a real "not found" — only transient
  /// failures are retried. The most common one is the plugin's
  /// `storekit_no_response` ("StoreKit: Failed to get response from platform"),
  /// which surfaces on cold start / sandbox sync before the store is warm.
  ///
  /// When the store still cannot resolve the products after the retries, a
  /// friendly [IapException] is thrown. The raw platform error plus the
  /// queried IDs are kept in [IapException.details] for telemetry and never
  /// shown to the user — `ErrorHandler.extractMessage` surfaces only `message`.
  ///
  /// [IapProductQuery.notFoundIds] carries the IDs the store did not
  /// recognize. StoreKit reports those as a plain absence with no error, so
  /// discarding them made a real misconfiguration (product not created in App
  /// Store Connect, wrong bundle namespace, agreements not signed) look
  /// identical to success — the paywall just rendered with no prices. Callers
  /// must report a non-empty set rather than ignore it.
  Future<IapProductQuery> fetchProducts(
    Set<String> productIds, {
    int maxRetries = 2,
  }) async {
    if (productIds.isEmpty || !await _purchase.isAvailable()) {
      return const IapProductQuery(products: [], notFoundIds: {});
    }
    // StoreKit 2's Product.products(for:) can surface `storekit_no_response`
    // on cold start / sandbox sync / the first call of a session before the
    // store is warm. A single transient failure must not be terminal.
    for (var attempt = 0;; attempt++) {
      final response = await _purchase.queryProductDetails(productIds);
      if (response.error == null) {
        final found = response.productDetails.map((p) => p.id).toSet();
        return IapProductQuery(
          products: response.productDetails,
          notFoundIds: productIds.difference(found),
        );
      }
      if (attempt >= maxRetries) {
        throw IapException(
          message: 'The store couldn\'t be reached for this plan right now. '
              'Please try again in a moment.',
          errorCode: response.error!.code,
          details: 'ids=${productIds.join(',')} | ${response.error.toString()}',
        );
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Start the store purchase flow for one product.
  ///
  /// Returns true when the flow was launched; the actual result (purchased /
  /// pending / canceled / error) arrives on [purchaseStream].
  ///
  /// [appAccountToken] is the FitCheck user ID. On iOS the plugin forwards it
  /// as StoreKit's `appAccountToken`, which Apple echoes back on every server
  /// notification for the subscription. That is the backend's only way to
  /// resolve the owning user when the in-app register call never landed (first
  /// purchase + dropped network), so a purchase can no longer be stranded with
  /// no entitlement. Apple requires a UUID; Supabase user IDs already are one.
  Future<bool> startPurchase(
    ProductDetails product, {
    String? appAccountToken,
  }) async {
    if (!await _purchase.isAvailable()) {
      throw IapException(
        message: 'Store purchases are not available on this device.',
      );
    }
    try {
      return await _purchase.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: appAccountToken,
        ),
      );
    } on PlatformException catch (e) {
      // A purchase whose backend verification failed is deliberately left
      // uncompleted (see SubscriptionController._registerStorePurchase), and
      // StoreKit then refuses a second attempt at the same product until the
      // pending transaction is finished. It resolves itself on relaunch, when
      // the plugin redelivers the unfinished transaction — say so instead of
      // showing a generic "Purchase failed" the user can only retry into.
      if (e.code == 'storekit_duplicate_product_object') {
        throw IapException(
          message: 'This purchase is still being processed. Reopen the app in '
              'a moment and it will finish automatically.',
          errorCode: e.code,
          details: 'productId=${product.id} | ${e.toString()}',
        );
      }
      rethrow;
    }
  }

  /// Ask the store to redeliver past purchases (required by Apple 3.1.1 and
  /// Play policy; results arrive on [purchaseStream] with status restored).
  Future<void> restorePurchases() => _purchase.restorePurchases();

  /// Mark a purchase as delivered so the store stops tracking it.
  Future<void> complete(PurchaseDetails details) =>
      _purchase.completePurchase(details);

  /// The identifier the backend verifies for a given purchase:
  /// - Apple: the StoreKit transaction ID (App Store Server API).
  /// - Google: the purchase token (Play Developer API).
  String? transactionIdFor(PurchaseDetails details) {
    if (isApple) return details.purchaseID;
    // Android: serverVerificationData is the purchase token.
    final token = details.verificationData.serverVerificationData;
    return token.isEmpty ? null : token;
  }
}

/// Store-billing failure with a user-friendly [message].
///
/// Extends [AppException] so `ErrorHandler.extractMessage` returns only
/// [message] (never the raw platform error), while [toString] — what Sentry
/// serializes — keeps [details] for diagnosis.
class IapException extends AppException {
  const IapException({
    required super.message,
    super.errorCode,
    this.details,
  });

  /// The raw platform error (e.g. `IAPError(code: storekit_no_response, ...)`)
  /// for telemetry; never shown to the user.
  final String? details;

  @override
  String toString() =>
      details == null ? message : '$message | $details';
}

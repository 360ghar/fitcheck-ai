import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
  Future<List<ProductDetails>> fetchProducts(Set<String> productIds) async {
    if (productIds.isEmpty || !await _purchase.isAvailable()) {
      return const [];
    }
    final response = await _purchase.queryProductDetails(productIds);
    if (response.error != null) {
      throw IapException('Store product lookup failed: ${response.error}');
    }
    return response.productDetails;
  }

  /// Start the store purchase flow for one product.
  ///
  /// Returns true when the flow was launched; the actual result (purchased /
  /// pending / canceled / error) arrives on [purchaseStream].
  Future<bool> startPurchase(ProductDetails product) async {
    if (!await _purchase.isAvailable()) {
      throw IapException('Store purchases are not available on this device.');
    }
    return _purchase.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
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

class IapException implements Exception {
  IapException(this.message);

  final String message;

  @override
  String toString() => message;
}

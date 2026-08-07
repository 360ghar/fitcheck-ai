import 'package:fitcheck_ai/features/subscription/models/subscription_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes a direct subscription update without a checkout URL', () {
    final session = CheckoutSessionModel.fromJson({
      'checkout_url': null,
      'session_id': 'sub_existing',
      'updated': true,
    });

    expect(session.updated, isTrue);
    expect(session.checkoutUrl, isNull);
    expect(session.sessionId, 'sub_existing');
  });

  test('keeps normal checkout response compatibility', () {
    final session = CheckoutSessionModel.fromJson({
      'checkout_url': 'https://checkout.example/session',
      'session_id': 'cs_new',
    });

    expect(session.updated, isFalse);
    expect(session.checkoutUrl, startsWith('https://'));
    expect(session.sessionId, 'cs_new');
  });

  test('subscription defaults to Stripe billing provider', () {
    final sub = SubscriptionModel.fromJson({
      'user_id': 'user-1',
      'plan_type': 'free',
    });

    expect(sub.billingProvider, 'stripe');
  });

  test('subscription parses store billing provider', () {
    final sub = SubscriptionModel.fromJson({
      'user_id': 'user-1',
      'plan_type': 'plus_monthly',
      'billing_provider': 'apple',
    });

    expect(sub.billingProvider, 'apple');
  });

  test('refunded status parses without throwing (admin mark-refunded flow)', () {
    // The admin "mark IAP transaction refunded" action performs a status-only
    // update (subscriptions.status = "refunded") and /subscription/me serves
    // it alongside plan_type "free". An unknown enum value used to throw
    // ArgumentError from the generated enum decode, crashing the app on the
    // subscription page.
    final sub = SubscriptionModel.fromJson({
      'user_id': 'user-1',
      'plan_type': 'free',
      'status': 'refunded',
    });

    expect(sub.status, SubscriptionStatus.refunded);

    // Round-trip: serializing a refunded row must emit the same wire value.
    expect(sub.toJson()['status'], 'refunded');
  });

  test('store products parse and resolve per-variant product IDs', () {
    final products = StoreProductsModel.fromJson({
      'apple': {
        'plus_monthly': 'com.fitcheck.plus.monthly',
        'plus_yearly': 'com.fitcheck.plus.yearly',
        'pro_monthly': null,
      },
      'google': {
        'plus_monthly': 'com.fitcheck.plus.monthly',
      },
    });

    expect(products.productIdFor('apple', 'plus_monthly'), 'com.fitcheck.plus.monthly');
    expect(products.productIdFor('apple', 'pro_monthly'), isNull);
    expect(products.productIdFor('google', 'plus_monthly'), 'com.fitcheck.plus.monthly');
    expect(products.productIdFor('google', 'pro_yearly'), isNull);
  });

  test('store products fail closed when backend sent no map', () {
    const products = StoreProductsModel();

    expect(products.productIdFor('apple', 'plus_monthly'), isNull);
  });

  test('store products fail closed when every entry is null', () {
    // The backend always sends the full map (with null values when the store
    // rail is unconfigured), so an unconfigured rail must return null — never
    // a made-up identifier. Regression: the old plan-type fallback sent
    // "plus_monthly" to StoreKit, which matches nothing in App Store Connect
    // or the repo's StoreKit configuration file and produced
    // `storekit_no_response` on every upgrade tap.
    final products = StoreProductsModel.fromJson({
      'apple': {
        'plus_monthly': null,
        'plus_yearly': null,
        'pro_monthly': null,
        'pro_yearly': null,
      },
    });

    expect(products.productIdFor('apple', 'plus_monthly'), isNull);
    expect(products.productIdFor('apple', 'pro_yearly'), isNull);
  });

  test('store products never fall back when only some variants are configured', () {
    final products = StoreProductsModel.fromJson({
      'apple': {
        'plus_monthly': 'com.fitcheck.plus.monthly',
        'plus_yearly': null,
      },
    });

    // A configured rail must not silently use the plan type as a product ID.
    expect(products.productIdFor('apple', 'plus_monthly'), 'com.fitcheck.plus.monthly');
    expect(products.productIdFor('apple', 'plus_yearly'), isNull);
  });

  test('plans response parses billing_configured', () {
    final response = PlansResponse.fromJson({
      'plans': <Map<String, dynamic>>[],
      'store_products': <String, dynamic>{},
      'billing_configured': true,
    });

    expect(response.billingConfigured, isTrue);
  });

  test('plans response defaults billing_configured to false', () {
    final response = PlansResponse.fromJson({
      'plans': [],
    });

    expect(response.billingConfigured, isFalse);
  });

  test('plans response bundles plans with store products', () {
    final response = PlansResponse.fromJson({
      'plans': [
        {'id': 'plus', 'name': 'Plus'},
      ],
      'store_products': {
        'apple': {'plus_monthly': 'com.fitcheck.plus.monthly'},
      },
    });

    expect(response.plans, hasLength(1));
    expect(response.plans.first.id, 'plus');
    expect(response.storeProducts.productIdFor('apple', 'plus_monthly'), 'com.fitcheck.plus.monthly');
    expect(response.storeProducts.productIdFor('apple', 'plus_yearly'), isNull);
  });
}

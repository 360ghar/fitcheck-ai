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

  test('store products fall back to plan type only when backend sent no map', () {
    const products = StoreProductsModel();

    expect(products.productIdFor('apple', 'plus_monthly'), 'plus_monthly');
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

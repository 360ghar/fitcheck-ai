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
}

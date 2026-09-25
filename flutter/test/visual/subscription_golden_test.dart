@Tags(['golden'])
library;

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/features/gifts/models/gift_models.dart';
import 'package:fitcheck_ai/features/gifts/providers/gift_providers.dart';
import 'package:fitcheck_ai/features/gifts/views/gift_vouchers_page.dart';
import 'package:fitcheck_ai/features/subscription/models/subscription_model.dart';
import 'package:fitcheck_ai/features/subscription/providers/subscription_providers.dart';
import 'package:fitcheck_ai/features/subscription/services/purchase_recovery_service.dart';
import 'package:fitcheck_ai/features/subscription/views/referral_page.dart';
import 'package:fitcheck_ai/features/subscription/views/subscription_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/gifts/gift_fakes.dart';
import '../features/subscription/subscription_fakes.dart';
import 'visual_harness.dart';

const _allIds = {
  'plus_monthly': 'plus_monthly',
  'plus_yearly': 'plus_yearly',
  'pro_monthly': 'pro_monthly',
  'pro_yearly': 'pro_yearly',
};

void main() {
  setUpAll(loadAppFonts);

  late FakeIapService iap;
  late FakeSubscriptionRepository repo;

  setUp(() {
    iap = FakeIapService();
    repo = FakeSubscriptionRepository()
      ..statsResult = const ReferralStatsModel(
        totalReferrals: 5,
        successfulReferrals: 3,
        monthsEarned: 3,
      );
  });
  tearDown(() => iap.dispose());

  List overrides() => [
    subscriptionRepositoryProvider.overrideWithValue(repo),
    purchaseRecoveryServiceProvider.overrideWithValue(
      PurchaseRecoveryService(iapService: iap, repository: repo),
    ),
    giftRepositoryProvider.overrideWithValue(
      FakeGiftRepository(
        summary: GiftDashboardSummary(
          allowances: const [
            GiftAllowance(
              durationMonths: 1,
              grantedCount: 3,
              usedCount: 1,
              remainingCount: 2,
            ),
            GiftAllowance(
              durationMonths: 12,
              grantedCount: 1,
              usedCount: 0,
              remainingCount: 1,
            ),
          ],
          incoming: [fakeVoucher(fromName: 'Priya')],
        ),
      ),
    ),
  ];

  Future<void> snap(
    WidgetTester tester,
    Widget page,
    String file, {
    bool dark = false,
    String? scrollTo,
  }) async {
    await pumpPhone(tester, page, dark: dark, overrides: overrides());
    await tester.pump(const Duration(milliseconds: 300));
    if (scrollTo != null) {
      await Scrollable.ensureVisible(
        tester.element(find.text(scrollTo)),
        alignment: 0.02,
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$file.png'),
    );
  }

  void storeReady() {
    repo.plansResponse = PlansResponse(
      storeProducts: fakeStoreProducts(ids: _allIds),
    );
    iap.productsToReturn = [
      fakeProduct('plus_monthly', price: r'$9.99'),
      fakeProduct('plus_yearly', price: r'$99.99'),
      fakeProduct('pro_monthly', price: r'$19.99'),
      fakeProduct('pro_yearly', price: r'$199.99'),
    ];
  }

  testWidgets('paywall top', (tester) async {
    storeReady();
    await snap(tester, const SubscriptionPage(), 'paywall_top_light');
  });

  for (final dark in [false, true]) {
    testWidgets('paywall plans ${dark ? 'dark' : 'light'}', (tester) async {
      storeReady();
      await snap(
        tester,
        const SubscriptionPage(),
        'paywall_plans_${dark ? 'dark' : 'light'}',
        dark: dark,
        scrollTo: 'Choose a plan',
      );
    });
  }

  testWidgets('paywall pro subscriber', (tester) async {
    repo.subscriptionResult = SubscriptionModel(
      userId: 'user-1',
      planType: PlanType.proYearly,
      billingProvider: 'google',
      referralCreditMonths: 2,
      currentPeriodEnd: DateTime(2027, 3, 14),
    );
    await snap(tester, const SubscriptionPage(), 'paywall_pro_light');
  });

  testWidgets('paywall store unavailable', (tester) async {
    repo.plansResponse = PlansResponse(
      storeProducts: fakeStoreProducts(ids: _allIds),
    );
    await snap(
      tester,
      const SubscriptionPage(),
      'paywall_store_unavailable_light',
      scrollTo: 'Choose a plan',
    );
  });

  testWidgets('paywall load error', (tester) async {
    repo.subscriptionError = const ServerException(
      message: 'boom',
      statusCode: 500,
    );
    await snap(tester, const SubscriptionPage(), 'paywall_error_light');
  });

  testWidgets('referral page', (tester) async {
    await snap(tester, const ReferralPage(), 'referral_light');
  });

  testWidgets('gift vouchers page', (tester) async {
    await snap(tester, const GiftVouchersPage(), 'gifts_light');
  });

  testWidgets('gift vouchers form', (tester) async {
    await snap(
      tester,
      const GiftVouchersPage(),
      'gifts_form_light',
      scrollTo: 'Send a free invitation',
    );
  });
}

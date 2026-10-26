import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/i18n/l10n.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/features/subscription/models/subscription_model.dart';
import 'package:fitcheck_ai/features/subscription/providers/subscription_providers.dart';
import 'package:fitcheck_ai/features/subscription/services/purchase_recovery_service.dart';
import 'package:fitcheck_ai/features/subscription/services/trial_eligibility.dart';
import 'package:fitcheck_ai/features/subscription/views/subscription_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'subscription_fakes.dart';

/// Answers eligibility without the platform channel.
class FakeTrialEligibilityService extends TrialEligibilityService {
  const FakeTrialEligibilityService(this.answer);

  final TrialEligibility answer;

  @override
  Future<TrialEligibility> check(String productId) async => answer;
}

void main() {
  late FakeIapService iap;
  late FakeSubscriptionRepository repo;

  setUp(() {
    iap = FakeIapService(storeName: 'apple');
    repo = FakeSubscriptionRepository();
    repo.plansResponse = PlansResponse(
      storeProducts: fakeStoreProducts(
        store: 'apple',
        ids: const {
          'plus_monthly': 'plus_monthly',
          'plus_yearly': 'plus_yearly',
          'pro_monthly': 'pro_monthly',
          'pro_yearly': 'pro_yearly',
        },
      ),
      plans: const [
        PlanDetailsModel(
          id: 'free',
          name: 'Free',
          monthlyExtractions: 50,
          monthlyGenerations: 50,
        ),
      ],
    );
    iap.productsToReturn = [
      fakeProduct('plus_monthly', price: r'$9.99'),
      fakeProduct('plus_yearly', price: r'$99.99'),
      fakeProduct('pro_monthly', price: r'$19.99'),
      fakeProduct('pro_yearly', price: r'$199.99'),
    ];
  });

  tearDown(() => iap.dispose());

  Future<void> pumpPaywall(
    WidgetTester tester, {
    required TrialEligibility eligibility,
  }) async {
    // Tall enough that the whole page builds: the assertions are about copy
    // that must be present, not about what fits on a phone.
    tester.view.physicalSize = const Size(390 * 2, 3200 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: noRetry,
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(repo),
          purchaseRecoveryServiceProvider.overrideWithValue(
            PurchaseRecoveryService(iapService: iap, repository: repo),
          ),
          trialEligibilityServiceProvider.overrideWithValue(
            FakeTrialEligibilityService(eligibility),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const SubscriptionPage(),
        ),
      ),
    );
    // Plans load, then the store products, then eligibility resolves.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  const trialTitle = 'Your first month of Pro is free';
  const trialBody =
      'Upload your whole closet at once. Add pieces as you go after that.';
  const trialCta = 'Start my free month';
  const freeForeverBody =
      'No card needed. Every month you get 50 AI uploads, 50 outfits and 10 '
      'photoshoot images a day.';

  group('eligible for the free month', () {
    testWidgets('the trial leads, with the whole closet and the price after it', (
      tester,
    ) async {
      await pumpPaywall(tester, eligibility: TrialEligibility.eligible);

      expect(find.text('1 month free'), findsOneWidget);
      expect(find.text(trialTitle), findsOneWidget);
      expect(find.text(trialBody), findsOneWidget);
      // The price that begins when the month ends, on the same card.
      expect(find.textContaining(r'$19.99'), findsWidgets);
      expect(
        find.textContaining('After the trial, Pro renews at \$19.99'),
        findsOneWidget,
      );
    });

    testWidgets('the permanent free tier is on the offer, not in fine print', (
      tester,
    ) async {
      await pumpPaywall(tester, eligibility: TrialEligibility.eligible);

      expect(find.text('Free forever'), findsOneWidget);
      expect(find.text(freeForeverBody), findsOneWidget);
    });

    testWidgets('the CTA promises the free month', (tester) async {
      await pumpPaywall(tester, eligibility: TrialEligibility.eligible);

      expect(find.text(trialCta), findsOneWidget);
      expect(find.text('Upgrade to Pro'), findsNothing);
    });

    testWidgets('Pro Monthly is preselected so the CTA matches the headline', (
      tester,
    ) async {
      await pumpPaywall(tester, eligibility: TrialEligibility.eligible);

      // The plan's price for Pro, not Plus, is the one on the trial card.
      expect(find.text(r'$19.99'), findsWidgets);
    });

    testWidgets('restore, terms and privacy stay reachable (3.1.2)', (
      tester,
    ) async {
      await pumpPaywall(tester, eligibility: TrialEligibility.eligible);

      expect(find.text('Restore purchases'), findsOneWidget);
      expect(find.text('Terms of use'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(
        find.textContaining('Manage or cancel any time in Settings'),
        findsOneWidget,
      );
    });
  });

  group('not eligible', () {
    testWidgets('never promises a free month', (tester) async {
      await pumpPaywall(tester, eligibility: TrialEligibility.ineligible);

      expect(find.text(trialTitle), findsNothing);
      expect(find.text(trialBody), findsNothing);
      expect(find.text('1 month free'), findsNothing);
      expect(find.text(trialCta), findsNothing);
    });

    testWidgets('shows the App Store trial wording instead', (tester) async {
      await pumpPaywall(tester, eligibility: TrialEligibility.ineligible);

      expect(
        find.textContaining('Free trial for new subscribers only'),
        findsOneWidget,
      );
      // With no trial to sell, the cheapest tier stays the default CTA.
      expect(find.text('Upgrade to Plus'), findsOneWidget);
    });

    testWidgets('still shows the free tier and the required links', (
      tester,
    ) async {
      await pumpPaywall(tester, eligibility: TrialEligibility.ineligible);

      expect(find.text(freeForeverBody), findsOneWidget);
      expect(find.text('Restore purchases'), findsOneWidget);
      expect(find.text('Terms of use'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
    });
  });

  group('unknown eligibility (Android, or a failed probe)', () {
    testWidgets('is treated as not eligible, never as eligible', (
      tester,
    ) async {
      await pumpPaywall(tester, eligibility: TrialEligibility.unknown);

      expect(find.text(trialTitle), findsNothing);
      expect(find.text(trialCta), findsNothing);
      expect(
        find.textContaining('Free trial for new subscribers only'),
        findsOneWidget,
      );
      expect(find.text('Upgrade to Plus'), findsOneWidget);
    });
  });
}

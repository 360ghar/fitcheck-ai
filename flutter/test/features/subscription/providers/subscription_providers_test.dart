import 'dart:async';

import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/core/services/notification_service.dart'
    show scaffoldMessengerKey;
import 'package:fitcheck_ai/features/subscription/models/subscription_model.dart';
import 'package:fitcheck_ai/features/subscription/providers/subscription_providers.dart';
import 'package:fitcheck_ai/features/subscription/services/iap_service.dart';
import 'package:fitcheck_ai/features/subscription/services/purchase_recovery_service.dart';
import 'package:fitcheck_ai/features/subscription/views/subscription_page.dart';
import 'package:fitcheck_ai/features/subscription/views/widgets/subscription_disclosure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../subscription_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeIapService iap;
  late FakeSubscriptionRepository repo;
  late PurchaseRecoveryService recovery;
  String? userId;

  setUp(() {
    iap = FakeIapService();
    repo = FakeSubscriptionRepository();
    userId = null;
    UrlLauncherPlatform.instance = FakeUrlLauncherPlatform();
  });

  tearDown(() => iap.dispose());

  List overrides() {
    recovery = PurchaseRecoveryService(
      iapService: iap,
      repository: repo,
      currentUserId: () => userId,
    );
    return [
      subscriptionRepositoryProvider.overrideWithValue(repo),
      purchaseRecoveryServiceProvider.overrideWithValue(recovery),
    ];
  }

  ProviderContainer makeContainer() =>
      ProviderContainer(retry: noRetry, overrides: [...overrides()]);

  /// A bare app so ErrorHandler's snackbars have somewhere to show.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const Scaffold(),
      ),
    );
  }

  /// Lets snackbars time out so no timer outlives the test.
  Future<void> settle(WidgetTester tester) async {
    scaffoldMessengerKey.currentState?.clearSnackBars();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Opens the paywall as the page would (listened, initial load done) and
  /// runs [body]. The container is disposed afterwards, like closing the
  /// page.
  Future<void> withPaywall(
    WidgetTester tester,
    Future<void> Function(ProviderContainer c, PaywallNotifier paywall) body,
  ) async {
    await pumpApp(tester);
    final c = makeContainer();
    try {
      c.listen(paywallProvider, (_, _) {});
      final paywall = c.read(paywallProvider.notifier);
      await tester.pump();
      await body(c, paywall);
    } finally {
      c.dispose();
    }
    await settle(tester);
  }

  /// Sets the published store products without the page-load store query.
  void setStoreProducts(PaywallNotifier paywall, StoreProductsModel products) {
    // ignore: invalid_use_of_protected_member
    paywall.state = paywall.state.copyWith(
      plans: PlansResponse(storeProducts: products),
    );
  }

  PaywallState paywallState(ProviderContainer c) => c.read(paywallProvider);

  Future<void> deliver(WidgetTester tester, PurchaseDetails details) async {
    iap.emit(details);
    await tester.pump();
    await tester.pump();
  }

  group('provider lifecycle', () {
    testWidgets('the paywall is the page handler only while it is alive', (
      tester,
    ) async {
      // The background drain verifies only with a signed-in user.
      userId = 'user-1';
      await pumpApp(tester);
      final c = makeContainer();
      expect(recovery.hasPageHandler, isFalse);

      final sub = c.listen(paywallProvider, (_, _) {});
      c.read(paywallProvider);
      expect(recovery.hasPageHandler, isTrue);

      sub.close();
      await tester.pump(const Duration(milliseconds: 10));
      expect(c.exists(paywallProvider), isFalse);
      // Page closed: the stream is back with the background drain.
      expect(recovery.hasPageHandler, isFalse);

      // A purchase that lands now drains in the background.
      await deliver(tester, fakePurchase());
      expect(repo.registerCalls, 1);
      expect(iap.completeCalls, 1);
      expect(find.text('Purchase complete'), findsOneWidget);
      c.dispose();
      await settle(tester);
    });

    testWidgets('subscription status does not fetch plans or store products', (
      tester,
    ) async {
      final c = makeContainer();
      addTearDown(c.dispose);
      repo.plansResponse = PlansResponse(storeProducts: fakeStoreProducts());

      final status = await c.read(subscriptionStatusProvider.future);

      expect(status.planName, 'Free');
      expect(repo.getSubscriptionCalls, 1);
      expect(repo.getPlansCalls, 0);
      expect(repo.getReferralCodeCalls, 0);
      expect(iap.fetchProductsCalls, 0);
      expect(recovery.hasPageHandler, isFalse);
    });

    testWidgets('opening the paywall loads plans, then store products', (
      tester,
    ) async {
      repo.plansResponse = PlansResponse(storeProducts: fakeStoreProducts());
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      await withPaywall(tester, (c, _) async {
        expect(repo.getPlansCalls, 1);
        expect(iap.fetchProductsCalls, 1);
        expect(paywallState(c).storeStatus, StoreStatus.ready);
      });
    });
  });

  group('mobile purchases', () {
    testWidgets('startCheckout purchases through the store on mobile', (
      tester,
    ) async {
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());

        await paywall.startCheckout('plus_monthly');

        expect(iap.fetchProductsCalls, 1);
        expect(iap.lastQueriedIds, {'plus_monthly'});
        expect(iap.startPurchaseCalls, 1);
        // The Stripe path must never run on mobile.
        expect(repo.checkoutCalls, 0);
        expect(find.byType(SnackBar), findsNothing);
      });
    });

    testWidgets('a store purchase registers with the backend and completes', (
      tester,
    ) async {
      await withPaywall(tester, (c, _) async {
        await deliver(tester, fakePurchase());

        expect(repo.registerCalls, 1);
        expect(repo.lastStore, 'google');
        expect(repo.lastTransactionId, 'token-abc');
        expect(repo.lastProductId, 'plus_monthly');
        expect(iap.completeCalls, 1);
        final status = c.read(subscriptionStatusProvider).value!;
        expect(status.subscription.billingProvider, 'google');
        expect(status.planType, PlanType.plusMonthly);
        expect(find.text('Subscription active'), findsOneWidget);
      });
    });

    testWidgets('a registration failure keeps the purchase uncompleted', (
      tester,
    ) async {
      repo.registerError = Exception('verification failed');
      await withPaywall(tester, (c, _) async {
        await deliver(tester, fakePurchase());

        expect(repo.registerCalls, 1);
        // Never complete a purchase the server did not verify: the store
        // keeps it for redelivery.
        expect(iap.completeCalls, 0);
        expect(find.text('Verification pending'), findsOneWidget);
      });
    });

    testWidgets('a pending purchase shows a message without registering', (
      tester,
    ) async {
      await withPaywall(tester, (c, _) async {
        await deliver(tester, fakePurchase(status: PurchaseStatus.pending));

        expect(repo.registerCalls, 0);
        expect(iap.completeCalls, 0);
        expect(find.text('Purchase pending'), findsOneWidget);
      });
    });

    testWidgets('restored purchases register and are completed', (
      tester,
    ) async {
      await withPaywall(tester, (c, _) async {
        await deliver(tester, fakePurchase(status: PurchaseStatus.restored));

        expect(repo.registerCalls, 1);
        expect(iap.completeCalls, 1);
      });
    });

    testWidgets('restorePurchases asks the store', (tester) async {
      await withPaywall(tester, (c, paywall) async {
        await paywall.restorePurchases();
        expect(iap.restoreCalls, 1);
      });
    });

    testWidgets('refreshStoreProducts single-flights concurrent queries', (
      tester,
    ) async {
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());
        iap.fetchGate = Completer<void>();

        final first = paywall.refreshStoreProducts();
        final second = paywall.refreshStoreProducts();
        // Both calls joined the one in-flight query.
        expect(iap.fetchProductsCalls, 1);

        iap.fetchGate!.complete();
        await first;
        await second;
        expect(iap.fetchProductsCalls, 1);
        expect(paywallState(c).storeStatus, StoreStatus.ready);

        // The slot is released once the query settles.
        await paywall.refreshStoreProducts();
        expect(iap.fetchProductsCalls, 2);
      });
    });

    testWidgets('isRestoring stays up until the restored update lands', (
      tester,
    ) async {
      await withPaywall(tester, (c, paywall) async {
        final restoring = paywall.restorePurchases();
        expect(paywallState(c).isRestoring, isTrue);

        await tester.pump();
        expect(paywallState(c).isRestoring, isTrue);

        // The flag drops before backend verification finishes.
        iap.emit(fakePurchase(status: PurchaseStatus.restored));
        await tester.pump();
        expect(paywallState(c).isRestoring, isFalse);
        expect(repo.registerCalls, 1);
        await restoring;
      });
    });

    testWidgets('the restore timeout releases a hung store call', (
      tester,
    ) async {
      iap.restoreGate = Completer<void>();
      await withPaywall(tester, (c, paywall) async {
        final restoring = paywall.restorePurchases();
        await tester.pump();
        expect(paywallState(c).isRestoring, isTrue);
        expect(paywallState(c).isCheckingOut, isFalse);

        await tester.pump(const Duration(seconds: 15));
        expect(paywallState(c).isRestoring, isFalse);
        expect(paywallState(c).isCheckingOut, isFalse);

        iap.restoreGate!.complete();
        await restoring;
      });
    });

    testWidgets('a restore failure shows one friendly message', (tester) async {
      await withPaywall(tester, (c, paywall) async {
        iap.restoreGate = Completer<void>()
          ..completeError(StateError('BillingClient: raw platform text'));
        await paywall.restorePurchases();
        await tester.pump();

        expect(paywallState(c).isRestoring, isFalse);
        expect(find.text('Restore failed'), findsOneWidget);
        expect(find.textContaining('raw platform'), findsNothing);
      });
    });

    testWidgets(
      'an unpublished plan is surfaced without launching a purchase',
      (tester) async {
        await withPaywall(tester, (c, paywall) async {
          await paywall.startCheckout('pro_yearly');
          await tester.pump();

          expect(iap.startPurchaseCalls, 0);
          // The Upgrade tap must never look like it did nothing.
          expect(find.byType(SnackBar), findsOneWidget);
          expect(find.textContaining('not available'), findsOneWidget);
        });
      },
    );

    testWidgets(
      'a store lookup failure shows a friendly message, never the raw StoreKit error',
      (tester) async {
        // storekit_no_response: StoreKit resolved zero products for the ID.
        iap.fetchError = IapException(
          message: kPlanNotAvailableInStoreMessage,
          errorCode: 'storekit_no_response',
          details:
              'IAPError(code: storekit_no_response, source: app_store, '
              'message: StoreKit: Failed to get response from platform., '
              'details: null)',
        );
        await withPaywall(tester, (c, paywall) async {
          setStoreProducts(paywall, fakeStoreProducts());

          await paywall.startCheckout('plus_monthly');
          await tester.pump();

          expect(iap.fetchProductsCalls, 1);
          expect(iap.startPurchaseCalls, 0);
          expect(find.byType(SnackBar), findsOneWidget);
          expect(
            find.textContaining('not available in the store yet'),
            findsOneWidget,
          );
          expect(find.textContaining('APError'), findsNothing);
          expect(find.textContaining('StoreKit'), findsNothing);
        });
      },
    );

    testWidgets('unavailable billing shows a snackbar', (tester) async {
      iap = FakeIapService(storeBillingAvailable: false);
      await withPaywall(tester, (c, paywall) async {
        await paywall.startCheckout('plus_monthly');
        await tester.pump();

        expect(iap.fetchProductsCalls, 0);
        expect(find.textContaining('not available'), findsOneWidget);
      });
    });

    testWidgets('only the tapped plan shows the checkout spinner', (
      tester,
    ) async {
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());
        iap.fetchGate = Completer<void>();

        final checkout = paywall.startCheckout('plus_monthly');
        await tester.pump();

        expect(paywallState(c).isCheckingOut, isTrue);
        expect(paywallState(c).isCheckingOutPlan('plus_monthly'), isTrue);
        expect(paywallState(c).isCheckingOutPlan('plus_yearly'), isFalse);

        iap.fetchGate!.complete();
        await checkout;
        expect(paywallState(c).isCheckingOutPlan('plus_monthly'), isFalse);
        expect(paywallState(c).isCheckingOut, isFalse);
      });
    });

    testWidgets('a second checkout tap is ignored while one is in flight', (
      tester,
    ) async {
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());
        iap.fetchGate = Completer<void>();

        final first = paywall.startCheckout('plus_monthly');
        await tester.pump();
        await paywall.startCheckout('pro_yearly');
        await tester.pump();

        expect(iap.fetchProductsCalls, 1);
        expect(paywallState(c).checkingOutPlanType, 'plus_monthly');

        iap.fetchGate!.complete();
        await first;
        expect(iap.startPurchaseCalls, 1);
        expect(paywallState(c).isCheckingOut, isFalse);
      });
    });

    testWidgets(
      'a purchase error shows a friendly message, never raw platform text',
      (tester) async {
        await withPaywall(tester, (c, _) async {
          final purchase = fakePurchase(status: PurchaseStatus.error);
          purchase.error = IAPError(
            source: 'app_store',
            code: 'payment_failed',
            message: 'StoreKit: Failed to get response from platform.',
          );
          await deliver(tester, purchase);

          expect(repo.registerCalls, 0);
          expect(iap.completeCalls, 0);
          expect(find.textContaining('Try again'), findsOneWidget);
          expect(find.textContaining('StoreKit'), findsNothing);
          expect(find.textContaining('IAPError'), findsNothing);
        });
      },
    );

    testWidgets('a localized store price resolves by plan type', (
      tester,
    ) async {
      const productId = 'com.fitcheckaiapp.fitcheckai.plus.monthly';
      iap.productsToReturn = [fakeProduct(productId)];
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(
          paywall,
          fakeStoreProducts(ids: {'plus_monthly': productId}),
        );

        await paywall.refreshStoreProducts();

        expect(iap.lastQueriedIds, {productId});
        expect(paywallState(c).storePriceFor('plus_monthly'), r'$9.99');
      });
    });

    testWidgets('a store-billed cancel is refused locally', (tester) async {
      await pumpApp(tester);
      repo.subscriptionResult = const SubscriptionModel(
        userId: 'user-1',
        planType: PlanType.plusMonthly,
        billingProvider: 'apple',
      );
      final c = makeContainer();
      await c.read(subscriptionStatusProvider.future);

      final cancelled = await c
          .read(subscriptionStatusProvider.notifier)
          .cancel();

      // The store owns billing; the Stripe cancel endpoint is never called.
      expect(cancelled, isFalse);
      expect(repo.cancelCalls, 0);
      c.dispose();
      await settle(tester);
    });

    testWidgets('checkout uses cached product details', (tester) async {
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      repo.plansResponse = PlansResponse(storeProducts: fakeStoreProducts());
      await withPaywall(tester, (c, paywall) async {
        // Page load cached the product.
        expect(iap.fetchProductsCalls, 1);
        iap.productsToReturn = const [];

        await paywall.startCheckout('plus_monthly');

        expect(iap.fetchProductsCalls, 1);
        expect(iap.startPurchaseCalls, 1);
        expect(find.byType(SnackBar), findsNothing);
      });
    });

    testWidgets('checkout queries the store when the cache misses', (
      tester,
    ) async {
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());

        await paywall.startCheckout('plus_monthly');

        expect(iap.fetchProductsCalls, 1);
        expect(iap.startPurchaseCalls, 1);
      });
    });

    testWidgets('the purchase carries the user id as the account token', (
      tester,
    ) async {
      userId = 'user-uuid-1';
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());

        await paywall.startCheckout('plus_monthly');

        expect(iap.startPurchaseCalls, 1);
        expect(iap.lastAppAccountToken, 'user-uuid-1');
      });
    });
  });

  group('iOS (Apple IAP only)', () {
    testWidgets('iOS checkout uses StoreKit and never Stripe', (tester) async {
      iap = FakeIapService(storeName: 'apple');
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts(store: 'apple'));

        await paywall.startCheckout('plus_monthly');

        expect(iap.fetchProductsCalls, 1);
        expect(iap.startPurchaseCalls, 1);
        expect(repo.checkoutCalls, 0);

        await deliver(
          tester,
          fakePurchase(
            purchaseID: '100000123456789',
            serverVerificationData: '100000123456789',
          ),
        );

        expect(repo.registerCalls, 1);
        expect(repo.lastStore, 'apple');
        expect(repo.lastTransactionId, '100000123456789');
        expect(iap.completeCalls, 1);
      });
    });

    testWidgets(
      'iOS manage opens App Store settings, never the Stripe portal',
      (tester) async {
        iap = FakeIapService(storeName: 'apple');
        await pumpApp(tester);
        final c = makeContainer();

        await c.read(subscriptionStatusProvider.notifier).openManage();
        await tester.pump();

        // The stub cannot launch the App Store URL, so the user is told.
        expect(repo.portalCalls, 0);
        expect(find.text('Could not open the link.'), findsOneWidget);
        c.dispose();
        await settle(tester);
      },
    );
  });

  group('store product diagnostics', () {
    testWidgets('unrecognized product IDs are recorded, not dropped', (
      tester,
    ) async {
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());
        await paywall.refreshStoreProducts();

        expect(paywallState(c).storePriceFor('plus_monthly'), isNull);
        expect(paywallState(c).missingStoreProductIds, ['plus_monthly']);
      });
    });

    testWidgets('a fully resolved store leaves no missing IDs', (tester) async {
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());
        await paywall.refreshStoreProducts();

        expect(paywallState(c).missingStoreProductIds, isEmpty);
      });
    });

    testWidgets('store status is notConfigured with no published IDs', (
      tester,
    ) async {
      await withPaywall(tester, (c, paywall) async {
        await paywall.refreshStoreProducts();

        expect(paywallState(c).storeStatus, StoreStatus.notConfigured);
        expect(iap.fetchProductsCalls, 0);
      });
    });

    testWidgets('store status is ready when products resolve', (tester) async {
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());
        await paywall.refreshStoreProducts();

        expect(paywallState(c).storeStatus, StoreStatus.ready);
      });
    });

    testWidgets('store status is unavailable on zero products', (tester) async {
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());
        await paywall.refreshStoreProducts();

        expect(paywallState(c).storeStatus, StoreStatus.unavailable);
        expect(paywallState(c).missingStoreProductIds, ['plus_monthly']);
      });
    });

    testWidgets('store status is unavailable when the query fails for good', (
      tester,
    ) async {
      iap.fetchError = IapException(
        message: kPlanNotAvailableInStoreMessage,
        errorCode: 'storekit_no_response',
      );
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());
        await paywall.refreshStoreProducts();

        expect(paywallState(c).storeStatus, StoreStatus.unavailable);
      });
    });

    testWidgets('a transient store error keeps the status unknown', (
      tester,
    ) async {
      iap.fetchError = IapException(
        message: "The store couldn't be reached for this plan right now.",
        errorCode: 'storekit2_products_error',
      );
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());
        await paywall.refreshStoreProducts();

        expect(paywallState(c).storeStatus, StoreStatus.unknown);
      });
    });

    testWidgets('a transient retry does not clear an unavailable store', (
      tester,
    ) async {
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());
        await paywall.refreshStoreProducts();
        expect(paywallState(c).storeStatus, StoreStatus.unavailable);

        iap.fetchError = IapException(
          message: "The store couldn't be reached for this plan right now.",
          errorCode: 'storekit2_products_error',
        );
        await paywall.refreshStoreProducts();

        expect(paywallState(c).storeStatus, StoreStatus.unavailable);
      });
    });

    testWidgets('checkout fails fast after a store failure this session', (
      tester,
    ) async {
      await withPaywall(tester, (c, paywall) async {
        setStoreProducts(paywall, fakeStoreProducts());
        await paywall.refreshStoreProducts();
        expect(paywallState(c).storeStatus, StoreStatus.unavailable);
        final callsBefore = iap.fetchProductsCalls;

        await paywall.startCheckout('plus_monthly');
        await tester.pump();

        expect(iap.fetchProductsCalls, callsBefore);
        expect(iap.startPurchaseCalls, 0);
        expect(
          find.textContaining('not available in the store yet'),
          findsOneWidget,
        );
      });
    });
  });

  group('purchase stream resilience and redelivery dedupe', () {
    testWidgets('a failed verification does not kill the listener', (
      tester,
    ) async {
      repo.registerError = Exception('verification failed');
      await withPaywall(tester, (c, _) async {
        await deliver(tester, fakePurchase(serverVerificationData: 'token-1'));
        expect(repo.registerCalls, 1);

        repo.registerError = null;
        await deliver(
          tester,
          fakePurchase(serverVerificationData: 'token-1', purchaseID: 'GPA.2'),
        );

        expect(repo.registerCalls, 2);
        expect(iap.completeCalls, 1);
        expect(
          c.read(subscriptionStatusProvider).value?.planType,
          PlanType.plusMonthly,
        );
      });
    });

    testWidgets('a stream error does not kill the subscription', (
      tester,
    ) async {
      await withPaywall(tester, (c, _) async {
        iap.emitError(StateError('storekit stream blew up'));
        await tester.pump();

        await deliver(tester, fakePurchase());

        expect(repo.registerCalls, 1);
        expect(iap.completeCalls, 1);
      });
    });

    testWidgets('the same transaction delivered twice verifies once', (
      tester,
    ) async {
      await withPaywall(tester, (c, _) async {
        final details = fakePurchase();
        await deliver(tester, details);
        await deliver(tester, details);

        expect(repo.registerCalls, 1);
        expect(iap.completeCalls, 1);
      });
    });

    testWidgets('a failed verification releases the ID for redelivery', (
      tester,
    ) async {
      repo.registerError = Exception('backend down');
      await withPaywall(tester, (c, _) async {
        await deliver(tester, fakePurchase());
        expect(iap.completeCalls, 0);

        repo.registerError = null;
        await deliver(tester, fakePurchase(purchaseID: 'GPA.redeliver'));

        expect(repo.registerCalls, 2);
        expect(iap.completeCalls, 1);
      });
    });
  });

  group('SubscriptionPage', () {
    Future<ProviderContainer> pumpPage(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          retry: noRetry,
          overrides: [...overrides()],
          child: MaterialApp(
            scaffoldMessengerKey: scaffoldMessengerKey,
            theme: AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: const SubscriptionPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return ProviderScope.containerOf(
        tester.element(find.byType(SubscriptionPage)),
      );
    }

    Future<void> scrollTo(WidgetTester tester, Finder finder) async {
      await tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
    }

    testWidgets('Upgrade is off while the store has no products', (
      tester,
    ) async {
      // The backend publishes a product ID but the store has no products.
      repo.plansResponse = PlansResponse(storeProducts: fakeStoreProducts());
      await pumpPage(tester);

      final upgrade = find.widgetWithText(ElevatedButton, 'Upgrade to Plus');
      await scrollTo(tester, upgrade);
      expect(tester.widget<ElevatedButton>(upgrade).onPressed, isNull);
      await tester.tap(upgrade, warnIfMissed: false);
      await tester.pump();

      expect(iap.startPurchaseCalls, 0);
      // The banner above the plans says why.
      expect(
        find.textContaining("aren't available in the store yet"),
        findsOneWidget,
      );
      await settle(tester);
    });

    testWidgets('the store-unavailable banner Retry recovers', (tester) async {
      repo.plansResponse = PlansResponse(storeProducts: fakeStoreProducts());
      final c = await pumpPage(tester);

      expect(c.read(paywallProvider).storeStatus, StoreStatus.unavailable);
      final banner = find.textContaining("aren't available in the store yet");
      await scrollTo(tester, banner);
      expect(banner, findsOneWidget);

      iap.productsToReturn = [fakeProduct('plus_monthly')];
      await tester.tap(find.widgetWithText(TextButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(c.read(paywallProvider).storeStatus, StoreStatus.ready);
      expect(banner, findsNothing);
      await settle(tester);
    });

    testWidgets('no store banner when the store is ready', (tester) async {
      iap.productsToReturn = [fakeProduct('plus_monthly')];
      repo.plansResponse = PlansResponse(storeProducts: fakeStoreProducts());
      final c = await pumpPage(tester);

      expect(c.read(paywallProvider).storeStatus, StoreStatus.ready);
      expect(
        find.textContaining("aren't available in the store yet"),
        findsNothing,
      );
    });

    testWidgets('Restore purchases renders for a Pro subscriber', (
      tester,
    ) async {
      repo.subscriptionResult = const SubscriptionModel(
        userId: 'user-1',
        planType: PlanType.proMonthly,
        billingProvider: 'apple',
      );
      await pumpPage(tester);

      expect(find.textContaining('Upgrade to'), findsNothing);
      await scrollTo(tester, find.text('Restore purchases'));
      expect(find.text('Restore purchases'), findsOneWidget);
      await scrollTo(tester, find.textContaining('Manage in the'));
      expect(find.textContaining('Manage in the'), findsOneWidget);
    });

    testWidgets('a refunded subscription renders as not entitled', (
      tester,
    ) async {
      repo.subscriptionResult = const SubscriptionModel(
        userId: 'user-1',
        planType: PlanType.free,
        status: SubscriptionStatus.refunded,
        billingProvider: 'apple',
      );
      final c = await pumpPage(tester);

      final status = c.read(subscriptionStatusProvider).value!;
      expect(status.isPro, isFalse);
      expect(status.isCancelled, isFalse);
      expect(status.planName, 'Free');
      await scrollTo(tester, find.text('Upgrade to Plus'));
      expect(find.text('Upgrade to Plus'), findsOneWidget);
    });

    testWidgets('the paywall discloses auto-renewal and links the terms', (
      tester,
    ) async {
      repo.plansResponse = PlansResponse(storeProducts: fakeStoreProducts());
      await pumpPage(tester);

      await scrollTo(tester, find.byType(SubscriptionDisclosure));
      await scrollTo(tester, find.text('Privacy policy'));

      expect(find.text('Terms of use'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(
        find.textContaining('auto-renewing subscriptions'),
        findsOneWidget,
      );
      expect(find.textContaining('renews automatically'), findsOneWidget);
      expect(find.textContaining(r'$10 a month'), findsOneWidget);
    });

    testWidgets('a Plus subscriber sees terms only for Pro', (tester) async {
      repo.subscriptionResult = const SubscriptionModel(
        userId: 'user-1',
        planType: PlanType.plusMonthly,
        billingProvider: 'apple',
      );
      repo.plansResponse = PlansResponse(storeProducts: fakeStoreProducts());
      await pumpPage(tester);

      await scrollTo(tester, find.byType(SubscriptionDisclosure));
      await scrollTo(tester, find.text('Privacy policy'));

      expect(
        find.textContaining('Pro is an auto-renewing subscription'),
        findsOneWidget,
      );
      expect(find.textContaining(r'Plus is $10 a month'), findsNothing);
      expect(find.text('Terms of use'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
    });

    testWidgets('a status load failure shows an error with retry', (
      tester,
    ) async {
      repo.subscriptionError = Exception('down');
      await pumpPage(tester);

      expect(find.text('Try again'), findsOneWidget);
      repo.subscriptionError = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Current plan'), findsOneWidget);
    });

    testWidgets('pull to refresh reloads everything in parallel', (
      tester,
    ) async {
      final c = await pumpPage(tester);
      final plansBefore = repo.getPlansCalls;
      final codeBefore = repo.getReferralCodeCalls;
      repo.subscriptionGate = Completer<void>();

      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, 400),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Plans and the code were requested while /subscription still waits.
      expect(repo.getPlansCalls, plansBefore + 1);
      expect(repo.getReferralCodeCalls, codeBefore + 1);
      repo.subscriptionGate!.complete();
      await tester.pumpAndSettle();
      expect(c.read(subscriptionStatusProvider).hasValue, isTrue);
    });
  });
}

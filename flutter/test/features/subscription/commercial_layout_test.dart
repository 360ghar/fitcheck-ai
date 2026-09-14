// Layout tests supply fixed state and intentionally skip controller network
// initialization and platform purchase listeners.
// ignore_for_file: must_call_super

import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/features/dashboard/widgets/referral_promo_banner.dart';
import 'package:fitcheck_ai/features/feedback/controllers/feedback_controller.dart';
import 'package:fitcheck_ai/features/feedback/views/feedback_page.dart';
import 'package:fitcheck_ai/features/gifts/controllers/gift_controller.dart';
import 'package:fitcheck_ai/features/gifts/models/gift_models.dart';
import 'package:fitcheck_ai/features/gifts/views/gift_vouchers_page.dart';
import 'package:fitcheck_ai/features/legal/views/legal_page.dart';
import 'package:fitcheck_ai/features/profile/views/help_page.dart';
import 'package:fitcheck_ai/features/social/views/shared_outfit_page.dart';
import 'package:fitcheck_ai/features/subscription/controllers/subscription_controller.dart';
import 'package:fitcheck_ai/features/subscription/models/subscription_model.dart';
import 'package:fitcheck_ai/features/subscription/views/referral_page.dart';
import 'package:fitcheck_ai/features/subscription/views/subscription_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class QuietSubscriptionController extends SubscriptionController {
  @override
  void onInit() {}
}

class QuietFeedbackController extends FeedbackController {
  @override
  void onInit() {}
}

class QuietGiftController extends GiftController {
  @override
  void onInit() {}
}

class HiddenOutfitPersistence extends PersistenceService {
  bool fail = false;
  @override
  Future<List<String>?> getStringList(String key) async {
    if (fail) throw StateError('Local storage unavailable');
    return ['hidden-test'];
  }
}

void main() {
  setUp(() {
    Get.put<PersistenceService>(HiddenOutfitPersistence());
    Get.put<SubscriptionController>(
      QuietSubscriptionController()
        ..subscription.value = const SubscriptionModel(userId: 'user')
        ..usage.value = const UsageLimitsModel(
          monthlyExtractions: 900,
          monthlyExtractionsLimit: 1000,
        )
        ..referralCode.value = const ReferralCodeModel(
          code: 'FASHION12345',
          shareUrl: 'https://fitcheckaiapp.com/referral/code',
          timesUsed: 12,
        )
        ..referralStats.value = const ReferralStatsModel(
          totalReferrals: 100,
          successfulReferrals: 90,
          monthsEarned: 90,
        ),
    );
    Get.put<FeedbackController>(QuietFeedbackController());
    Get.put<GiftController>(
      QuietGiftController()
        ..summary.value = const GiftDashboardSummary(
          allowances: [
            GiftAllowance(
              durationMonths: 1,
              grantedCount: 2,
              usedCount: 0,
              remainingCount: 2,
            ),
          ],
          incoming: [],
        ),
    );
  });
  tearDown(Get.reset);

  testWidgets(
    'shared-outfit storage failure offers retry instead of a false 404',
    (tester) async {
      final persistence =
          Get.find<PersistenceService>() as HiddenOutfitPersistence;
      persistence.fail = true;
      await tester.pumpWidget(
        const GetMaterialApp(home: SharedOutfitPage(shareId: 'hidden-test')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Outfit not found'), findsNothing);
      persistence.fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Content hidden'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final dark in [false, true]) {
    for (final urgent in [false, true]) {
      testWidgets(
        'Home referral banner at 320px / 200% text, dark=$dark, urgent=$urgent',
        (tester) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final semantics = tester.ensureSemantics();
          try {
            var copies = 0;
            var shares = 0;
            var dismissals = 0;
            Rect? shareOrigin;
            await tester.pumpWidget(
              GetMaterialApp(
                theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(2)),
                  child: child!,
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ReferralPromoBanner(
                      isUrgent: urgent,
                      onCopyLink: () => copies++,
                      onShare: ({sharePositionOrigin}) async {
                        shares++;
                        shareOrigin = sharePositionOrigin;
                      },
                      onDismiss: () => dismissals++,
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            for (final label in ['Copy Link', 'Share']) {
              await tester.ensureVisible(find.text(label));
              await tester.pumpAndSettle();
              expect(find.text(label).hitTestable(), findsOneWidget);
              await tester.tap(find.text(label));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            expect(copies, 1);
            expect(shares, 1);
            expect(shareOrigin, isNotNull);
            expect(shareOrigin!.isEmpty, isFalse);
            if (urgent) {
              expect(find.byTooltip('Dismiss'), findsNothing);
            } else {
              final dismiss = find.byTooltip('Dismiss');
              await tester.ensureVisible(dismiss);
              await tester.pumpAndSettle();
              final dismissSemantics = tester
                  .getSemantics(dismiss)
                  .getSemanticsData();
              expect(dismissSemantics.tooltip, 'Dismiss');
              expect(dismissSemantics.flagsCollection.isButton, isTrue);
              expect(
                tester.getSize(dismiss).shortestSide,
                greaterThanOrEqualTo(48),
              );
              await tester.tap(dismiss);
              await tester.pumpAndSettle();
            }
            expect(dismissals, urgent ? 0 : 1);
            expect(tester.takeException(), isNull);
          } finally {
            semantics.dispose();
          }
        },
      );
    }
    for (final entry in <String, Widget>{
      'subscription': const SubscriptionPage(),
      'referral': const ReferralPage(),
      'gift': const GiftVouchersPage(),
      'feedback': const FeedbackPage(),
      'help': const HelpPage(),
      'legal': const LegalPage(),
      'shared outfit': const SharedOutfitPage(shareId: 'hidden-test'),
    }.entries) {
      testWidgets(
        '${entry.key} supports 320px and 200% text (${dark ? 'dark' : 'light'})',
        (tester) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            GetMaterialApp(
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(2)),
                child: child!,
              ),
              home: entry.value,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (var scroll = 0; scroll < 18; scroll++) {
            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, -450),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'scroll=$scroll');
          }
        },
      );
    }
  }
}

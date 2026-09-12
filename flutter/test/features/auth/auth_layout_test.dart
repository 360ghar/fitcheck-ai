// These view tests provide fixed auth state without starting network listeners.
// ignore_for_file: must_call_super

import 'dart:async';

import 'package:fitcheck_ai/app/routes/app_routes.dart';
import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/core/services/referral_redemption_service.dart';
import 'package:fitcheck_ai/features/auth/controllers/auth_controller.dart';
import 'package:fitcheck_ai/features/auth/services/auth_service.dart';
import 'package:fitcheck_ai/features/auth/services/referral_service.dart';
import 'package:fitcheck_ai/features/auth/services/user_initialization_service.dart';
import 'package:fitcheck_ai/features/auth/views/auth_entry_page.dart';
import 'package:fitcheck_ai/features/auth/views/forgot_password_page.dart';
import 'package:fitcheck_ai/features/auth/views/login_page.dart';
import 'package:fitcheck_ai/features/auth/views/register_page.dart';
import 'package:fitcheck_ai/features/auth/views/widgets/auth_ui.dart';
import 'package:fitcheck_ai/features/splash/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _UnusedRedemption implements ReferralRedemptionService {
  @override
  Future<bool> redeemReferralCode(String code) async => true;
}

class _AuthViewController extends AuthController {
  Completer<void>? initialization;

  @override
  void onInit() {}

  @override
  Future<void> initializeAuth() async => initialization?.future;

  @override
  bool get isAuthenticated => false;
}

List<SemanticsData> _semantics(WidgetTester tester) {
  final data = <SemanticsData>[];
  void visit(SemanticsNode node) {
    data.add(node.getSemanticsData());
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return data;
}

void main() {
  late _AuthViewController controller;
  setUp(() {
    Get.put<AuthService>(AuthService());
    Get.put<ReferralService>(
      ReferralService(
        persistence: PersistenceService(),
        userInitService: UserInitializationService(
          subscriptionRepo: _UnusedRedemption(),
        ),
      ),
    );
    controller =
        Get.put<AuthController>(_AuthViewController()) as _AuthViewController;
  });
  tearDown(Get.reset);

  Future<void> pumpPage(
    WidgetTester tester,
    Widget page, {
    bool dark = false,
    bool keyboard = false,
    bool reducedMotion = false,
  }) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: (dark ? AppTheme.darkTheme : AppTheme.lightTheme).copyWith(
          platform: TargetPlatform.iOS,
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(2),
            viewInsets: EdgeInsets.only(bottom: keyboard ? 260 : 0),
            disableAnimations: reducedMotion,
          ),
          child: child!,
        ),
        home: page,
        getPages: [
          GetPage(
            name: Routes.onboarding,
            page: () => const Scaffold(body: Text('Welcome destination')),
          ),
        ],
      ),
    );
    await tester.pump();
  }

  for (final dark in [false, true]) {
    for (final entry in <String, Widget>{
      'entry': const AuthEntryPage(),
      'login': const LoginPage(),
      'register': const RegisterPage(),
      'reset': const ForgotPasswordPage(),
    }.entries) {
      testWidgets(
        '${entry.key} supports 320px, 200% text and keyboard/errors (${dark ? 'dark' : 'light'})',
        (tester) async {
          await pumpPage(tester, entry.value, dark: dark, keyboard: true);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (entry.key != 'entry') {
            final title = switch (entry.key) {
              'login' => 'Welcome Back',
              'register' => 'Create Account',
              _ => 'Reset Password',
            };
            final heading = find.text(title).first;
            expect(
              tester.widget<Text>(heading).style,
              Theme.of(tester.element(heading)).textTheme.headlineMedium,
            );
            final form = tester.state<FormState>(find.byType(Form));
            expect(form.validate(), isFalse);
            if (entry.key == 'login') {
              controller.showEmailNotVerifiedError.value = true;
            }
            await tester.pumpAndSettle();
            expect(find.text('Please enter your email'), findsOneWidget);
          }
          for (var step = 0; step < 18; step++) {
            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, -360),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          expect(find.text('Terms of service').hitTestable(), findsOneWidget);
          if (entry.key != 'entry') {
            final button = find.byType(ElevatedButton).first;
            await Scrollable.ensureVisible(tester.element(button));
            await tester.pumpAndSettle();
            expect(button.hitTestable(), findsOneWidget);
            final theme = Theme.of(tester.element(button));
            expect(
              tester
                  .widget<ElevatedButton>(button)
                  .style!
                  .foregroundColor!
                  .resolve({}),
              theme.colorScheme.onPrimary,
            );
          }
        },
      );
    }
  }

  testWidgets(
    'pushed iOS auth pages expose native Back; direct entry does not',
    (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS),
          home: const AuthEntryPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsNothing);
      for (final page in [
        const LoginPage(),
        const RegisterPage(),
        const ForgotPasswordPage(),
      ]) {
        unawaited(
          navigator.currentState!.push(
            CupertinoPageRoute<void>(builder: (_) => page),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(BackButton), findsOneWidget);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byType(AuthEntryPage), findsOneWidget);
      }
    },
  );

  testWidgets('auth controls expose one native accessible label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const LoginPage()),
      );
      await tester.pumpAndSettle();
      final data = _semantics(tester);
      final emailFields = data.where(
        (node) =>
            node.flagsCollection.isTextField && node.label.contains('Email'),
      );
      expect(emailFields, hasLength(1));
      expect(emailFields.single.label, isNot(contains('Email\nEmail')));
      final signIn = data.where(
        (node) =>
            node.flagsCollection.isButton && node.label.contains('Sign In'),
      );
      expect(signIn, hasLength(1));
      expect(signIn.single.label, 'Sign In');
    } finally {
      handle.dispose();
    }
  });

  testWidgets(
    'Apple sign-in label stays within its native button at 200% text',
    (tester) async {
      await pumpPage(
        tester,
        Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: AppleSignInButton(onPressed: () {}),
            ),
          ),
        ),
      );
      final label = tester.getRect(find.text('Sign in with Apple'));
      final button = tester.getRect(find.byType(CupertinoButton));
      expect(label.top, greaterThanOrEqualTo(button.top));
      expect(label.bottom, lessThanOrEqualTo(button.bottom));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'splash is readable with reduced motion and routes when auth is ready',
    (tester) async {
      controller.initialization = Completer<void>();
      await pumpPage(tester, const SplashPage(), reducedMotion: true);
      expect(find.text('FitCheck AI'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.binding.hasScheduledFrame, isFalse);
      controller.initialization!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Welcome destination'), findsOneWidget);
    },
  );
}

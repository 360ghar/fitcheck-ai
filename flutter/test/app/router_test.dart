import 'package:fitcheck_ai/app/router.dart';
import 'package:fitcheck_ai/core/providers.dart';
import 'package:fitcheck_ai/core/services/notification_service.dart';
import 'package:fitcheck_ai/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuth extends AuthNotifier {
  _FakeAuth({required this.initialized, required this.signedIn});

  final bool initialized;
  final bool signedIn;

  @override
  AuthState build() => AuthState(initialized: initialized);

  @override
  bool get hasSession => signedIn;
}

void main() {
  String? redirect(
    String location, {
    bool initialized = true,
    bool signedIn = false,
  }) {
    final container = ProviderContainer.test(
      retry: noRetry,
      overrides: [
        authProvider.overrideWith(
          () => _FakeAuth(initialized: initialized, signedIn: signedIn),
        ),
      ],
    );
    addTearDown(container.dispose);
    return authRedirect(container, Uri.parse(location).path);
  }

  group('authRedirect', () {
    test('holds every location on the splash until the session restores', () {
      expect(redirect('/wardrobe', initialized: false), Routes.splash);
      expect(redirect(Routes.splash, initialized: false), isNull);
    });

    test('sends a signed-out user to onboarding, but not from guest pages', () {
      expect(redirect(Routes.splash), Routes.onboarding);
      expect(redirect(Routes.item('abc')), Routes.onboarding);
      expect(redirect(Routes.login), isNull);
      expect(redirect(Routes.register), isNull);
    });

    test('sends a signed-in user from guest pages to home', () {
      expect(redirect(Routes.login, signedIn: true), Routes.home);
      expect(redirect(Routes.splash, signedIn: true), Routes.home);
      expect(redirect(Routes.item('abc'), signedIn: true), isNull);
    });

    test('keeps the policy and shared-outfit pages public', () {
      expect(redirect(Routes.legal), isNull);
      expect(redirect('/shared/xyz'), isNull);
    });
  });

  group('route table', () {
    String? leaf(String location) {
      final route = appRouter.configuration
          .findMatch(Uri.parse(location))
          .lastOrNull
          ?.route;
      return route is GoRoute ? route.path : null;
    }

    test('static paths win over their :id siblings', () {
      expect(leaf(Routes.wardrobeStats), Routes.wardrobeStats);
      expect(leaf(Routes.outfitCollections), Routes.outfitCollections);
      expect(leaf(Routes.outfitBuilder), Routes.outfitBuilder);
      expect(leaf(Routes.item('abc')), '/wardrobe/:id');
      expect(leaf(Routes.itemEdit('abc')), '/wardrobe/edit/:id');
      expect(leaf(Routes.outfitEdit('abc')), '/outfits/edit/:id');
    });

    test('every tab root resolves', () {
      for (final tab in Routes.tabs) {
        expect(leaf(tab), tab);
      }
    });
  });

  testWidgets('an open snackbar does not block a pop', (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const Scaffold(body: Text('first')),
      ),
    );
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('second')),
      ),
    );
    await tester.pumpAndSettle();
    NotificationService.present(
      AppNotification(
        title: 'Hi',
        message: 'Hello',
        type: NotificationType.info,
      ),
    );
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);

    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsNothing);
  });
}

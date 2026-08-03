import 'package:fitcheck_ai/app/routes/app_routes.dart';
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/core/services/referral_redemption_service.dart';
import 'package:fitcheck_ai/features/auth/controllers/auth_controller.dart';
import 'package:fitcheck_ai/features/auth/models/user_model.dart';
import 'package:fitcheck_ai/features/auth/services/auth_service.dart';
import 'package:fitcheck_ai/features/auth/services/referral_service.dart';
import 'package:fitcheck_ai/features/auth/services/user_initialization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse, Session, User;

/// Referral durability across signup failure points (RCA 2026-08-04):
///
/// A referral code must never be silently lost when the signup-time
/// redemption cannot run. AuthController.register now stashes the code via
/// ReferralService.setPendingReferralCode when (a) the redemption fails
/// transiently (missing backend RPC, dead connection) or (b) email
/// confirmation is required (the redemption cannot run until the account is
/// confirmed). The auth-change listener / next login then retries through
/// handleOAuthCallback's pending-code path.
class _FakeAuthService extends AuthService {
  _FakeAuthService() : super(googleSignInLauncher: () async => true);

  AuthResponse? registerResponse;

  @override
  Future<AuthResponse> register(
    String email,
    String password, {
    String? fullName,
  }) async {
    return registerResponse!;
  }

  @override
  Future<UserModel?> loadUserData({User? supabaseUser}) async => null;

  @override
  void trackRegister({required bool hasReferral}) {}

  @override
  void trackLogin(String method) {}

  @override
  String? get accessToken => 'test-access-token';
}

class _FakeRedemptionRepo implements ReferralRedemptionService {
  @override
  Future<void> redeemReferralCode(String code) async {}
}

class _FakeReferralService extends ReferralService {
  _FakeReferralService()
      : super(
          persistence: PersistenceService(),
          userInitService: UserInitializationService(
            subscriptionRepo: _FakeRedemptionRepo(),
          ),
        );

  bool redeemResult = true;
  final List<String> stashedCodes = [];

  @override
  Future<bool> redeemReferralCode(String code) async => redeemResult;

  @override
  Future<void> setPendingReferralCode(String code) async {
    stashedCodes.add(code);
  }
}

User _user() => User(
      id: 'user-referral-test',
      appMetadata: <String, dynamic>{},
      userMetadata: <String, dynamic>{},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

Session _session() => Session(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'bearer',
      expiresIn: 3600,
      user: _user(),
    );

void main() {
  late _FakeAuthService authService;
  late _FakeReferralService referralService;

  setUp(() {
    Get.reset();
    authService = _FakeAuthService();
    referralService = _FakeReferralService();
    Get.put<AuthService>(authService);
    Get.put<ReferralService>(referralService);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: SizedBox()),
        getPages: [
          GetPage(name: Routes.home, page: () => const Scaffold(body: SizedBox())),
        ],
      ),
    );
  }

  testWidgets('transient redeem failure stashes the referral code', (tester) async {
    await pumpApp(tester);
    authService.registerResponse = AuthResponse(user: _user(), session: _session());
    referralService.redeemResult = false;

    final controller = AuthController();
    await controller.register(
      'referral@example.com',
      'aaaaaaaa',
      referralCode: 'FIT-ABC123',
    );
    // Let the welcome snackbar play out and its overlay entry dispose so the
    // widget tree is clean at teardown.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(referralService.stashedCodes, ['FIT-ABC123']);
  });

  testWidgets('email-confirmation signup stashes the referral code', (tester) async {
    await pumpApp(tester);
    // No session => Supabase requires email confirmation; the redemption
    // cannot run until the account is confirmed, so the code must be
    // stashed for the post-confirmation login.
    authService.registerResponse = AuthResponse(user: _user(), session: null);

    final controller = AuthController();
    await controller.register(
      'confirm@example.com',
      'aaaaaaaa',
      referralCode: 'FIT-ABC123',
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(referralService.stashedCodes, ['FIT-ABC123']);
  });

  testWidgets('successful redemption does not stash the code', (tester) async {
    await pumpApp(tester);
    authService.registerResponse = AuthResponse(user: _user(), session: _session());
    referralService.redeemResult = true;

    final controller = AuthController();
    await controller.register(
      'ok@example.com',
      'aaaaaaaa',
      referralCode: 'FIT-ABC123',
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(referralService.stashedCodes, isEmpty);
  });
}

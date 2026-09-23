import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/persistence_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/referral_service.dart';
import '../services/user_initialization_service.dart';

part 'auth_provider.freezed.dart';

/// Which auth action is running. One at a time.
enum AuthBusy { none, email, google, apple, logout, reset, password, resend }

@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    /// Backend profile. Null until `/users/me` loads, and after sign-out.
    UserModel? user,

    /// True once the stored session has been restored at startup.
    @Default(false) bool initialized,
    @Default(AuthBusy.none) AuthBusy busy,

    /// Email that must be confirmed before sign-in. Drives the inline
    /// "verify your email" panel on the login page.
    String? unverifiedEmail,
  }) = _AuthState;

  /// A form submit (email sign-in, register, reset, password change) runs.
  bool get isSubmitting =>
      busy == AuthBusy.email ||
      busy == AuthBusy.reset ||
      busy == AuthBusy.password;
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final referralServiceProvider = Provider<ReferralService>(
  (ref) => ReferralService(
    persistence: PersistenceService.instance,
    userInitService: ref.read(userInitializationServiceProvider),
  ),
);
final userInitializationServiceProvider = Provider<UserInitializationService>(
  (ref) => UserInitializationService(subscriptionRepo: SubscriptionRepository()),
);
final supabaseServiceProvider = Provider<SupabaseService>(
  (ref) => SupabaseService.instance,
);

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Session, profile and every sign-in / sign-out flow.
class AuthNotifier extends Notifier<AuthState> {
  SupabaseService get _supabase => ref.read(supabaseServiceProvider);
  AuthService get _authService => ref.read(authServiceProvider);
  ReferralService get _referrals => ref.read(referralServiceProvider);

  /// True while a credential flow (email, register, Apple) runs the post-auth
  /// steps itself. The session listener also fires for those flows; without
  /// this flag every sign-in would load the profile twice.
  bool _credentialFlowDriving = false;
  Future<void>? _initializing;

  @override
  AuthState build() {
    listenValue(ref, _supabase.isAuthenticated, _onSessionChanged);
    return const AuthState();
  }

  /// True when the profile is loaded for a live session.
  bool get isAuthenticated =>
      _supabase.isAuthenticated.value && state.user != null;

  /// True when a session exists even if the profile has not loaded (for
  /// example an offline start). The shell tolerates a late profile load.
  bool get hasSession => _supabase.currentSession != null;

  String? get currentUserEmail => _supabase.currentUserEmail;

  /// Raw session user (carries the auth `provider` in `appMetadata`).
  User? get currentUser => _supabase.currentUser.value;

  String? get accessToken => _authService.accessToken;

  Future<void> _onSessionChanged(bool signedIn) async {
    if (!signedIn) {
      state = state.copyWith(user: null);
      return;
    }
    // Credential flows own their sequence. This listener drives session
    // restores and OAuth deep-link returns, which have no explicit flow.
    if (_credentialFlowDriving) return;
    await _loadUser();
    await _referrals.handleOAuthCallback();
  }

  /// Restores the stored session. Concurrent callers share one run.
  Future<void> initialize() =>
      _initializing ??= _initialize().whenComplete(() => _initializing = null);

  Future<void> _initialize() async {
    // Callers may start this from a widget's initState. Riverpod forbids a
    // state change during build, so wait one microtask first.
    await Future<void>.value();
    if (!ref.mounted) return;
    if (state.initialized) state = state.copyWith(initialized: false);
    try {
      if (!_supabase.isInitialized.value) await _supabase.init();
      if (_supabase.isAuthenticated.value) await _loadUser();
    } catch (e, stack) {
      ErrorHandler.reportError(e, 'Session restore failed', stackTrace: stack);
    }
    if (ref.mounted) state = state.copyWith(initialized: true);
  }

  /// Loads the backend profile. A failure keeps the session: the profile is
  /// retried on the next [refreshUser].
  Future<void> _loadUser({User? supabaseUser}) async {
    try {
      final loaded = await _authService.loadUserData(
        supabaseUser: supabaseUser,
      );
      if (loaded != null && ref.mounted) state = state.copyWith(user: loaded);
    } catch (e, stack) {
      ErrorHandler.reportError(e, 'Profile load failed', stackTrace: stack);
    }
  }

  Future<void> refreshUser() => _loadUser();

  /// Runs [action] as the single busy auth action. Returns false when another
  /// action is already running.
  Future<bool> _run(
    AuthBusy busy,
    Future<void> Function() action, {
    bool credentialFlow = false,
  }) async {
    if (state.busy != AuthBusy.none) return false;
    state = state.copyWith(busy: busy);
    _credentialFlowDriving = credentialFlow;
    try {
      await action();
      return true;
    } finally {
      _credentialFlowDriving = false;
      if (ref.mounted) state = state.copyWith(busy: AuthBusy.none);
    }
  }

  /// Wrong credentials are user errors: shown, not reported.
  void _showAuthError(Object e, String title) {
    if (e is AuthException) {
      ErrorHandler.showValidation(e.message, title: title);
    } else {
      ErrorHandler.showError(e, title: title);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(unverifiedEmail: null);
    await _run(AuthBusy.email, credentialFlow: true, () async {
      try {
        final response = await _authService.login(email, password);
        final user = response.user;
        if (user == null) throw Exception('Sign-in failed. Please try again.');
        await _loadUser(supabaseUser: user);
        // Email-confirmed signups resume here, so redeem a pending referral
        // before a later sign-out can clear it.
        await _referrals.handleOAuthCallback();
        _authService.trackLogin('email');
        final name = state.user?.fullName ?? state.user?.email;
        ErrorHandler.showInfo(
          name != null ? 'Signed in as $name' : 'Signed in',
          title: 'Welcome back',
        );
      } on AuthException catch (e) {
        if (e.message.toLowerCase().contains('email not confirmed')) {
          state = state.copyWith(unverifiedEmail: email);
          return; // Shown inline on the login page.
        }
        _showAuthError(e, 'Sign-in failed');
      } catch (e, stack) {
        ErrorHandler.showError(e, title: 'Sign-in failed', stackTrace: stack);
      }
    });
  }

  Future<void> register(
    String email,
    String password, {
    String? fullName,
    String? referralCode,
  }) async {
    final code = (referralCode?.isNotEmpty ?? false) ? referralCode : null;
    await _run(AuthBusy.email, credentialFlow: true, () async {
      try {
        final response = await _authService.register(
          email,
          password,
          fullName: fullName,
        );
        final user = response.user;
        if (user == null) throw Exception('Sign-up failed. Please try again.');
        if (response.session?.accessToken == null) {
          // Email confirmation is on. The referral cannot be redeemed until
          // the account is confirmed, so keep it for the first sign-in.
          if (code != null) await _referrals.setPendingReferralCode(code);
          state = state.copyWith(unverifiedEmail: email);
          ErrorHandler.showInfo(
            'Check your inbox for a confirmation email, then sign in.',
            title: 'Confirm your email',
          );
          return;
        }
        await _loadUser(supabaseUser: user);
        _authService.trackRegister(hasReferral: code != null);
        if (code != null && !await _referrals.redeemReferralCode(code)) {
          // Transient failure: retried on the next auth event.
          await _referrals.setPendingReferralCode(code);
        }
        ErrorHandler.showInfo('Your closet is ready.', title: 'Welcome');
      } catch (e, stack) {
        if (e is AuthException) {
          _showAuthError(e, 'Sign-up failed');
        } else {
          ErrorHandler.showError(e, title: 'Sign-up failed', stackTrace: stack);
        }
      }
    });
  }

  /// Opens the Google consent page. The session arrives later through the
  /// OAuth deep link and [_onSessionChanged].
  Future<void> signInWithGoogle() async {
    await _run(AuthBusy.google, () async {
      try {
        await _authService.signInWithGoogle();
      } catch (e, stack) {
        if (e is AuthException) {
          _showAuthError(e, 'Google sign-in failed');
        } else {
          ErrorHandler.showError(
            e,
            title: 'Google sign-in failed',
            stackTrace: stack,
          );
        }
      }
    });
  }

  Future<void> signInWithApple() async {
    await _run(AuthBusy.apple, credentialFlow: true, () async {
      try {
        final response = await _authService.signInWithApple();
        final user = response.user;
        if (user == null) throw Exception('Apple sign-in failed.');
        await _loadUser(supabaseUser: user);
        await _referrals.handleOAuthCallback();
        _authService.trackLogin('apple');
      } on SignInWithAppleAuthorizationException catch (e, stack) {
        if (e.code == AuthorizationErrorCode.canceled) return;
        ErrorHandler.showError(
          e.message,
          title: 'Apple sign-in failed',
          stackTrace: stack,
        );
      } catch (e, stack) {
        if (e is AuthException) {
          _showAuthError(e, 'Apple sign-in failed');
        } else {
          ErrorHandler.showError(
            e,
            title: 'Apple sign-in failed',
            stackTrace: stack,
          );
        }
      }
    });
  }

  /// Signs out locally even when the server call fails (for example
  /// offline); see [SupabaseService.signOut].
  Future<void> logout() async {
    await _run(AuthBusy.logout, () async {
      try {
        await _authService.logout();
        AnalyticsService.instance.reset();
        // A pending referral must not be redeemed by the next account.
        await _referrals.clearPendingReferral();
        state = state.copyWith(user: null, unverifiedEmail: null);
        ErrorHandler.showInfo('You are signed out.', title: 'Signed out');
      } catch (e, stack) {
        ErrorHandler.showError(e, title: 'Sign-out failed', stackTrace: stack);
      }
    });
  }

  /// Returns true when the reset email was sent.
  Future<bool> requestPasswordReset(String email) async {
    var sent = false;
    await _run(AuthBusy.reset, () async {
      try {
        await _authService.requestPasswordReset(email);
        sent = true;
        ErrorHandler.showSuccess(
          'Check your email for a reset link.',
          title: 'Email sent',
        );
      } catch (e) {
        _showAuthError(e, 'Could not send the email');
      }
    });
    return sent;
  }

  /// Throws [AuthException] when [password] is wrong. Shows nothing: the
  /// caller decides what a failure means.
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) => _authService.reauthenticate(email: email, password: password);

  /// Rethrows on failure so the caller can keep its dialog open. Shows the
  /// result either way.
  Future<void> updatePassword(String newPassword) async {
    Object? failure;
    await _run(AuthBusy.password, () async {
      try {
        await _authService.updatePassword(newPassword);
        ErrorHandler.showSuccess(
          'Your password is updated.',
          title: 'Password updated',
        );
      } catch (e) {
        failure = e;
        _showAuthError(e, 'Password not updated');
      }
    });
    if (failure != null) throw failure!;
  }

  void clearEmailVerificationError() {
    if (state.unverifiedEmail != null) {
      state = state.copyWith(unverifiedEmail: null);
    }
  }

  Future<void> resendVerificationEmail() async {
    final email = state.unverifiedEmail;
    if (email == null) return;
    await _run(AuthBusy.resend, () async {
      try {
        await _authService.resendVerificationEmail(email);
        ErrorHandler.showSuccess(
          'We sent a new confirmation email.',
          title: 'Email sent',
        );
      } catch (e) {
        _showAuthError(e, 'Email not sent');
      }
    });
  }

  Future<void> setPendingReferralCode(String code) =>
      _referrals.setPendingReferralCode(code);
}

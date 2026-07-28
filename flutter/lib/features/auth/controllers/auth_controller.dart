import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/frame_safe.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/referral_service.dart';

/// Authentication controller using Supabase.
///
/// Orchestration-only controller (FL7): delegates auth operations to
/// [AuthService], referral handling to [ReferralService], and keeps
/// reactive state for the view layer. No direct Supabase, SharedPreferences,
/// or subscription repository calls.
class AuthController extends GetxController {
  final SupabaseService _supabase = SupabaseService.instance;
  final AuthService _authService = Get.find<AuthService>();
  final ReferralService _referralService = Get.find<ReferralService>();

  // Workers for cleanup (prevent memory leaks)
  final List<Worker> _workers = [];

  // Reactive state
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString error = RxString('');

  // Action-specific loading states
  final RxBool isLoggingOut = false.obs;
  final RxBool isGoogleSigningIn = false.obs;
  final RxBool isAppleSigningIn = false.obs;
  final RxBool isResendingVerification = false.obs;

  // Email verification state for login page
  final RxBool showEmailNotVerifiedError = false.obs;
  final RxString unverifiedEmail = RxString('');

  // Getters
  bool get isAuthenticated =>
      _supabase.isAuthenticated.value && user.value != null;
  bool get hasError => error.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges();
    initializeAuth();
  }

  @override
  void onClose() {
    // Clean up all workers to prevent memory leaks
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.onClose();
  }

  /// Listen to Supabase auth state changes
  void _listenToAuthChanges() {
    _workers.add(
      ever<bool>(_supabase.isAuthenticated, (isAuth) async {
        if (!isAuth) {
          user.value = null;
          return;
        }
        await _loadUserData();
        // Check for pending referral code from OAuth flow
        await _referralService.handleOAuthCallback();
      }),
    );
  }

  /// Initialize authentication state
  Future<void> initializeAuth() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      isInitialized.value = false;

      // Ensure Supabase is ready
      if (!_supabase.isInitialized.value) {
        await _supabase.init();
      }

      // Check if user is authenticated
      if (_supabase.isAuthenticated.value) {
        await _loadUserData();
      }

      isInitialized.value = true;
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      isInitialized.value = true;
    }
  }

  /// Load user data from Supabase and backend via [AuthService].
  Future<void> _loadUserData({User? supabaseUser}) async {
    try {
      final loaded = await _authService.loadUserData(supabaseUser: supabaseUser);
      if (loaded != null) {
        user.value = loaded;
      }
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
    }
  }

  /// Login with email and password using [AuthService].
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';
      showEmailNotVerifiedError.value = false;

      final response = await _authService.login(email, password);

      if (response.user != null) {
        await _loadUserData(supabaseUser: response.user);
        _authService.trackLogin('email');

        // Navigate first so snackbar isn't dismissed by stack replacement
        Get.offAllNamed(Routes.home);
        ErrorHandler.showInfo('Successfully logged in as ${user.value?.fullName ?? user.value?.email}', title: 'Welcome back!');
      } else {
        throw Exception('Login failed. Please try again.');
      }
    } on AuthException catch (e, stackTrace) {
      error.value = e.message;
      // Check for email not confirmed error
      if (e.message.toLowerCase().contains('email not confirmed')) {
        showEmailNotVerifiedError.value = true;
        unverifiedEmail.value = email;
        // Don't show snackbar for this error, we show inline UI instead
      } else {
        ErrorHandler.reportError(e, e.message, stackTrace: stackTrace);
        ErrorHandler.showError(e.message, title: 'Login Failed');
      }
      rethrow;
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
      ErrorHandler.showError(error.value, title: 'Login Failed');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Register new user using [AuthService].
  Future<void> register(
    String email,
    String password, {
    String? fullName,
    String? referralCode,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _authService.register(
        email,
        password,
        fullName: fullName,
      );

      if (response.user != null) {
        await _loadUserData(supabaseUser: response.user);
        _authService.trackRegister(
          hasReferral: referralCode != null && referralCode.isNotEmpty,
        );

        // Redeem referral code if provided
        if (referralCode != null && referralCode.isNotEmpty) {
          await _referralService.redeemReferralCode(referralCode);
        }

        ErrorHandler.showInfo('Account created successfully', title: 'Welcome to Fit Check!');

        // Navigate to home
        Get.offAllNamed(Routes.home);
      } else {
        throw Exception('Registration failed. Please try again.');
      }
    } on AuthException catch (e, stackTrace) {
      error.value = e.message;
      ErrorHandler.reportError(e, e.message, stackTrace: stackTrace);
      ErrorHandler.showError(e.message, title: 'Registration Failed');
      rethrow;
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
      ErrorHandler.showError(error.value, title: 'Registration Failed');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign in with Google OAuth.
  Future<void> signInWithGoogle() async {
    try {
      isGoogleSigningIn.value = true;
      error.value = '';

      await _authService.signInWithGoogle();
      _authService.trackLogin('google');
      // OAuth flow will redirect - state will be updated via deep link
    } on AuthException catch (e, stackTrace) {
      error.value = e.message;
      ErrorHandler.reportError(e, e.message, stackTrace: stackTrace);
      ErrorHandler.showError(e.message, title: 'Google Sign-In Failed');
      rethrow;
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
      ErrorHandler.showError(error.value, title: 'Google Sign-In Failed');
      rethrow;
    } finally {
      isGoogleSigningIn.value = false;
    }
  }

  /// Sign in with Apple (native flow).
  Future<void> signInWithApple() async {
    try {
      isAppleSigningIn.value = true;
      error.value = '';

      final response = await _authService.signInWithApple();

      if (response.user != null) {
        await _loadUserData(supabaseUser: response.user);
        // Sync backend profile and redeem any pending referral code.
        await _referralService.handleOAuthCallback();
        _authService.trackLogin('apple');

        // Navigate to home
        Get.offAllNamed(Routes.home);
      } else {
        throw Exception('Apple sign-in failed. Please try again.');
      }
    } on SignInWithAppleAuthorizationException catch (e, stackTrace) {
      // User cancelled the native sheet - fail silently, no snackbar/report.
      if (e.code == AuthorizationErrorCode.canceled) {
        return;
      }
      error.value = e.message;
      ErrorHandler.reportError(e, e.message, stackTrace: stackTrace);
      ErrorHandler.showError(e.message, title: 'Apple Sign-In Failed');
      rethrow;
    } on AuthException catch (e, stackTrace) {
      error.value = e.message;
      ErrorHandler.reportError(e, e.message, stackTrace: stackTrace);
      ErrorHandler.showError(e.message, title: 'Apple Sign-In Failed');
      rethrow;
    } catch (e, stackTrace) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.reportError(e, error.value, stackTrace: stackTrace);
      ErrorHandler.showError(error.value, title: 'Apple Sign-In Failed');
      rethrow;
    } finally {
      isAppleSigningIn.value = false;
    }
  }

  /// Logout user.
  Future<void> logout() async {
    isLoggingOut.value = true;
    try {
      await _authService.logout();
      AnalyticsService.instance.reset();
      user.value = null;
      error.value = '';

      Get.offAllNamed(Routes.splash);

      ErrorHandler.showInfo('You have been logged out successfully', title: 'Logged Out');
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      debugPrint('Logout error: $e');
    } finally {
      isLoggingOut.value = false;
    }
  }

  /// Request password reset.
  Future<void> requestPasswordReset(String email) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _authService.requestPasswordReset(email);

      ErrorHandler.showSuccess('Check your email for password reset instructions', title: 'Email Sent');
    } on AuthException catch (e) {
      error.value = e.message;
      ErrorHandler.showError(e.message, title: 'Request Failed');
      rethrow;
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value, title: 'Request Failed');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update password.
  Future<void> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _authService.updatePassword(newPassword);

      ErrorHandler.showSuccess('Your password has been updated successfully', title: 'Password Updated');
    } on AuthException catch (e) {
      error.value = e.message;
      ErrorHandler.showError(e.message, title: 'Update Failed');
      rethrow;
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value, title: 'Update Failed');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh user data.
  Future<void> refreshUser() async {
    await _loadUserData();
  }

  /// Clear error.
  void clearError() {
    error.value = '';
  }

  /// Clear email verification error state.
  void clearEmailVerificationError() {
    showEmailNotVerifiedError.value = false;
    unverifiedEmail.value = '';
  }

  /// Resend verification email.
  Future<void> resendVerificationEmail() async {
    if (unverifiedEmail.value.isEmpty) return;

    try {
      isResendingVerification.value = true;
      error.value = '';

      await _authService.resendVerificationEmail(unverifiedEmail.value);

      ErrorHandler.showSuccess('Verification email has been sent. Please check your inbox.', title: 'Email Sent');
    } on AuthException catch (e) {
      error.value = e.message;
      ErrorHandler.showError(e.message, title: 'Failed to Send Email');
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value, title: 'Failed to Send Email');
    } finally {
      isResendingVerification.value = false;
    }
  }

  /// Get current access token for API calls.
  String? get accessToken => _authService.accessToken;

  /// Store pending referral code for OAuth flow.
  Future<void> setPendingReferralCode(String code) async {
    await _referralService.setPendingReferralCode(code);
  }

  /// Handle OAuth callback and check for pending referral.
  Future<void> handleOAuthCallback() async {
    await _referralService.handleOAuthCallback();
  }
}

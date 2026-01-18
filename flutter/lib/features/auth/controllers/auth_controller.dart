import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../models/user_model.dart';

/// Authentication controller using Supabase
class AuthController extends GetxController {
  final SupabaseService _supabase = SupabaseService.instance;
  final SubscriptionRepository _subscriptionRepo = SubscriptionRepository();

  // Key for storing pending referral code
  static const String _pendingReferralKey = 'pending_referral_code';

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
  final RxBool isResendingVerification = false.obs;

  // Email verification state for login page
  final RxBool showEmailNotVerifiedError = false.obs;
  final RxString unverifiedEmail = RxString('');

  // Getters
  bool get isAuthenticated => _supabase.isAuthenticated.value && user.value != null;
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
        await handleOAuthCallback();
      }),
    );
  }

  /// Initialize authentication state
  Future<void> initializeAuth() async {
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
      error.value = e.toString();
      isInitialized.value = true;
    }
  }

  /// Load user data from Supabase and backend
  Future<void> _loadUserData({User? supabaseUser}) async {
    try {
      final resolvedUser = supabaseUser ?? _supabase.currentUser.value;
      if (resolvedUser == null) return;

      _setUserFromSupabase(resolvedUser);
    } catch (e) {
      error.value = e.toString();
    }
  }

  void _setUserFromSupabase(User supabaseUser) {
    user.value = UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      fullName: supabaseUser.userMetadata?['full_name'] as String?,
      avatarUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.tryParse(supabaseUser.createdAt),
    );
    AnalyticsService.instance.identify(
      supabaseUser.id,
      traits: {
        'email': supabaseUser.email,
        'full_name': supabaseUser.userMetadata?['full_name'],
      },
    );
  }

  /// Login with email and password using Supabase
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';
      showEmailNotVerifiedError.value = false;

      final response = await _supabase.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _supabase.syncFromAuthResponse(response);
        await _loadUserData(supabaseUser: response.user);
        AnalyticsService.instance.track('auth_login', properties: {
          'method': 'email',
        });

        Get.snackbar(
          'Welcome back!',
          'Successfully logged in as ${user.value?.fullName ?? user.value?.email}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
        );

        // Navigate to home
        Get.offAllNamed(Routes.home);
      } else {
        throw Exception('Login failed. Please try again.');
      }
    } on AuthException catch (e) {
      error.value = e.message;
      // Check for email not confirmed error
      if (e.message.toLowerCase().contains('email not confirmed')) {
        showEmailNotVerifiedError.value = true;
        unverifiedEmail.value = email;
        // Don't show snackbar for this error, we show inline UI instead
      } else {
        Get.snackbar(
          'Login Failed',
          e.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade900,
        );
      }
      rethrow;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Login Failed',
        error.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Register new user using Supabase
  Future<void> register(String email, String password, {String? fullName, String? referralCode}) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _supabase.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        _supabase.syncFromAuthResponse(response);
        await _loadUserData(supabaseUser: response.user);
        AnalyticsService.instance.track('auth_register', properties: {
          'method': 'email',
          'has_referral': referralCode != null && referralCode.isNotEmpty,
        });

        // Redeem referral code if provided
        if (referralCode != null && referralCode.isNotEmpty) {
          await _redeemReferralCode(referralCode);
        }

        Get.snackbar(
          'Welcome to Fit Check!',
          'Account created successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
        );

        // Navigate to home
        Get.offAllNamed(Routes.home);
      } else {
        throw Exception('Registration failed. Please try again.');
      }
    } on AuthException catch (e) {
      error.value = e.message;
      Get.snackbar(
        'Registration Failed',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Registration Failed',
        error.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    try {
      isGoogleSigningIn.value = true;
      error.value = '';

      await _supabase.signInWithGoogle();
      AnalyticsService.instance.track('auth_login', properties: {
        'method': 'google',
      });
      // OAuth flow will redirect - state will be updated via deep link
    } on AuthException catch (e) {
      error.value = e.message;
      Get.snackbar(
        'Google Sign-In Failed',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Google Sign-In Failed',
        error.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } finally {
      isGoogleSigningIn.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    isLoggingOut.value = true;
    try {
      await _supabase.signOut();
      AnalyticsService.instance.reset();
      user.value = null;
      error.value = '';

      Get.offAllNamed(Routes.splash);

      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoggingOut.value = false;
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _supabase.resetPassword(email);

      Get.snackbar(
        'Email Sent',
        'Check your email for password reset instructions',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
      );
    } on AuthException catch (e) {
      error.value = e.message;
      Get.snackbar(
        'Request Failed',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Request Failed',
        error.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _supabase.updatePassword(newPassword);

      Get.snackbar(
        'Password Updated',
        'Your password has been updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
      );
    } on AuthException catch (e) {
      error.value = e.message;
      Get.snackbar(
        'Update Failed',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Update Failed',
        error.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    await _loadUserData();
  }

  /// Clear error
  void clearError() {
    error.value = '';
  }

  /// Clear email verification error state
  void clearEmailVerificationError() {
    showEmailNotVerifiedError.value = false;
    unverifiedEmail.value = '';
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    if (unverifiedEmail.value.isEmpty) return;

    try {
      isResendingVerification.value = true;
      error.value = '';

      await _supabase.resendVerificationEmail(unverifiedEmail.value);

      Get.snackbar(
        'Email Sent',
        'Verification email has been sent. Please check your inbox.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
      );
    } on AuthException catch (e) {
      error.value = e.message;
      Get.snackbar(
        'Failed to Send Email',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Failed to Send Email',
        error.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
    } finally {
      isResendingVerification.value = false;
    }
  }

  /// Get current access token for API calls
  String? get accessToken => _supabase.currentAccessToken;

  /// Store pending referral code for OAuth flow
  Future<void> setPendingReferralCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingReferralKey, code);
  }

  /// Get and clear pending referral code
  Future<String?> _getAndClearPendingReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_pendingReferralKey);
    if (code != null) {
      await prefs.remove(_pendingReferralKey);
    }
    return code;
  }

  /// Redeem a referral code after registration
  Future<void> _redeemReferralCode(String code) async {
    try {
      await _subscriptionRepo.redeemReferralCode(code);
      Get.snackbar(
        'Referral Applied!',
        'You and your friend both get 1 month of Pro free!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      // Don't fail registration if referral redemption fails
      debugPrint('Failed to redeem referral code: $e');
    }
  }

  /// Handle OAuth callback and check for pending referral
  Future<void> handleOAuthCallback() async {
    // Check for pending referral code from before OAuth redirect
    final pendingCode = await _getAndClearPendingReferralCode();
    if (pendingCode != null && pendingCode.isNotEmpty) {
      await _redeemReferralCode(pendingCode);
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/analytics_service.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Handles all authentication operations — login, register, logout, token
/// management, and email verification.
///
/// Extracted from [AuthController] as part of FL7 to trim its size and
/// separate concerns.
class AuthService extends GetxService {
  final SupabaseService _supabase = SupabaseService.instance;
  final AuthRepository _authRepository = AuthRepository();

  /// Login with email and password using Supabase.
  /// Returns the [AuthResponse] on success, or throws on failure.
  Future<AuthResponse> login(String email, String password) async {
    final response = await _supabase.signInWithEmail(
      email: email,
      password: password,
    );

    if (response.user != null) {
      _supabase.syncFromAuthResponse(response);
    }

    return response;
  }

  /// Register a new user using Supabase.
  Future<AuthResponse> register(
    String email,
    String password, {
    String? fullName,
  }) async {
    final response = await _supabase.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );

    if (response.user != null) {
      _supabase.syncFromAuthResponse(response);
    }

    return response;
  }

  /// Sign in with Google OAuth.
  Future<void> signInWithGoogle() async {
    await _supabase.signInWithGoogle();
  }

  /// Sign in with Apple (native flow). Returns the [AuthResponse].
  Future<AuthResponse> signInWithApple() async {
    final response = await _supabase.signInWithApple();

    if (response.user != null) {
      _supabase.syncFromAuthResponse(response);
    }

    return response;
  }

  /// Logout the current user.
  Future<void> logout() async {
    await _supabase.signOut();
  }

  /// Request a password reset email.
  Future<void> requestPasswordReset(String email) async {
    await _supabase.resetPassword(email);
  }

  /// Update the user's password.
  Future<void> updatePassword(String newPassword) async {
    await _supabase.updatePassword(newPassword);
  }

  /// Resend the verification email.
  Future<void> resendVerificationEmail(String email) async {
    await _supabase.resendVerificationEmail(email);
  }

  /// Load user data from Supabase Auth and merge the backend profile.
  Future<UserModel?> loadUserData({User? supabaseUser}) async {
    final resolvedUser = supabaseUser ?? _supabase.currentUser.value;
    if (resolvedUser == null) return null;

    final userModel = _buildUserModel(resolvedUser);

    // Attempt backend profile merge (best-effort)
    try {
      final backendUser = await _authRepository.getCurrentUserProfile();
      if (backendUser.isNotEmpty) {
        return _mergeProfile(userModel, backendUser);
      }
    } catch (e) {
      debugPrint('Failed to merge backend profile: $e');
    }

    return userModel;
  }

  UserModel _buildUserModel(User supabaseUser) {
    final model = UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      fullName: supabaseUser.userMetadata?['full_name'] as String?,
      avatarUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      birthDate: supabaseUser.userMetadata?['birth_date'] as String?,
      birthTime: supabaseUser.userMetadata?['birth_time'] as String?,
      birthPlace: supabaseUser.userMetadata?['birth_place'] as String?,
      createdAt: DateTime.tryParse(supabaseUser.createdAt),
    );

    AnalyticsService.instance.identify(
      supabaseUser.id,
      traits: {
        'email': supabaseUser.email,
        'full_name': supabaseUser.userMetadata?['full_name'],
      },
    );

    return model;
  }

  UserModel _mergeProfile(UserModel current, Map<String, dynamic> backendUser) {
    String? toNullableString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return current.copyWith(
      fullName: toNullableString(backendUser['full_name']) ?? current.fullName,
      avatarUrl: toNullableString(backendUser['avatar_url']) ?? current.avatarUrl,
      birthDate: toNullableString(backendUser['birth_date']),
      birthTime: toNullableString(backendUser['birth_time']),
      birthPlace: toNullableString(backendUser['birth_place']),
      createdAt: DateTime.tryParse(backendUser['created_at']?.toString() ?? '') ??
          current.createdAt,
      updatedAt: DateTime.tryParse(backendUser['updated_at']?.toString() ?? '') ??
          current.updatedAt,
    );
  }

  /// Track authentication events.
  void trackLogin(String method) {
    AnalyticsService.instance.track('auth_login', properties: {'method': method});
  }

  void trackRegister({required bool hasReferral}) {
    AnalyticsService.instance.track(
      'auth_register',
      properties: {
        'method': 'email',
        'has_referral': hasReferral,
      },
    );
  }

  /// Get the current access token for API calls.
  String? get accessToken => _supabase.currentAccessToken;
}

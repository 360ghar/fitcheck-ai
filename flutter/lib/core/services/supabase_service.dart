import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../constants/api_constants.dart';
import 'analytics_service.dart';

/// Supabase configuration and service
/// Manages Supabase client initialization and authentication state
class SupabaseService extends GetxService {
  SupabaseService._internal();
  static final SupabaseService _instance = SupabaseService._internal();
  static SupabaseService get instance => _instance;

  late final SupabaseClient _client;

  /// Get the Supabase client
  SupabaseClient get client => _client;

  /// Get current auth state
  Rxn<User> currentUser = Rxn<User>();
  final RxBool isAuthenticated = false.obs;
  final RxBool isInitialized = false.obs;

  /// Get the GoTrue client for auth operations
  GoTrueClient get auth => _client.auth;

  /// Initialize Supabase with environment variables
  /// IMPORTANT: SUPABASE_URL and SUPABASE_ANON_KEY must be provided
  /// via `.env` asset or build-time --dart-define
  Future<SupabaseService> init() async {
    if (isInitialized.value) return this;

    // Get Supabase URL and key from environment - NO DEFAULTS for security
    final supabaseUrl = EnvConfig.supabaseUrl;
    final supabaseAnonKey = EnvConfig.supabaseAnonKey;
    final supabasePublishableKey = EnvConfig.supabasePublishableKey;
    final resolvedAnonKey = supabaseAnonKey.isNotEmpty
        ? supabaseAnonKey
        : supabasePublishableKey;

    // Validate that credentials were provided
    if (supabaseUrl.isEmpty || resolvedAnonKey.isEmpty) {
      throw Exception(
        'Supabase credentials not provided. Ensure `.env` is loaded or pass:\n'
        'flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: resolvedAnonKey,
      debug: kDebugMode,
    );

    _client = Supabase.instance.client;

    // Set up auth state listener
    _client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        currentUser.value = session.user;
        isAuthenticated.value = true;
      } else if (event == AuthChangeEvent.signedOut) {
        currentUser.value = null;
        isAuthenticated.value = false;
        AnalyticsService.instance.reset();
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        currentUser.value = session.user;
      } else if (event == AuthChangeEvent.initialSession) {
        if (session != null) {
          currentUser.value = session.user;
          isAuthenticated.value = true;
        } else {
          currentUser.value = null;
          isAuthenticated.value = false;
        }
      }
    });

    isInitialized.value = true;
    return this;
  }

  /// Get current session
  Session? get currentSession {
    return _client.auth.currentSession;
  }

  /// Get current access token
  String? get currentAccessToken {
    return currentSession?.accessToken;
  }

  /// Get current user ID
  String? get currentUserId {
    return currentUser.value?.id;
  }

  /// Get current user email
  String? get currentUserEmail {
    return currentUser.value?.email;
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Sync local auth state from an AuthResponse when available
  void syncFromAuthResponse(AuthResponse response) {
    final session = response.session;
    final user = response.user;
    if (session == null || user == null) {
      return;
    }

    currentUser.value = user;
    isAuthenticated.value = true;
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
    return response;
  }

  /// Sign in with Google OAuth
  /// Returns true if OAuth flow was initiated successfully
  Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'fitcheck.ai://login-callback',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: '${ApiConstants.baseUrl}/auth/reset-password',
    );
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Refresh the session
  Future<void> refreshSession() async {
    await _client.auth.refreshSession();
  }
}

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../constants/api_constants.dart';
import 'analytics_service.dart';
import 'secure_local_storage.dart';

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

    // Matches supabase_flutter's own default SharedPreferencesLocalStorage
    // key (see its Supabase.initialize source) so SecureLocalStorage can
    // find and migrate an already-signed-in user's session on first run.
    final legacySessionKey =
        'sb-${Uri.parse(supabaseUrl).host.split(".").first}-auth-token';

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: resolvedAnonKey,
      debug: kDebugMode,
      // Keychain/Keystore-backed session storage instead of the package
      // default (plaintext SharedPreferences/NSUserDefaults) - a device
      // backup or filesystem access on a rooted/jailbroken device would
      // otherwise expose the long-lived refresh token in cleartext.
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureLocalStorage(
          persistSessionKey: 'fitcheck_supabase_auth_token',
          legacySharedPreferencesKey: legacySessionKey,
        ),
      ),
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
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Generate a cryptographically secure raw nonce string
  String _generateRawNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// SHA-256 hash (hex) of the provided input
  String _sha256Hex(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  /// Sign in with Apple using the native flow (iOS).
  ///
  /// Uses a raw nonce hashed with SHA-256: the HASHED nonce is sent to Apple,
  /// while the RAW nonce is sent to Supabase. These must NOT be swapped.
  /// Returns the [AuthResponse] from Supabase on success.
  Future<AuthResponse> signInWithApple() async {
    // Raw nonce goes to Supabase; its SHA-256 hash goes to Apple.
    final rawNonce = _generateRawNonce();
    final hashedNonce = _sha256Hex(rawNonce);

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException(
        'Apple sign-in failed: no identity token returned.',
      );
    }

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    // Apple only returns the name on the FIRST authorization. Persist it as
    // full_name when present and the user metadata does not already have one.
    final givenName = credential.givenName;
    final familyName = credential.familyName;
    final fullName = [givenName, familyName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(' ');
    final existingFullName =
        response.user?.userMetadata?['full_name'] as String?;
    if (fullName.isNotEmpty &&
        (existingFullName == null || existingFullName.trim().isEmpty)) {
      await _client.auth.updateUser(
        UserAttributes(data: {'full_name': fullName}),
      );
    }

    return response;
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
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Refresh the session
  Future<void> refreshSession() async {
    await _client.auth.refreshSession();
  }

  /// Resend verification email
  Future<void> resendVerificationEmail(String email) async {
    await _client.auth.resend(type: OtpType.signup, email: email);
  }
}

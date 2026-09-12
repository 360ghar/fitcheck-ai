import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import 'package:supabase_flutter/supabase_flutter.dart'
    show
        AuthException,
        AuthRetryableFetchException,
        AuthSessionMissingException;
import '../../app/routes/app_routes.dart';
import '../constants/api_constants.dart';
import '../services/supabase_service.dart';
import 'auth_url_policy.dart';

String? _currentAccessToken() => SupabaseService.instance.currentAccessToken;

bool _requiresSession(RequestOptions options) =>
    urlAcceptsAuthToken(options.uri.toString()) &&
    !ApiConstants.isPublicEndpoint(options.uri.path);

/// Interceptor to add Supabase auth token to API requests
class AuthInterceptor extends Interceptor {
  AuthInterceptor({String? Function()? currentAccessToken})
    : _accessToken = currentAccessToken ?? _currentAccessToken;

  final String? Function() _accessToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip auth for public endpoints and for URLs that must NOT carry the
    // bearer token (A9-01): presigned S3/R2 URLs reject any second auth
    // mechanism ("Only one auth mechanism allowed") and third-party hosts
    // must never receive the session token. Relative API paths are always
    // ours and stay eligible.
    if (!_requiresSession(options)) {
      options.headers.removeWhere(
        (key, _) => key.toLowerCase() == 'authorization',
      );
      return handler.next(options);
    }

    // Add Supabase auth token to API requests
    final token = _accessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

/// Interceptor to handle token refresh on 401 using Supabase
class TokenRefreshInterceptor extends Interceptor {
  final Dio _dio; // Store reference to the main Dio instance
  final String? Function() _accessToken;
  final Future<void> Function() _refreshSession;
  final Future<void> Function() _signOut;
  final void Function() _onSessionRejected;
  Future<void>? _refreshFuture;

  TokenRefreshInterceptor(
    this._dio, {
    String? Function()? currentAccessToken,
    Future<void> Function()? refreshSession,
    Future<void> Function()? signOut,
    void Function()? onSessionRejected,
  }) : _accessToken = currentAccessToken ?? _currentAccessToken,
       _refreshSession =
           refreshSession ?? SupabaseService.instance.refreshSession,
       _signOut = signOut ?? SupabaseService.instance.signOut,
       _onSessionRejected =
           onSessionRejected ??
           (() {
             getx.Get.offAllNamed(Routes.splash);
           });

  /// Marks a retried request so a second 401 on the replayed request does not
  /// start another refresh (which would loop: refresh -> fetch -> 401 ->
  /// refresh...). The original 401 then propagates to the caller, which is the
  /// correct terminal behaviour for a token that refresh cannot fix.
  static const String _retryMarkerKey = 'fitcheck_retried_after_refresh';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If it's a 401 and not a public endpoint, and this request has not
    // already been retried after a refresh.
    final alreadyRetried = err.requestOptions.extra[_retryMarkerKey] == true;
    if (err.response?.statusCode == 401 &&
        _requiresSession(err.requestOptions) &&
        !alreadyRetried) {
      Future<void>? refresh;
      try {
        // Single-flight: racing 401s share one refreshSession() call. The
        // slot is cleared only while it still holds the future we awaited —
        // an unconditional null here (or in a finally) would clobber a NEWER
        // refresh started by another racing caller between our await
        // resuming and our clear, breaking single-flight for it.
        _refreshFuture ??= _refreshAuthentication();
        refresh = _refreshFuture;
        await refresh;
      } catch (e) {
        if (identical(_refreshFuture, refresh)) _refreshFuture = null;
        if (kDebugMode) {
          debugPrint('Token refresh failed: $e');
        }
        return handler.next(err);
      }
      if (identical(_refreshFuture, refresh)) _refreshFuture = null;

      final newToken = _accessToken();
      if (newToken == null || newToken.isEmpty) {
        return handler.next(err);
      }

      // A multipart body is finalized by its first send; replaying the same
      // RequestOptions throws instead of retrying. Surface the original 401
      // to the upload's own error path (the refresh above still fixed the
      // session for every other queued request).
      if (err.requestOptions.data is FormData) {
        return handler.next(err);
      }

      final opts = err.requestOptions;
      opts.extra[_retryMarkerKey] = true;
      opts.headers['Authorization'] = 'Bearer $newToken';

      try {
        final response = await _dio.fetch(opts);
        return handler.resolve(response);
      } on DioException catch (replayError) {
        // A failed retry is a request failure, not proof of a dead session.
        // Preserve its real status so a transient 503 is not shown as a 401.
        return handler.next(replayError);
      } catch (_) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  Future<void> _refreshAuthentication() async {
    final tokenBeforeRefresh = _accessToken();
    try {
      await _refreshSession();
    } catch (e) {
      // This runs inside the shared refresh, so racing 401s cause at most
      // one logout/navigation. Transient failures do not trigger an extra
      // logout here; the auth SDK controls its own session state.
      // The SDK preserves a login that replaced this refresh's session.
      // Its stale rejection must not make this interceptor sign it out.
      final currentToken = _accessToken();
      final sessionWasReplaced =
          currentToken != null &&
          currentToken.isNotEmpty &&
          currentToken != tokenBeforeRefresh;
      if (!sessionWasReplaced && _isRejectedSession(e)) {
        try {
          await _signOut();
        } catch (_) {}
        _onSessionRejected();
      }
      rethrow;
    }
  }
}

bool _isRejectedSession(Object error) {
  if (error is AuthRetryableFetchException) return false;
  if (error is AuthSessionMissingException) return true;
  if (error is! AuthException) return false;
  return const {
        'refresh_token_not_found',
        'refresh_token_already_used',
        'session_not_found',
        'session_expired',
        'user_not_found',
        'user_banned',
      }.contains(error.code) ||
      const {'400', '401', '403'}.contains(error.statusCode);
}

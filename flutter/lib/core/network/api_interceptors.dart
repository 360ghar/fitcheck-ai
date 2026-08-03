import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import '../../app/routes/app_routes.dart';
import '../constants/api_constants.dart';
import '../services/supabase_service.dart';

/// Interceptor to add Supabase auth token to API requests
class AuthInterceptor extends Interceptor {
  final SupabaseService _supabase = SupabaseService.instance;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    // Add Supabase auth token to API requests
    final token = _supabase.currentAccessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  bool _isPublicEndpoint(String path) {
    return ApiConstants.publicEndpoints.any((endpoint) => path.contains(endpoint));
  }
}

/// Interceptor to handle token refresh on 401 using Supabase
class TokenRefreshInterceptor extends Interceptor {
  final SupabaseService _supabase = SupabaseService.instance;
  final Dio _dio; // Store reference to the main Dio instance
  Future<void>? _refreshFuture;

  TokenRefreshInterceptor(this._dio);

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
        !_isPublicEndpoint(err.requestOptions.path) &&
        !alreadyRetried) {
      try {
        _refreshFuture ??= _supabase.refreshSession();
        await _refreshFuture;
        _refreshFuture = null;

        final newToken = _supabase.currentAccessToken;
        if (newToken == null || newToken.isEmpty) {
          return handler.next(err);
        }

        final opts = err.requestOptions;
        opts.extra[_retryMarkerKey] = true;
        opts.headers['Authorization'] = 'Bearer $newToken';

        final response = await _dio.fetch(opts);
        return handler.resolve(response);
      } catch (e) {
        // Only a FAILED REFRESH is a session problem. A failure of the
        // replayed request itself (transient 5xx, network blip, or the
        // second 401 the retry marker intends to propagate to the caller)
        // must NOT force a sign-out — the marker's terminal behaviour is
        // "the original 401 propagates to the caller". Throwing out of
        // `_dio.fetch` lands here, so distinguish the two: wrap only the
        // refresh in the sign-out path.
        final isRefreshFailure = _refreshFuture != null;
        _refreshFuture = null;
        if (isRefreshFailure) {
          if (kDebugMode) {
            debugPrint('Token refresh failed: $e');
          }
          await _supabase.signOut();
          getx.Get.offAllNamed(Routes.splash);
        }
        return handler.next(err);
      } finally {
        _refreshFuture = null;
      }
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    return ApiConstants.publicEndpoints.any((endpoint) => path.contains(endpoint));
  }
}

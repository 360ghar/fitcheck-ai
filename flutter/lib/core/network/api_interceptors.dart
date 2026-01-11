import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import '../../app/routes/app_routes.dart';
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
    final publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/reset-password',
      '/auth/verify-email',
      '/waitlist',
    ];
    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }
}

/// Interceptor to handle token refresh on 401 using Supabase
class TokenRefreshInterceptor extends Interceptor {
  final SupabaseService _supabase = SupabaseService.instance;
  final Dio _dio; // Store reference to the main Dio instance
  Future<void>? _refreshFuture;

  TokenRefreshInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If it's a 401 and not a public endpoint
    if (err.response?.statusCode == 401 &&
        !_isPublicEndpoint(err.requestOptions.path)) {
      try {
        _refreshFuture ??= _supabase.refreshSession();
        await _refreshFuture;
        _refreshFuture = null;

        final newToken = _supabase.currentAccessToken;
        if (newToken == null || newToken.isEmpty) {
          return handler.next(err);
        }

        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';

        final response = await _dio.fetch(opts);
        return handler.resolve(response);
      } catch (e) {
        _refreshFuture = null;
        if (kDebugMode) {
          debugPrint('Token refresh failed: $e');
        }
        await _supabase.signOut();
        getx.Get.offAllNamed(Routes.splash);
        return handler.next(err);
      } finally {
        _refreshFuture = null;
      }
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    final publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/reset-password',
      '/auth/verify-email',
      '/waitlist',
    ];
    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }
}

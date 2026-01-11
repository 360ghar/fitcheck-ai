import '../config/env_config.dart';

/// API endpoint constants
class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    final envUrl = EnvConfig.apiBaseUrl;
    return envUrl.isNotEmpty ? envUrl : 'https://api.fitcheckaiapp.com';
  }

  /// Get base URL for development (defaults to localhost if not set)
  static String get developmentBaseUrl {
    final envUrl = EnvConfig.apiBaseUrl;
    return envUrl.isNotEmpty ? envUrl : 'http://localhost:8000';
  }

  // API Version
  static const String apiVersion = '/api/v1';

  // Endpoints
  static const String auth = '$apiVersion/auth';
  static const String items = '$apiVersion/items';
  static const String outfits = '$apiVersion/outfits';
  static const String recommendations = '$apiVersion/recommendations';
  static const String calendar = '$apiVersion/calendar';
  static const String weather = '$apiVersion/weather';
  static const String gamification = '$apiVersion/gamification';
  static const String ai = '$apiVersion/ai';
  static const String aiSettings = '$apiVersion/ai/settings';
  static const String users = '$apiVersion/users';
  static const String waitlist = '$apiVersion/waitlist';

  // Auth Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String refresh = '/refresh';
  static const String oauthSync = '/oauth-sync';
  static const String resetPassword = '/reset-password';
  static const String resetPasswordConfirm = '/reset-password/confirm';
  static const String verifyEmail = '/verify-email';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(minutes: 10); // For AI operations
  static const Duration sendTimeout = Duration(seconds: 30);
}

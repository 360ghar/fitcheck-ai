import 'package:flutter/foundation.dart';
import '../config/env_config.dart';

/// API endpoint constants
class ApiConstants {
  ApiConstants._();

  /// Get base URL - fails explicitly in release builds if not configured
  static String get baseUrl {
    final envUrl = EnvConfig.apiBaseUrl;
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // In debug mode, fall back to localhost for development
    if (kDebugMode) {
      return 'http://localhost:8000';
    }

    // In release builds, fail explicitly if not configured
    throw StateError(
      'API_BASE_URL is not configured. '
      'Please set API_BASE_URL in your .env file or via --dart-define.',
    );
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
  static const String subscription = '$apiVersion/subscription';
  static const String referral = '$apiVersion/referral';
  static const String feedback = '$apiVersion/feedback';
  static const String photoshoot = '$apiVersion/photoshoot';
  static String photoshootEvents(String jobId) => '$photoshoot/$jobId/events';
  static String photoshootCancel(String jobId) => '$photoshoot/$jobId/cancel';
  static String photoshootStatus(String jobId) => '$photoshoot/$jobId/status';

  // Batch Extraction Endpoints
  static const String aiBatchExtract = '$apiVersion/ai/batch-extract';
  static String aiBatchExtractEvents(String jobId) =>
      '$aiBatchExtract/$jobId/events';
  static String aiBatchExtractCancel(String jobId) =>
      '$aiBatchExtract/$jobId/cancel';
  static String aiBatchExtractStatus(String jobId) =>
      '$aiBatchExtract/$jobId/status';

  // AI Extraction Endpoints
  static const String aiExtractItems = '$ai/extract-items';
  static const String aiExtractSingleItem = '$ai/extract-single-item';
  static const String aiGenerateOutfit = '$ai/generate-outfit';
  static const String aiGenerateProductImage = '$ai/generate-product-image';
  static const String aiTryOn = '$ai/try-on';
  static const String aiEmbeddings = '$ai/embeddings';
  static const String aiEmbeddingsBatch = '$ai/embeddings/batch';
  static const String aiEmbeddingsSearch = '$ai/embeddings/search';
  static const String aiModels = '$ai/models';

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
  // Increased connection timeout to handle AI operations that take longer to respond
  static const Duration connectionTimeout = Duration(minutes: 3);
  static const Duration receiveTimeout = Duration(minutes: 10); // For AI operations
  static const Duration sendTimeout = Duration(minutes: 3);
}

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

    // In release builds, default to production
    // Note: This fallback is intentional for release builds where
    // API_BASE_URL is not explicitly configured
    debugPrint(
      'Warning: API_BASE_URL not configured, using production default',
    );
    return 'https://api.fitcheckaiapp.com';
  }

  /// Web frontend base URL (for password-reset email links, etc.)
  static String get webBaseUrl {
    final envUrl = EnvConfig.frontendUrl;
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    if (kDebugMode) {
      return 'http://localhost:3000';
    }
    return 'https://fitcheckaiapp.com';
  }

  // API Version
  static const String apiVersion = '/api/v1';

  /// Path fragments that don't require an auth token and are exempt from
  /// 401 token-refresh handling. Shared by [AuthInterceptor] and
  /// [TokenRefreshInterceptor] so the list only needs to be updated once.
  static const List<String> publicEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/reset-password',
    '/auth/verify-email',
    '/waitlist',
  ];

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

  // Image serving: re-mint a fresh client-fetchable URL for a storage_path
  // (the API serves short-lived presigned URLs; clients re-mint on expiry).
  static const String imagesPresigned = '$apiVersion/images/presigned';
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

  // Single Item Async Extraction (uses same SSE infrastructure as batch)
  static const String aiSingleExtract = '$ai/single-extract';

  // Social Import Endpoints
  static const String aiSocialImportJobs = '$apiVersion/ai/social-import/jobs';
  static String aiSocialImportStatus(String jobId) =>
      '$aiSocialImportJobs/$jobId/status';
  static String aiSocialImportEvents(String jobId) =>
      '$aiSocialImportJobs/$jobId/events';
  static String aiSocialImportOAuthConnect(String jobId) =>
      '$aiSocialImportJobs/$jobId/auth/oauth/connect';
  static String aiSocialImportOAuthSubmit(String jobId) =>
      '$aiSocialImportJobs/$jobId/auth/oauth';
  static String aiSocialImportScraperLogin(String jobId) =>
      '$aiSocialImportJobs/$jobId/auth/scraper-login';
  static String aiSocialImportPatchItem(
    String jobId,
    String photoId,
    String itemId,
  ) => '$aiSocialImportJobs/$jobId/photos/$photoId/items/$itemId';
  static String aiSocialImportApprovePhoto(String jobId, String photoId) =>
      '$aiSocialImportJobs/$jobId/photos/$photoId/approve';
  static String aiSocialImportRejectPhoto(String jobId, String photoId) =>
      '$aiSocialImportJobs/$jobId/photos/$photoId/reject';
  static String aiSocialImportCancel(String jobId) =>
      '$aiSocialImportJobs/$jobId/cancel';

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
  static const String oauthSync = '/oauth/sync';
  static const String resetPassword = '/reset-password';
  static const String resetPasswordConfirm = '/reset-password/confirm';
  static const String verifyEmail = '/verify-email';

  // Timeout durations
  // Base timeouts for standard CRUD/auth endpoints. Anything that generates
  // with AI or moves a multipart body must go through
  // [ApiClient.postWithExtendedTimeout], [ApiClient.upload] or
  // [ApiClient.uploadMultiple], all of which override send/receive with the
  // ai* values below. A plain `post` to an AI endpoint gets 60s and fails.
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // Extended timeouts for AI generation and large file uploads.
  static const Duration aiReceiveTimeout = Duration(minutes: 10);
  static const Duration aiSendTimeout = Duration(minutes: 5);
}

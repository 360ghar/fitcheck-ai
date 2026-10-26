import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/widgets.dart';
import '../exceptions/app_exceptions.dart';
import '../i18n/l10n.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';

/// Utility class for handling errors consistently across the app
class ErrorHandler {
  /// Extract a user-friendly error message from any error.
  ///
  /// This is the **English** form and it is what telemetry receives, so error
  /// text stays groupable in Sentry instead of arriving in 43 languages. Use
  /// [localizedMessage] for anything a user reads.
  static String extractMessage(dynamic error) {
    if (error == null) return 'An unexpected error occurred';

    // Handle custom exceptions
    if (error is AppException) {
      return error.message;
    }

    // Handle DioException
    if (error is DioException) {
      return handleDioException(error).message;
    }

    // Handle Exception with message
    if (error is Exception) {
      final message = error.toString();
      // Remove 'Exception: ' prefix if present
      if (message.startsWith('Exception: ')) {
        return message.replaceFirst('Exception: ', '');
      }
      return message;
    }

    // Handle String
    if (error is String) {
      return error;
    }

    return 'An unexpected error occurred';
  }

  /// The localizations in scope, or null before the first frame.
  ///
  /// Exceptions are thrown deep in repositories where no `BuildContext` exists,
  /// and threading one through every call site to translate a snackbar is a huge
  /// amount of noise. Every `AppException` already carries a stable
  /// `errorCode`, so the message is translated here, once, at the boundary where
  /// it becomes pixels.
  ///
  /// Returns null rather than throwing in three cases that are all "not
  /// rendering yet": the binding is absent (a pure unit test constructing an
  /// exception), no messenger is mounted, or the messenger has no widget
  /// context. Services and repositories construct exceptions in all three, and
  /// a lookup that throws would turn a handled error into an unhandled one.
  static AppLocalizations? get l10n {
    try {
      final context = scaffoldMessengerKey.currentContext;
      if (context == null) return null;
      return Localizations.of<AppLocalizations>(context, AppLocalizations);
    } catch (_) {
      return null;
    }
  }

  /// Map an [AppException.errorCode] to its translated message.
  ///
  /// Returning null means "no key for this code", and the caller falls back to
  /// the English message the exception was constructed with. That fallback is
  /// deliberate: a new exception type with a code added here but not in the ARB
  /// catalog must still show something, never an empty snackbar.
  static String? _localizedByCode(AppLocalizations l10n, String? code) {
    return switch (code) {
      'NO_CONNECTION' => l10n.errorNoConnection,
      'TIMEOUT' => l10n.errorTimeout,
      'SERVER_ERROR' => l10n.errorServerError,
      'BAD_GATEWAY' => l10n.errorBadGateway,
      'SERVICE_UNAVAILABLE' => l10n.errorServiceUnavailable,
      'INTERNAL_ERROR' => l10n.errorInternalError,
      'UNAUTHORIZED' => l10n.errorUnauthorized,
      'FORBIDDEN' => l10n.errorForbidden,
      'SESSION_EXPIRED' => l10n.errorSessionExpired,
      'INVALID_CREDENTIALS' => l10n.errorInvalidCredentials,
      'TOKEN_REFRESH_FAILED' => l10n.errorTokenRefreshFailed,
      'REQUEST_CANCELLED' => l10n.errorRequestCancelled,
      'INVALID_FORMAT' => l10n.errorInvalidFormat,
      'FILE_TOO_LARGE' => l10n.errorFileTooLarge,
      'UPLOAD_FAILED' => l10n.errorUploadFailed,
      'CACHE_CORRUPTED' => l10n.errorCacheCorrupted,
      'CACHE_NOT_FOUND' => l10n.errorCacheNotFound,
      'USER_NOT_FOUND' => l10n.errorUserNotFound,
      'ITEM_NOT_FOUND' => l10n.errorItemNotFound,
      'OUTFIT_NOT_FOUND' => l10n.errorOutfitNotFound,
      _ => null,
    };
  }

  /// The message to show a user, in their language.
  ///
  /// Raw `Exception('...')` and `String` errors keep their original text: those
  /// carry either backend prose or a developer message, and guessing a
  /// translation for them would be worse than showing the original.
  static String localizedMessage(dynamic error) {
    final l10n = ErrorHandler.l10n;
    if (l10n == null) return extractMessage(error);
    if (error == null) return l10n.errorUnknown;

    if (error is AppException) {
      return _localizedByCode(l10n, error.errorCode) ?? error.message;
    }
    if (error is DioException) {
      final converted = handleDioException(error);
      return _localizedByCode(l10n, converted.errorCode) ?? converted.message;
    }
    if (error is Exception || error is String) {
      return extractMessage(error);
    }
    return l10n.errorUnknown;
  }

  /// Show error to user via snackbar, and report it for telemetry.
  ///
  /// Previously a caught error only ever reached the user via this snackbar -
  /// it never reached Sentry/PostHog, so a production regression in any
  /// caught path was invisible until a user complained. Every handled error
  /// generates telemetry now, matching what the global uncaught-error
  /// handlers in main.dart already do.
  static void showError(dynamic error, {String? title, StackTrace? stackTrace}) {
    // Telemetry gets the English message so Sentry groups one error as one
    // issue; the user gets the same error in their own language.
    reportError(error, extractMessage(error), stackTrace: stackTrace);
    NotificationService.present(AppNotification(
      title: title ?? l10n?.errorTitle ?? 'Error',
      message: localizedMessage(error),
      type: NotificationType.error,
    ));
  }

  /// Show a validation problem to the user WITHOUT reporting telemetry.
  ///
  /// "Please enter a title" is normal user behaviour, not a defect. Routing it
  /// through [showError] would file a Sentry event every time someone taps Save
  /// on an empty form and drown the signal this class exists to produce.
  /// Presentation is identical -- only the reporting differs.
  static void showValidation(String message, {String? title}) {
    NotificationService.present(AppNotification(
      title: title ?? l10n?.errorTitle ?? 'Error',
      message: message,
      type: NotificationType.error,
    ));
  }

  /// Report a handled error to telemetry without showing any UI. Useful for
  /// silent/background failures that don't warrant interrupting the user
  /// but should still be visible to the team.
  static void reportError(dynamic error, String message, {StackTrace? stackTrace}) {
    AnalyticsService.instance.recordNonFatalError(
      message,
      context: {'error_type': error?.runtimeType.toString() ?? 'unknown'},
    );
    captureToSentry(error, stackTrace: stackTrace);
  }

  /// The single guarded entry point for Sentry captures.
  ///
  /// `SentryFlutter.init` may never run at all (empty `EnvConfig.sentryDsn`)
  /// or may still be in flight during cold start, and capturing before it
  /// completes is a no-op at best and can throw at worst. [Sentry.isEnabled]
  /// is the SDK's own truth for that (it is backed by a `NoOpHub` until init
  /// installs the real one), so there is no separate flag to keep in sync.
  /// Never call `Sentry.captureException` directly - route it through here.
  static void captureToSentry(dynamic error, {StackTrace? stackTrace}) {
    if (!Sentry.isEnabled) return;
    Sentry.captureException(error, stackTrace: stackTrace);
  }

  /// Show success message via snackbar
  static void showSuccess(String message, {String? title}) {
    NotificationService.present(AppNotification(
      title: title ?? 'Success',
      message: message,
      type: NotificationType.success,
    ));
  }

  /// Show info message via snackbar
  static void showInfo(String message, {String? title}) {
    NotificationService.present(AppNotification(
      title: title ?? 'Info',
      message: message,
      type: NotificationType.info,
    ));
  }

  /// Show warning message via snackbar
  static void showWarning(String message, {String? title}) {
    NotificationService.present(AppNotification(
      title: title ?? 'Warning',
      message: message,
      type: NotificationType.warning,
    ));
  }
}

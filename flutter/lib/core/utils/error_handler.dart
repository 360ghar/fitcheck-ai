import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../exceptions/app_exceptions.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';

/// Utility class for handling errors consistently across the app
class ErrorHandler {
  /// Extract a user-friendly error message from any error
  static String extractMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

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

  /// Show error to user via snackbar, and report it for telemetry.
  ///
  /// Previously a caught error only ever reached the user via this snackbar -
  /// it never reached Sentry/PostHog, so a production regression in any
  /// caught path was invisible until a user complained. Every handled error
  /// generates telemetry now, matching what the global uncaught-error
  /// handlers in main.dart already do.
  static void showError(dynamic error, {String? title, StackTrace? stackTrace}) {
    final message = extractMessage(error);
    reportError(error, message, stackTrace: stackTrace);
    NotificationService.present(AppNotification(
      title: title ?? 'Error',
      message: message,
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
      title: title ?? 'Error',
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

/// Extension to easily show errors from controllers
extension ErrorHandlerExtension on GetxController {
  void handleError(dynamic error, {String? title, StackTrace? stackTrace}) {
    ErrorHandler.showError(error, title: title, stackTrace: stackTrace);
  }

  void handleSuccess(String message, {String? title}) {
    ErrorHandler.showSuccess(message, title: title);
  }

  void handleInfo(String message, {String? title}) {
    ErrorHandler.showInfo(message, title: title);
  }

  void handleWarning(String message, {String? title}) {
    ErrorHandler.showWarning(message, title: title);
  }
}

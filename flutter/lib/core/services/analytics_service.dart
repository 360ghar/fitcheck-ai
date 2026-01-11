import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../config/env_config.dart';

/// Lightweight analytics wrapper around PostHog with crash reporting.
class AnalyticsService {
  AnalyticsService._internal();

  static final AnalyticsService instance = AnalyticsService._internal();

  bool _enabled = false;

  Future<void> init() async {
    final apiKey = EnvConfig.posthogApiKey;
    final host = EnvConfig.posthogHost.isNotEmpty
        ? EnvConfig.posthogHost
        : 'https://app.posthog.com';

    if (apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('PostHog disabled: POSTHOG_API_KEY not set.');
      }
      return;
    }

    final config = PostHogConfig(apiKey)
      ..host = host
      ..debug = kDebugMode;
    await Posthog().setup(config);
    _enabled = true;

    // Set up Flutter error handling
    _setupErrorHandling();
  }

  /// Set up global error handling for crash reporting
  void _setupErrorHandling() {
    // Capture Flutter framework errors
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      recordError(
        details.exception,
        details.stack,
        reason: details.context?.toString(),
        fatal: false,
      );
      // Call original handler
      originalOnError?.call(details);
    };
  }

  /// Record an error for crash reporting
  ///
  /// [error] - The error or exception object
  /// [stackTrace] - Optional stack trace
  /// [reason] - Additional context about when/where the error occurred
  /// [fatal] - Whether this error caused the app to crash
  void recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    if (!_enabled) {
      if (kDebugMode) {
        debugPrint('Error (not reported): $error');
        if (stackTrace != null) {
          debugPrint('Stack trace: $stackTrace');
        }
      }
      return;
    }

    // Build error properties
    final properties = <String, Object>{
      'error_type': error.runtimeType.toString(),
      'error_message': error.toString(),
      'fatal': fatal,
    };

    if (reason != null) {
      properties['reason'] = reason;
    }

    if (stackTrace != null) {
      // Limit stack trace length to avoid payload issues
      final stackString = stackTrace.toString();
      properties['stack_trace'] = stackString.length > 4000
          ? stackString.substring(0, 4000)
          : stackString;
    }

    // Capture as error event
    Posthog().capture(
      eventName: fatal ? 'app_crash' : 'app_error',
      properties: properties,
    );

    if (kDebugMode) {
      debugPrint('Error recorded: $error');
    }
  }

  /// Record a non-fatal error with context
  void recordNonFatalError(
    String message, {
    Map<String, dynamic>? context,
  }) {
    if (!_enabled) return;

    final properties = <String, Object>{
      'error_message': message,
      'fatal': false,
      ...?_sanitize(context),
    };

    Posthog().capture(
      eventName: 'app_error',
      properties: properties,
    );
  }

  void screen(String name, {Map<String, dynamic>? properties}) {
    if (!_enabled) return;
    Posthog().capture(
      eventName: 'screen_view',
      properties: {
        'screen': name,
        ...?_sanitize(properties),
      },
    );
  }

  void track(String event, {Map<String, dynamic>? properties}) {
    if (!_enabled) return;
    Posthog().capture(eventName: event, properties: _sanitize(properties));
  }

  void identify(String userId, {Map<String, dynamic>? traits}) {
    if (!_enabled) return;
    Posthog().identify(
      userId: userId,
      userProperties: _sanitize(traits),
    );
  }

  void reset() {
    if (!_enabled) return;
    Posthog().reset();
  }

  Map<String, Object>? _sanitize(Map<String, dynamic>? input) {
    if (input == null) return null;
    final sanitized = <String, Object>{};
    input.forEach((key, value) {
      if (value != null) {
        sanitized[key] = value;
      }
    });
    return sanitized.isEmpty ? null : sanitized;
  }
}

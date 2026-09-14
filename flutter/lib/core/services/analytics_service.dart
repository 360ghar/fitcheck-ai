import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../config/env_config.dart';

/// Lightweight analytics wrapper around PostHog with crash reporting.
class AnalyticsService {
  AnalyticsService({Posthog? posthog}) : _posthog = posthog ?? Posthog();

  static final AnalyticsService instance = AnalyticsService();
  final Posthog _posthog;

  bool _enabled = false;

  /// A reset requested while the SDK was still coming up. Identity must not
  /// survive a sign-out that lands in that window (e.g. a launch-time session
  /// restore whose refresh token is rejected): replaying it keeps the next
  /// user's events from being attributed to the previous PostHog person.
  bool _resetPending = false;

  Future<void> init({
    String? apiKey,
    Duration setupTimeout = const Duration(seconds: 5),
  }) async {
    if (_enabled) return;
    final resolvedKey = apiKey ?? EnvConfig.posthogApiKey;
    final host = EnvConfig.posthogHost.isNotEmpty
        ? EnvConfig.posthogHost
        : 'https://app.posthog.com';

    if (resolvedKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('PostHog disabled: POSTHOG_API_KEY not set.');
      }
      return;
    }

    final config = PostHogConfig(resolvedKey)
      ..host = host
      ..debug = kDebugMode
      // Session replay: also requires "Record user sessions" in PostHog project settings.
      ..sessionReplay = true;
    // Mask all text and images in replays so screen recordings never capture
    // wardrobe/try-on photos or user-typed text: the App Privacy manifest
    // declares only product interaction/crash data, so unmasked replays would
    // be undeclared collection (nutrition-label mismatch).
    config.sessionReplayConfig.maskAllTexts = true;
    config.sessionReplayConfig.maskAllImages = true;
    final setup = _posthog.setup(config);
    // Enable on the setup future itself, not on the timeout race below: if
    // setup outlives the launch timeout, init() returns while the SDK still
    // comes up later, and this session should start reporting once it does.
    unawaited(
      setup
          .then((_) {
            _enabled = true;
            if (_resetPending) {
              _resetPending = false;
              _send(_posthog.reset);
            }
          })
          .catchError((Object e) {
            // Analytics is optional. Do not report its own failure through the
            // application error handler: that would call analytics recursively.
            if (kDebugMode) debugPrint('PostHog disabled: $e');
          }),
    );
    try {
      await setup.timeout(setupTimeout);
    } catch (e) {
      if (kDebugMode) debugPrint('PostHog disabled: $e');
    }
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
    _send(
      () => _posthog.capture(
        eventName: fatal ? 'app_crash' : 'app_error',
        properties: properties,
      ),
    );

    if (kDebugMode) {
      debugPrint('Error recorded: $error');
    }
  }

  /// Record a non-fatal error with context
  void recordNonFatalError(String message, {Map<String, dynamic>? context}) {
    if (!_enabled) return;

    final properties = <String, Object>{
      'error_message': message,
      'fatal': false,
      ...?_sanitize(context),
    };

    _send(
      () => _posthog.capture(eventName: 'app_error', properties: properties),
    );
  }

  void screen(String name, {Map<String, dynamic>? properties}) {
    if (!_enabled) return;
    _send(
      () => _posthog.capture(
        eventName: 'screen_view',
        properties: {'screen': name, ...?_sanitize(properties)},
      ),
    );
  }

  void track(String event, {Map<String, dynamic>? properties}) {
    if (!_enabled) return;
    _send(
      () =>
          _posthog.capture(eventName: event, properties: _sanitize(properties)),
    );
  }

  void identify(String userId, {Map<String, dynamic>? traits}) {
    if (!_enabled) return;
    _send(
      () =>
          _posthog.identify(userId: userId, userProperties: _sanitize(traits)),
    );
  }

  void reset() {
    if (!_enabled) {
      // The SDK is still setting up; a dropped reset here would leak the
      // previous user's identity into the next session's events.
      _resetPending = true;
      return;
    }
    _send(_posthog.reset);
  }

  void _send(Future<void> Function() action) {
    unawaited(
      Future<void>.sync(action).catchError((Object error) {
        if (kDebugMode) debugPrint('PostHog event skipped: $error');
      }),
    );
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

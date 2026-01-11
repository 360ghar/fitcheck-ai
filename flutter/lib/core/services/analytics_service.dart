import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../config/env_config.dart';

/// Lightweight analytics wrapper around PostHog.
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

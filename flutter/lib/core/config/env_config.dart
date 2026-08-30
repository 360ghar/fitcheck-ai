import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Loads environment values from an asset `.env` file with
/// compile-time overrides via --dart-define.
class EnvConfig {
  EnvConfig._();

  static const String _apiBaseUrlEnv = String.fromEnvironment('API_BASE_URL');
  static const String _frontendUrlEnv = String.fromEnvironment('FRONTEND_URL');
  static const String _supabaseUrlEnv = String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKeyEnv = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const String _supabasePublishableKeyEnv = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const String _posthogApiKeyEnv = String.fromEnvironment(
    'POSTHOG_API_KEY',
  );
  static const String _posthogHostEnv = String.fromEnvironment('POSTHOG_HOST');
  static const String _paywallEnabledEnv = String.fromEnvironment(
    'PAYWALL_ENABLED',
  );
  static const String _sentryDsnEnv = String.fromEnvironment('SENTRY_DSN');

  static final Map<String, String> _fileValues = {};
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    await _loadAsset('.env');
    if (_fileValues.isEmpty) {
      await _loadAsset('assets/.env');
    }
    _loaded = true;
  }

  static String get apiBaseUrl {
    return _apiBaseUrlEnv.isNotEmpty
        ? _apiBaseUrlEnv
        : (_fileValues['API_BASE_URL'] ?? '');
  }

  static String get frontendUrl {
    return _frontendUrlEnv.isNotEmpty
        ? _frontendUrlEnv
        : (_fileValues['FRONTEND_URL'] ?? '');
  }

  static String get supabaseUrl {
    return _supabaseUrlEnv.isNotEmpty
        ? _supabaseUrlEnv
        : (_fileValues['SUPABASE_URL'] ?? '');
  }

  static String get supabaseAnonKey {
    return _supabaseAnonKeyEnv.isNotEmpty
        ? _supabaseAnonKeyEnv
        : (_fileValues['SUPABASE_ANON_KEY'] ?? '');
  }

  static String get supabasePublishableKey {
    return _supabasePublishableKeyEnv.isNotEmpty
        ? _supabasePublishableKeyEnv
        : (_fileValues['SUPABASE_PUBLISHABLE_KEY'] ?? '');
  }

  static String get posthogApiKey {
    return _posthogApiKeyEnv.isNotEmpty
        ? _posthogApiKeyEnv
        : (_fileValues['POSTHOG_API_KEY'] ?? '');
  }

  static String get posthogHost {
    return _posthogHostEnv.isNotEmpty
        ? _posthogHostEnv
        : (_fileValues['POSTHOG_HOST'] ?? '');
  }

  /// Monetization CTAs (paywall, purchase flow). ON everywhere by default:
  /// iOS/Android purchase through the stores via in-app billing, web through
  /// Stripe checkout. Override: --dart-define=PAYWALL_ENABLED=false (used for
  /// App Review builds that must not surface monetization).
  static bool get paywallEnabled {
    if (_paywallEnabledEnv.isNotEmpty) {
      return _paywallEnabledEnv.toLowerCase() == 'true';
    }
    // Fall back to the .env file value (same parsing as dart-define), so
    // PAYWALL_ENABLED=false in a bundled .env is honored too.
    final fileValue = _fileValues['PAYWALL_ENABLED'];
    if (fileValue != null && fileValue.isNotEmpty) {
      return fileValue.toLowerCase() == 'true';
    }
    return true;
  }

  static String get sentryDsn {
    return _sentryDsnEnv.isNotEmpty
        ? _sentryDsnEnv
        : (_fileValues['SENTRY_DSN'] ?? '');
  }

  static Future<void> _loadAsset(String path) async {
    try {
      final content = await rootBundle.loadString(path);
      _parseEnv(content);
    } catch (e) {
      // Missing or unreadable .env assets are an expected fallback path
      // (dart-defines carry all real values in CI/release builds), so keep the
      // silent-fallback behavior but leave a debug breadcrumb.
      if (kDebugMode) {
        debugPrint('EnvConfig: failed to load .env asset "$path": $e');
      }
    }
  }

  static void _parseEnv(String content) {
    final lines = content.split('\n');
    for (final raw in lines) {
      var line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      if (line.startsWith('export ')) {
        line = line.substring(7).trim();
      }
      final idx = line.indexOf('=');
      if (idx <= 0) continue;
      final key = line.substring(0, idx).trim();
      var value = line.substring(idx + 1).trim();

      value = _stripInlineComment(value);
      final fullyQuoted =
          value.length >= 2 &&
          ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith('\'') && value.endsWith('\'')));

      if (fullyQuoted) {
        value = value.substring(1, value.length - 1);
      }
      _fileValues[key] = value;
    }
  }

  static String _stripInlineComment(String value) {
    // Quotes only change comment parsing when they open the entire value.
    // An unquoted apostrophe in `it's` must not hide a later ` # comment`.
    final openingQuote = value.isEmpty ? '' : value[0];
    if (openingQuote == '"' || openingQuote == '\'') {
      final closingQuote = _closingQuoteIndex(value, openingQuote);
      if (closingQuote != null) {
        return value.substring(0, closingQuote + 1) +
            _stripUnquotedInlineComment(value.substring(closingQuote + 1));
      }
    }
    return _stripUnquotedInlineComment(value);
  }

  static int? _closingQuoteIndex(String value, String quote) {
    var escaped = false;
    for (var index = 1; index < value.length; index++) {
      final character = value[index];
      if (escaped) {
        escaped = false;
        continue;
      }
      if (character == '\\' && quote == '"') {
        escaped = true;
      } else if (character == quote) {
        return index;
      }
    }
    return null;
  }

  static String _stripUnquotedInlineComment(String value) {
    for (var index = 1; index < value.length; index++) {
      if (value[index] == '#' && value[index - 1].trim().isEmpty) {
        return value.substring(0, index).trimRight();
      }
    }
    return value.trimRight();
  }

  @visibleForTesting
  static String stripInlineCommentForTesting(String value) =>
      _stripInlineComment(value);
}

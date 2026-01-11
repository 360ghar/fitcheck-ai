import 'package:flutter/services.dart';

/// Loads environment values from an asset `.env` file with
/// compile-time overrides via --dart-define.
class EnvConfig {
  EnvConfig._();

  static const String _apiBaseUrlEnv = String.fromEnvironment('API_BASE_URL');
  static const String _supabaseUrlEnv = String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKeyEnv =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _supabasePublishableKeyEnv =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const String _posthogApiKeyEnv = String.fromEnvironment('POSTHOG_API_KEY');
  static const String _posthogHostEnv = String.fromEnvironment('POSTHOG_HOST');

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

  static Future<void> _loadAsset(String path) async {
    try {
      final content = await rootBundle.loadString(path);
      _parseEnv(content);
    } catch (_) {}
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
      if (value.length >= 2) {
        final first = value[0];
        final last = value[value.length - 1];
        if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
          value = value.substring(1, value.length - 1);
        }
      }
      _fileValues[key] = value;
    }
  }
}

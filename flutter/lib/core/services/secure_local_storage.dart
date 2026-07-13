import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Persists the Supabase session (access + refresh token) in the platform
/// keychain/keystore instead of the package default (plaintext
/// SharedPreferences / NSUserDefaults), so a device backup or filesystem
/// access on a rooted/jailbroken device doesn't expose a long-lived refresh
/// token in cleartext.
///
/// [legacySharedPreferencesKey] is the key supabase_flutter's default
/// SharedPreferencesLocalStorage would have used
/// (`"sb-${host}-auth-token"` - see supabase_flutter's own Supabase.initialize
/// source). On first run after this storage backend changes, an
/// already-signed-in user's session lives under that key in plain
/// SharedPreferences, not in this new secure store - without migrating it,
/// every existing installed user would be silently signed out on update.
/// initialize() migrates it once, then removes the legacy copy.
class SecureLocalStorage extends LocalStorage {
  const SecureLocalStorage({
    required this.persistSessionKey,
    required this.legacySharedPreferencesKey,
  });

  final String persistSessionKey;
  final String legacySharedPreferencesKey;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<void> initialize() async {
    final alreadyMigrated = await _storage.containsKey(key: persistSessionKey);
    if (alreadyMigrated) return;

    final prefs = await SharedPreferences.getInstance();
    final legacySession = prefs.getString(legacySharedPreferencesKey);
    if (legacySession != null && legacySession.isNotEmpty) {
      await _storage.write(key: persistSessionKey, value: legacySession);
      await prefs.remove(legacySharedPreferencesKey);
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    return _storage.containsKey(key: persistSessionKey);
  }

  @override
  Future<String?> accessToken() {
    return _storage.read(key: persistSessionKey);
  }

  @override
  Future<void> removePersistedSession() {
    return _storage.delete(key: persistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) {
    return _storage.write(key: persistSessionKey, value: persistSessionString);
  }
}

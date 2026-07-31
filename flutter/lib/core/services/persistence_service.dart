import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction over [SharedPreferences] that provides a consistent API for
/// persisting key-value data. All app code should inject this service instead
/// of calling [SharedPreferences.getInstance] directly (see FL2).
class PersistenceService extends GetxService {
  SharedPreferences? _prefs;

  /// Whether the backing [SharedPreferences] instance is ready.
  bool get isReady => _prefs != null;

  /// Ensure the backing store is initialised.
  Future<void> ensureReady() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ------------------------------------------------------------------
  // String
  // ------------------------------------------------------------------

  Future<String?> getString(String key) async {
    await ensureReady();
    return _prefs!.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    await ensureReady();
    return _prefs!.setString(key, value);
  }

  // ------------------------------------------------------------------
  // bool
  // ------------------------------------------------------------------

  Future<bool?> getBool(String key) async {
    await ensureReady();
    return _prefs!.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    await ensureReady();
    return _prefs!.setBool(key, value);
  }

  // ------------------------------------------------------------------
  // int
  // ------------------------------------------------------------------

  Future<int?> getInt(String key) async {
    await ensureReady();
    return _prefs!.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    await ensureReady();
    return _prefs!.setInt(key, value);
  }

  // ------------------------------------------------------------------
  // double
  // ------------------------------------------------------------------

  Future<double?> getDouble(String key) async {
    await ensureReady();
    return _prefs!.getDouble(key);
  }

  Future<bool> setDouble(String key, double value) async {
    await ensureReady();
    return _prefs!.setDouble(key, value);
  }

  // ------------------------------------------------------------------
  // String list
  // ------------------------------------------------------------------

  Future<List<String>?> getStringList(String key) async {
    await ensureReady();
    return _prefs!.getStringList(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    await ensureReady();
    return _prefs!.setStringList(key, value);
  }

  // ------------------------------------------------------------------
  // Generic contains / remove
  // ------------------------------------------------------------------

  Future<bool> containsKey(String key) async {
    await ensureReady();
    return _prefs!.containsKey(key);
  }

  Future<bool> remove(String key) async {
    await ensureReady();
    return _prefs!.remove(key);
  }

  /// Read a value, decode it as the given type, and return null on mismatch
  /// or absence. Convenience for optional scalar reads.
  Future<T?> getValue<T>(String key) async {
    await ensureReady();
    final raw = _prefs!.get(key);
    if (raw is T) return raw;
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/models/user_preferences_model.dart';

/// Theme service - handles theme persistence with local storage
/// Loads immediately on app start, syncs with backend when online
class ThemeService extends GetxController {
  static const String _themeStorageKey = 'fitcheck_theme_mode';
  static const AppThemeMode _defaultTheme = AppThemeMode.light;

  final Rx<AppThemeMode> _themeMode = _defaultTheme.obs;

  AppThemeMode get appThemeMode => _themeMode.value;

  ThemeMode get currentThemeMode {
    switch (_themeMode.value) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadCachedTheme();
  }

  /// Load theme from local storage immediately on app start
  Future<void> _loadCachedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedValue = prefs.getString(_themeStorageKey);

      if (storedValue != null) {
        final mode = AppThemeMode.values.firstWhere(
          (e) => e.name == storedValue,
          orElse: () => _defaultTheme,
        );
        _themeMode.value = mode;
        Get.changeThemeMode(currentThemeMode);
      }
      // If no stored value, keep the default (light)
    } catch (e) {
      // Silently fail, use default theme
      debugPrint('Failed to load cached theme: $e');
    }
  }

  /// Update theme mode - saves to local storage and applies theme
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(currentThemeMode);
    await _saveToLocalStorage(mode);
  }

  /// Save theme to local storage
  Future<void> _saveToLocalStorage(AppThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeStorageKey, mode.name);
    } catch (e) {
      debugPrint('Failed to save theme to local storage: $e');
    }
  }

  /// Sync theme from backend (called after API response)
  /// Backend is source of truth when online
  void syncFromBackend(AppThemeMode? backendMode) {
    if (backendMode != null && backendMode != _themeMode.value) {
      _themeMode.value = backendMode;
      Get.changeThemeMode(currentThemeMode);
      _saveToLocalStorage(backendMode);
    }
  }
}

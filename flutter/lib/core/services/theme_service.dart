import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/settings/models/user_preferences_model.dart';
import 'persistence_service.dart';

/// Theme service - handles theme persistence with local storage
/// Loads immediately on app start, syncs with backend when online
class ThemeService extends GetxController {
  static const String _themeStorageKey = 'fitcheck_theme_mode';
  static const AppThemeMode _defaultTheme = AppThemeMode.light;

  PersistenceService get _persistence => Get.find<PersistenceService>();

  final Rx<AppThemeMode> _themeMode = _defaultTheme.obs;

  final Completer<void> _ready = Completer<void>();

  /// Completes once the cached theme has been read from storage.
  ///
  /// `main()` awaits this before `runApp`, so the very first build already
  /// reflects the persisted theme. Without it, a dark-mode user sees a
  /// light splash/frame flash until the async SharedPreferences read lands
  /// (previously the load only won the race against `runApp` because of
  /// incidental `await`s in `main()`).
  Future<void> get ready => _ready.future;

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
      final storedValue = await _persistence.getString(_themeStorageKey);

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
    } finally {
      // Always resolve `ready` so `main()`'s await can never deadlock.
      if (!_ready.isCompleted) _ready.complete();
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
      await _persistence.setString(_themeStorageKey, mode.name);
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

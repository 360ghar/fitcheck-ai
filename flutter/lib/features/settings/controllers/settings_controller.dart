import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_preferences_model.dart';
import '../repositories/settings_repository.dart';
import '../../auth/controllers/auth_controller.dart';

/// Settings controller - manages settings and preferences state
class SettingsController extends GetxController {
  final SettingsRepository _repository = SettingsRepository();
  final AuthController _authController = Get.find<AuthController>();

  // State
  final Rx<UserPreferencesModel?> preferences = Rx<UserPreferencesModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString error = ''.obs;

  // Getters
  bool get hasError => error.value.isNotEmpty;
  bool get hasPreferences => preferences.value != null;

  @override
  void onInit() {
    super.onInit();
    fetchPreferences();
  }

  /// Fetch user preferences
  Future<void> fetchPreferences() async {
    try {
      isLoading.value = true;
      error.value = '';
      preferences.value = await _repository.getPreferences();
      _applyThemeMode(preferences.value?.themeMode);
    } catch (e) {
      error.value = e.toString();
      // If preferences don't exist yet, use defaults
      if (preferences.value == null) {
        preferences.value = UserPreferencesModel();
      }
      _applyThemeMode(preferences.value?.themeMode);
    } finally {
      isLoading.value = false;
    }
  }

  /// Update theme mode
  Future<void> updateThemeMode(AppThemeMode mode) async {
    final current = preferences.value ?? UserPreferencesModel();

    final updated = current.copyWith(themeMode: mode);
    preferences.value = updated;
    _applyThemeMode(mode);
    await savePreferences(updated);
  }

  /// Update temperature unit
  Future<void> updateTemperatureUnit(TemperatureUnit unit) async {
    final current = preferences.value;
    if (current == null) return;

    final updated = current.copyWith(temperatureUnit: unit);
    await savePreferences(updated);
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    final current = preferences.value;
    if (current == null) return;

    final updated = current.copyWith(notificationsEnabled: enabled);
    await savePreferences(updated);
  }

  /// Toggle email notifications
  Future<void> toggleEmailNotifications(bool enabled) async {
    final current = preferences.value;
    if (current == null) return;

    final updated = current.copyWith(emailNotificationsEnabled: enabled);
    await savePreferences(updated);
  }

  /// Toggle outfit reminders
  Future<void> toggleOutfitReminders(bool enabled) async {
    final current = preferences.value;
    if (current == null) return;

    final updated = current.copyWith(outfitRemindersEnabled: enabled);
    await savePreferences(updated);
  }

  /// Toggle weekly summary
  Future<void> toggleWeeklySummary(bool enabled) async {
    final current = preferences.value;
    if (current == null) return;

    final updated = current.copyWith(weeklySummaryEnabled: enabled);
    await savePreferences(updated);
  }

  /// Add preferred style
  Future<void> addPreferredStyle(String style) async {
    final current = preferences.value;
    if (current == null) return;

    final List<String> styles = [...current.preferredStyles ?? [], style];
    final updated = current.copyWith(preferredStyles: styles);
    await savePreferences(updated);
  }

  /// Remove preferred style
  Future<void> removePreferredStyle(String style) async {
    final current = preferences.value;
    if (current == null) return;

    final styles = current.preferredStyles?.where((s) => s != style).toList() ?? [];
    final updated = current.copyWith(preferredStyles: styles);
    await savePreferences(updated);
  }

  /// Add preferred color
  Future<void> addPreferredColor(String color) async {
    final current = preferences.value;
    if (current == null) return;

    final List<String> colors = [...current.preferredColors ?? [], color];
    final updated = current.copyWith(preferredColors: colors);
    await savePreferences(updated);
  }

  /// Remove preferred color
  Future<void> removePreferredColor(String color) async {
    final current = preferences.value;
    if (current == null) return;

    final colors = current.preferredColors?.where((c) => c != color).toList() ?? [];
    final updated = current.copyWith(preferredColors: colors);
    await savePreferences(updated);
  }

  /// Save preferences
  Future<void> savePreferences(UserPreferencesModel newPreferences) async {
    try {
      isSaving.value = true;
      error.value = '';

      final saved = await _repository.updatePreferences(newPreferences);
      preferences.value = saved;

      Get.snackbar(
        'Saved',
        'Your preferences have been updated',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _repository.updatePassword(currentPassword, newPassword);
      Get.back();
      Get.snackbar(
        'Success',
        'Password updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Request data export
  Future<void> exportData() async {
    try {
      final exportUrl = await _repository.requestDataExport();
      Get.snackbar(
        'Export Started',
        'Your data export is being prepared. You will receive an email when it\'s ready.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      await _repository.deleteAccount();
      await _authController.logout();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void clearError() {
    error.value = '';
  }

  void _applyThemeMode(AppThemeMode? mode) {
    final ThemeMode targetMode;
    switch (mode) {
      case AppThemeMode.light:
        targetMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        targetMode = ThemeMode.dark;
        break;
      case AppThemeMode.system:
      default:
        targetMode = ThemeMode.system;
        break;
    }

    Get.changeThemeMode(targetMode);
  }

}

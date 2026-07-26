import 'package:get/get.dart';
import '../models/user_preferences_model.dart';
import '../repositories/settings_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

/// Settings controller - manages settings and preferences state
class SettingsController extends GetxController {
  final SettingsRepository _repository = SettingsRepository();
  final AuthController _authController = Get.find<AuthController>();

  // State
  final Rx<UserPreferencesModel?> preferences = Rx<UserPreferencesModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString error = ''.obs;

  // Action-specific loading states
  final RxBool isChangingPassword = false.obs;
  final RxBool isExportingData = false.obs;
  final RxBool isDeletingAccount = false.obs;

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
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      isLoading.value = true;
      error.value = '';
      preferences.value = await _repository.getPreferences();

      // Sync theme from backend to ThemeService
      final themeService = Get.find<ThemeService>();
      themeService.syncFromBackend(preferences.value?.themeMode);
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      // If preferences don't exist yet, use defaults
      if (preferences.value == null) {
        preferences.value = UserPreferencesModel();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Update theme mode
  Future<void> updateThemeMode(AppThemeMode mode) async {
    final current = preferences.value ?? UserPreferencesModel();

    final updated = current.copyWith(themeMode: mode);
    preferences.value = updated;

    // Update ThemeService (handles local storage and applies theme)
    final themeService = Get.find<ThemeService>();
    await themeService.setThemeMode(mode);

    // Save to backend
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

      ErrorHandler.showSuccess('Your preferences have been updated', title: 'Saved');
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
    } finally {
      isSaving.value = false;
    }
  }

  /// Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    isChangingPassword.value = true;
    try {
      await _repository.updatePassword(currentPassword, newPassword);
      Get.back();
      ErrorHandler.showSuccess('Password updated successfully', title: 'Success');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
      rethrow;
    } finally {
      isChangingPassword.value = false;
    }
  }

  /// Request data export
  Future<void> exportData() async {
    isExportingData.value = true;
    try {
      await _repository.requestDataExport();
      ErrorHandler.showInfo('Your data export is being prepared. You will receive an email when it\'s ready.', title: 'Export Started');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
    } finally {
      isExportingData.value = false;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    isDeletingAccount.value = true;
    try {
      await _repository.deleteAccount();
      await _authController.logout();
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
      rethrow;
    } finally {
      isDeletingAccount.value = false;
    }
  }

  void clearError() {
    error.value = '';
  }
}

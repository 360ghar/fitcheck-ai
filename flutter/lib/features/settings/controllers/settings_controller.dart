import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import 'package:url_launcher/url_launcher.dart';
import '../models/user_preferences_model.dart';
import '../repositories/settings_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

/// Settings controller - manages settings and preferences state
class SettingsController extends GetxController {
  final SettingsRepository _repository;
  final AuthController _authController;
  final ThemeService _themeService;

  /// [repository], [authController] and [themeService] are injectable for unit tests.
  SettingsController({
    SettingsRepository? repository,
    AuthController? authController,
    ThemeService? themeService,
  }) : _repository = repository ?? SettingsRepository(),
       _authController = authController ?? Get.find<AuthController>(),
       _themeService = themeService ?? Get.find<ThemeService>();

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
      _themeService.syncFromBackend(preferences.value?.themeMode);
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
    await _themeService.setThemeMode(mode);

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

  /// Change password via Supabase, RE-AUTHENTICATING with the current one first.
  ///
  /// There is no backend change-password endpoint any more (the repository method
  /// that POSTed `/users/change-password` was removed), and Supabase's
  /// `updateUser` only requires a valid session — so simply calling it ignored
  /// the "current password" the dialog collects and requires. A wrong current
  /// password succeeded, which means anyone holding an unlocked device or a
  /// stolen session could take the account over without knowing the old
  /// password. The endpoint used to prevent exactly that.
  ///
  /// Signing in with the supplied current password is the re-auth Supabase gives
  /// us: it fails for a wrong password and leaves the session untouched.
  Future<void> changePassword(String currentPassword, String newPassword) async {
    isChangingPassword.value = true;
    try {
      final email = _authController.currentUserEmail;
      // Key the OAuth guard on the auth provider, not the email: Google/Apple
      // sessions DO carry an email, so an email-based check was unreachable
      // and OAuth-only users fell through to reauthenticate(), where
      // signInWithPassword fails with a misleading "Current password is
      // incorrect". When the session's provider is not 'email', the account
      // has no password to verify - send them through the reset flow instead
      // of silently accepting an unverified change. The email check stays as a
      // defensive fallback for a session with no email at all.
      final provider = _authController.currentUser?.appMetadata['provider'];
      if ((provider != null && provider != 'email') ||
          email == null ||
          email.isEmpty) {
        ErrorHandler.showError(
          'This account signs in with Google or Apple. Use "Forgot password" to '
          'set a password first.',
          title: 'Cannot Change Password',
        );
        return;
      }

      try {
        await _authController.reauthenticate(
          email: email,
          password: currentPassword,
        );
      } on AuthException {
        ErrorHandler.showError(
          'Current password is incorrect.',
          title: 'Cannot Change Password',
        );
        return;
      }

      await _authController.updatePassword(newPassword);
      Get.back();
      // The dialog just closed silently; confirm the change happened (the
      // reworked flow was closing with no feedback at all).
      ErrorHandler.showSuccess('Password updated successfully', title: 'Success');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
      rethrow;
    } finally {
      isChangingPassword.value = false;
    }
  }

  /// Request data export and open the download link in the browser.
  ///
  /// The success message is INSIDE the launch branch. Announcing it
  /// unconditionally made a failed launch indistinguishable from success: on a
  /// device where `canLaunchUrl` returns false (no default browser handler on
  /// Android, or iOS declining an unqueryable scheme) nothing opened, the
  /// short-lived presigned URL was thrown away, and the user was told their GDPR
  /// export was "ready to download" with no way left to retrieve it. The URL is
  /// surfaced through the clipboard instead so it is never simply lost.
  Future<void> exportData() async {
    isExportingData.value = true;
    try {
      final exportUrl = await _repository.requestDataExport();
      final uri = Uri.parse(exportUrl);

      var opened = false;
      if (await canLaunchUrl(uri)) {
        try {
          opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          // A throw here means the same thing as `false`: nothing opened.
          opened = false;
        }
      }

      if (opened) {
        ErrorHandler.showInfo(
          'Your data export is ready to download.',
          title: 'Export Ready',
        );
        return;
      }

      await Clipboard.setData(ClipboardData(text: exportUrl));
      ErrorHandler.showError(
        'Could not open your browser. The download link has been copied to your '
        'clipboard — paste it into a browser soon, it expires shortly.',
        title: 'Export Ready, Link Copied',
      );
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

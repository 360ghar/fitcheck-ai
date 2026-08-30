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

class _PreferenceSaveOutcome {
  const _PreferenceSaveOutcome({
    required this.revision,
    required this.succeeded,
  });

  final int revision;
  final bool succeeded;
}

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
  Future<void> _preferenceWriteQueue = Future<void>.value();
  int _preferenceRevision = 0;
  UserPreferencesModel? _lastConfirmedPreferences;

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
    final fetchRevision = _preferenceRevision;
    try {
      isLoading.value = true;
      error.value = '';
      final fetched = await _repository.getPreferences();
      // Do not overwrite a preference change that started while this initial
      // fetch was in flight. The queued write owns the newer local state.
      if (isClosed || fetchRevision != _preferenceRevision) return;
      _lastConfirmedPreferences = fetched;
      preferences.value = fetched;

      // Sync theme from backend to ThemeService
      _themeService.syncFromBackend(fetched.themeMode);
    } catch (e) {
      if (isClosed || fetchRevision != _preferenceRevision) return;
      error.value = ErrorHandler.extractMessage(e);
      // If preferences don't exist yet, use defaults
      if (preferences.value == null) {
        final defaults = UserPreferencesModel();
        preferences.value = defaults;
        _lastConfirmedPreferences ??= defaults;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Update theme mode
  ///
  /// Applies optimistically (snappy UI), then persists. If the backend save
  /// fails, both the controller state AND the ThemeService persistence are
  /// restored from the latest confirmed preference — otherwise rapid changes
  /// can restore an older, already superseded mode.
  Future<void> updateThemeMode(AppThemeMode mode) async {
    final current = preferences.value ?? UserPreferencesModel();
    final updated = current.copyWith(themeMode: mode);
    // Queue the backend write synchronously so a following preference change
    // builds on this optimistic mode rather than the pre-change model.
    final outcomeFuture = _queuePreferences(
      updated,
      fallbackPreferences: current,
    );
    // Update ThemeService (handles local storage and applies theme).
    await _themeService.setThemeMode(mode);

    // A latest failure rolls back to the most recent successful queued write,
    // not to the mode captured before an overlapping user choice.
    final outcome = await outcomeFuture;
    if (!outcome.succeeded &&
        outcome.revision == _preferenceRevision &&
        !isClosed) {
      final confirmed = _lastConfirmedPreferences ?? current;
      await _themeService.setThemeMode(
        confirmed.themeMode ?? AppThemeMode.system,
      );
    }
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

    final styles =
        current.preferredStyles?.where((s) => s != style).toList() ?? [];
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

    final colors =
        current.preferredColors?.where((c) => c != color).toList() ?? [];
    final updated = current.copyWith(preferredColors: colors);
    await savePreferences(updated);
  }

  /// Save preferences
  ///
  /// Returns whether the save succeeded so callers that optimistically applied
  /// state can observe the result. Every latest failure also restores the
  /// confirmed model, so fire-and-forget callers cannot leave a rejected value
  /// on screen.
  Future<bool> savePreferences(UserPreferencesModel newPreferences) async {
    final current = preferences.value ?? UserPreferencesModel();
    return (await _queuePreferences(
      newPreferences,
      fallbackPreferences: current,
    )).succeeded;
  }

  Future<_PreferenceSaveOutcome> _queuePreferences(
    UserPreferencesModel newPreferences, {
    required UserPreferencesModel fallbackPreferences,
  }) {
    final revision = ++_preferenceRevision;
    _lastConfirmedPreferences ??= fallbackPreferences;
    preferences.value = newPreferences;
    isSaving.value = true;
    error.value = '';

    final operation = _preferenceWriteQueue.then((_) async {
      try {
        final saved = await _repository.updatePreferences(newPreferences);
        _lastConfirmedPreferences = saved;
        if (!isClosed && revision == _preferenceRevision) {
          preferences.value = saved;
          ErrorHandler.showSuccess(
            'Your preferences have been updated',
            title: 'Saved',
          );
        }
        return _PreferenceSaveOutcome(revision: revision, succeeded: true);
      } catch (e) {
        if (!isClosed && revision == _preferenceRevision) {
          preferences.value = _lastConfirmedPreferences ?? fallbackPreferences;
          error.value = ErrorHandler.extractMessage(e);
          ErrorHandler.showError(error.value, title: 'Error');
        }
        return _PreferenceSaveOutcome(revision: revision, succeeded: false);
      } finally {
        if (!isClosed && revision == _preferenceRevision) {
          isSaving.value = false;
        }
      }
    });
    _preferenceWriteQueue = operation.then<void>((_) {});
    return operation;
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
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
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
      ErrorHandler.showSuccess(
        'Password updated successfully',
        title: 'Success',
      );
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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/exceptions/app_exceptions.dart' show NotFoundException;
import '../../../core/services/theme_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/user_preferences_model.dart';
import '../repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(),
);

final themeServiceProvider = Provider<ThemeService>(
  (ref) => ThemeService.instance,
);

/// Saved preferences and the state of their load.
@immutable
class SettingsState {
  const SettingsState({
    this.preferences,
    this.isLoading = false,
    this.loadError,
    this.isSaving = false,
  });

  /// Null until a load succeeds. Never replaced by defaults after a failed
  /// load, so a later save cannot overwrite what the server has.
  final UserPreferencesModel? preferences;
  final bool isLoading;

  /// The last load failure. Shown as a full error state when there are no
  /// preferences, or as a banner over them.
  final Object? loadError;
  final bool isSaving;

  SettingsState copyWith({
    UserPreferencesModel? preferences,
    bool? isLoading,
    Object? Function()? loadError,
    bool? isSaving,
  }) => SettingsState(
    preferences: preferences ?? this.preferences,
    isLoading: isLoading ?? this.isLoading,
    loadError: loadError == null ? this.loadError : loadError(),
    isSaving: isSaving ?? this.isSaving,
  );
}

class _SaveOutcome {
  const _SaveOutcome(this.revision, this.succeeded);

  final int revision;
  final bool succeeded;
}

final settingsProvider =
    NotifierProvider.autoDispose<SettingsNotifier, SettingsState>(
      SettingsNotifier.new,
    );

/// Preferences with optimistic, serialized writes, plus account actions.
///
/// A plain [Notifier] (not an AsyncNotifier) because optimistic writes must
/// win over a fetch that is still in flight, and an AsyncNotifier's build
/// result always lands.
class SettingsNotifier extends Notifier<SettingsState> {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);
  ThemeService get _theme => ref.read(themeServiceProvider);
  AuthNotifier get _auth => ref.read(authProvider.notifier);

  Future<void> _writeQueue = Future<void>.value();
  int _revision = 0;
  int _fetchGeneration = 0;
  UserPreferencesModel? _lastConfirmed;

  @override
  SettingsState build() {
    // State cannot change during build; start the load right after it.
    Future.microtask(fetchPreferences);
    return const SettingsState(isLoading: true);
  }

  bool _isCurrent(int generation, int revision) =>
      ref.mounted && generation == _fetchGeneration && revision == _revision;

  Future<void> fetchPreferences() async {
    if (!ref.mounted) return;
    final generation = ++_fetchGeneration;
    // A write that starts during this fetch owns the newer local value; the
    // fetch result must not replace it.
    final revision = _revision;
    state = state.copyWith(isLoading: true);
    try {
      final fetched = await _repository.getPreferences();
      if (!_isCurrent(generation, revision)) return;
      _lastConfirmed = fetched;
      state = state.copyWith(
        preferences: fetched,
        isLoading: false,
        loadError: () => null,
      );
      _theme.syncFromBackend(fetched.themeMode);
    } on NotFoundException {
      // No row yet: defaults are the truth, and the first save creates it.
      if (!_isCurrent(generation, revision)) return;
      final defaults = state.preferences ?? UserPreferencesModel();
      _lastConfirmed ??= defaults;
      state = state.copyWith(
        preferences: defaults,
        isLoading: false,
        loadError: () => null,
      );
    } catch (e, stack) {
      if (!_isCurrent(generation, revision)) return;
      ErrorHandler.reportError(e, 'Preferences load failed', stackTrace: stack);
      // Keep what is on screen (null when nothing loaded). Defaults here
      // would let the next toggle PUT them over every saved preference.
      state = state.copyWith(isLoading: false, loadError: () => e);
    }
  }

  /// Applies the theme at once, then saves it. A failed latest save puts
  /// back the last confirmed mode.
  Future<void> updateThemeMode(AppThemeMode mode) async {
    final current = state.preferences;
    if (current == null) {
      // Nothing loaded: apply on this device only, never PUT defaults.
      await _theme.setThemeMode(mode);
      return;
    }
    // Queue synchronously so a following change builds on this mode.
    final outcome = _queue(
      current.copyWith(themeMode: mode),
      fallback: current,
    );
    await _theme.setThemeMode(mode);
    final result = await outcome;
    if (!result.succeeded && result.revision == _revision && ref.mounted) {
      final confirmed = _lastConfirmed ?? current;
      await _theme.setThemeMode(confirmed.themeMode ?? AppThemeMode.system);
    }
  }

  Future<void> _update(
    UserPreferencesModel Function(UserPreferencesModel p) change,
  ) async {
    final current = state.preferences;
    if (current == null) return;
    await savePreferences(change(current));
  }

  Future<void> updateTemperatureUnit(TemperatureUnit unit) =>
      _update((p) => p.copyWith(temperatureUnit: unit));

  Future<void> toggleNotifications(bool enabled) =>
      _update((p) => p.copyWith(notificationsEnabled: enabled));

  Future<void> toggleEmailNotifications(bool enabled) =>
      _update((p) => p.copyWith(emailNotificationsEnabled: enabled));

  Future<void> toggleOutfitReminders(bool enabled) =>
      _update((p) => p.copyWith(outfitRemindersEnabled: enabled));

  Future<void> toggleWeeklySummary(bool enabled) =>
      _update((p) => p.copyWith(weeklySummaryEnabled: enabled));

  Future<void> addPreferredStyle(String style) => _update(
    (p) => p.copyWith(preferredStyles: [...?p.preferredStyles, style]),
  );

  Future<void> removePreferredStyle(String style) => _update(
    (p) => p.copyWith(preferredStyles: [...?p.preferredStyles]..remove(style)),
  );

  Future<void> addPreferredColor(String color) => _update(
    (p) => p.copyWith(preferredColors: [...?p.preferredColors, color]),
  );

  Future<void> removePreferredColor(String color) => _update(
    (p) => p.copyWith(preferredColors: [...?p.preferredColors]..remove(color)),
  );

  /// Returns whether the save succeeded. A failed latest save restores the
  /// confirmed model, so a rejected value never stays on screen.
  Future<bool> savePreferences(UserPreferencesModel next) async {
    final current = state.preferences ?? UserPreferencesModel();
    return (await _queue(next, fallback: current)).succeeded;
  }

  Future<_SaveOutcome> _queue(
    UserPreferencesModel next, {
    required UserPreferencesModel fallback,
  }) {
    final revision = ++_revision;
    // A fetch that began before this write must not apply a stale server
    // snapshot or keep its spinner.
    _fetchGeneration++;
    _lastConfirmed ??= fallback;
    state = state.copyWith(preferences: next, isLoading: false, isSaving: true);

    bool latest() => ref.mounted && revision == _revision;

    final operation = _writeQueue.then((_) async {
      try {
        final saved = await _repository.updatePreferences(next);
        // The backend persists only preferred_styles of this model and
        // echoes null for every other key. Take the server value only for
        // what it stores, and keep the client value for the rest; storing
        // the echo verbatim reverted each saved setting on the next trip.
        final confirmed = next.copyWith(preferredStyles: saved.preferredStyles);
        _lastConfirmed = confirmed;
        if (latest()) {
          state = state.copyWith(preferences: confirmed, isSaving: false);
          ErrorHandler.showSuccess(
            'Your preferences are saved.',
            title: 'Saved',
          );
        }
        return _SaveOutcome(revision, true);
      } catch (e, stack) {
        if (latest()) {
          state = state.copyWith(
            preferences: _lastConfirmed ?? fallback,
            isSaving: false,
          );
          ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
        }
        return _SaveOutcome(revision, false);
      }
    });
    _writeQueue = operation.then<void>((_) {});
    return operation;
  }

  /// Changes the password after re-authenticating with the current one.
  /// Returns true on success.
  ///
  /// Supabase's updateUser needs only a live session, so without the
  /// re-auth anyone holding an unlocked device could change the password.
  /// [AuthNotifier.updatePassword] shows its own success or error message;
  /// this method adds none for that step.
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final email = _auth.currentUserEmail;
    // Google and Apple sessions carry an email too, so the guard keys on
    // the auth provider. Such accounts have no password to verify.
    final provider = _auth.currentUser?.appMetadata['provider'];
    if ((provider != null && provider != 'email') ||
        email == null ||
        email.isEmpty) {
      ErrorHandler.showValidation(
        'This account signs in with Google or Apple. Use "Forgot password" '
        'to set a password first.',
        title: 'Password not changed',
      );
      return false;
    }
    try {
      await _auth.reauthenticate(email: email, password: currentPassword);
    } on AuthException {
      ErrorHandler.showValidation(
        'Current password is incorrect.',
        title: 'Password not changed',
      );
      return false;
    } catch (e, stack) {
      ErrorHandler.showError(
        e,
        title: 'Password not changed',
        stackTrace: stack,
      );
      return false;
    }
    try {
      await _auth.updatePassword(newPassword);
      return true;
    } catch (_) {
      return false; // Already shown by AuthNotifier.
    }
  }

  /// Requests an export and opens the link. When nothing opens, the
  /// short-lived link goes to the clipboard so it is not lost.
  Future<void> exportData() async {
    try {
      final exportUrl = await _repository.requestDataExport();
      final uri = Uri.parse(exportUrl);
      var opened = false;
      if (await canLaunchUrl(uri)) {
        try {
          opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          opened = false;
        }
      }
      if (opened) {
        ErrorHandler.showInfo(
          'Your data export is ready to download.',
          title: 'Export ready',
        );
        return;
      }
      await Clipboard.setData(ClipboardData(text: exportUrl));
      ErrorHandler.showWarning(
        'We could not open your browser, so we copied the download link. '
        'Paste it into a browser soon: it expires.',
        title: 'Link copied',
      );
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Export failed', stackTrace: stack);
    }
  }

  /// Deletes the account, then signs out. Returns false when the delete
  /// failed (the error is shown).
  Future<bool> deleteAccount() async {
    try {
      await _repository.deleteAccount();
    } catch (e, stack) {
      ErrorHandler.showError(
        e,
        title: 'Account not deleted',
        stackTrace: stack,
      );
      return false;
    }
    await _auth.logout();
    return true;
  }
}

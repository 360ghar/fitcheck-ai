import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/providers/settings_provider.dart';
import '../services/persistence_service.dart';
import 'locale_registry.dart';

/// The settings repository, read directly rather than through the settings
/// notifier: that notifier is auto-disposed and touching it here would start a
/// full preferences fetch just to write one field.
final _settingsRepositoryProvider = settingsRepositoryProvider;

/// The user's explicit language choice, or null for "follow the device".
@immutable
class LocaleSelection {
  const LocaleSelection({this.asc, this.loaded = false});

  /// An App Store Connect locale code, e.g. `hi` or `pt-BR`.
  final String? asc;

  /// False until the stored choice has been read, so the first frame does not
  /// flash English before a Hindi user's preference loads.
  final bool loaded;

  bool get followsDevice => asc == null;

  Locale resolve(List<Locale> deviceLocales) =>
      LocaleRegistry.resolve(preferredAsc: asc, deviceLocales: deviceLocales);

  LocaleSelection copyWith({String? asc, bool clearAsc = false, bool? loaded}) =>
      LocaleSelection(
        asc: clearAsc ? null : (asc ?? this.asc),
        loaded: loaded ?? this.loaded,
      );
}

/// Reads, applies and persists the app language.
///
/// Precedence is explicit choice, then the device's preferred languages, then
/// English. A choice is written to disk *and* to the user's backend settings,
/// because the backend uses the same value for AI output: an outfit name
/// generated after a language switch must come back in the new language.
class LocaleController extends Notifier<LocaleSelection> {
  static const String storageKey = 'app_locale_asc';

  @override
  LocaleSelection build() => const LocaleSelection();

  Future<void> load() async {
    String? stored;
    try {
      stored = await PersistenceService.instance.getString(storageKey);
    } catch (_) {
      // A corrupt or unavailable store means "follow the device", which is a
      // correct default rather than an error worth showing.
      stored = null;
    }
    final valid = LocaleRegistry.byAsc(stored) != null ? stored : null;
    state = LocaleSelection(asc: valid, loaded: true);
  }

  /// `null` restores "follow the device".
  Future<void> setLocale(String? asc) async {
    if (asc != null && LocaleRegistry.byAsc(asc) == null) {
      throw ArgumentError.value(asc, 'asc', 'not an App Store locale this app ships');
    }
    state = LocaleSelection(asc: asc, loaded: true);

    try {
      if (asc == null) {
        await PersistenceService.instance.remove(storageKey);
      } else {
        await PersistenceService.instance.setString(storageKey, asc);
      }
    } catch (_) {
      // The in-memory change stands for this session even if the write fails.
    }

    // Best-effort backend sync: the settings endpoint carries the same value
    // and is what AI prompts read. A failure here must not revert the UI.
    try {
      await ref
          .read(_settingsRepositoryProvider)
          .updateSettings({'language': asc ?? 'en'});
    } catch (_) {
      // Offline or signed out. The local choice still applies, and the next
      // successful settings load carries it up.
    }
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, LocaleSelection>(LocaleController.new);

/// The effective locale, given the stored choice and the device list.
///
/// Kept separate from the controller so a widget can resolve the locale it is
/// about to render without writing anything.
Locale effectiveLocale(LocaleSelection selection, List<Locale> deviceLocales) {
  if (!selection.loaded && selection.followsDevice) {
    return LocaleRegistry.resolve(deviceLocales: deviceLocales);
  }
  return selection.resolve(deviceLocales);
}

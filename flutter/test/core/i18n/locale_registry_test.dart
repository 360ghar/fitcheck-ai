import 'package:fitcheck_ai/core/i18n/locale_registry.dart';
import 'package:fitcheck_ai/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the boundary between "the 50 storefronts we publish listings for" and
/// "the languages this binary can actually render".
///
/// `flutter gen-l10n` accepts a missing `app_<lang>.arb` silently: the locale
/// simply does not appear in `AppLocalizations.supportedLocales` and Flutter
/// resolves it to English. Nothing crashes, nothing warns, and a user who
/// picked their own language gets an English app. These tests make that gap
/// visible instead of shipping it.
void main() {
  group('LocaleRegistry catalog coverage', () {
    test('every registry locale agrees with the generated delegate', () {
      for (final entry in LocaleRegistry.all) {
        expect(
          LocaleRegistry.shipsCatalog(entry),
          AppLocalizations.delegate.isSupported(entry.locale),
          reason:
              '${entry.asc} disagrees with AppLocalizations.delegate. '
              'shipsCatalog must be the single source of truth for "can this '
              'build render ${entry.nativeName}".',
        );
      }
    });

    test('supportedLocales never contains a locale the app cannot render', () {
      for (final locale in LocaleRegistry.supportedLocales) {
        expect(
          AppLocalizations.delegate.isSupported(locale),
          isTrue,
          reason:
              'LocaleRegistry.supportedLocales leaked $locale. Wiring that '
              'into MaterialApp.supportedLocales makes AppLocalizations throw '
              '"failed to load unsupported locale" at runtime.',
        );
      }
    });

    test('English always ships, because every fallback resolves to it', () {
      final english = LocaleRegistry.byAsc('en-US');
      expect(english, isNotNull);
      expect(LocaleRegistry.shipsCatalog(english!), isTrue);
      expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
    });

    test('the language picker only ever offers shippable locales', () {
      final offered = LocaleRegistry.pickerOrder
          .where(LocaleRegistry.shipsCatalog)
          .toList();
      expect(offered, isNotEmpty);
      for (final entry in offered) {
        expect(
          AppLocalizations.delegate.isSupported(entry.locale),
          isTrue,
          reason: '${entry.asc} would appear in the picker and do nothing.',
        );
      }
    });

    test('regional variants dispatch to their own catalog', () {
      // pt-PT and es-MX differ from their base language, so if the country
      // lookup ever regressed they would silently serve pt/es instead.
      for (final asc in ['pt-PT', 'es-MX', 'fr-CA']) {
        final entry = LocaleRegistry.byAsc(asc);
        expect(entry, isNotNull, reason: '$asc missing from the registry');
        expect(
          AppLocalizations.delegate.isSupported(entry!.locale),
          isTrue,
          reason: '$asc has a catalog but the delegate does not accept it',
        );
      }
    });

    test(
      'shipping at least 43 languages',
      () {
        final shipped = LocaleRegistry.all
            .where(LocaleRegistry.shipsCatalog)
            .map((entry) => entry.locale.languageCode)
            .toSet();
        expect(
          shipped.length,
          greaterThanOrEqualTo(43),
          reason:
              'Only ${shipped.length} languages have a catalog. The App Store '
              'listing promises 43. Regenerate the missing app_<lang>.arb '
              'files before submitting.',
        );
      },
      skip:
          'Release gate, not a code bug: catalogs are still being generated '
          'and Gemini quota blocks the remaining ones. Remove this skip once '
          'python3 scripts/i18n/check_locales.py reports zero missing.',
    );
  });
}

import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

/// One locale the app ships.
///
/// [asc] is the App Store Connect shortcode, which is also the key used by
/// `store/asc/locales.json`. [locale] is what Flutter resolves against.
/// [tier] drives translation review: 1 is a reviewed translation, 2 is machine
/// plus back-translation, 3 is machine with an in-app feedback link.
@immutable
class AppLocale {
  const AppLocale({
    required this.asc,
    required this.locale,
    required this.nativeName,
    required this.englishName,
    required this.tier,
    required this.rtl,
  });

  final String asc;
  final Locale locale;
  final String nativeName;
  final String englishName;
  final int tier;
  final bool rtl;

  String get tag => locale.toLanguageTag();

  @override
  String toString() => '$asc ($nativeName)';
}

/// The 50 locales App Store Connect accepts, in the order the picker shows
/// them: English first, then the tier-1 languages, then the rest by name.
///
/// This table must stay in lock-step with `store/asc/locales.json`.
/// `python3 scripts/i18n/check_locales.py` compares the two and fails on a
/// mismatch, because a locale that exists in the store listing but not in the
/// binary shows English to a user who was promised their language.
class LocaleRegistry {
  LocaleRegistry._();

  static const String defaultAsc = 'en-US';
  static const String defaultLanguageCode = 'en';

  static const List<AppLocale> all = [
    AppLocale(asc: 'en-US', locale: Locale('en'), nativeName: 'English (US)', englishName: 'English (US)', tier: 1, rtl: false),
    AppLocale(asc: 'en-GB', locale: Locale('en', 'GB'), nativeName: 'English (UK)', englishName: 'English (UK)', tier: 1, rtl: false),
    AppLocale(asc: 'en-AU', locale: Locale('en', 'AU'), nativeName: 'English (Australia)', englishName: 'English (Australia)', tier: 3, rtl: false),
    AppLocale(asc: 'en-CA', locale: Locale('en', 'CA'), nativeName: 'English (Canada)', englishName: 'English (Canada)', tier: 3, rtl: false),
    AppLocale(asc: 'es-ES', locale: Locale('es'), nativeName: 'Español (España)', englishName: 'Spanish (Spain)', tier: 1, rtl: false),
    AppLocale(asc: 'es-MX', locale: Locale('es', 'MX'), nativeName: 'Español (México)', englishName: 'Spanish (Mexico)', tier: 1, rtl: false),
    AppLocale(asc: 'pt-BR', locale: Locale('pt', 'BR'), nativeName: 'Português (Brasil)', englishName: 'Portuguese (Brazil)', tier: 1, rtl: false),
    AppLocale(asc: 'pt-PT', locale: Locale('pt', 'PT'), nativeName: 'Português (Portugal)', englishName: 'Portuguese (Portugal)', tier: 2, rtl: false),
    AppLocale(asc: 'fr-FR', locale: Locale('fr'), nativeName: 'Français', englishName: 'French', tier: 1, rtl: false),
    AppLocale(asc: 'fr-CA', locale: Locale('fr', 'CA'), nativeName: 'Français (Canada)', englishName: 'French (Canada)', tier: 2, rtl: false),
    AppLocale(asc: 'de-DE', locale: Locale('de'), nativeName: 'Deutsch', englishName: 'German', tier: 1, rtl: false),
    AppLocale(asc: 'it', locale: Locale('it'), nativeName: 'Italiano', englishName: 'Italian', tier: 1, rtl: false),
    AppLocale(asc: 'nl-NL', locale: Locale('nl'), nativeName: 'Nederlands', englishName: 'Dutch', tier: 2, rtl: false),
    AppLocale(asc: 'sv', locale: Locale('sv'), nativeName: 'Svenska', englishName: 'Swedish', tier: 2, rtl: false),
    AppLocale(asc: 'no', locale: Locale('no'), nativeName: 'Norsk', englishName: 'Norwegian', tier: 2, rtl: false),
    AppLocale(asc: 'da', locale: Locale('da'), nativeName: 'Dansk', englishName: 'Danish', tier: 2, rtl: false),
    AppLocale(asc: 'fi', locale: Locale('fi'), nativeName: 'Suomi', englishName: 'Finnish', tier: 2, rtl: false),
    AppLocale(asc: 'pl', locale: Locale('pl'), nativeName: 'Polski', englishName: 'Polish', tier: 2, rtl: false),
    AppLocale(asc: 'cs', locale: Locale('cs'), nativeName: 'Čeština', englishName: 'Czech', tier: 2, rtl: false),
    AppLocale(asc: 'sk', locale: Locale('sk'), nativeName: 'Slovenčina', englishName: 'Slovak', tier: 2, rtl: false),
    AppLocale(asc: 'sl-SI', locale: Locale('sl'), nativeName: 'Slovenščina', englishName: 'Slovenian', tier: 3, rtl: false),
    AppLocale(asc: 'hr', locale: Locale('hr'), nativeName: 'Hrvatski', englishName: 'Croatian', tier: 3, rtl: false),
    AppLocale(asc: 'ro', locale: Locale('ro'), nativeName: 'Română', englishName: 'Romanian', tier: 3, rtl: false),
    AppLocale(asc: 'hu', locale: Locale('hu'), nativeName: 'Magyar', englishName: 'Hungarian', tier: 3, rtl: false),
    AppLocale(asc: 'el', locale: Locale('el'), nativeName: 'Ελληνικά', englishName: 'Greek', tier: 3, rtl: false),
    AppLocale(asc: 'tr', locale: Locale('tr'), nativeName: 'Türkçe', englishName: 'Turkish', tier: 1, rtl: false),
    AppLocale(asc: 'ru', locale: Locale('ru'), nativeName: 'Русский', englishName: 'Russian', tier: 2, rtl: false),
    AppLocale(asc: 'uk', locale: Locale('uk'), nativeName: 'Українська', englishName: 'Ukrainian', tier: 2, rtl: false),
    AppLocale(asc: 'ar-SA', locale: Locale('ar'), nativeName: 'العربية', englishName: 'Arabic', tier: 1, rtl: true),
    AppLocale(asc: 'he', locale: Locale('he'), nativeName: 'עברית', englishName: 'Hebrew', tier: 2, rtl: true),
    AppLocale(asc: 'ur-PK', locale: Locale('ur'), nativeName: 'اردو', englishName: 'Urdu', tier: 2, rtl: true),
    AppLocale(asc: 'hi', locale: Locale('hi'), nativeName: 'हिन्दी', englishName: 'Hindi', tier: 1, rtl: false),
    AppLocale(asc: 'bn-BD', locale: Locale('bn'), nativeName: 'বাংলা', englishName: 'Bangla', tier: 1, rtl: false),
    AppLocale(asc: 'gu-IN', locale: Locale('gu'), nativeName: 'ગુજરાતી', englishName: 'Gujarati', tier: 1, rtl: false),
    AppLocale(asc: 'kn-IN', locale: Locale('kn'), nativeName: 'ಕನ್ನಡ', englishName: 'Kannada', tier: 1, rtl: false),
    AppLocale(asc: 'ml-IN', locale: Locale('ml'), nativeName: 'മലയാളം', englishName: 'Malayalam', tier: 1, rtl: false),
    AppLocale(asc: 'mr-IN', locale: Locale('mr'), nativeName: 'मराठी', englishName: 'Marathi', tier: 1, rtl: false),
    AppLocale(asc: 'or-IN', locale: Locale('or'), nativeName: 'ଓଡ଼ିଆ', englishName: 'Odia', tier: 2, rtl: false),
    AppLocale(asc: 'pa-IN', locale: Locale('pa'), nativeName: 'ਪੰਜਾਬੀ', englishName: 'Punjabi', tier: 1, rtl: false),
    AppLocale(asc: 'ta-IN', locale: Locale('ta'), nativeName: 'தமிழ்', englishName: 'Tamil', tier: 1, rtl: false),
    AppLocale(asc: 'te-IN', locale: Locale('te'), nativeName: 'తెలుగు', englishName: 'Telugu', tier: 1, rtl: false),
    AppLocale(asc: 'zh-Hans', locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), nativeName: '简体中文', englishName: 'Chinese (Simplified)', tier: 1, rtl: false),
    AppLocale(asc: 'zh-Hant', locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), nativeName: '繁體中文', englishName: 'Chinese (Traditional)', tier: 1, rtl: false),
    AppLocale(asc: 'ja', locale: Locale('ja'), nativeName: '日本語', englishName: 'Japanese', tier: 1, rtl: false),
    AppLocale(asc: 'ko', locale: Locale('ko'), nativeName: '한국어', englishName: 'Korean', tier: 1, rtl: false),
    AppLocale(asc: 'th', locale: Locale('th'), nativeName: 'ไทย', englishName: 'Thai', tier: 2, rtl: false),
    AppLocale(asc: 'vi', locale: Locale('vi'), nativeName: 'Tiếng Việt', englishName: 'Vietnamese', tier: 2, rtl: false),
    AppLocale(asc: 'id', locale: Locale('id'), nativeName: 'Bahasa Indonesia', englishName: 'Indonesian', tier: 2, rtl: false),
    AppLocale(asc: 'ms', locale: Locale('ms'), nativeName: 'Bahasa Melayu', englishName: 'Malay', tier: 2, rtl: false),
    AppLocale(asc: 'ca', locale: Locale('ca'), nativeName: 'Català', englishName: 'Catalan', tier: 3, rtl: false),
  ];

  /// The locales the binary can genuinely render, not the full 50 storefront
  /// list.
  ///
  /// This is deliberately the intersection with the generated catalogs. Passing
  /// the raw 50 to `MaterialApp.supportedLocales` would make Flutter resolve a
  /// device set to Arabic to `ar`, and `AppLocalizations` would then throw
  /// "failed to load unsupported locale" at runtime. `main.dart` uses
  /// `AppLocalizations.supportedLocales` directly; this exists so any other
  /// caller gets a safe answer too.
  static final List<Locale> supportedLocales = List<Locale>.unmodifiable(
    all.map((entry) => entry.locale).where(AppLocalizations.delegate.isSupported),
  );

  /// The picker order: tier 1 first, then tier 2, then tier 3; English stays on
  /// top because it is the fallback every other locale resolves to.
  static final List<AppLocale> pickerOrder = () {
    final english = all.where((entry) => entry.locale.languageCode == 'en').toList();
    final rest = all.where((entry) => entry.locale.languageCode != 'en').toList()
      ..sort((a, b) {
        final byTier = a.tier.compareTo(b.tier);
        if (byTier != 0) return byTier;
        return a.nativeName.toLowerCase().compareTo(b.nativeName.toLowerCase());
      });
    return List<AppLocale>.unmodifiable([...english, ...rest]);
  }();

  static AppLocale? byAsc(String? code) {
    if (code == null) return null;
    for (final entry in all) {
      if (entry.asc == code) return entry;
    }
    return null;
  }

  /// Whether this build actually contains a catalog for [entry].
  ///
  /// `flutter gen-l10n` accepts a missing `app_<lang>.arb` without complaint:
  /// it simply omits that locale from `AppLocalizations.supportedLocales`, and
  /// Flutter then resolves the locale to English. A user who picks Arabic from
  /// a picker that lists it would therefore get an English app with no error
  /// anywhere. Every surface that offers a language must ask this first, so
  /// that the app never advertises a language it cannot render.
  static bool shipsCatalog(AppLocale entry) =>
      AppLocalizations.delegate.isSupported(entry.locale);

  static AppLocale? byTag(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final normalized = tag.replaceAll('-', '_');
    for (final entry in all) {
      if (entry.locale.toLanguageTag().replaceAll('-', '_') == normalized) return entry;
      if (entry.asc.replaceAll('-', '_') == normalized) return entry;
    }
    // A language-only tag ("hi") still has an unambiguous match for most
    // languages. Where several countries share it, the first entry wins, and
    // the table is ordered so that first entry is the primary variant.
    final language = normalized.split('_').first;
    for (final entry in all) {
      if (entry.locale.languageCode == language) return entry;
    }
    return null;
  }

  static AppLocale? forLocale(Locale? locale) {
    if (locale == null) return null;
    for (final entry in all) {
      if (entry.locale == locale) return entry;
    }
    for (final entry in all) {
      if (entry.locale.languageCode == locale.languageCode
          && entry.locale.scriptCode == locale.scriptCode
          && entry.locale.countryCode == locale.countryCode) {
        return entry;
      }
    }
    for (final entry in all) {
      if (entry.locale.languageCode == locale.languageCode) return entry;
    }
    return null;
  }

  static bool isRtl(Locale locale) =>
      forLocale(locale)?.rtl ?? const {'ar', 'he', 'ur', 'fa', 'ps'}.contains(locale.languageCode);

  /// Resolves the app locale from the stored preference and the device list.
  ///
  /// Exact language+script+country wins, then language+script, then
  /// language+country, then language alone. Falling back to English rather
  /// than the first supported locale matters: a device set to Georgian must
  /// show English, not Spanish.
  static Locale resolve({String? preferredAsc, List<Locale>? deviceLocales}) {
    final preferred = byAsc(preferredAsc);
    if (preferred != null) return preferred.locale;

    final candidates = deviceLocales ?? const <Locale>[];
    for (final candidate in candidates) {
      for (final entry in all) {
        if (entry.locale == candidate) return entry.locale;
      }
    }
    for (final candidate in candidates) {
      for (final entry in all) {
        if (entry.locale.languageCode == candidate.languageCode
            && entry.locale.scriptCode == candidate.scriptCode) {
          return entry.locale;
        }
      }
    }
    for (final candidate in candidates) {
      for (final entry in all) {
        if (entry.locale.languageCode == candidate.languageCode
            && entry.locale.countryCode == candidate.countryCode) {
          return entry.locale;
        }
      }
    }
    for (final candidate in candidates) {
      for (final entry in all) {
        if (entry.locale.languageCode == candidate.languageCode) {
          return entry.locale;
        }
      }
    }
    return const Locale(defaultLanguageCode);
  }
}

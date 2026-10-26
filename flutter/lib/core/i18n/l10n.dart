import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';
import 'locale_registry.dart';

export '../../l10n/generated/app_localizations.dart';

/// Shorthand for the generated localizations.
///
/// `context.l10n.wardrobeTitle` reads better than
/// `AppLocalizations.of(context).wardrobeTitle` at every call site, and the
/// non-nullable getter means a missing delegate is a build error rather than a
/// null check at 200 call sites.
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// True when the surrounding [Directionality] is right-to-left.
///
/// Used for the handful of places that cannot rely on directional padding or a
/// mirrored icon: a custom painter, a transform, or a chevron drawn by hand.
extension DirectionalityContext on BuildContext {
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// Horizontal inset that is always on the leading edge.
  EdgeInsetsDirectional get leadingInset =>
      const EdgeInsetsDirectional.only(start: 16);

  /// The native name of the locale currently rendered.
  String get localeNativeName {
    final entry = LocaleRegistry.forLocale(Localizations.localeOf(this));
    return entry?.nativeName ?? Localizations.localeOf(this).toLanguageTag();
  }
}

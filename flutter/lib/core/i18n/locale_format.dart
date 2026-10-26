import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Locale-correct formatting for everything the app displays as a date, time,
/// number or money amount.
///
/// The previous helpers hardcoded `M/d/yyyy`, English month names and `AM/PM`.
/// That is wrong in most of the 50 locales the app now ships: most of the world
/// writes the day first, Japan and Korea put the year first, and Arabic,
/// Hindi and Thai do not use Latin month names at all.
///
/// [DateFormat] and [NumberFormat] resolve the pattern from the locale's CLDR
/// data, so the fix is to route every call through here rather than to write 50
/// patterns.
class LocaleFormat {
  LocaleFormat._();

  static String _tag(Locale locale) => locale.toLanguageTag();

  /// Standard date, e.g. `7/28/2026` (en-US) or `28/07/2026` (en-GB, hi, de).
  static String date(DateTime value, Locale locale) =>
      DateFormat.yMd(_tag(locale)).format(value.toLocal());

  /// Date with time, e.g. `7/28/2026 2:30 PM`.
  static String dateTime(DateTime value, Locale locale) =>
      DateFormat.yMd(_tag(locale)).add_jm().format(value.toLocal());

  /// Month and year, e.g. `July 2026` / `जुलाई 2026`.
  static String monthYear(DateTime value, Locale locale) =>
      DateFormat.yMMMM(_tag(locale)).format(value.toLocal());

  /// Short month, day and year, e.g. `Jul 28, 2026` or `28 जुल॰ 2026`.
  static String mediumDate(DateTime value, Locale locale) =>
      DateFormat.yMMMd(_tag(locale)).format(value.toLocal());

  /// Weekday and date, for a calendar header.
  static String weekdayDate(DateTime value, Locale locale) =>
      DateFormat.MMMEd(_tag(locale)).format(value.toLocal());

  /// Time only, in the locale's 12- or 24-hour convention.
  static String time(DateTime value, Locale locale) =>
      DateFormat.jm(_tag(locale)).format(value.toLocal());

  /// Month name alone, for a month selector.
  static String monthName(DateTime value, Locale locale) =>
      DateFormat.MMMM(_tag(locale)).format(value.toLocal());

  /// A relative day description with ICU plurals, so Arabic's six plural forms
  /// and Slavic's four come out right instead of "3 day ago".
  ///
  /// [dayLabel] supplies the already-localized plural strings; passing them in
  /// keeps this file free of a dependency on the generated localizations class.
  static String relativeDay(
    DateTime value,
    DateTime now, {
    required String today,
    required String yesterday,
    required String Function(int count) daysAgo,
    required String Function(int count) weeksAgo,
    required String Function(int count) monthsAgo,
    required String Function(int count) yearsAgo,
  }) {
    final difference = now.difference(value);
    final days = difference.inDays < 0 ? 0 : difference.inDays;
    if (days == 0) return today;
    if (days == 1) return yesterday;
    if (days < 7) return daysAgo(days);
    if (days < 30) return weeksAgo(days ~/ 7);
    if (days < 365) return monthsAgo(days ~/ 30);
    return yearsAgo(days ~/ 365);
  }

  /// Money in the user's currency.
  ///
  /// Prices come from the store as already-formatted strings, so this is for
  /// computed values only: cost-per-wear, total closet value, savings.
  static String money(num amount, Locale locale, String currencyCode) =>
      NumberFormat.simpleCurrency(
        locale: _tag(locale),
        name: currencyCode,
      ).format(amount);

  /// A plain count with the locale's digit grouping.
  static String number(num value, Locale locale) =>
      NumberFormat.decimalPattern(_tag(locale)).format(value);

  /// A percentage, e.g. `42%` or `42 %` depending on the locale.
  static String percent(num fraction, Locale locale) =>
      NumberFormat.percentPattern(_tag(locale)).format(fraction);
}

/// `BuildContext` shorthand so a widget does not repeat `Localizations.localeOf`.
extension LocaleFormatContext on BuildContext {
  Locale get appLocale => Localizations.localeOf(this);
}

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';

/// Centralized date formatting utilities.
///
/// All date display in the app should use these helpers so formatting is
/// consistent across views. See FL1 in SIMPLIFY.md.
///
/// Everything here delegates to `intl`, which resolves the pattern from the
/// locale's CLDR data. The locale comes from [locale], which `FitCheckApp` sets
/// on every build from the same value `MaterialApp` renders with — so these
/// helpers are correct in all 50 locales without a `BuildContext`, which is
/// what the ~40 existing call sites need.
///
/// Before this change every helper hardcoded US conventions (`M/d/yyyy`,
/// English month names, `AM/PM`). That reads as broken to most of the world:
/// a British user expects 28/07/2026, and an Arabic or Hindi user expects
/// neither the order nor the Latin month name.
class AppDateUtils {
  AppDateUtils._();

  /// The locale dates render in. Set by the app root; English until then.
  static Locale locale = const Locale('en');

  static String get _tag => locale.toLanguageTag();

  /// Standard display format, e.g. "7/28/2026" (en-US) or "28/07/2026" (en-GB).
  static String formatDate(DateTime date) {
    // Model timestamps parse as UTC (DateTime.parse on ISO 'Z' values);
    // normalize to the device's local zone or dates near midnight render
    // on the wrong calendar day.
    return DateFormat.yMd(_tag).format(date.toLocal());
  }

  /// Display with time, e.g. "7/28/2026 2:30 PM".
  static String formatDateTime(DateTime date) {
    return DateFormat.yMd(_tag).add_jm().format(date.toLocal());
  }

  /// Relative time description: "Today", "Yesterday", "3 days ago",
  /// "2 weeks ago", "1 month ago", "2 years ago".
  ///
  /// The counts go through ICU plurals from the generated localizations, so
  /// languages with more than two plural forms get the right one. English is
  /// the fallback when no localization is installed (tests, background
  /// isolates).
  static String formatRelativeTime(DateTime date, {AppLocalizations? l10n}) {
    final now = DateTime.now();
    // Future timestamps (e.g. a user-entered future purchase date) must not
    // render as '-1 days ago' — clamp to zero.
    final days = now.difference(date).inDays < 0 ? 0 : now.difference(date).inDays;

    if (l10n == null) {
      if (days == 0) return 'Today';
      if (days == 1) return 'Yesterday';
      if (days < 7) return '$days days ago';
      if (days < 30) return '${days ~/ 7} weeks ago';
      if (days < 365) return '${days ~/ 30} months ago';
      return '${days ~/ 365} years ago';
    }

    if (days == 0) return l10n.dateToday;
    if (days == 1) return l10n.dateYesterday;
    if (days < 7) return l10n.dateDaysAgo(days);
    if (days < 30) return l10n.dateWeeksAgo(days ~/ 7);
    if (days < 365) return l10n.dateMonthsAgo(days ~/ 30);
    return l10n.dateYearsAgo(days ~/ 365);
  }

  /// Format a month+year string like "July 2026".
  static String formatMonthYear(DateTime date) =>
      DateFormat.yMMMM(_tag).format(date.toLocal());

  /// Format like "Jul 28, 2026" (short month name + day + year).
  static String formatMonthDayYear(DateTime date) =>
      DateFormat.yMMMd(_tag).format(date.toLocal());

  /// Format time only. 12- or 24-hour follows the locale.
  static String formatTimeOnly(DateTime time) =>
      DateFormat.jm(_tag).format(time.toLocal());

  /// Weekday plus date, for calendar headers.
  static String formatWeekdayDate(DateTime date) =>
      DateFormat.MMMEd(_tag).format(date.toLocal());

  /// Month name alone, for month selectors.
  static String formatMonthName(DateTime date) =>
      DateFormat.MMMM(_tag).format(date.toLocal());

  /// Check if two [DateTime]s fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    // Compare in the local zone: UTC timestamps near midnight would otherwise
    // disagree with locally-constructed dates for the same calendar day.
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }
}

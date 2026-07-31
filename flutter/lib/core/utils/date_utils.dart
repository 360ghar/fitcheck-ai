/// Centralized date formatting utilities.
///
/// All date display in the app should use these helpers so formatting is
/// consistent across views. See FL1 in SIMPLIFY.md.
class AppDateUtils {
  AppDateUtils._();

  /// Standard display format, e.g. "7/28/2026".
  static String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Display with time, e.g. "7/28/2026 2:30 PM".
  static String formatDateTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '${formatDate(date)} $hour:$minute $amPm';
  }

  /// Relative time description, e.g. "Today", "Yesterday", "3 days ago",
  /// "2 weeks ago", "1 month ago", "2 years ago".
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    // Future timestamps (e.g. a user-entered future purchase date) must not
    // render as '-1 days ago' — clamp to zero.
    final days = difference.inDays < 0 ? 0 : difference.inDays;

    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) {
      final weeks = (days / 7).floor();
      return '$weeks weeks ago';
    }
    if (days < 365) {
      final months = (days / 30).floor();
      return '$months months ago';
    }
    final years = (days / 365).floor();
    return '$years years ago';
  }

  /// Format a month+year string like "July 2026".
  static String formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Format time only, e.g. "02:30".
  static String formatTimeOnly(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Check if two [DateTime]s fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

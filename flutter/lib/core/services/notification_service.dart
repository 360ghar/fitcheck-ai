import 'package:flutter/material.dart';

import '../theme/paper_tokens.dart';

/// App-level messenger key. Passed to the app widget so snackbars can be
/// shown from code without a [BuildContext].
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Notification types for consistent styling
enum NotificationType { success, error, warning, info }

/// Represents a notification to be displayed
class AppNotification {
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;

  AppNotification({
    required this.title,
    required this.message,
    required this.type,
  }) : timestamp = DateTime.now();
}

/// Builds the app's snackbars. Code shows messages through `ErrorHandler`.
abstract final class NotificationService {
  /// The single place the app builds a snackbar.
  ///
  /// Nothing else in the app should build a snackbar -- see
  /// test/core/utils/snackbar_policy_test.dart. Uses the app-level
  /// [ScaffoldMessenger], so a snackbar never blocks a pop.
  static void present(AppNotification notification) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    final colors = _getColors(notification.type);
    final hasTitle = notification.title.isNotEmpty;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.background,
          duration: Duration(
            seconds: notification.type == NotificationType.error ? 4 : 2,
          ),
          content: Row(
            children: [
              Icon(colors.icon, color: colors.iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasTitle)
                      Text(
                        notification.title,
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(
                      notification.message,
                      style: TextStyle(color: colors.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  /// Paper colours for [type]. The snackbar sits on the stock's card colour
  /// (see the theme's snackBarTheme); only the icon carries the status.
  static _NotificationColors _getColors(NotificationType type) {
    final context = scaffoldMessengerKey.currentContext;
    final tokens = context == null
        ? PaperTokens.light
        : PaperTokens.of(context);
    final (icon, color) = switch (type) {
      NotificationType.success => (
        Icons.check_circle_outline_rounded,
        tokens.success,
      ),
      NotificationType.error => (Icons.error_outline_rounded, tokens.error),
      NotificationType.warning => (Icons.warning_amber_rounded, tokens.warning),
      NotificationType.info => (
        Icons.info_outline_rounded,
        tokens.stock.accent,
      ),
    };
    return _NotificationColors(
      background: tokens.stock.card,
      text: tokens.textPrimary,
      icon: icon,
      iconColor: color,
    );
  }
}

class _NotificationColors {
  final Color background;
  final Color text;
  final IconData icon;
  final Color iconColor;

  _NotificationColors({
    required this.background,
    required this.text,
    required this.icon,
    required this.iconColor,
  });
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

/// Centralized notification service
/// Controllers emit notifications, this service handles presentation
/// This separates UI concerns from business logic in controllers
class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();

  // Observable for testing/custom UI if needed
  final Rx<AppNotification?> lastNotification = Rx<AppNotification?>(null);

  /// Show a success notification
  void showSuccess(String message, {String title = 'Success'}) {
    _show(AppNotification(
      title: title,
      message: message,
      type: NotificationType.success,
    ));
  }

  /// Show an error notification
  void showError(String message, {String title = 'Error'}) {
    _show(AppNotification(
      title: title,
      message: message,
      type: NotificationType.error,
    ));
  }

  /// Show a warning notification
  void showWarning(String message, {String title = 'Warning'}) {
    _show(AppNotification(
      title: title,
      message: message,
      type: NotificationType.warning,
    ));
  }

  /// Show an info notification
  void showInfo(String message, {String title = 'Info'}) {
    _show(AppNotification(
      title: title,
      message: message,
      type: NotificationType.info,
    ));
  }

  /// Show a simple message without title
  void showMessage(String message, {NotificationType type = NotificationType.info}) {
    _show(AppNotification(
      title: '',
      message: message,
      type: type,
    ));
  }

  void _show(AppNotification notification) {
    lastNotification.value = notification;

    final colors = _getColors(notification.type);
    Get.snackbar(
      notification.title,
      notification.message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: colors.background,
      colorText: colors.text,
      duration: Duration(
        seconds: notification.type == NotificationType.error ? 4 : 2,
      ),
      icon: Icon(colors.icon, color: colors.iconColor, size: 24),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  _NotificationColors _getColors(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return _NotificationColors(
          background: Colors.green.shade50,
          text: Colors.green.shade900,
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
        );
      case NotificationType.error:
        return _NotificationColors(
          background: Colors.red.shade50,
          text: Colors.red.shade900,
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
      case NotificationType.warning:
        return _NotificationColors(
          background: Colors.orange.shade50,
          text: Colors.orange.shade900,
          icon: Icons.warning_outlined,
          iconColor: Colors.orange,
        );
      case NotificationType.info:
        return _NotificationColors(
          background: Colors.blue.shade50,
          text: Colors.blue.shade900,
          icon: Icons.info_outline,
          iconColor: Colors.blue,
        );
    }
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

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../exceptions/app_exceptions.dart';

/// Utility class for handling errors consistently across the app
class ErrorHandler {
  /// Extract a user-friendly error message from any error
  static String extractMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    // Handle custom exceptions
    if (error is AppException) {
      return error.message;
    }

    // Handle DioException
    if (error is DioException) {
      return handleDioException(error).message;
    }

    // Handle Exception with message
    if (error is Exception) {
      final message = error.toString();
      // Remove 'Exception: ' prefix if present
      if (message.startsWith('Exception: ')) {
        return message.replaceFirst('Exception: ', '');
      }
      return message;
    }

    // Handle String
    if (error is String) {
      return error;
    }

    return 'An unexpected error occurred';
  }

  /// Show error to user via snackbar
  static void showError(dynamic error, {String? title}) {
    final message = extractMessage(error);
    Get.snackbar(
      title ?? 'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 4),
      icon: const Icon(
        Icons.error_outline,
        color: Colors.red,
      ),
    );
  }

  /// Show success message via snackbar
  static void showSuccess(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.green,
      ),
    );
  }

  /// Show info message via snackbar
  static void showInfo(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Info',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade900,
      duration: const Duration(seconds: 2),
      icon: const Icon(
        Icons.info_outline,
        color: Colors.blue,
      ),
    );
  }

  /// Show warning message via snackbar
  static void showWarning(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Warning',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.shade50,
      colorText: Colors.orange.shade900,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.warning_outlined,
        color: Colors.orange,
      ),
    );
  }
}

/// Extension to easily show errors from controllers
extension ErrorHandlerExtension on GetxController {
  void handleError(dynamic error, {String? title}) {
    ErrorHandler.showError(error, title: title);
  }

  void handleSuccess(String message, {String? title}) {
    ErrorHandler.showSuccess(message, title: title);
  }

  void handleInfo(String message, {String? title}) {
    ErrorHandler.showInfo(message, title: title);
  }

  void handleWarning(String message, {String? title}) {
    ErrorHandler.showWarning(message, title: title);
  }
}

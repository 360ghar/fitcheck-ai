import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'error_handler.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lightweight helpers for permission pre-prompts (rationale) and recovery
/// (deep-link to Settings) without adding a permissions package. These improve
/// the picker/camera experience per Apple's Human Interface Guidelines.
class PermissionHelper {
  PermissionHelper._();

  static Future<void> openAppSettings() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await const MethodChannel(
          'fitcheck/permissions',
        ).invokeMethod<void>('openAppSettings');
      } else if (!await launchUrl(
        Uri.parse('app-settings:'),
        mode: LaunchMode.externalApplication,
      )) {
        throw StateError('Settings unavailable');
      }
    } catch (_) {
      ErrorHandler.showInfo(
        'Open your device Settings, select FitCheck AI, and enable the required permission.',
        title: 'Open Device Settings',
      );
    }
  }

  /// Shows a camera-usage rationale before the OS permission prompt.
  /// Returns true if the user taps Continue.
  static Future<bool> confirmCameraRationale() {
    return _confirmRationale(
      icon: Icons.camera_alt_outlined,
      title: 'Camera Access',
      message:
          'FitCheck AI uses your camera to capture photos of your clothing '
          'and outfits for AI try-on and closet organization.',
    );
  }

  /// Shows a photo-library rationale before the OS permission prompt.
  /// Returns true if the user taps Continue.
  static Future<bool> confirmPhotoRationale() {
    return _confirmRationale(
      icon: Icons.photo_library_outlined,
      title: 'Photo Access',
      message:
          'FitCheck AI needs access to your photos so you can select clothing '
          'and outfit images for AI features and your closet.',
    );
  }

  /// image_picker also throws for unavailable cameras, busy pickers and file
  /// errors. Only actual permission denials should send people to Settings.
  static Future<void> handleImagePickerError(
    Object error, {
    required String permissionName,
  }) async {
    final code = error is PlatformException ? error.code : null;
    if (code == 'camera_access_denied' || code == 'photo_access_denied') {
      await showDeniedRecovery(permissionName: permissionName);
    } else if (code == 'camera_access_restricted' ||
        code == 'photo_access_restricted') {
      ErrorHandler.showInfo(
        '$permissionName access is restricted on this device. Check your device restrictions.',
        title: 'Access Restricted',
      );
    } else {
      ErrorHandler.showInfo(
        code == 'already_active'
            ? 'Finish the open photo picker, then try again.'
            : 'Could not open ${permissionName == 'Camera' ? 'the camera' : 'the photo picker'}. Please try again.',
        title: 'Photo Picker Unavailable',
      );
    }
  }

  /// Shown when a permission was denied: offers to open the system Settings
  /// app so the user can grant access on either mobile platform.
  static Future<void> showDeniedRecovery({
    required String permissionName,
  }) async {
    await Get.dialog<void>(
      AlertDialog(
        scrollable: true,
        title: Text('$permissionName Access Needed'),
        content: Text(
          'Access to $permissionName is currently denied. Open Settings to '
          'enable it so you can continue.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Not Now')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  static Future<bool> _confirmRationale({
    required IconData icon,
    required String title,
    required String message,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        scrollable: true,
        title: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Continue'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}

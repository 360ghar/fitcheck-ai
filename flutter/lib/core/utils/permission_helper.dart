import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lightweight helpers for permission pre-prompts (rationale) and recovery
/// (deep-link to Settings) without adding a permissions package. These improve
/// the picker/camera experience per Apple's Human Interface Guidelines.
class PermissionHelper {
  PermissionHelper._();

  /// Shows a camera-usage rationale before the OS permission prompt.
  /// Returns true if the user taps Continue.
  static Future<bool> confirmCameraRationale() {
    return _confirmRationale(
      icon: Icons.camera_alt_outlined,
      title: 'Camera Access',
      message:
          'FitCheck AI uses your camera to capture photos of your clothing '
          'and outfits for AI try-on and wardrobe organization.',
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
          'and outfit images for AI features and your wardrobe.',
    );
  }

  /// Shown when a permission was denied: offers to open the system Settings
  /// app so the user can grant access (iOS deep-link `app-settings:`).
  static Future<void> showDeniedRecovery({
    required String permissionName,
  }) async {
    await Get.dialog<void>(
      AlertDialog(
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
              final uri = Uri.parse('app-settings:');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
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

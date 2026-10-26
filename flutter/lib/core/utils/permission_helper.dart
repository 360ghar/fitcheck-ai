import 'package:flutter/material.dart';
import '../i18n/l10n.dart';
import '../providers.dart';
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
      title: (l10n) => l10n.permissionCameraTitle,
      message: (l10n) => l10n.permissionCameraRationale,
    );
  }

  /// Shows a photo-library rationale before the OS permission prompt.
  /// Returns true if the user taps Continue.
  static Future<bool> confirmPhotoRationale() {
    return _confirmRationale(
      icon: Icons.photo_library_outlined,
      title: (l10n) => l10n.permissionPhotoTitle,
      message: (l10n) => l10n.permissionPhotoRationale,
    );
  }

  /// Shown when a permission was denied: offers to open the system Settings
  /// app so the user can grant access (iOS deep-link `app-settings:`).
  static Future<void> showDeniedRecovery({
    required String permissionName,
  }) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.permissionAccessNeededTitle(permissionName)),
        content: Text(
          context.l10n.permissionAccessDeniedBody(permissionName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.permissionNotNow),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse('app-settings:');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            child: Text(context.l10n.permissionOpenSettings),
          ),
        ],
      ),
    );
  }

  static Future<bool> _confirmRationale({
    required IconData icon,
    required String Function(AppLocalizations) title,
    required String Function(AppLocalizations) message,
  }) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return false;
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(title(l10n))),
          ],
        ),
        content: Text(message(l10n)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionContinue),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

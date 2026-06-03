import 'package:get/get.dart';

/// Service for local notifications (background extraction progress updates).
///
/// NOTE: This is currently an inert no-op stub. It is NOT registered or used
/// anywhere in the app, and the `flutter_local_notifications` package it
/// originally depended on is intentionally not a dependency (it would require
/// extra iOS/Android notification setup that is out of scope for the v1 launch).
///
/// The public API below is preserved so the feature can be wired up later
/// without changing call sites. To activate:
/// 1. Add `flutter_local_notifications` to pubspec.yaml
/// 2. Configure Android (AndroidManifest.xml) and iOS (Info.plist + push setup)
/// 3. Restore the implementation and `Get.put(PushNotificationService())` in main.dart
class PushNotificationService extends GetxService {
  static PushNotificationService get instance =>
      Get.find<PushNotificationService>();

  final RxBool isInitialized = false.obs;
  final RxBool isEnabled = false.obs;

  /// Notification IDs
  static const int extractionProgressId = 1;
  static const int extractionCompleteId = 2;

  /// Initialize notification service (no-op until the plugin is wired up).
  Future<void> init() async {
    // Intentionally a no-op. See class doc.
  }

  /// Request notification permissions (no-op stub).
  Future<bool> requestPermissions() async => false;

  /// Show extraction progress notification (no-op stub).
  Future<void> showExtractionProgress({
    required String jobId,
    required int progress, // 0-100
    required int total,
    required int completed,
    String? currentItem,
  }) async {
    // Intentionally a no-op. See class doc.
  }

  /// Show extraction complete notification (no-op stub).
  Future<void> showExtractionComplete({
    required String jobId,
    required int itemCount,
    bool success = true,
  }) async {
    // Intentionally a no-op. See class doc.
  }

  /// Cancel all notifications (no-op stub).
  Future<void> cancelAll() async {
    // Intentionally a no-op. See class doc.
  }

  /// Cancel extraction progress notification (no-op stub).
  Future<void> cancelExtractionProgress() async {
    // Intentionally a no-op. See class doc.
  }

  /// Enable background notifications (no-op stub).
  Future<void> enableBackgroundMode() async {
    // Intentionally a no-op. See class doc.
  }

  /// Disable background notifications (no-op stub).
  Future<void> disableBackgroundMode() async {
    isEnabled.value = false;
  }
}

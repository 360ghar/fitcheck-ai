import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// Service for handling local push notifications
/// Enables background extraction progress updates when user navigates away
///
/// To use this service:
/// 1. Add flutter_local_notifications to pubspec.yaml
/// 2. Configure Android (android/app/src/main/AndroidManifest.xml)
/// 3. Configure iOS (ios/Runner/Info.plist)
/// 4. Initialize in main.dart: Get.put(PushNotificationService())
class PushNotificationService extends GetxService {
  static PushNotificationService get instance =>
      Get.find<PushNotificationService>();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final RxBool isInitialized = false.obs;
  final RxBool isEnabled = false.obs;

  /// Notification IDs
  static const int extractionProgressId = 1;
  static const int extractionCompleteId = 2;

  /// Initialize notification service
  Future<void> init() async {
    if (isInitialized.value) return;

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      isInitialized.value = initialized ?? false;

      if (isInitialized.value) {
        // Request permissions
        await requestPermissions();
      }
    } catch (e) {
      print('Failed to initialize notifications: $e');
      isInitialized.value = false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!isInitialized.value) return false;

    // Android 13+ requires runtime permission
    final androidImpl =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    bool? androidGranted;
    if (androidImpl != null) {
      androidGranted = await androidImpl.requestNotificationsPermission();
    }

    // iOS permissions
    final iosImpl = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool? iosGranted;
    if (iosImpl != null) {
      iosGranted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final granted = androidGranted ?? iosGranted ?? true;
    isEnabled.value = granted;
    return granted;
  }

  /// Show extraction progress notification
  Future<void> showExtractionProgress({
    required String jobId,
    required int progress, // 0-100
    required int total,
    required int completed,
    String? currentItem,
  }) async {
    if (!isEnabled.value) return;

    final title = 'Processing Items';
    final body = currentItem != null
        ? 'Current: $currentItem ($completed/$total)'
        : 'Completed $completed of $total items';

    await _notifications.show(
      extractionProgressId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'extraction_progress',
          'Extraction Progress',
          channelDescription: 'Shows progress of item extraction',
          importance: Importance.low,
          priority: Priority.low,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          ongoing: true,
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: true,
          subtitle: body,
        ),
      ),
      payload: 'extraction_progress:$jobId',
    );
  }

  /// Show extraction complete notification
  Future<void> showExtractionComplete({
    required String jobId,
    required int itemCount,
    bool success = true,
  }) async {
    if (!isEnabled.value) return;

    // Cancel progress notification
    await _notifications.cancel(extractionProgressId);

    final title = success ? 'Items Ready!' : 'Extraction Failed';
    final body = success
        ? '$itemCount item${itemCount != 1 ? 's' : ''} ready to add to your wardrobe'
        : 'Could not extract items from photo';

    await _notifications.show(
      extractionCompleteId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'extraction_complete',
          'Extraction Complete',
          channelDescription: 'Notifies when extraction is complete',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          subtitle: body,
        ),
      ),
      payload: 'extraction_complete:$jobId',
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel extraction progress notification
  Future<void> cancelExtractionProgress() async {
    await _notifications.cancel(extractionProgressId);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final parts = payload.split(':');
    if (parts.length != 2) return;

    final type = parts[0];
    final jobId = parts[1];

    switch (type) {
      case 'extraction_progress':
      case 'extraction_complete':
        // Navigate to item add page with job ID
        // The app should check if job is complete and show results
        Get.toNamed('/wardrobe/item-add', arguments: {'resumeJobId': jobId});
        break;
    }
  }

  /// Enable background notifications
  Future<void> enableBackgroundMode() async {
    if (!isInitialized.value) {
      await init();
    }

    if (!isEnabled.value) {
      final granted = await requestPermissions();
      if (!granted) {
        Get.snackbar(
          'Permission Required',
          'Please enable notifications to use background mode',
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  /// Disable background notifications
  Future<void> disableBackgroundMode() async {
    await cancelAll();
    isEnabled.value = false;
  }
}

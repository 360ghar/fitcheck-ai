import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// OS-level alerts for extraction jobs that finish while the user is
/// elsewhere. In-app toasts stay in `ErrorHandler`; this service owns the
/// notification shade only.
///
/// Kill semantics, stated plainly: Dart code cannot run after the OS kills
/// the process, so a job that finishes while the app is dead notifies on the
/// NEXT launch instead — the jobs registry detects the terminal state during
/// restore and calls [showFinishedWhileAway]. No push infrastructure needed.
class JobNotifications {
  JobNotifications._();

  static final JobNotifications instance = JobNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  bool _permissionsRequested = false;

  /// Payloads the registry emits. `jobs` opens the activity list;
  /// `job:<id>` opens it too (the list highlights the job).
  static const String jobsPayload = 'jobs';

  static String jobPayload(String jobId) => 'job:$jobId';

  /// Notification ids are 32-bit signed on Android: mask to 31 bits. The
  /// "finished while away" id differs so it never replaces a live one.
  @visibleForTesting
  static int idFor(String jobId, {bool away = false}) =>
      (away ? jobId.hashCode ^ 0x1e3779b9 : jobId.hashCode) & 0x7fffffff;

  Future<void> init({required void Function(String? payload) onTap}) async {
    if (_ready) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      // Permission is asked in context by [requestPermissions], never here.
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
      );
      const settings = InitializationSettings(
        android: android,
        iOS: darwin,
      );
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) =>
            onTap(response.payload),
      );
      _ready = true;
    } catch (e) {
      debugPrint('JobNotifications init failed: $e');
    }
  }

  /// Asks for shade permission in context (first tracked job), never at
  /// startup. Safe to call repeatedly; runs once.
  Future<void> requestPermissions() async {
    if (!_ready || _permissionsRequested) return;
    _permissionsRequested = true;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('JobNotifications permission request failed: $e');
    }
  }

  Future<void> showJobComplete({
    required String jobId,
    required String title,
    required String body,
  }) => _show(
    id: idFor(jobId),
    title: title,
    body: body,
    payload: jobPayload(jobId),
  );

  Future<void> showJobFailed({
    required String jobId,
    required String title,
    required String body,
  }) => _show(
    id: idFor(jobId),
    title: title,
    body: body,
    payload: jobPayload(jobId),
  );

  /// A job that reached its terminal state while the process was dead.
  Future<void> showFinishedWhileAway({
    required String jobId,
    required String title,
    required String body,
  }) => _show(
    id: idFor(jobId, away: true),
    title: title,
    body: body,
    payload: jobPayload(jobId),
  );

  Future<void> _show({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    if (!_ready) return;
    try {
      const android = AndroidNotificationDetails(
        'extraction_jobs',
        'Wardrobe scans',
        channelDescription: 'Alerts when a wardrobe scan finishes.',
        importance: Importance.defaultImportance,
      );
      const darwin = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: android,
        iOS: darwin,
      );
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('JobNotifications show failed: $e');
    }
  }
}

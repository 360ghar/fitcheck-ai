import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Two invariants that only hold structurally.
///
/// Before this, the app had two snackbar stacks that built the identical
/// widget -- `ErrorHandler.show*` and `NotificationService.show*` -- plus ~180
/// raw `Get.snackbar` calls bypassing both. Only `ErrorHandler` reported to
/// Sentry/PostHog, so every error raised through the other two paths was
/// invisible to the team until a user complained. Consolidating fixes it once;
/// these tests are what stop it drifting back apart.
void main() {
  final lib = Directory('lib');

  Iterable<File> dartFiles() => lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where(
        (f) => !f.path.endsWith('.g.dart') && !f.path.endsWith('.freezed.dart'),
      );

  test('snackbars are only built by NotificationService.present', () {
    final offenders = <String>[];
    for (final f in dartFiles()) {
      if (f.path.endsWith('core/services/notification_service.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('Get.snackbar(') ||
            lines[i].contains('.showSnackBar(')) {
          offenders.add('  ${f.path}:${i + 1}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Build snackbars through ErrorHandler (showError / showValidation /\n'
          'showSuccess / showInfo / showWarning) so failures reach telemetry and\n'
          'every toast looks the same. Raw snackbar found at:\n'
          '${offenders.join('\n')}',
    );
  });

  test(
    'errors are not stringified by hand instead of ErrorHandler.extractMessage',
    () {
      // `e.toString()` leaks a literal "Exception: " prefix into the UI, and the
      // `.replaceAll('Exception: ', '')` workaround was pasted 76 times rather
      // than calling the helper that already handles AppException, DioException,
      // Exception and String correctly.
      final offenders = <String>[];
      for (final f in dartFiles()) {
        if (f.path.endsWith('core/utils/error_handler.dart')) continue;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final l = lines[i];
          if (l.contains("toString().replaceAll('Exception: '") ||
              l.contains("toString().replaceFirst('Exception: '") ||
              RegExp(
                r'\berror\w*\.value\s*=\s*\w+\.toString\(\);',
              ).hasMatch(l)) {
            offenders.add('  ${f.path}:${i + 1}');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            'Use ErrorHandler.extractMessage(e). Found at:\n${offenders.join('\n')}',
      );
    },
  );

  test('no GetX: state is Riverpod, routing is go_router', () {
    final offenders = [
      for (final f in dartFiles())
        if (f.readAsStringSync().contains('package:get/')) '  ${f.path}',
    ];
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('colours come from the paper tokens', () {
    // White and black stay for content over photos and scrims. The bounding
    // box painter needs many distinct hues for overlapping detections.
    final allowed = RegExp(r'^((white|black)\d*|transparent|length)$');
    final hue = RegExp(r'\bColors\.(\w+)');
    final literal = RegExp(r'\bColor(\(0x|\.fromARGB|\.fromRGBO)');
    final offenders = <String>[];
    for (final f in dartFiles()) {
      final path = f.path.replaceAll(r'\', '/');
      if (path.contains('lib/core/theme/') ||
          path.endsWith('bounding_box_painter.dart') ||
          path.endsWith('google_mark.dart')) {
        continue;
      }
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final l = lines[i];
        final bad = hue
            .allMatches(l)
            .any((m) => !allowed.hasMatch(m.group(1)!));
        if (bad || literal.hasMatch(l)) offenders.add('  $path:${i + 1}');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'Use PaperTokens.of(context) instead:\n${offenders.join('\n')}',
    );
  });
}

import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/widgets/report_content_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);
  for (final dark in [false, true]) {
    testWidgets('report remains scrollable above keyboard, dark=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              viewInsets: const EdgeInsets.only(bottom: 260),
              textScaler: TextScaler.linear(2),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: TextButton(
              onPressed: () => showReportContentSheet(
                contentType: 'outfit',
                contentId: 'fixture',
              ),
              child: const Text('Report'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final viewport = tester.getRect(find.byType(SingleChildScrollView));
      expect(
        viewport.height,
        greaterThan(280),
        reason: 'keyboard inset must only apply once',
      );
      await tester.ensureVisible(find.text('Submit Report'));
      await tester.pumpAndSettle();
      final action = tester.getRect(find.text('Submit Report'));
      expect(action.bottom, lessThanOrEqualTo(380));
      expect(action.top, greaterThanOrEqualTo(viewport.top));
      // Dismiss without sending a real report.
      Get.back<void>();
      await tester.pumpAndSettle();
    });
  }
}

// Fit Check AI widget tests
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';

import 'package:fitcheck_ai/main.dart';
import 'package:fitcheck_ai/core/services/theme_service.dart';
import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/core/widgets/app_image_viewer.dart';
import 'package:fitcheck_ai/features/settings/models/user_preferences_model.dart';

class _Network extends NetworkService {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(Get.reset);
    Get.put<NetworkService>(_Network());
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitCheckApp());

    // Verify that app launches without crashing
    expect(find.byType(MaterialApp), findsOneWidget);

    // Let the splash page's post-init navigation timer complete so the
    // widget tree has no pending timers when the test tears down.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Entry and shell pages have no AppBar to supply system icon brightness.
    // Verify the actual platform style follows the same runtime theme as pages.
    final service = Get.find<ThemeService>();
    for (final mode in [AppThemeMode.dark, AppThemeMode.light]) {
      await service.setThemeMode(mode);
      await tester.pumpAndSettle();
      expect(
        SystemChrome.latestStyle?.statusBarIconBrightness,
        mode == AppThemeMode.dark ? Brightness.light : Brightness.dark,
      );
      expect(
        SystemChrome.latestStyle?.systemNavigationBarIconBrightness,
        mode == AppThemeMode.dark ? Brightness.light : Brightness.dark,
      );
      const photo =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNgAAIAAAUAAXpeqz8AAAAASUVORK5CYII=';
      final context = tester.element(find.byType(Scaffold).last);
      AppImageViewer.show(context, imageUrls: const [photo]);
      await tester.pump();
      final image = tester.widget<PhotoView>(find.byType(PhotoView));
      await tester.runAsync(() => precacheImage(image.imageProvider!, context));
      await tester.pumpAndSettle();
      expect(
        SystemChrome.latestStyle?.statusBarIconBrightness,
        Brightness.light,
      );
      await tester.tap(find.byTooltip('Close image viewer'));
      await tester.pumpAndSettle();
      expect(
        SystemChrome.latestStyle?.statusBarIconBrightness,
        mode == AppThemeMode.dark ? Brightness.light : Brightness.dark,
      );
      expect(
        SystemChrome.latestStyle?.systemNavigationBarIconBrightness,
        mode == AppThemeMode.dark ? Brightness.light : Brightness.dark,
      );
    }
  });
}

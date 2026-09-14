import 'dart:convert';
import 'dart:io';
import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/features/photoshoot/controllers/photoshoot_controller.dart';
import 'package:fitcheck_ai/features/photoshoot/models/photoshoot_models.dart';
import 'package:fitcheck_ai/features/photoshoot/views/photoshoot_results_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Photoshoot extends PhotoshootController {
  final downloads = <int>[];
  @override
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> downloadImage(int index) async => downloads.add(index);
}

void main() {
  late _Photoshoot controller;
  setUp(() {
    controller = _Photoshoot();
    controller.generatedImages.add(
      GeneratedImage(
        id: 'fixture',
        index: 0,
        imageBase64: base64Encode(
          File('test/fixtures/outfit.webp').readAsBytesSync(),
        ),
      ),
    );
    Get.put<PhotoshootController>(controller);
  });
  tearDown(Get.reset);

  Future<void> show(
    WidgetTester tester, {
    double width = 390,
    double scale = 1,
    bool dark = false,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const Scaffold(body: PhotoshootResultsStep()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'photo download action is not intercepted by full-screen preview',
    (tester) async {
      await show(tester);
      await tester.tap(find.byIcon(Icons.download).last);
      await tester.pump();
      expect(controller.downloads, [0]);
      expect(find.byType(Dialog), findsNothing);
    },
  );
  for (final dark in [false, true]) {
    testWidgets('partial results and retries fit large text, dark=$dark', (
      tester,
    ) async {
      controller.failedIndices.add(1);
      controller.failedCount.value = 1;
      controller.partialSuccess.value = true;
      await show(tester, width: 320, scale: 2, dark: dark);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('Retry'), 300);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Retry').hitTestable(), findsOneWidget);
    });
  }
}

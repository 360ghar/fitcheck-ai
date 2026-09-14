// Fixed state avoids platform pickers and network initialization in view tests.
// ignore_for_file: must_call_super
import 'dart:io';
import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/features/photoshoot/controllers/photoshoot_controller.dart';
import 'package:fitcheck_ai/features/photoshoot/models/photoshoot_models.dart';
import 'package:fitcheck_ai/features/shell/controllers/main_shell_controller.dart';
import 'package:fitcheck_ai/features/shell/views/studio_content.dart';
import 'package:fitcheck_ai/features/tryon/controllers/tryon_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Photoshoot extends PhotoshootController {
  @override
  void onInit() {}
  @override
  Future<void> pickPhotos() async {
    selectedPhotos.add(File('assets/images/studio-example.webp'));
  }
}

class _TryOn extends TryOnController {
  @override
  void onInit() {}
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(MainShellController(initialTab: 3));
    Get.put<PhotoshootController>(_Photoshoot());
    Get.put<TryOnController>(_TryOn());
  });
  tearDown(Get.reset);

  Future<void> pumpStudio(
    WidgetTester tester,
    bool dark,
    ValueNotifier<double> inset,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => ValueListenableBuilder<double>(
          valueListenable: inset,
          builder: (context, bottom, _) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(2),
              viewInsets: EdgeInsets.only(bottom: bottom),
              disableAnimations: true,
            ),
            child: child!,
          ),
        ),
        home: const Scaffold(body: StudioContent()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  for (final dark in [false, true]) {
    testWidgets(
      'photo upload, style and keyboard stay usable at 320px/200%, dark=$dark',
      (tester) async {
        final inset = ValueNotifier<double>(0);
        addTearDown(inset.dispose);
        await pumpStudio(tester, dark, inset);
        expect(find.text('Example photo'), findsOneWidget);
        await tester.ensureVisible(find.text('Add photos').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add photos').last);
        await tester.pumpAndSettle();
        expect(find.text('Your photo set'), findsOneWidget);
        expect(find.text('Example photo'), findsNothing);
        await tester.ensureVisible(find.text('Choose your style'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Choose your style'));
        await tester.pumpAndSettle();
        final controller = Get.find<PhotoshootController>();
        expect(controller.currentStep.value, PhotoshootStep.configure);
        await tester.ensureVisible(find.text(PhotoshootUseCase.custom.label));
        await tester.pumpAndSettle();
        await tester.tap(find.text(PhotoshootUseCase.custom.label));
        await tester.pumpAndSettle();
        inset.value = 260;
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(TextField));
        await tester.enterText(
          find.byType(TextField),
          'A portrait in natural light',
        );
        await tester.pumpAndSettle();
        expect(
          controller.customPromptController.text,
          'A portrait in natural light',
        );
        await tester.ensureVisible(
          find.text('Generate ${controller.numImages.value} Images'),
        );
        await tester.pumpAndSettle();
        expect(
          find
              .text('Generate ${controller.numImages.value} Images')
              .hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('try-on sources and options scroll at 320px/200%, dark=$dark', (
      tester,
    ) async {
      final inset = ValueNotifier<double>(0);
      addTearDown(inset.dispose);
      await pumpStudio(tester, dark, inset);
      await tester.tap(find.text('Try-on'));
      await tester.pumpAndSettle();
      for (final label in [
        'Add photo',
        'Choose from closet',
        'Photos',
        'Camera',
        'Generate try-on',
      ]) {
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();
        expect(find.text(label).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
      expect(Get.find<TryOnController>().isGenerating.value, isFalse);
    });
  }
}

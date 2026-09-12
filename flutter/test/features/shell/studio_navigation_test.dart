import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/features/photoshoot/controllers/photoshoot_controller.dart';
import 'package:fitcheck_ai/features/photoshoot/views/photoshoot_content.dart';
import 'package:fitcheck_ai/features/shell/controllers/main_shell_controller.dart';
import 'package:fitcheck_ai/features/shell/views/main_shell_page.dart';
import 'package:fitcheck_ai/features/shell/views/studio_content.dart';
import 'package:fitcheck_ai/features/tryon/controllers/tryon_controller.dart';
import 'package:fitcheck_ai/features/tryon/views/tryon_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Photoshoot extends PhotoshootController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _TryOn extends TryOnController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  setUp(Get.reset);
  tearDown(Get.reset);

  void registerStudio() {
    Get.put(MainShellController(initialTab: 3));
    Get.lazyPut<PhotoshootController>(() => _Photoshoot());
    Get.lazyPut<TryOnController>(() => _TryOn());
  }

  testWidgets(
    'Studio loads tools lazily, keeps state and disables hidden tickers',
    (tester) async {
      registerStudio();
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: StudioContent()),
        ),
      );
      await tester.pumpAndSettle();
      expect(Get.isPrepared<TryOnController>(), isTrue);
      final photoshootElement = tester.element(find.byType(PhotoshootContent));
      final photoshoot = Get.find<PhotoshootController>();
      photoshoot.customPromptController.text = 'Keep this styling idea';
      await tester.tap(find.text('Try-on'));
      await tester.pumpAndSettle();
      final tryOnElement = tester.element(find.byType(TryOnContent));
      final tryOn = Get.find<TryOnController>();
      tryOn.selectedStyle.value = 'formal';
      await tester.pump();
      expect(TickerMode.valuesOf(photoshootElement).enabled, isFalse);
      expect(TickerMode.valuesOf(tryOnElement).enabled, isTrue);
      await tester.tap(find.text('Photoshoot'));
      await tester.pumpAndSettle();
      expect(
        tester.element(find.byType(PhotoshootContent)),
        same(photoshootElement),
      );
      expect(photoshoot.customPromptController.text, 'Keep this styling idea');
      expect(TickerMode.valuesOf(tryOnElement).enabled, isFalse);
      await tester.tap(find.text('Try-on'));
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(TryOnContent)), same(tryOnElement));
      expect(tryOn.selectedStyle.value, 'formal');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Studio fits 320px and 200% text; wide shell uses a rail', (
    tester,
  ) async {
    registerStudio();
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const MainShellPage(initialTab: 3, initialStudioTool: 1),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
    final retainedTool = tester.element(find.byType(TryOnContent));
    tester.view.physicalSize = const Size(1024, 600);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.element(find.byType(TryOnContent)), same(retainedTool));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'native Back returns from a pushed Studio route without clearing history',
    (tester) async {
      registerStudio();
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MainShellPage(
                      initialTab: 3,
                      initialStudioTool: 1,
                    ),
                  ),
                ),
                child: const Text('Open Studio'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open Studio'));
      await tester.pumpAndSettle();
      expect(find.byType(MainShellPage), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Open Studio'), findsOneWidget);
      expect(find.byType(MainShellPage), findsNothing);
      expect(Get.find<MainShellController>().studioTool.value, 1);
    },
  );

  test('logout resets all destinations and Studio selections', () {
    final shell = MainShellController();
    shell.changeTab(1);
    shell.changeTab(3);
    shell.changeStudioTool(1);
    expect(shell.loadedTabs, containsAll([0, 1, 3]));
    expect(shell.loadedStudioTools, containsAll([0, 1]));
    shell.resetForNewSession();
    expect(shell.currentIndex.value, 0);
    expect(shell.loadedTabs, {0});
    expect(shell.studioTool.value, 0);
    expect(shell.loadedStudioTools, {0});
  });
}

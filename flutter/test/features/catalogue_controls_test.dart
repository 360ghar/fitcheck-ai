import 'dart:ui' show SemanticsAction;

import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/core/widgets/app_ui.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/outfits/controllers/outfit_generation_controller.dart';
import 'package:fitcheck_ai/features/outfits/controllers/outfit_list_controller.dart';
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:fitcheck_ai/features/outfits/views/outfits_content.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/wardrobe_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/views/wardrobe_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Network extends NetworkService {
  @override
  // These fixtures do not start platform listeners or network requests.
  // ignore: must_call_super
  void onInit() {}
}

class _Wardrobe extends WardrobeController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Outfits extends OutfitListController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

const _pixel =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNgAAIAAAUAAXpeqz8AAAAASUVORK5CYII=';
const _item = ItemModel(
  id: 'shirt',
  userId: 'user',
  name: 'Cotton shirt',
  category: Category.tops,
  condition: domain.Condition.clean,
  itemImages: [ItemImage(id: 'photo', url: _pixel)],
);

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<NetworkService>(_Network());
    Get.put<WardrobeController>(
      _Wardrobe()
        ..hasMore.value = false
        ..totalItems.value = 1
        ..items.add(_item),
    );
    Get.put<OutfitListController>(_Outfits()..hasMore.value = false);
    Get.put<OutfitGenerationController>(OutfitGenerationController());
  });
  tearDown(() => Get.reset());

  Future<void> pump(
    WidgetTester tester,
    Widget body, {
    bool largeText = false,
    double width = 320,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: largeText ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(largeText ? 2 : 1),
            disableAnimations: true,
          ),
          child: child!,
        ),
        getPages: [
          GetPage(
            name: '/wardrobe/:id',
            page: () => const Scaffold(body: Text('Item detail')),
          ),
        ],
        home: Scaffold(body: body),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  testWidgets('closet search stays in sync after clearing filters', (
    tester,
  ) async {
    final controller = Get.find<WardrobeController>();
    controller.searchQuery.value = 'cotton';
    controller.selectedCategories.add(Category.tops);
    await pump(tester, const WardrobeContent());
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'cotton');
    // Categories remain available even when absent from the current page.
    expect(find.widgetWithText(FilterChip, 'Shoes'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'linen');
    expect(controller.searchQuery.value, 'linen');
    controller.clearAllFilters();
    await tester.pump();
    expect(field.controller!.text, isEmpty);
    expect(find.byTooltip('Clear search'), findsNothing);
  });

  for (final mode in ['grid', 'list']) {
    testWidgets('closet $mode shows only the primary image and semantic name', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        final controller = Get.find<WardrobeController>();
        controller.viewMode.value = mode;
        controller.items.assignAll([
          _item.copyWith(
            brand: 'Fixture brand',
            description: 'Fixture description',
            isFavorite: true,
            itemImages: const [
              ItemImage(
                id: 'original',
                url: _pixel,
                storagePath: 'original.png',
              ),
              ItemImage(
                id: 'primary',
                url: _pixel,
                storagePath: 'cutout.png',
                isPrimary: true,
              ),
            ],
          ),
        ]);
        await pump(tester, const WardrobeContent());
        final tile = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Closet item: Cotton shirt',
        );
        expect(tile, findsOneWidget);
        expect(
          find.descendant(of: tile, matching: find.byType(Text)),
          findsNothing,
        );
        expect(
          find.descendant(of: tile, matching: find.byIcon(Icons.favorite)),
          findsNothing,
        );
        final data = tester.getSemantics(tile).getSemanticsData();
        expect(data.hasAction(SemanticsAction.tap), isTrue);
        expect(data.hasAction(SemanticsAction.longPress), isTrue);
        final photo = tester.widget<AppImage>(find.byType(AppImage));
        expect(photo.storagePath, 'cutout.png');
        expect(photo.imageUrl, _pixel);
        expect(photo.fallbackUrl, _pixel);
        expect(photo.remintUrl, isNotNull);
        expect(photo.backgroundColor, Colors.transparent);
        expect(photo.fit, BoxFit.contain);
        expect(photo.enableZoom, isFalse);
        // No opaque box or frame can obscure transparent garment pixels.
        for (final box in tester.widgetList<Container>(
          find.descendant(of: tile, matching: find.byType(Container)),
        )) {
          expect(box.color == null || box.color!.a == 0, isTrue);
          expect(box.decoration, isNull);
        }
        await tester.tap(find.byType(AppImage));
        await tester.pumpAndSettle();
        expect(Get.currentRoute, '/wardrobe/shirt');
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        semantics.dispose();
      }
    });
  }

  testWidgets('closet exposes transparent loading and missing-image states', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      final controller = Get.find<WardrobeController>();
      controller.items.assignAll([
        _item.copyWith(
          itemImages: const [
            ItemImage(id: 'pending', url: 'https://fixture.invalid/item.png'),
          ],
        ),
      ]);
      await pump(tester, const WardrobeContent());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Loading item image')),
        findsOneWidget,
      );
      expect(
        tester.widget<AppImage>(find.byType(AppImage)).backgroundColor,
        Colors.transparent,
      );
      controller.items.assignAll([
        _item.copyWith(
          itemImages: const [ItemImage(id: 'missing', url: '')],
        ),
      ]);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        find.bySemanticsLabel(RegExp('Image unavailable')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('closet long press preserves item actions and selection', (
    tester,
  ) async {
    final controller = Get.find<WardrobeController>();
    controller.items.assignAll([
      _item.copyWith(isFavorite: true),
      _item.copyWith(id: 'second', name: 'Second shirt'),
    ]);
    await pump(tester, const WardrobeContent(), largeText: true);
    expect(find.byIcon(Icons.favorite), findsNothing);
    await tester.longPress(find.byType(AppImage).first);
    await tester.pumpAndSettle();
    expect(find.text('Remove from Favorites'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    await tester.tap(find.text('Select item'));
    await tester.pumpAndSettle();
    expect(controller.selectedIds, contains('shirt'));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byTooltip('Delete selected'), findsOneWidget);
    await tester.tap(find.byType(AppImage).at(1));
    await tester.pump();
    expect(controller.selectedIds, containsAll(['shirt', 'second']));
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    await tester.tap(find.byType(AppImage).first);
    await tester.pump();
    expect(controller.selectedIds, {'second'});
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    controller.clearSelection();
    await tester.pump();
    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  testWidgets('image-only grid keeps two phone columns at 200 percent text', (
    tester,
  ) async {
    final controller = Get.find<WardrobeController>();
    controller.items.add(_item.copyWith(id: 'second', name: 'Second shirt'));
    await pump(tester, const WardrobeContent(), largeText: true);
    final photos = find.byType(AppImage);
    expect(photos, findsNWidgets(2));
    final first = tester.getRect(photos.at(0));
    final second = tester.getRect(photos.at(1));
    expect(first.top, second.top);
    expect(first.right, lessThan(second.left));
    expect(first.width, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
    controller.viewMode.value = 'list';
    tester.view.physicalSize = const Size(1024, 844);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(AppImage).first).width,
      lessThanOrEqualTo(360),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('lookbook filters clear the visible search field', (
    tester,
  ) async {
    final controller = Get.find<OutfitListController>();
    await pump(tester, const OutfitsContent());
    await tester.enterText(find.byType(TextField), 'weekend');
    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Drafts'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Drafts'));
    await tester.pump();
    expect(controller.searchQuery.value, 'weekend');
    expect(controller.draftsOnly.value, isTrue);
    await tester.ensureVisible(find.widgetWithText(FilterChip, 'All looks'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'All looks'));
    await tester.pump();
    expect(controller.draftsOnly.value, isFalse);
    expect(controller.searchQuery.value, isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('saved outfit composes at most four existing item photos', (
    tester,
  ) async {
    Get.find<OutfitListController>().outfits.add(
      OutfitModel(
        id: 'look',
        userId: 'user',
        name: 'Weekend edit',
        itemIds: List.generate(5, (index) => '$index'),
        items: List.generate(5, (index) => _item.copyWith(id: '$index')),
      ),
    );
    await pump(tester, const OutfitsContent());
    expect(find.byType(AppImage), findsNWidgets(4));
    expect(find.text('5 pieces'), findsOneWidget);
    for (final image in tester.widgetList<AppImage>(find.byType(AppImage))) {
      expect(image.fit, BoxFit.contain);
      expect(image.enableZoom, isFalse);
    }
  });

  testWidgets('filtered empty collections recover at 320px and 200 percent', (
    tester,
  ) async {
    Get.find<WardrobeController>()
      ..items.clear()
      ..searchQuery.value = 'missing';
    Get.find<OutfitListController>().searchQuery.value = 'missing';
    for (final body in [const WardrobeContent(), const OutfitsContent()]) {
      await pump(tester, body, largeText: true);
      await tester.ensureVisible(find.text('Clear filters'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Clear filters'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}

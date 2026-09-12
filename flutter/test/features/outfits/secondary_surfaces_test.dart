import 'dart:async';

import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/features/outfits/controllers/outfit_generation_controller.dart';
import 'package:fitcheck_ai/features/outfits/controllers/outfit_list_controller.dart';
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:fitcheck_ai/features/outfits/repositories/outfit_repository.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_collections_page.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_detail_page.dart';
import 'package:fitcheck_ai/features/outfits/views/outfits_content.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/wardrobe_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/views/wardrobe_stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Network extends NetworkService {
  @override
  // Skip platform listeners in UI fixtures.
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
  @override
  Future<void> refreshOutfitById(String id) async {}
}

class _Collections extends OutfitRepository {
  _Collections({this.empty = false, this.fail = false});
  final bool empty;
  final bool fail;
  @override
  Future<List<Map<String, dynamic>>> getCollections() async {
    if (fail) throw Exception('Connection lost. Reconnect and try again.');
    return empty
        ? []
        : [
            {
              'id': 'collection',
              'name': 'Weekend looks',
              'outfit_ids': <String>[],
            },
          ];
  }
}

class _PendingCollections extends _Collections {
  final response = Completer<OutfitsListResponse>();

  @override
  Future<OutfitsListResponse> getOutfits({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? styles,
    List<String>? seasons,
    bool? favoritesOnly,
    bool? draftsOnly,
  }) => response.future;
}

class _Stats extends ItemRepository {
  @override
  Future<Map<String, dynamic>> getStatistics() async =>
      throw Exception('Connection lost. Reconnect and try again.');
}

const _outfit = OutfitModel(
  id: 'outfit',
  userId: 'user',
  name: 'Weekend edit',
  itemIds: [],
  wornCount: 6,
);

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<NetworkService>(_Network());
    Get.put<WardrobeController>(_Wardrobe());
    Get.put<OutfitListController>(
      _Outfits()
        ..hasMore.value = false
        ..outfits.add(_outfit)
        ..wearHistoryCache['outfit'] = List.generate(
          6,
          (i) => WearHistoryEntry(
            id: '$i',
            outfitId: 'outfit',
            wornAt: DateTime(2026, 8, i + 1),
          ),
        ),
    );
    Get.put<OutfitGenerationController>(OutfitGenerationController());
  });
  tearDown(() => Get.reset());

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    double scale = 2,
  }) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 500));
    });
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.darkTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: page),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('outfit quick actions remain usable at 200 percent text', (
    tester,
  ) async {
    await pump(tester, const OutfitsContent());
    final tile = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Outfit: Weekend edit',
    );
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.longPress(tile);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Outfit?'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'collection options and details remain reachable at 200 percent',
    (tester) async {
      await pump(tester, OutfitCollectionsPage(repository: _Collections()));
      await tester.tap(find.byTooltip('Options for Weekend looks'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('View Collection'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Collection?'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    },
  );

  for (final fail in [false, true]) {
    testWidgets(
      'collection ${fail ? 'error' : 'empty'} state scrolls at 200 percent',
      (tester) async {
        await pump(
          tester,
          OutfitCollectionsPage(
            repository: _Collections(empty: !fail, fail: fail),
          ),
        );
        final action = find.text(fail ? 'Retry' : 'Create Collection');
        await tester.ensureVisible(action);
        await tester.pumpAndSettle();
        expect(tester.getRect(action).bottom, lessThanOrEqualTo(640));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('statistics retry remains reachable at 200 percent', (
    tester,
  ) async {
    await pump(tester, WardrobeStatsPage(repository: _Stats()));
    await tester.ensureVisible(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Retry')).bottom, lessThanOrEqualTo(640));
    expect(tester.takeException(), isNull);
  });

  testWidgets('collection form scrolls above the keyboard at 200 percent', (
    tester,
  ) async {
    await pump(tester, OutfitCollectionsPage(repository: _Collections()));
    await tester.tap(find.text('New Collection'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(
      find.widgetWithText(TextField, 'Description (optional)'),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'closing a focused collection form keeps its exit transition valid',
    (tester) async {
      await pump(
        tester,
        OutfitCollectionsPage(repository: _Collections()),
        scale: 1,
      );
      await tester.tap(find.text('New Collection'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Collection Name'),
        'Test',
      );
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'edit collection scrolls with keyboard and closes without early disposal',
    (tester) async {
      await pump(tester, OutfitCollectionsPage(repository: _Collections()));
      await tester.tap(find.byTooltip('Options for Weekend looks'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Edit Collection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Collection'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(
        find.widgetWithText(TextField, 'Collection Name'),
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Collection Name'),
        'Edited',
      );
      await tester.ensureVisible(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('collection chooser does not open after leaving its page', (
    tester,
  ) async {
    final repository = _PendingCollections();
    await pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OutfitCollectionsPage(repository: repository),
            ),
          ),
          child: const Text('Open collections'),
        ),
      ),
      scale: 1,
    );
    await tester.tap(find.text('Open collections'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekend looks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Outfits'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(OutfitCollectionsPage))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Open collections'), findsOneWidget);
    repository.response.complete(
      const OutfitsListResponse(
        outfits: [],
        total: 0,
        page: 1,
        limit: 100,
        hasMore: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'full wear history has an accessible close action at 200 percent',
    (tester) async {
      await pump(tester, const OutfitDetailPage(outfitId: 'outfit'));
      await tester.ensureVisible(find.text('View all 6 entries'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View all 6 entries'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Full Wear History'), findsOneWidget);
      expect(find.byTooltip('Close wear history'), findsOneWidget);
    },
  );
}

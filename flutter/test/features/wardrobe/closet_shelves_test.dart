import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/core/services/notification_service.dart'
    show scaffoldMessengerKey;
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/wardrobe_providers.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/views/wardrobe_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ItemModel piece(String id, Category category) => ItemModel(
  id: id,
  userId: 'user-1',
  name: 'Piece $id',
  category: category,
  condition: domain.Condition.clean,
);

/// Answers getItems from [items], filtered by category like the API.
class ShelfRepository extends ItemRepository {
  ShelfRepository(this.items);

  List<ItemModel> items;

  @override
  Future<ItemsListResponse> getItems({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? categories,
    List<String>? colors,
    String? occasion,
    List<String>? conditions,
    bool? isFavorite,
    String? sortBy,
    String? sortOrder,
  }) async {
    final matches = [
      for (final i in items)
        if (categories == null || categories.contains(i.category.name)) i,
    ];
    return ItemsListResponse(
      items: matches,
      total: matches.length,
      page: 1,
      limit: limit,
      hasMore: false,
    );
  }

  @override
  Future<void> deleteItem(String itemId) async => items = [
    for (final i in items)
      if (i.id != itemId) i,
  ];
}

final closet = [
  piece('t1', Category.tops),
  piece('t2', Category.tops),
  piece('b1', Category.bottoms),
  piece('s1', Category.shoes),
  piece('a1', Category.accessories),
];

void main() {
  group('closet rows', () {
    Future<void> pumpCloset(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          retry: noRetry,
          overrides: [
            itemRepositoryProvider.overrideWithValue(ShelfRepository(closet)),
          ],
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 1600),
              disableAnimations: true,
            ),
            child: MaterialApp(
              scaffoldMessengerKey: scaffoldMessengerKey,
              home: const Scaffold(body: WardrobeContent()),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('one row per non-empty category, in dressing order', (
      tester,
    ) async {
      await pumpCloset(tester);
      final labels = [
        find.text('Tops  2'),
        find.text('Bottoms  1'),
        find.text('Accessories  1'),
        find.text('Shoes  1'),
      ];
      for (final label in labels) {
        expect(label, findsOneWidget);
      }
      final tops = [for (final l in labels) tester.getTopLeft(l).dy];
      expect(tops, [...tops]..sort());
      expect(find.textContaining('Outerwear  '), findsNothing);
    });

    testWidgets('a row holds only its category', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpCloset(tester);
      final t1 = tester.getCenter(find.bySemanticsLabel('Piece t1')).dy;
      final t2 = tester.getCenter(find.bySemanticsLabel('Piece t2')).dy;
      final b1 = tester.getCenter(find.bySemanticsLabel('Piece b1')).dy;
      expect(t1, t2);
      expect(b1, greaterThan(t1));
      // Image-only cells: no names are drawn in the rows.
      expect(find.text('Piece t1'), findsNothing);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Piece t1')),
        matchesSemantics(
          label: 'Piece t1',
          isButton: true,
          hasSelectedState: true,
          hasTapAction: true,
          hasLongPressAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('a category chip shows the grid of matches', (tester) async {
      await pumpCloset(tester);
      await tester.tap(find.widgetWithText(FilterChip, 'Tops'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Tops  2'), findsNothing);
      expect(find.text('Piece t1'), findsOneWidget);
      expect(find.text('Piece b1'), findsNothing);
    });

    testWidgets('the view button cycles rows, grid, list', (tester) async {
      await pumpCloset(tester);
      await tester.tap(find.byTooltip('Show as grid'));
      await tester.pump();
      expect(find.text('Tops  2'), findsNothing);
      expect(find.text('Piece t1'), findsOneWidget);

      await tester.tap(find.byTooltip('Show as list'));
      await tester.pump();
      expect(find.byTooltip('Show as rows'), findsOneWidget);

      await tester.tap(find.byTooltip('Show as rows'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Tops  2'), findsOneWidget);
    });
  });

  group('row sync', () {
    late ShelfRepository repo;
    late ProviderContainer container;

    setUp(() {
      repo = ShelfRepository([...closet]);
      container = ProviderContainer(
        retry: noRetry,
        overrides: [itemRepositoryProvider.overrideWithValue(repo)],
      );
    });
    tearDown(() => container.dispose());

    Future<List<ItemModel>> items() async =>
        (await container.read(wardrobeProvider.future)).items;

    Future<void> start() async {
      container.listen(wardrobeProvider, (_, _) {});
      await container.read(wardrobeProvider.future);
    }

    test('an edit that changes the category patches the piece', () async {
      await start();
      final moved = piece('t1', Category.bottoms);
      repo.items = [for (final i in repo.items) i.id == 't1' ? moved : i];

      container.read(wardrobeProvider.notifier).replace(moved);

      expect(
        (await items()).firstWhere((i) => i.id == 't1').category,
        Category.bottoms,
      );
    });

    test('a delete removes the piece from the list', () async {
      await start();

      await container.read(wardrobeProvider.notifier).deleteItem('t2');

      final state = container.read(wardrobeProvider).value!;
      expect([for (final i in state.items) i.id], ['t1', 'b1', 's1', 'a1']);
      expect(state.total, 4);
    });
  });
}

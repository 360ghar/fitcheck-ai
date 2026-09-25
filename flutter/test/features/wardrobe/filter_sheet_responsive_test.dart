import 'package:fitcheck_ai/core/services/notification_service.dart'
    show scaffoldMessengerKey;
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/wardrobe_providers.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/views/wardrobe_content.dart';
import 'package:flutter/material.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// One item, so the closet renders its grid instead of the empty state.
class FakeItemRepository extends ItemRepository {
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
  }) async => ItemsListResponse(
    items: [
      ItemModel(
        id: 'item-1',
        userId: 'user-1',
        name: 'Blue Shirt',
        category: Category.tops,
        condition: domain.Condition.clean,
      ),
    ],
    total: 1,
    page: 1,
    limit: 20,
    hasMore: false,
  );
}

void main() {
  /// Injects a keyboard inset above the app. Animations are off so the
  /// paper scenes hold still and pumpAndSettle can settle.
  late ValueNotifier<bool> keyboardOpen;

  setUp(() => keyboardOpen = ValueNotifier(false));
  tearDown(() => keyboardOpen.dispose());

  Future<void> pumpWardrobe(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: noRetry,
        overrides: [
          itemRepositoryProvider.overrideWithValue(FakeItemRepository()),
        ],
        child: ValueListenableBuilder<bool>(
          valueListenable: keyboardOpen,
          builder: (context, open, child) {
            final base = MediaQuery.of(context);
            return MediaQuery(
              data: base.copyWith(
                disableAnimations: true,
                viewInsets: open
                    ? const EdgeInsets.only(bottom: 400)
                    : base.viewInsets,
              ),
              child: child!,
            );
          },
          child: MaterialApp(
            scaffoldMessengerKey: scaffoldMessengerKey,
            home: const Scaffold(body: WardrobeContent()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openFilterSheet(WidgetTester tester) async {
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Use case'), findsOneWidget);
  }

  testWidgets('Done stays reachable when the keyboard is open', (tester) async {
    await pumpWardrobe(tester);
    await openFilterSheet(tester);

    await tester.enterText(find.byType(TextField).last, 'brunch');
    keyboardOpen.value = true;
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Use case'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a category chip narrows the closet filter', (tester) async {
    await pumpWardrobe(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WardrobeContent)),
    );

    await tester.tap(find.widgetWithText(FilterChip, 'Shoes'));
    await tester.pumpAndSettle();

    expect(
      container.read(wardrobeFiltersProvider).categories,
      {Category.shoes},
    );
  });
}

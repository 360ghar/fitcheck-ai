import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/wardrobe/controllers/wardrobe_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/views/wardrobe_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Test double for [NetworkService] that avoids the connectivity_plus plugin.
class FakeNetworkService extends NetworkService {
  FakeNetworkService({bool connected = true}) {
    isConnected.value = connected;
  }

  @override
  // ignore: must_call_super
  void onInit() {
    // Skip real connectivity subscription.
  }
}

/// Fake [ItemRepository] that never touches the network / Supabase. Seeded
/// with one item so the closet renders its grid instead of the empty state.
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
  }) async {
    return ItemsListResponse(
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeNetworkService fakeNetwork;
  late FakeItemRepository fakeRepo;

  /// Simulates the platform keyboard by injecting a bottom view inset into
  /// [MediaQuery] above the app. The test binding's root view reports zero
  /// insets unconditionally, so the inset is applied at the widget level —
  /// the exact data shape the sheet builder reacts to when a real keyboard
  /// opens.
  late ValueNotifier<bool> keyboardOpen;

  setUp(() {
    Get.reset();
    fakeNetwork = FakeNetworkService(connected: true);
    Get.put<NetworkService>(fakeNetwork);
    fakeRepo = FakeItemRepository();
    Get.put(WardrobeController(itemRepository: fakeRepo));
    keyboardOpen = ValueNotifier<bool>(false);
  });

  tearDown(() {
    keyboardOpen.dispose();
    Get.reset();
  });

  Future<void> pumpWardrobe(WidgetTester tester) async {
    await tester.pumpWidget(
      ValueListenableBuilder<bool>(
        valueListenable: keyboardOpen,
        builder: (context, open, child) {
          final base = MediaQuery.of(context);
          return MediaQuery(
            data: base.copyWith(
              viewInsets: open
                  ? const EdgeInsets.only(bottom: 400)
                  : base.viewInsets,
            ),
            child: child!,
          );
        },
        child: GetMaterialApp(home: Scaffold(body: WardrobeContent())),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Opens the filter sheet through the app-bar overflow menu (the sheet
  /// itself is a private builder on the wardrobe page, so it is exercised
  /// through the public widget).
  Future<void> openFilterSheet(WidgetTester tester) async {
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsOneWidget);
  }

  testWidgets(
    'filter sheet scrolls so Set stays reachable when the keyboard is open',
    (tester) async {
      await pumpWardrobe(tester);
      await openFilterSheet(tester);

      expect(find.text('Set'), findsOneWidget);

      // Focus the custom use-case field.
      await tester.enterText(find.byType(TextField), 'brunch');
      await tester.pump();

      // Open the (simulated) keyboard: GetX's modal bottom-sheet route
      // consumes the inset, shrinking the sheet; the content must become
      // scrollable so the Set button stays reachable.
      keyboardOpen.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final sheetScrollView = find
          .ancestor(
            of: find.text('Set'),
            matching: find.byType(SingleChildScrollView),
          )
          .first;

      // Precondition: Set starts outside the sheet's visible viewport (it
      // would be unreachable without the scrollable content).
      final sheetRectBefore = tester.getRect(sheetScrollView);
      final beforeRect = tester.getRect(find.text('Set'));
      expect(
        beforeRect.bottom,
        greaterThan(sheetRectBefore.bottom),
        reason: 'precondition: Set starts below the sheet viewport',
      );

      final sheetScrollable = tester.state<ScrollableState>(
        find
            .descendant(
              of: sheetScrollView,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      final offsetBefore = sheetScrollable.position.pixels;

      // Scrolling the sheet must bring the Set button into the visible area.
      await tester.ensureVisible(find.text('Set'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        sheetScrollable.position.pixels,
        greaterThan(offsetBefore),
        reason: 'sheet content must actually scroll',
      );

      final sheetRect = tester.getRect(sheetScrollView);
      final setRect = tester.getRect(find.text('Set'));
      expect(setRect.top, greaterThanOrEqualTo(sheetRect.top - 1));
      expect(setRect.bottom, lessThanOrEqualTo(sheetRect.bottom + 1));
      expect(tester.takeException(), isNull);

      // Clean up: dismiss the sheet so the focused field is disposed and the
      // tree is fully torn down before the test ends (keeps the next test's
      // Get registrations isolated). Pump past the deferred controller
      // dispose (350ms) so no timers are left pending.
      await tester.ensureVisible(find.text('Apply'));
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.text('Filters'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );

  testWidgets('filter sheet opens and closes without layout exceptions', (
    tester,
  ) async {
    await pumpWardrobe(tester);
    await openFilterSheet(tester);

    // The whole stack (chips + field + actions) is present and reachable.
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Use Case'), findsOneWidget);
    expect(find.text('Custom use case'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Apply'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Filters'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

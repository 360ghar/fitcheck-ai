import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/wardrobe_providers.dart';
import 'package:flutter/material.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/views/item_detail_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcheck_ai/core/services/notification_service.dart'
    show scaffoldMessengerKey;

/// Fake that fakes both list and single-item endpoints, so detail-page tests
/// can assert the refresh-on-open behaviour without any network.
class FakeItemRepository extends ItemRepository {
  int getItemCalls = 0;
  Future<ItemModel> Function(String itemId)? onGetItem;

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
      items: [item('item-1')],
      total: 1,
      page: 1,
      limit: 20,
      hasMore: false,
    );
  }

  @override
  Future<ItemModel> getItem(String itemId) {
    getItemCalls++;
    return onGetItem?.call(itemId) ?? Future.value(item(itemId));
  }
}

ItemModel item(String id) => ItemModel(
  id: id,
  userId: 'user-1',
  name: id,
  category: Category.tops,
  condition: Condition.clean,
);

void main() {
  /// Loads the closet list first, so the page has a cached copy to show.
  Future<FakeItemRepository> pumpDetail(
    WidgetTester tester,
    Future<ItemModel> Function(String id) onGetItem,
  ) async {
    final repository = FakeItemRepository()..onGetItem = onGetItem;
    final container = ProviderContainer(
      retry: noRetry,
      overrides: [itemRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(wardrobeProvider, (_, _) {});
    await container.read(wardrobeProvider.future);

    // A phone-sized screen: the name sits under a square photo.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: ItemDetailPage(itemId: 'item-1'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    return repository;
  }

  testWidgets('opening a cached item fetches it fresh', (tester) async {
    final repository = await pumpDetail(
      tester,
      (_) async => ItemModel(
        id: 'item-1',
        userId: 'user-1',
        name: 'refreshed-name',
        category: Category.tops,
        condition: Condition.clean,
      ),
    );

    // Image URLs are presigned and expire: the page must not render the
    // cached copy blind.
    expect(repository.getItemCalls, 1);
    expect(find.text('refreshed-name'), findsWidgets);
  });

  testWidgets('a failed fetch keeps the cached item and shows a banner', (
    tester,
  ) async {
    final repository = await pumpDetail(
      tester,
      (_) async => throw Exception('network down'),
    );

    expect(repository.getItemCalls, 1);
    expect(find.text('item-1'), findsWidgets);
    expect(find.text('Retry'), findsOneWidget);
  });
}

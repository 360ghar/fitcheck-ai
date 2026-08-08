import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/wardrobe_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/views/item_detail_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Condition;

class FakeNetworkService extends NetworkService {
  FakeNetworkService({bool connected = true}) {
    isConnected.value = connected;
  }

  @override
  // ignore: must_call_super
  void onInit() {}
}

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
    String? sortBy,
    String? sortOrder,
  }) async {
    return const ItemsListResponse(
      items: [],
      total: 0,
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
  setUp(Get.reset);
  tearDown(Get.reset);

  group('ItemDetailPage refresh-on-open', () {
    testWidgets(
      'refreshes a cached item from the server instead of serving it blind',
      (tester) async {
        final network = FakeNetworkService();
        Get.put<NetworkService>(network);
        final repository = FakeItemRepository()
          ..onGetItem = (_) async => ItemModel(
            id: 'item-1',
            userId: 'user-1',
            name: 'refreshed-name',
            category: Category.tops,
            condition: Condition.clean,
          );
        final controller = WardrobeController(
          itemRepository: repository,
          networkService: network,
        );
        // Simulate the app state before the fix: the list already holds the
        // item from an earlier fetch, with presigned image URLs that may
        // have expired since.
        controller.items.add(item('item-1'));
        Get.put(controller);

        await tester.pumpWidget(
          const GetMaterialApp(home: ItemDetailPage(itemId: 'item-1')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          repository.getItemCalls,
          1,
          reason: 'opening a detail page must re-mint fresh presigned image '
              'URLs (refreshItemById) instead of rendering the cached model '
              'blind — an expired URL otherwise leaves a permanently broken '
              'image tile',
        );
        expect(
          find.text('refreshed-name'),
          findsOneWidget,
          reason: 'the page must render the freshly fetched item',
        );
        controller.onClose();
      },
    );

    testWidgets('falls back to the cached item when the refresh fails', (
      tester,
    ) async {
      final network = FakeNetworkService();
      Get.put<NetworkService>(network);
      final repository = FakeItemRepository()
        ..onGetItem = (_) async => throw Exception('network down');
      final controller = WardrobeController(
        itemRepository: repository,
        networkService: network,
      );
      controller.items.add(item('item-1'));
      Get.put(controller);

      await tester.pumpWidget(
        const GetMaterialApp(home: ItemDetailPage(itemId: 'item-1')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        repository.getItemCalls,
        1,
        reason: 'the refresh attempt must still happen on open',
      );
      expect(
        find.text('item-1'),
        findsOneWidget,
        reason: 'a failed refresh must not blank the page — the cached '
            'model is shown',
      );

      // Flush the error snackbar: advance past its auto-dismiss duration,
      // then let the dismiss animation finish so no ticker is left running
      // when the tree is torn down.
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      controller.onClose();
    });
  });
}

import 'dart:async';

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/wardrobe/controllers/wardrobe_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Test double for [NetworkService] that avoids the connectivity_plus plugin.
class FakeNetworkService extends NetworkService {
  FakeNetworkService({bool connected = true}) {
    isConnected.value = connected;
  }

  set connected(bool value) => isConnected.value = value;

  @override
  // ignore: must_call_super
  void onInit() {
    // Skip real connectivity subscription.
  }
}

ItemModel _item(String id, {String name = 'Test Item'}) => ItemModel(
  id: id,
  userId: 'user-1',
  name: name,
  category: Category.tops,
  condition: domain.Condition.clean,
);

/// A fake [ItemRepository] driven by callbacks so tests can simulate success
/// and failure without any network / Supabase involvement.
class FakeItemRepository extends ItemRepository {
  int getItemsCalls = 0;
  Future<ItemsListResponse> Function()? onGetItems;
  Future<void> Function(String id)? onDeleteItem;
  Future<ItemModel> Function(String id)? onToggleFavorite;

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
  }) {
    getItemsCalls++;
    final handler = onGetItems;
    if (handler != null) return handler();
    return Future.value(
      const ItemsListResponse(
        items: [],
        total: 0,
        page: 1,
        limit: 20,
        hasMore: false,
      ),
    );
  }

  @override
  Future<void> deleteItem(String itemId) {
    final handler = onDeleteItem;
    if (handler != null) return handler(itemId);
    return Future.value();
  }

  @override
  Future<ItemModel> toggleFavorite(String itemId) {
    final handler = onToggleFavorite;
    if (handler != null) return handler(itemId);
    return Future.value(_item(itemId));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeNetworkService fakeNetwork;
  late FakeItemRepository fakeRepo;

  setUp(() {
    Get.reset();
    fakeNetwork = FakeNetworkService(connected: true);
    Get.put<NetworkService>(fakeNetwork);
    fakeRepo = FakeItemRepository();
  });

  tearDown(() {
    Get.reset();
  });

  /// Pumps a minimal [GetMaterialApp] so the controller's `Get.snackbar` error
  /// reporting has a real overlay to attach to (otherwise it throws a
  /// null-check error in a pure unit-test environment).
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    await tester.pump();
  }

  /// Flushes any pending snackbar timers/animations so tests don't leak timers.
  Future<void> settle(WidgetTester tester) async {
    Get.closeAllSnackbars();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  group('WardrobeController.fetchItems', () {
    testWidgets('stale refresh response cannot overwrite newer results', (
      tester,
    ) async {
      await pumpApp(tester);
      final first = Completer<ItemsListResponse>();
      final second = Completer<ItemsListResponse>();
      fakeRepo.onGetItems = () =>
          fakeRepo.getItemsCalls == 1 ? first.future : second.future;
      final controller = WardrobeController(itemRepository: fakeRepo);

      final firstRequest = controller.fetchItems(refresh: true);
      await tester.pump();
      final secondRequest = controller.fetchItems(refresh: true);
      await tester.pump();

      second.complete(
        ItemsListResponse(
          items: [_item('new')],
          total: 1,
          page: 1,
          limit: 20,
          hasMore: false,
        ),
      );
      await tester.pump();
      first.complete(
        ItemsListResponse(
          items: [_item('old')],
          total: 1,
          page: 1,
          limit: 20,
          hasMore: false,
        ),
      );
      await Future.wait([firstRequest, secondRequest]);
      await tester.pump();

      expect(controller.items.single.id, 'new');
      controller.onClose();
      await settle(tester);
    });

    testWidgets('a failed refresh preserves the previously loaded items', (
      tester,
    ) async {
      await pumpApp(tester);
      final controller = WardrobeController(itemRepository: fakeRepo);
      controller.onInit();
      fakeRepo.onGetItems = () async => ItemsListResponse(
        items: [_item('item-1'), _item('item-2')],
        total: 2,
        page: 1,
        limit: 20,
        hasMore: false,
      );
      await tester.pumpAndSettle();
      expect(controller.items.length, 2);

      // Pull-to-refresh hits a server error. Regression: the list used to be
      // cleared BEFORE the fetch resolved, so a transient failure left a
      // fake "empty closet" state.
      fakeRepo.onGetItems = () async => throw AuthException.unauthorized();
      await controller.fetchItems(refresh: true);
      await tester.pumpAndSettle();

      expect(
        controller.items.map((i) => i.id),
        ['item-1', 'item-2'],
        reason: 'a failed refresh must not wipe the loaded closet',
      );
      expect(controller.error.value, isNotEmpty);
      controller.onClose();
      await settle(tester);
    });

    testWidgets(
      'overlapping failed refreshes restore the original pagination',
      (tester) async {
        await pumpApp(tester);
        final first = Completer<ItemsListResponse>();
        final second = Completer<ItemsListResponse>();
        fakeRepo.onGetItems = () =>
            fakeRepo.getItemsCalls == 1 ? first.future : second.future;
        final controller = WardrobeController(itemRepository: fakeRepo);
        controller.items.addAll([_item('item-1'), _item('item-2')]);
        controller.currentPage.value = 3;
        controller.hasMore.value = false;

        final firstRefresh = controller.fetchItems(refresh: true);
        await tester.pump();
        final secondRefresh = controller.fetchItems(refresh: true);
        await tester.pump();

        second.completeError(AuthException.unauthorized());
        await tester.pump();
        first.completeError(AuthException.unauthorized());
        await Future.wait([firstRefresh, secondRefresh]);

        expect(controller.items.map((item) => item.id), ['item-1', 'item-2']);
        expect(controller.currentPage.value, 3);
        expect(controller.hasMore.value, isFalse);
        controller.onClose();
        await settle(tester);
      },
    );

    testWidgets(
      'offline invalidation clears a stale refresh pagination baseline',
      (tester) async {
        await pumpApp(tester);
        final firstRefresh = Completer<ItemsListResponse>();
        fakeRepo.onGetItems = () {
          switch (fakeRepo.getItemsCalls) {
            case 1:
              return firstRefresh.future;
            case 2:
              return Future.value(
                ItemsListResponse(
                  items: [_item('reconnected-page-one')],
                  total: 2,
                  page: 1,
                  limit: 20,
                  hasMore: true,
                ),
              );
            default:
              return Future.error(AuthException.unauthorized());
          }
        };
        final controller = WardrobeController(itemRepository: fakeRepo);
        controller.items.add(_item('existing'));
        controller.currentPage.value = 3;
        controller.hasMore.value = false;

        final activeRefresh = controller.fetchItems(refresh: true);
        await tester.pump();
        fakeNetwork.connected = false;
        await controller.fetchItems(refresh: true);
        firstRefresh.complete(
          ItemsListResponse(
            items: [_item('stale')],
            total: 1,
            page: 1,
            limit: 20,
            hasMore: false,
          ),
        );
        await activeRefresh;

        fakeNetwork.connected = true;
        await controller.fetchItems();
        expect(controller.currentPage.value, 2);
        expect(controller.hasMore.value, isTrue);

        await controller.fetchItems(refresh: true);

        expect(controller.currentPage.value, 2);
        expect(controller.hasMore.value, isTrue);
        controller.onClose();
        await settle(tester);
      },
    );

    testWidgets('load-more appends instead of replacing', (tester) async {
      await pumpApp(tester);
      var call = 0;
      fakeRepo.onGetItems = () async {
        call++;
        return ItemsListResponse(
          items: [_item('item-$call')],
          total: 2,
          page: call,
          limit: 20,
          hasMore: call < 2,
        );
      };
      final controller = WardrobeController(itemRepository: fakeRepo);
      controller.onInit();
      await tester.pumpAndSettle();

      await controller.fetchItems();

      expect(
        controller.items.map((i) => i.id),
        ['item-1', 'item-2'],
        reason: 'the non-refresh path must append to the loaded list',
      );
      controller.onClose();
      await settle(tester);
    });

    testWidgets('populates items on successful response', (tester) async {
      await pumpApp(tester);
      fakeRepo.onGetItems = () async => ItemsListResponse(
        items: [
          _item('item-1', name: 'Blue Shirt'),
          _item('item-2'),
        ],
        total: 2,
        page: 1,
        limit: 20,
        hasMore: false,
      );

      final controller = WardrobeController(itemRepository: fakeRepo);
      controller.onInit();
      await tester.pumpAndSettle();

      expect(controller.items.length, 2);
      expect(controller.filteredItems.length, 2);
      expect(controller.totalItems.value, 2);
      expect(controller.isLoading.value, isFalse);
      expect(controller.error.value, isEmpty);

      controller.onClose();
      await settle(tester);
    });

    testWidgets('sets error and resets loading on non-retryable failure', (
      tester,
    ) async {
      await pumpApp(tester);
      fakeRepo.onGetItems = () async => throw AuthException.unauthorized();

      final controller = WardrobeController(itemRepository: fakeRepo);
      controller.onInit();
      await tester.pumpAndSettle();

      expect(controller.items, isEmpty);
      expect(controller.error.value, isNotEmpty);
      expect(
        controller.isLoading.value,
        isFalse,
        reason: 'loading flag must reset in finally block',
      );
      expect(controller.isLoadingMore.value, isFalse);

      controller.onClose();
      await settle(tester);
    });

    testWidgets('empty response results in empty list and no error', (
      tester,
    ) async {
      await pumpApp(tester);

      final controller = WardrobeController(itemRepository: fakeRepo);
      controller.onInit();
      await tester.pumpAndSettle();

      expect(controller.items, isEmpty);
      expect(controller.totalItems.value, 0);
      expect(controller.hasMore.value, isFalse);
      expect(controller.error.value, isEmpty);
      expect(controller.isLoading.value, isFalse);

      controller.onClose();
      await settle(tester);
    });
  });

  group('WardrobeController.deleteItem', () {
    testWidgets('removes item from list on success', (tester) async {
      await pumpApp(tester);
      // Back the fake with a mutable "server" list so the re-fetch triggered by
      // applyFilters() after deletion reflects the deletion (the controller
      // calls fetchItems(refresh: true) inside deleteItem).
      final serverItems = <ItemModel>[_item('item-1')];
      fakeRepo.onGetItems = () async => ItemsListResponse(
        items: List.of(serverItems),
        total: serverItems.length,
        page: 1,
        limit: 20,
        hasMore: false,
      );
      fakeRepo.onDeleteItem = (id) async {
        serverItems.removeWhere((i) => i.id == id);
      };

      final controller = WardrobeController(itemRepository: fakeRepo);
      controller.onInit();
      await tester.pumpAndSettle();
      expect(controller.items.length, 1);

      await controller.deleteItem('item-1');
      await tester.pumpAndSettle();

      expect(controller.items, isEmpty);
      expect(controller.isDeleting('item-1'), isFalse);

      controller.onClose();
      await settle(tester);
    });

    testWidgets('resets deleting state and rethrows on failure', (
      tester,
    ) async {
      await pumpApp(tester);
      fakeRepo.onGetItems = () async => ItemsListResponse(
        items: [_item('item-1')],
        total: 1,
        page: 1,
        limit: 20,
        hasMore: false,
      );
      fakeRepo.onDeleteItem = (id) async =>
          throw ServerException.internalError();

      final controller = WardrobeController(itemRepository: fakeRepo);
      controller.onInit();
      await tester.pumpAndSettle();
      expect(controller.items.length, 1);

      await expectLater(
        controller.deleteItem('item-1'),
        throwsA(isA<AppException>()),
      );
      await tester.pumpAndSettle();

      // Item stays in the list and the per-item loading flag is reset.
      expect(controller.items.length, 1);
      expect(controller.isDeleting('item-1'), isFalse);

      controller.onClose();
      await settle(tester);
    });
  });

  group('WardrobeController.toggleFavorite', () {
    testWidgets('resets favoriting state on failure', (tester) async {
      await pumpApp(tester);
      fakeRepo.onGetItems = () async => ItemsListResponse(
        items: [_item('item-1')],
        total: 1,
        page: 1,
        limit: 20,
        hasMore: false,
      );
      fakeRepo.onToggleFavorite = (id) async =>
          throw ServerException.internalError();

      final controller = WardrobeController(itemRepository: fakeRepo);
      controller.onInit();
      await tester.pumpAndSettle();

      // toggleFavorite swallows errors (shows snackbar) but must reset state.
      await controller.toggleFavorite('item-1');
      await tester.pumpAndSettle();

      expect(controller.isFavoriting('item-1'), isFalse);

      controller.onClose();
      await settle(tester);
    });
  });

  group('WardrobeController network monitoring', () {
    testWidgets('does not call the repository while offline', (tester) async {
      await pumpApp(tester);
      fakeNetwork.connected = false;

      final controller = WardrobeController(itemRepository: fakeRepo);
      controller.onInit();
      await tester.pumpAndSettle();

      expect(fakeRepo.getItemsCalls, 0);
      expect(controller.isOffline.value, isTrue);

      controller.onClose();
      await settle(tester);
    });

    testWidgets('reflects offline state from NetworkService', (tester) async {
      await pumpApp(tester);
      fakeNetwork.connected = false;

      final controller = WardrobeController(itemRepository: fakeRepo);
      controller.onInit();
      await tester.pumpAndSettle();

      expect(controller.isOffline.value, isTrue);

      fakeNetwork.connected = true;
      await tester.pumpAndSettle();
      expect(controller.isOffline.value, isFalse);

      controller.onClose();
      await settle(tester);
    });
  });

  group('WardrobeController selection', () {
    testWidgets('clearSelection empties the selection set', (tester) async {
      await pumpApp(tester);

      final controller = WardrobeController(itemRepository: fakeRepo);

      controller.selectedIds.addAll({'a', 'b', 'c'});
      expect(controller.isSelectionActive, isTrue);
      expect(controller.selectedCount, 3);

      controller.clearSelection();
      expect(controller.isSelectionActive, isFalse);
      expect(controller.selectedCount, 0);

      controller.onClose();
      await settle(tester);
    });
  });
}

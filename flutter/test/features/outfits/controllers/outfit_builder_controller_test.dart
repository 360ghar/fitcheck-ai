import 'dart:async';

import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart';
import 'package:fitcheck_ai/features/outfits/controllers/outfit_builder_controller.dart';
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:fitcheck_ai/features/outfits/repositories/outfit_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/controllers/wardrobe_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Condition;

/// A fake [OutfitRepository] whose save-time image-upload methods record
/// their inputs so tests can assert the outfit save strategy without any
/// network.
class FakeOutfitBuilderRepository extends OutfitRepository {
  final List<String> base64Uploads = [];
  final List<String> urlUploads = [];
  int createOutfitCalls = 0;
  Future<OutfitModel> Function(CreateOutfitRequest request)? onCreateOutfit;
  Future<OutfitImage?> Function(String outfitId, String base64Image)?
  onUploadBase64;
  Future<OutfitImage?> Function(String outfitId, String imageUrl)?
  onUploadFromUrl;

  @override
  Future<OutfitModel> createOutfit(CreateOutfitRequest request) async {
    createOutfitCalls++;
    final handler = onCreateOutfit;
    return handler?.call(request) ??
        OutfitModel(
          id: 'outfit-1',
          userId: 'user-1',
          name: request.name,
          itemIds: request.itemIds,
        );
  }

  @override
  Future<OutfitImage?> uploadOutfitImageFromBase64(
    String outfitId,
    String base64Image, {
    bool isPrimary = true,
    String? pose,
  }) async {
    base64Uploads.add(base64Image);
    final handler = onUploadBase64;
    return handler == null ? null : await handler(outfitId, base64Image);
  }

  @override
  Future<OutfitImage?> uploadOutfitImageFromUrl(
    String outfitId,
    String imageUrl, {
    bool isPrimary = true,
    String? pose,
  }) async {
    urlUploads.add(imageUrl);
    final handler = onUploadFromUrl;
    return handler == null ? null : await handler(outfitId, imageUrl);
  }
}

class FakeOutfitBuilderItemRepository extends ItemRepository {
  FakeOutfitBuilderItemRepository(this.serverItems);

  final List<ItemModel> serverItems;
  int getItemsCalls = 0;
  Future<ItemsListResponse> Function()? onGetItems;

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
    getItemsCalls++;
    final handler = onGetItems;
    if (handler != null) return handler();
    final start = (page - 1) * limit;
    final pageItems = serverItems.skip(start).take(limit).toList();
    return ItemsListResponse(
      items: pageItems,
      total: serverItems.length,
      page: page,
      limit: limit,
      hasMore: start + pageItems.length < serverItems.length,
    );
  }
}

class _BuilderNetworkService extends NetworkService {
  _BuilderNetworkService() {
    isConnected.value = true;
  }

  @override
  // Skip real connectivity subscriptions in this fake.
  // ignore: must_call_super
  void onInit() {}
}

OutfitBuilderItem selectedItem(String id) => OutfitBuilderItem(
  item: ItemModel(
    id: id,
    userId: 'user-1',
    name: id,
    category: Category.tops,
    condition: Condition.clean,
  ),
  id: id,
  position: Offset.zero,
  isVisible: true,
  layer: 0,
);

ItemModel availableItem(String id) => ItemModel(
  id: id,
  userId: 'user-1',
  name: id,
  category: Category.tops,
  condition: Condition.clean,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(Get.reset);
  tearDown(Get.reset);

  /// Hosts the controller's `Get.back()` + success snackbar: pushes a real
  /// route so the pop is a no-op-safe navigation back to the home route, and
  /// flushes the snackbar's auto-dismiss timer.
  Future<OutfitBuilderController> hostController(
    WidgetTester tester,
    FakeOutfitBuilderRepository repo,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(home: const Scaffold(body: Text('home'))),
    );
    Get.to(const Scaffold(body: Text('page')));
    await tester.pumpAndSettle();
    return OutfitBuilderController(outfitRepository: repo);
  }

  /// Flushes the success snackbar timer (4s display + dismiss animation).
  Future<void> flushSnackbar(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('OutfitBuilderController.saveOutfit image strategy', () {
    testWidgets(
      'saves a URL-valued generated visualization via uploadOutfitImageFromUrl '
      '(regression: the URL branch previously skipped the upload entirely)',
      (tester) async {
        final repo = FakeOutfitBuilderRepository();
        final controller = await hostController(tester, repo);
        controller.name.value = 'Weekend Look';
        controller.selectedItems.add(selectedItem('item-1'));
        // save_to_storage response contract: the backend returns a presigned
        // URL instead of base64.
        controller.generatedImageUrl.value =
            'https://cdn.example.com/generated/outfit-1.png';

        await controller.saveOutfit();

        expect(
          repo.urlUploads,
          ['https://cdn.example.com/generated/outfit-1.png'],
          reason:
              'a real URL must be downloaded and re-uploaded, not '
              'silently skipped',
        );
        expect(repo.base64Uploads, isEmpty);
        await flushSnackbar(tester);
        controller.onClose();
      },
    );

    testWidgets(
      'uploads a data-URI visualization via uploadOutfitImageFromBase64',
      (tester) async {
        final repo = FakeOutfitBuilderRepository();
        final controller = await hostController(tester, repo);
        controller.name.value = 'Weekend Look';
        controller.selectedItems.add(selectedItem('item-1'));
        controller.generatedImageUrl.value = 'data:image/png;base64,QUJD';

        await controller.saveOutfit();

        expect(repo.base64Uploads, ['QUJD']);
        expect(repo.urlUploads, isEmpty);
        await flushSnackbar(tester);
        controller.onClose();
      },
    );

    testWidgets(
      'keeps the outfit saved and reports when no image strategy succeeds',
      (tester) async {
        final repo = FakeOutfitBuilderRepository()
          ..onUploadFromUrl = (_, _) async => null;
        final controller = await hostController(tester, repo);
        controller.name.value = 'Weekend Look';
        controller.selectedItems.add(selectedItem('item-1'));
        controller.generatedImageUrl.value =
            'https://cdn.example.com/generated/outfit-1.png';

        await controller.saveOutfit();

        expect(repo.urlUploads, hasLength(1));
        expect(repo.createOutfitCalls, 1);
        // The outfit row is created regardless; the image loss is surfaced
        // via ErrorHandler.reportError (no-op without Sentry in tests) and
        // recoverable from the detail page re-mint fallback.
        await flushSnackbar(tester);
        controller.onClose();
      },
    );
  });

  group('OutfitBuilderController wardrobe synchronization', () {
    testWidgets('refreshes the full picker list after a wardrobe mutation', (
      tester,
    ) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );
      final existing = availableItem('existing');
      final added = availableItem('added');
      final itemRepository = FakeOutfitBuilderItemRepository([existing]);
      final wardrobe = Get.put<WardrobeController>(
        WardrobeController(
          itemRepository: itemRepository,
          networkService: _BuilderNetworkService(),
        ),
      );
      wardrobe.items.assignAll([existing]);
      final controller = OutfitBuilderController(
        outfitRepository: FakeOutfitBuilderRepository(),
        itemRepository: itemRepository,
      );
      controller.onInit();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.availableItems.map((item) => item.id), ['existing']);

      itemRepository.serverItems.add(added);
      wardrobe.addItem(added);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(controller.availableItems.map((item) => item.id), [
        'existing',
        'added',
      ]);
      controller.onClose();
      wardrobe.onClose();
    });

    testWidgets('ignores a stale picker refresh after a wardrobe mutation', (
      tester,
    ) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );
      final first = Completer<ItemsListResponse>();
      final second = Completer<ItemsListResponse>();
      final newItem = availableItem('new');
      final pickerRepository = FakeOutfitBuilderItemRepository([]);
      pickerRepository.onGetItems = () =>
          pickerRepository.getItemsCalls == 1 ? first.future : second.future;
      final wardrobe = Get.put<WardrobeController>(
        WardrobeController(
          itemRepository: FakeOutfitBuilderItemRepository([]),
          networkService: _BuilderNetworkService(),
        ),
      );
      final controller = OutfitBuilderController(
        outfitRepository: FakeOutfitBuilderRepository(),
        itemRepository: pickerRepository,
      );
      controller.onInit();
      await tester.pump();
      expect(pickerRepository.getItemsCalls, 1);

      wardrobe.addItem(newItem);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(pickerRepository.getItemsCalls, 2);

      second.complete(
        ItemsListResponse(
          items: [newItem],
          total: 1,
          page: 1,
          limit: 100,
          hasMore: false,
        ),
      );
      await tester.pump();
      first.complete(
        ItemsListResponse(
          items: [availableItem('old')],
          total: 1,
          page: 1,
          limit: 100,
          hasMore: false,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(controller.availableItems.map((item) => item.id), ['new']);
      controller.onClose();
      wardrobe.onClose();
    });

    testWidgets(
      'does not materialize lazy wardrobe state and re-arms after Fenix recreation',
      (tester) async {
        await tester.pumpWidget(
          const GetMaterialApp(home: Scaffold(body: SizedBox())),
        );
        final pickerRepository = FakeOutfitBuilderItemRepository([]);
        final wardrobeRepository = FakeOutfitBuilderItemRepository([]);
        var wardrobeCreates = 0;
        Get.lazyPut<WardrobeController>(() {
          wardrobeCreates++;
          return WardrobeController(
            itemRepository: wardrobeRepository,
            networkService: _BuilderNetworkService(),
          );
        }, fenix: true);
        final controller = OutfitBuilderController(
          outfitRepository: FakeOutfitBuilderRepository(),
          itemRepository: pickerRepository,
        );
        controller.onInit();
        await tester.pump();

        expect(wardrobeCreates, 0);

        final firstWardrobe = Get.find<WardrobeController>();
        await tester.pump(const Duration(milliseconds: 300));
        pickerRepository.serverItems.add(availableItem('first'));
        firstWardrobe.addItem(availableItem('first'));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        expect(controller.availableItems.map((item) => item.id), ['first']);

        await Get.delete<WardrobeController>();
        await tester.pump(const Duration(milliseconds: 300));
        final recreatedWardrobe = Get.find<WardrobeController>();
        await tester.pump(const Duration(milliseconds: 300));
        pickerRepository.serverItems.add(availableItem('second'));
        recreatedWardrobe.addItem(availableItem('second'));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(wardrobeCreates, 2);
        expect(controller.availableItems.map((item) => item.id), [
          'first',
          'second',
        ]);
        controller.onClose();
        recreatedWardrobe.onClose();
      },
    );
  });
}

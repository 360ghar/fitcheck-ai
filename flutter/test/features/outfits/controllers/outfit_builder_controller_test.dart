import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart';
import 'package:fitcheck_ai/features/outfits/controllers/outfit_builder_controller.dart';
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:fitcheck_ai/features/outfits/repositories/outfit_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
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
          reason: 'a real URL must be downloaded and re-uploaded, not '
              'silently skipped',
        );
        expect(repo.base64Uploads, isEmpty);
        await flushSnackbar(tester);
        controller.onClose();
      },
    );

    testWidgets('uploads a data-URI visualization via uploadOutfitImageFromBase64', (
      tester,
    ) async {
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
    });

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
}

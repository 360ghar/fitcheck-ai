import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fitcheck_ai/core/network/api_client.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/tryon/controllers/tryon_controller.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Serves the wardrobe temp-image download from `ApiClient.dio` without any
/// network: returns fake image bytes so `dio.download` writes a real temp file.
class _FakeDownloadAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      'fake-tryon-image-bytes',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/octet-stream'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ItemModel _wardrobeItem(String id, {String name = 'Test Item'}) => ItemModel(
  id: id,
  userId: 'user-1',
  name: name,
  category: Category.tops,
  condition: domain.Condition.clean,
  itemImages: [
    ItemImage(id: 'img-$id', url: 'https://cdn.test/$id.png', isPrimary: true),
  ],
);

/// Simulates a camera/gallery photo. The real picker is a platform channel,
/// so tests seed the public [TryOnController.clothingImages] list directly;
/// camera files are deliberately NOT tracked for cleanup, like real picks.
File _cameraFile(String suffix) {
  final file = File('${Directory.systemTemp.path}/camera_$suffix.png');
  file.writeAsBytesSync([1, 2, 3, 4]);
  return file;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'try-on payload rejects multiple garments under the singular API contract',
    () {
      expect(
        () => TryOnController.buildTryOnPayload(
          ['one', 'two'],
          style: 'casual',
          background: 'studio white',
          pose: 'standing front',
        ),
        throwsArgumentError,
      );
    },
  );

  group('extractDataMap response-shape tolerance', () {
    test('unwraps the canonical envelope', () {
      expect(
        TryOnController.extractDataMap({
          'data': {'image_url': 'https://cdn.test/x.webp'},
          'message': 'OK',
        }),
        {'image_url': 'https://cdn.test/x.webp'},
      );
    });

    test('unwraps an array-of-envelope (observed production shape)', () {
      expect(
        TryOnController.extractDataMap([
          {'data': {'image_url': 'https://cdn.test/x.webp'}, 'message': 'OK'},
        ]),
        {'image_url': 'https://cdn.test/x.webp'},
      );
    });

    test('unwraps an array-of-result', () {
      expect(
        TryOnController.extractDataMap([
          {'image_url': 'https://cdn.test/x.webp'},
        ]),
        {'image_url': 'https://cdn.test/x.webp'},
      );
    });

    test('passes a bare result object through', () {
      expect(
        TryOnController.extractDataMap({'image_url': 'https://cdn.test/x.webp'}),
        {'image_url': 'https://cdn.test/x.webp'},
      );
    });

    test('returns an empty map for unusable payloads', () {
      expect(TryOnController.extractDataMap(null), <String, dynamic>{});
      expect(TryOnController.extractDataMap([]), <String, dynamic>{});
      expect(TryOnController.extractDataMap('nope'), <String, dynamic>{});
    });
  });

  testWidgets('downloads a base64 result through the gallery saver', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    Uint8List? savedBytes;
    String? savedName;
    final controller = TryOnController(
      imageSaver: (bytes, name) async {
        savedBytes = bytes;
        savedName = name;
      },
    );
    controller.generatedImageBase64.value = base64Encode([1, 2, 3]);

    await controller.downloadResult();
    // downloadResult reports success through the production snackbar service;
    // let its animation/timer finish before the test tree is disposed.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(savedBytes, orderedEquals([1, 2, 3]));
    expect(savedName, startsWith('tryon_'));
    controller.onClose();
  });

  group('wardrobe item list desync fixes', () {
    late TryOnController controller;

    setUp(() {
      Get.reset();
      // Route all ApiClient traffic (the wardrobe temp-image download) through
      // a fake adapter; no real network or Supabase is available in tests.
      final dio = ApiClient.instance.dio;
      dio.interceptors.clear();
      dio.httpClientAdapter = _FakeDownloadAdapter();
      controller = TryOnController();
    });

    tearDown(() {
      // Cleans up any temp files still tracked by the controller.
      controller.onClose();
      Get.reset();
    });

    /// Pumps a minimal [GetMaterialApp] so the controller's `Get.snackbar`
    /// success/info messages have an overlay to attach to.
    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
      await tester.pump();
    }

    /// Adds a wardrobe item. The temp-file download does real `dart:io` work,
    /// which cannot complete under the test's fake clock, so it runs inside
    /// [WidgetTester.runAsync]; snackbars are closed right after.
    Future<void> addWardrobeItem(
      WidgetTester tester,
      ItemModel item,
    ) async {
      await tester.runAsync(() => controller.pickClothingFromWardrobe(item));
      Get.closeAllSnackbars();
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets(
      'removing a wardrobe item removes its own image, keeps camera photos, '
      'and never crashes',
      (tester) async {
        await pumpApp(tester);

        // Camera photo first, then two wardrobe items: indices are now offset
        // between clothingImages and selectedWardrobeItems (the pre-fix
        // index-based removal would delete the camera photo instead).
        final camera = _cameraFile('mixed');
        controller.clothingImages.add(camera);
        controller.clothingImage.value = camera;
        controller.currentImageIndex.value = 0;

        final itemA = _wardrobeItem('item-a', name: 'Jacket');
        final itemB = _wardrobeItem('item-b', name: 'Jeans');
        await addWardrobeItem(tester, itemA);
        await addWardrobeItem(tester, itemB);

        expect(controller.clothingImages, hasLength(3));
        expect(controller.selectedWardrobeItems, hasLength(2));
        final aFile = controller.clothingImages[1];
        final bFile = controller.clothingImages[2];

        // Removing wardrobe item A must remove A's image (not the camera at
        // index 0) and must not throw a RangeError.
        controller.removeWardrobeItem('item-a');

        expect(controller.clothingImages, hasLength(2));
        expect(controller.clothingImages.first.path, camera.path);
        expect(controller.clothingImages[1].path, bFile.path);
        expect(
          camera.existsSync(),
          isTrue,
          reason: 'the camera photo must survive a wardrobe-item removal',
        );
        expect(
          aFile.existsSync(),
          isFalse,
          reason: 'the removed item temp file must be deleted',
        );
        expect(controller.selectedWardrobeItems.map((i) => i.id), ['item-b']);
        expect(controller.isWardrobeItemSelected('item-a'), isFalse);
        expect(controller.clothingImage.value?.path, camera.path);
        expect(
          controller.selectedWardrobeItem.value,
          isNull,
          reason: 'the current image is a camera photo, not a wardrobe item',
        );

        // Removing the last wardrobe item must not crash either: the pre-fix
        // code indexed the now-empty selectedWardrobeItems with index 0.
        controller.removeWardrobeItem('item-b');

        expect(controller.clothingImages, hasLength(1));
        expect(controller.clothingImages.first.path, camera.path);
        expect(controller.selectedWardrobeItems, isEmpty);
        expect(controller.selectedWardrobeItem.value, isNull);
        expect(controller.clothingImage.value?.path, camera.path);
        expect(bFile.existsSync(), isFalse);
      },
    );

    testWidgets(
      'removing the current wardrobe image clears the selection so the item '
      'can be re-added',
      (tester) async {
        await pumpApp(tester);

        final itemA = _wardrobeItem('item-a', name: 'Jacket');
        final itemB = _wardrobeItem('item-b', name: 'Jeans');
        await addWardrobeItem(tester, itemA);
        await addWardrobeItem(tester, itemB);

        final aFile = controller.clothingImages[0];
        expect(controller.clothingImage.value?.path, aFile.path);
        expect(controller.selectedWardrobeItem.value?.id, 'item-a');

        // Remove the currently displayed image (item A).
        controller.removeCurrentImage();

        expect(controller.clothingImages, hasLength(1));
        expect(controller.selectedWardrobeItems.map((i) => i.id), ['item-b']);
        expect(controller.isWardrobeItemSelected('item-a'), isFalse);
        expect(controller.selectedWardrobeItem.value?.id, 'item-b');
        expect(controller.clothingImage.value?.path, isNot(aFile.path));
        expect(
          aFile.existsSync(),
          isFalse,
          reason: 'the removed wardrobe temp file must be deleted',
        );

        // Item A can be selected again (pre-fix it stayed "already selected").
        await addWardrobeItem(tester, itemA);
        expect(
          controller.selectedWardrobeItems.map((i) => i.id),
          ['item-b', 'item-a'],
        );
        expect(controller.clothingImages, hasLength(2));
        expect(controller.clothingImages[1].existsSync(), isTrue);
      },
    );

    testWidgets('nextImage/previousImage keep selectedWardrobeItem in sync', (
      tester,
    ) async {
      await pumpApp(tester);

      final itemA = _wardrobeItem('item-a', name: 'Jacket');
      final itemB = _wardrobeItem('item-b', name: 'Jeans');
      await addWardrobeItem(tester, itemA);
      await addWardrobeItem(tester, itemB);

      final camera = _cameraFile('cycle');
      controller.clothingImages.add(camera);

      // Order: [A, B, camera]; current index 0 -> A.
      expect(controller.clothingImages.first.path, isNot(camera.path));
      expect(controller.selectedWardrobeItem.value?.id, 'item-a');

      controller.nextImage(); // index 1 -> B
      expect(controller.clothingImage.value?.path, controller.clothingImages[1].path);
      expect(controller.selectedWardrobeItem.value?.id, 'item-b');

      controller.nextImage(); // index 2 -> camera photo
      expect(controller.clothingImage.value?.path, camera.path);
      expect(controller.selectedWardrobeItem.value, isNull);

      controller.nextImage(); // wraps to index 0 -> A
      expect(controller.selectedWardrobeItem.value?.id, 'item-a');

      controller.previousImage(); // index 2 -> camera photo
      expect(controller.selectedWardrobeItem.value, isNull);

      controller.previousImage(); // index 1 -> B
      expect(controller.selectedWardrobeItem.value?.id, 'item-b');
    });
  });
}

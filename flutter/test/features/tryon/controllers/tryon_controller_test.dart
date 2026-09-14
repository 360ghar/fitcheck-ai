import 'dart:async';
import 'dart:convert';
import 'package:fitcheck_ai/core/services/ai_consent_service.dart';
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

class _PendingConsent extends AiConsentService {
  final completion = Completer<bool>();
  int calls = 0;
  @override
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<bool> ensureConsent({required String featureLabel}) {
    calls++;
    return completion.future;
  }
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
          {
            'data': {'image_url': 'https://cdn.test/x.webp'},
            'message': 'OK',
          },
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
        TryOnController.extractDataMap({
          'image_url': 'https://cdn.test/x.webp',
        }),
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

  test('repeated Generate taps share one pending consent attempt', () async {
    Get.reset();
    final consent = _PendingConsent();
    Get.put<AiConsentService>(consent);
    final controller = TryOnController();
    controller.clothingImage.value = File('/not-read-before-consent.png');
    controller.userAvatarUrl.value = 'https://cdn.test/avatar.png';
    controller.isAvatarReady.value = true;
    final first = controller.generateTryOn();
    await controller.generateTryOn();
    expect(consent.calls, 1);
    expect(controller.isGenerating.value, isTrue);
    consent.completion.complete(false);
    await first;
    expect(controller.isGenerating.value, isFalse);
    controller.onClose();
    Get.reset();
  });

  group('single garment selection', () {
    late TryOnController controller;
    setUp(() {
      Get.reset();
      final dio = ApiClient.instance.dio;
      dio.interceptors.clear();
      dio.httpClientAdapter = _FakeDownloadAdapter();
      controller = TryOnController();
    });
    tearDown(() {
      controller.onClose();
      Get.reset();
    });

    testWidgets(
      'replacing a garment cleans owned files and clears stale results',
      (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
        final camera = File(
          '${Directory.systemTemp.path}/tryon_camera_test.png',
        )..writeAsBytesSync([1, 2, 3]);
        addTearDown(() {
          if (camera.existsSync()) camera.deleteSync();
        });
        controller.setClothingImage(camera);
        controller.generatedImageUrl.value = 'https://cdn.test/old.png';
        await tester.runAsync(
          () => controller.pickClothingFromWardrobe(_wardrobeItem('a')),
        );
        final first = controller.clothingImage.value!;
        expect(
          camera.existsSync(),
          isTrue,
          reason: 'The user photo is not an owned temp download.',
        );
        expect(controller.selectedWardrobeItem.value?.id, 'a');
        expect(controller.generatedImageUrl.value, isEmpty);
        await tester.runAsync(
          () => controller.pickClothingFromWardrobe(_wardrobeItem('b')),
        );
        expect(controller.selectedWardrobeItem.value?.id, 'b');
        expect(first.existsSync(), isFalse);
        expect(controller.tempFiles, hasLength(1));
        controller.removeCurrentImage();
        expect(controller.clothingImage.value, isNull);
        expect(controller.selectedWardrobeItem.value, isNull);
        expect(controller.tempFiles, isEmpty);
      },
    );

    testWidgets('an invalid replacement keeps the current garment and result', (
      tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
      await tester.runAsync(
        () => controller.pickClothingFromWardrobe(_wardrobeItem('a')),
      );
      final previous = controller.clothingImage.value;
      controller.generatedImageUrl.value = 'https://cdn.test/good.png';
      final invalid = _wardrobeItem('b').copyWith(itemImages: []);
      final selected = await controller.pickClothingFromWardrobe(invalid);
      expect(selected, isFalse);
      expect(controller.clothingImage.value, same(previous));
      expect(controller.generatedImageUrl.value, 'https://cdn.test/good.png');
      expect(controller.error.value, contains('no photo'));
    });
  });
}

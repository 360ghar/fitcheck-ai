import 'dart:convert';
import 'dart:typed_data';

import 'package:fitcheck_ai/features/tryon/controllers/tryon_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
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
}

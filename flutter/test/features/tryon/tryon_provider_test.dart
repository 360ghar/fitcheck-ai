import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/core/providers.dart'
    show noRetry, rootNavigatorKey;
import 'package:fitcheck_ai/core/services/ai_consent_service.dart';
import 'package:fitcheck_ai/core/services/notification_service.dart'
    show scaffoldMessengerKey;
import 'package:fitcheck_ai/features/tryon/providers/tryon_provider.dart';
import 'package:fitcheck_ai/features/tryon/repositories/tryon_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

class FakeAiConsentService extends AiConsentService {
  @override
  Future<bool> ensureConsent({required String featureLabel}) async => true;
}

class FakeTryOnRepository extends TryOnRepository {
  final avatarResults = <Object?>['https://cdn.test/me.png'];
  Map<String, dynamic> result = const {};
  int downloads = 0;
  Uint8List? saved;
  String? savedName;

  @override
  Future<String?> fetchAvatarUrl() async {
    final next = avatarResults.length > 1
        ? avatarResults.removeAt(0)
        : avatarResults.first;
    if (next is Exception) throw next;
    return next as String?;
  }

  @override
  Future<Map<String, dynamic>> generate(Map<String, dynamic> payload) async =>
      result;

  @override
  Future<Uint8List> downloadBytes(String url) async {
    downloads++;
    return Uint8List.fromList([9]);
  }

  @override
  Future<void> saveToGallery(Uint8List bytes, String name) async {
    saved = bytes;
    savedName = name;
  }
}

/// Records picker calls. Multi-select must never be used: the API takes one
/// garment.
class FakePicker extends ImagePicker {
  FakePicker(this.path);

  final String path;
  final calls = <({ImageSource source, double? maxWidth, int? quality})>[];

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    calls.add((source: source, maxWidth: maxWidth, quality: imageQuality));
    return XFile(path);
  }

  @override
  Future<List<XFile>> pickMultipleMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) => throw StateError('multi-select is not allowed');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTryOnRepository repo;
  late FakePicker picker;
  late ProviderContainer container;
  late File garment;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('tryon_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    garment = File('${dir.path}/shirt.png')..writeAsBytesSync([1, 2, 3, 4]);
    repo = FakeTryOnRepository();
    picker = FakePicker(garment.path);
    container = ProviderContainer(
      retry: noRetry,
      overrides: [
        aiConsentServiceProvider.overrideWithValue(FakeAiConsentService()),
        tryOnRepositoryProvider.overrideWithValue(repo),
        tryOnImagePickerProvider.overrideWithValue(picker),
      ],
    );
    container.listen(tryOnProvider, (_, _) {});
    container.listen(tryOnAvatarProvider, (_, _) {});
  });

  tearDown(() {
    container.dispose();
  });

  TryOnNotifier notifier() => container.read(tryOnProvider.notifier);
  TryOnState state() => container.read(tryOnProvider);

  test('the payload rejects more than one garment', () {
    expect(
      () => TryOnRepository.buildPayload(
        ['one', 'two'],
        style: 'casual',
        background: 'studio white',
        pose: 'standing front',
      ),
      throwsArgumentError,
    );
  });

  group('extractDataMap response shapes', () {
    const result = {'image_url': 'https://cdn.test/x.webp'};

    test('unwraps the envelope', () {
      expect(
        TryOnRepository.extractDataMap({'data': result, 'message': 'OK'}),
        result,
      );
    });

    test('unwraps an array of envelopes', () {
      expect(
        TryOnRepository.extractDataMap([
          {'data': result, 'message': 'OK'},
        ]),
        result,
      );
    });

    test('unwraps an array of results', () {
      expect(TryOnRepository.extractDataMap([result]), result);
    });

    test('passes a bare result through', () {
      expect(TryOnRepository.extractDataMap(result), result);
    });

    test('returns an empty map for unusable payloads', () {
      expect(TryOnRepository.extractDataMap(null), <String, dynamic>{});
      expect(TryOnRepository.extractDataMap([]), <String, dynamic>{});
      expect(TryOnRepository.extractDataMap('nope'), <String, dynamic>{});
    });
  });

  test('decodeImagePayload strips a data URI prefix', () {
    final raw = base64Encode([1, 2, 3]);
    expect(decodeImagePayload(raw), [1, 2, 3]);
    expect(decodeImagePayload('data:image/png;base64,$raw'), [1, 2, 3]);
    expect(decodeImagePayload('not base64!'), isNull);
    expect(decodeImagePayload(''), isNull);
  });

  test('a result is decoded once and saved from those bytes', () async {
    await container.read(tryOnAvatarProvider.future);
    repo.result = {
      'image_base64': 'data:image/png;base64,${base64Encode([1, 2, 3])}',
    };
    notifier().setGarment(garment);

    await notifier().generate();

    expect(state().resultBytes, [1, 2, 3]);
    expect(state().resultUrl, isNull);
    expect(state().generating, isFalse);

    await notifier().downloadResult();
    expect(repo.saved, [1, 2, 3]);
    expect(repo.savedName, startsWith('tryon_'));
    expect(repo.downloads, 0);
  });

  test('a new garment clears the old result', () async {
    await container.read(tryOnAvatarProvider.future);
    repo.result = {'image_url': 'https://cdn.test/result.png'};
    notifier().setGarment(garment);
    await notifier().generate();
    expect(state().hasResult, isTrue);

    notifier().setGarment(File('${garment.parent.path}/other.png'));
    expect(state().hasResult, isFalse);
  });

  test('an avatar load failure is retryable', () async {
    repo.avatarResults
      ..clear()
      ..addAll([
        const NetworkException(message: 'offline'),
        'https://cdn.test/me.png',
      ]);
    container.invalidate(tryOnAvatarProvider);
    await expectLater(
      container.read(tryOnAvatarProvider.future),
      throwsA(isA<NetworkException>()),
    );
    expect(container.read(tryOnAvatarProvider).hasError, isTrue);

    await container.read(tryOnAvatarProvider.notifier).refresh();
    expect(
      container.read(tryOnAvatarProvider).value?.url,
      'https://cdn.test/me.png',
    );
  });

  testWidgets('the gallery picks exactly one garment image', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: rootNavigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const Scaffold(),
      ),
    );
    final pick = notifier().pickGarment();
    await tester.pumpAndSettle();
    // The photo-access rationale comes first.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await pick;

    expect(picker.calls, hasLength(1));
    expect(picker.calls.single.source, ImageSource.gallery);
    expect(picker.calls.single.maxWidth, 1024);
    expect(picker.calls.single.quality, 85);
    expect(state().garment?.path, garment.path);
  });
}

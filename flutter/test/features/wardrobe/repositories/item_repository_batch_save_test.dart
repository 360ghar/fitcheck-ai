import 'dart:io';

import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// The batch save must reference the server-held image instead of
/// re-uploading bytes: a studio URL becomes a primary `images` entry next to
/// the idempotency key, and an entry without any image carries no `images`
/// key at all (the caller stages the source photo first). Asserted on the
/// request BODY because the transport is an [ApiClient] singleton with no
/// injectable seam.
void main() {
  CreateItemRequest request() =>
      CreateItemRequest(name: 'Blue Shirt', category: Category.tops);

  test('batchSaveEntry promotes a studio URL without re-upload fields', () {
    final entry = ItemRepository.batchSaveEntry(
      tempId: 't1',
      request: request(),
      clientRequestId: 'item-abc',
      imageUrl: 'https://cdn.example.com/studio/t1.jpg',
    );

    expect(entry['temp_id'], 't1');
    final item = entry['item'] as Map<String, dynamic>;
    expect(item['client_request_id'], 'item-abc');
    final images = item['images'] as List;
    expect(images, hasLength(1));
    expect(images.single['image_url'], 'https://cdn.example.com/studio/t1.jpg');
    expect(images.single['is_primary'], isTrue);
    expect((images.single as Map<String, dynamic>).keys.toSet(), {
      'image_url',
      'is_primary',
    }, reason: 'a promoted URL must not carry re-upload fields');
  });

  test('batchSaveEntry carries a staged storage path when there is no URL', () {
    final entry = ItemRepository.batchSaveEntry(
      tempId: 't2',
      request: request(),
      storagePath: 'users/u/tmp/stage.jpg',
    );

    final item = entry['item'] as Map<String, dynamic>;
    final images = item['images'] as List;
    expect(images, hasLength(1));
    expect(images.single['storage_path'], 'users/u/tmp/stage.jpg');
    expect((images.single as Map<String, dynamic>).keys.toSet(), {
      'image_url',
      'storage_path',
      'is_primary',
    });
  });

  test('batchSaveEntry omits images when the piece has no image yet', () {
    final entry = ItemRepository.batchSaveEntry(
      tempId: 't3',
      request: request(),
    );

    final item = entry['item'] as Map<String, dynamic>;
    expect(item.containsKey('images'), isFalse);
  });

  group('saveBatch slicing', () {
    List<SaveEntryInput> entries(int n) => [
      for (var i = 0; i < n; i++)
        SaveEntryInput(
          tempId: 't$i',
          request: request(),
          imageUrl: 'https://cdn.example.com/studio/t$i.jpg',
        ),
    ];

    test('51 entries go out as two requests of 50 and 1', () async {
      final repo = _SlicingRepo();

      final result = await repo.saveBatch(entries: entries(51));

      expect(repo.posted.map((p) => p.length), [50, 1]);
      expect(result.failed, isEmpty);
      expect(repo.posted.expand((p) => p).length, 51);
    });

    test('a failing later slice fails only its entries', () async {
      final repo = _SlicingRepo(failOnCall: 1);

      final result = await repo.saveBatch(entries: entries(51));

      expect(result.failed.map((f) => f.tempId), ['t50']);
    });

    test('unsupported on the first slice rethrows for the legacy path', () {
      final repo = _SlicingRepo(unsupportedOnCall: 0);

      expect(
        repo.saveBatch(entries: entries(51)),
        throwsA(isA<BatchSaveUnsupported>()),
      );
    });

    test('unsupported on a later slice marks its entries failed', () async {
      final repo = _SlicingRepo(unsupportedOnCall: 1);

      final result = await repo.saveBatch(entries: entries(51));

      expect(result.failed.map((f) => f.tempId), ['t50']);
    });
  });

  group('pairStagedImages', () {
    Map<String, dynamic> stored(String name) => {
      'filename': name,
      'storage_path': 'users/u/tmp/$name',
      'image_url': 'https://cdn.example.com/$name',
    };

    test('a full response pairs by position', () {
      final files = [File('/a/one.jpg'), File('/b/one.jpg')];
      final staged = ItemRepository.pairStagedImages(files, [
        stored('one.jpg'),
        stored('one.jpg'),
      ]);
      expect(staged.map((s) => s.sourcePath), ['/a/one.jpg', '/b/one.jpg']);
    });

    test('a short response pairs by filename, never onto the wrong photo', () {
      final files = [File('/a/one.jpg'), File('/a/two.jpg')];
      // Photo one failed to store; only photo two came back.
      final staged = ItemRepository.pairStagedImages(files, [
        stored('two.jpg'),
      ]);
      expect(staged, hasLength(1));
      expect(staged.single.sourcePath, '/a/two.jpg');
      expect(staged.single.storagePath, 'users/u/tmp/two.jpg');
    });

    test('a short response with a shared name stages nothing for it', () {
      final files = [File('/a/x.jpg'), File('/b/x.jpg'), File('/a/y.jpg')];
      final staged = ItemRepository.pairStagedImages(files, [stored('x.jpg')]);
      expect(staged, isEmpty);
    });
  });
}

/// Records each posted slice instead of calling the network.
class _SlicingRepo extends ItemRepository {
  _SlicingRepo({this.failOnCall, this.unsupportedOnCall});

  final int? failOnCall;
  final int? unsupportedOnCall;
  final List<List<Map<String, dynamic>>> posted = [];

  @override
  Future<BatchSaveResult> batchSaveItems({
    String? jobId,
    required List<Map<String, dynamic>> entries,
  }) async {
    final call = posted.length;
    posted.add(entries);
    if (call == unsupportedOnCall) throw BatchSaveUnsupported();
    if (call == failOnCall) throw Exception('offline');
    return const BatchSaveResult(saved: [], failed: []);
  }
}

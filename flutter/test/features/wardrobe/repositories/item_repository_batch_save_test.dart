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
  });

  test('batchSaveEntry omits images when the piece has no image yet', () {
    final entry = ItemRepository.batchSaveEntry(
      tempId: 't3',
      request: request(),
    );

    final item = entry['item'] as Map<String, dynamic>;
    expect(item.containsKey('images'), isFalse);
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

import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// TD-109: the item create must carry an idempotency key, because the backend
/// replays a committed create instead of inserting a duplicate when it sees a
/// key it has already stored. Asserted on the request BODY because the
/// transport is an [ApiClient] singleton with no injectable seam.
void main() {
  CreateItemRequest request() =>
      CreateItemRequest(name: 'Blue Shirt', category: Category.tops);

  test('createItemPayload forwards the caller-supplied key', () {
    final payload = ItemRepository().createItemPayload(
      request(),
      clientRequestId: 'item-abc',
    );

    expect(payload['client_request_id'], 'item-abc');
    expect(payload['name'], 'Blue Shirt');
  });

  test('createItemPayload mints a fresh key when the caller has none', () {
    final repository = ItemRepository();

    final first = repository.createItemPayload(request());
    final second = repository.createItemPayload(request());

    final firstKey = first['client_request_id'];
    expect(firstKey, isA<String>());
    expect((firstKey! as String).isNotEmpty, isTrue);
    expect(
      (firstKey as String).length,
      lessThanOrEqualTo(64),
      reason: 'the backend caps client_request_id at 64 chars',
    );
    expect(
      second['client_request_id'],
      isNot(firstKey),
      reason: 'two separate saves must not collapse into one replay',
    );
  });
}

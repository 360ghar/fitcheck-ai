/// Idempotency keys for write endpoints.
///
/// The backend accepts a `client_request_id` on the create endpoints (items,
/// outfits, gifts) and REPLAYS the committed row when it sees a key it has
/// already stored instead of inserting a duplicate. That is what makes a retry
/// safe after a response is lost in transit (the server committed, the client
/// never saw it) and after the user re-taps Save on a partially failed batch.
///
/// TD-109: the item create paths sent no key at all, so a retry either
/// duplicated the item or - when it re-sent a temp key the server had already
/// deleted after the first attempt committed - failed with a 503 that no retry
/// could clear.
///
/// Contract for callers: mint the key ONCE per logical save and keep it until
/// that save succeeds, so every attempt of the same save sends the same value,
/// and different saves send different values. The backend caps the field at 64
/// chars (`ItemCreate`); the format below stays well inside that.
library;

import 'dart:math';

final Random _random = Random();

/// A fresh idempotency key: `<prefix>-<microseconds>-<random>`.
String newRequestId(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

/// Stable identity for one item's key within a save.
///
/// Prefer the model's own id, which identifies the garment across attempts and
/// re-taps of Save. Fall back to the object's identity when the model carries no
/// usable id (`null`, empty, or the `'unknown'` sentinel that
/// `DetectedItemData.fromJson` uses for a missing `temp_id`): two garments
/// sharing an identity would COLLAPSE into one item, because the second create
/// would replay the first row instead of inserting its own.
String requestIdIdentity(String? modelId, Object item) {
  final id = modelId?.trim() ?? '';
  if (id.isEmpty || id == 'unknown') {
    return 'anonymous#${identityHashCode(item)}';
  }
  return id;
}

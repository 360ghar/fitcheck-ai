import 'package:fitcheck_ai/core/utils/request_id.dart';
import 'package:flutter_test/flutter_test.dart';

/// TD-109: the idempotency key handed to the backend must be unique per save
/// and stable for a given item across retries of the same save.
void main() {
  group('newRequestId', () {
    test('is prefixed, unique per call, and inside the backend 64-char cap', () {
      final first = newRequestId('item');
      final second = newRequestId('item');

      expect(first.startsWith('item-'), isTrue);
      expect(first, isNot(second));
      expect(first.length, lessThanOrEqualTo(64));
    });
  });

  group('requestIdIdentity', () {
    test('uses the model id when there is one', () {
      final item = Object();

      expect(requestIdIdentity('temp-1', item), 'temp-1');
      expect(
        requestIdIdentity('temp-1', item),
        requestIdIdentity('temp-1', Object()),
        reason: 'the model id identifies the garment, not the instance',
      );
    });

    test('falls back to object identity for missing ids', () {
      final first = Object();
      final second = Object();

      for (final missing in <String?>[null, '', '   ', 'unknown']) {
        expect(
          requestIdIdentity(missing, first),
          startsWith('anonymous#'),
          reason: 'a missing id must not become a shared key',
        );
      }
      expect(
        requestIdIdentity('unknown', first),
        isNot(requestIdIdentity('unknown', second)),
        reason: 'two garments sharing the sentinel must not collapse into one',
      );
      expect(
        requestIdIdentity('unknown', first),
        requestIdIdentity('unknown', first),
        reason: 'the same garment must reuse its identity across retries',
      );
    });
  });
}

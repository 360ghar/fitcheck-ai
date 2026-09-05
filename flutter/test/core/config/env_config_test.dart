import 'package:fitcheck_ai/core/config/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gift vouchers are enabled when no override is supplied', () {
    expect(EnvConfig.giftVouchersEnabled, isTrue);
  });

  group('EnvConfig inline comments', () {
    test(
      'keeps literal hashes and quoted hashes while removing real comments',
      () {
        expect(EnvConfig.stripInlineCommentForTesting('#code'), '#code');
        expect(
          EnvConfig.stripInlineCommentForTesting('"value # literal" # comment'),
          '"value # literal"',
        );
        expect(
          EnvConfig.stripInlineCommentForTesting("it's a value # comment"),
          "it's a value",
        );
      },
    );

    test('does not let an unmatched quote hide a trailing comment', () {
      expect(
        EnvConfig.stripInlineCommentForTesting(
          'value" still unquoted # comment',
        ),
        'value" still unquoted',
      );
      expect(
        EnvConfig.stripInlineCommentForTesting('"unterminated # comment'),
        '"unterminated',
      );
    });
  });
}

import 'dart:math' as math;

import 'package:fitcheck_ai/core/theme/paper_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final entry in {'light': PaperTokens.light, 'dark': PaperTokens.dark}
      .entries) {
    final t = entry.value;
    group('${entry.key} paper tokens meet WCAG AA', () {
      for (final id in PaperStockId.values) {
        final s = t.stockOf(id);
        final surfaces = {
          'page': s.page,
          'card': s.card,
          'sunk': s.sunk,
          'tint': s.tint,
        };
        test(id.name, () {
          final failures = <String>[];
          void check(String what, Color fg, Color bg, double min) {
            final r = _contrast(fg, bg);
            if (r < min) failures.add('$what ${r.toStringAsFixed(2)} < $min');
          }

          for (final surface in surfaces.entries) {
            final n = surface.key;
            check('text on $n', t.textPrimary, surface.value, 4.5);
            check('secondary on $n', t.textSecondary, surface.value, 4.5);
            check('muted on $n', t.textMuted, surface.value, 4.5);
            check('accent on $n', s.accent, surface.value, 4.5);
            check('success on $n', t.success, surface.value, 4.5);
            check('warning on $n', t.warning, surface.value, 4.5);
            check('error on $n', t.error, surface.value, 4.5);
            // A filled primary button edge needs 3:1 where it sits (page or
            // card). In dark mode the white label (5:1 on red) identifies
            // the button, as WCAG 1.4.11 allows.
            if (entry.key == 'light' && (n == 'page' || n == 'card')) {
              check('brand fill on $n', t.brand, surface.value, 3);
            }
          }
          check('onAccent on accent', s.onAccent, s.accent, 4.5);
          expect(failures, isEmpty, reason: failures.join('\n'));
        });
      }
      test('white on brand red', () {
        expect(_contrast(t.onBrand, t.brand), greaterThanOrEqualTo(4.5));
      });
    });
  }
}

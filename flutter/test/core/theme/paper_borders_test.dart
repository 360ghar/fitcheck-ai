import 'package:fitcheck_ai/core/theme/paper_borders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deckle generation terminates for tiny and invalid steps', () {
    for (final step in [1e-20, 0.0, -1.0, double.nan, double.infinity]) {
      for (final edge in [PaperEdge.top, PaperEdge.bottom]) {
        final path = DeckleBorder(
          step: step,
          edge: edge,
        ).getOuterPath(const Rect.fromLTWH(100, 100, 200, 100));
        expect(path.getBounds().isFinite, isTrue);
        expect(path.contains(const Offset(200, 150)), isTrue);
      }
    }
  });
}

import 'package:flutter/material.dart';

import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';

/// A cut-paper garment silhouette for a category: the closet's own icon set,
/// drawn from the same shapes as the paper scenes.
class GarmentGlyph extends StatelessWidget {
  const GarmentGlyph({super.key, required this.category, this.size = 48});

  final Category category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return Semantics(
      label: category.displayName,
      child: CustomPaint(
        size: Size.square(size),
        painter: _GlyphPainter(
          category: category,
          fill: tokens.cutOf(tokens.current),
          slab: tokens.stock.shadow,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter({
    required this.category,
    required this.fill,
    required this.slab,
  });

  final Category category;
  final Color fill;
  final Color slab;

  Path _shape(Size s) => switch (category) {
    Category.tops ||
    Category.activewear => paperTee(s, const Offset(0.5, 0.12), 0.76),
    Category.outerwear => paperCoat(s, const Offset(0.5, 0.06), 0.8),
    Category.bottoms => paperTrousers(s, const Offset(0.5, 0.08), 0.5),
    Category.swimwear => paperDress(s, const Offset(0.5, 0.04), 0.56),
    Category.shoes => paperShoe(s, const Offset(0.5, 0.32), 0.86),
    Category.accessories => paperBag(s, const Offset(0.5, 0.12), 0.7),
    Category.other => paperScrap(s, const Offset(0.5, 0.5), 0.7, -0.15, 5),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final path = _shape(size);
    canvas.drawPath(path.shift(const Offset(1, 2)), Paint()..color = slab);
    canvas.drawPath(path, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.category != category || old.fill != fill || old.slab != slab;
}

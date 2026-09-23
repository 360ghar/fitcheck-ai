import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// A rounded rectangle with a solid paper slab offset below it: the edge of
/// the sheet underneath. The slab is never blurred.
///
/// Material paints a shape's border in the foreground, so only the part of
/// the slab outside the face is drawn. The face itself stays clean.
class PaperSlabBorder extends RoundedRectangleBorder {
  const PaperSlabBorder({
    super.side,
    super.borderRadius,
    this.slab = const Color(0x33000000),
    this.depth = 3,
  });

  /// Slab colour.
  final Color slab;

  /// Downward offset of the slab in logical pixels. 0 hides it.
  final double depth;

  @override
  PaperSlabBorder copyWith({
    BorderSide? side,
    BorderRadiusGeometry? borderRadius,
    Color? slab,
    double? depth,
  }) => PaperSlabBorder(
    side: side ?? this.side,
    borderRadius: borderRadius ?? this.borderRadius,
    slab: slab ?? this.slab,
    depth: depth ?? this.depth,
  );

  @override
  ShapeBorder scale(double t) => PaperSlabBorder(
    side: side.scale(t),
    borderRadius: borderRadius * t,
    slab: slab,
    depth: depth * t,
  );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is PaperSlabBorder) return _lerp(a, this, t);
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is PaperSlabBorder) return _lerp(this, b, t);
    return super.lerpTo(b, t);
  }

  static PaperSlabBorder _lerp(PaperSlabBorder a, PaperSlabBorder b, double t) =>
      PaperSlabBorder(
        side: BorderSide.lerp(a.side, b.side, t),
        borderRadius: BorderRadiusGeometry.lerp(
          a.borderRadius,
          b.borderRadius,
          t,
        )!,
        slab: Color.lerp(a.slab, b.slab, t)!,
        depth: lerpDouble(a.depth, b.depth, t)!,
      );

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (depth > 0) {
      final face = borderRadius.resolve(textDirection).toRRect(rect);
      final below = Path.combine(
        PathOperation.difference,
        Path()..addRRect(face.shift(Offset(depth / 2, depth))),
        Path()..addRRect(face),
      );
      canvas.drawPath(below, Paint()..color = slab);
    }
    super.paint(canvas, rect, textDirection: textDirection);
  }

  @override
  bool operator ==(Object other) =>
      other is PaperSlabBorder &&
      other.side == side &&
      other.borderRadius == borderRadius &&
      other.slab == slab &&
      other.depth == depth;

  @override
  int get hashCode => Object.hash(side, borderRadius, slab, depth);
}

/// Which edge of a surface is torn.
enum PaperEdge { none, top, bottom }

/// A rounded rectangle whose [edge] is torn like hand-ripped paper.
///
/// The tear is seeded, so the same size always gives the same edge.
class DeckleBorder extends OutlinedBorder {
  const DeckleBorder({
    super.side,
    this.edge = PaperEdge.bottom,
    this.radius = 12,
    this.amplitude = 1.8,
    this.step = 6,
    this.seed = 7,
  });

  final PaperEdge edge;
  final double radius;

  /// Maximum depth of the tear in logical pixels.
  final double amplitude;

  /// Horizontal distance between tear points.
  final double step;
  final int seed;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  DeckleBorder copyWith({BorderSide? side}) => DeckleBorder(
    side: side ?? this.side,
    edge: edge,
    radius: radius,
    amplitude: amplitude,
    step: step,
    seed: seed,
  );

  @override
  ShapeBorder scale(double t) => DeckleBorder(
    side: side.scale(t),
    edge: edge,
    radius: radius * t,
    amplitude: amplitude * t,
    step: step,
    seed: seed,
  );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(side.width), textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r = math.min(radius, rect.shortestSide / 2);
    final rng = math.Random(seed);
    final path = Path();
    final torn = <Offset>[];
    for (var x = rect.left + r; x < rect.right - r; x += step) {
      torn.add(Offset(x, rng.nextDouble() * amplitude));
    }
    torn.add(Offset(rect.right - r, 0));

    // Top edge, left to right.
    path.moveTo(rect.left, rect.top + r);
    path.arcToPoint(Offset(rect.left + r, rect.top), radius: Radius.circular(r));
    if (edge == PaperEdge.top) {
      for (final p in torn) {
        path.lineTo(p.dx, rect.top + p.dy);
      }
    } else {
      path.lineTo(rect.right - r, rect.top);
    }
    path.arcToPoint(Offset(rect.right, rect.top + r), radius: Radius.circular(r));

    // Right edge, then bottom edge right to left.
    path.lineTo(rect.right, rect.bottom - r);
    path.arcToPoint(
      Offset(rect.right - r, rect.bottom),
      radius: Radius.circular(r),
    );
    if (edge == PaperEdge.bottom) {
      for (final p in torn.reversed) {
        path.lineTo(p.dx, rect.bottom - p.dy);
      }
    } else {
      path.lineTo(rect.left + r, rect.bottom);
    }
    path.arcToPoint(
      Offset(rect.left, rect.bottom - r),
      radius: Radius.circular(r),
    );
    return path..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    canvas.drawPath(
      getOuterPath(rect, textDirection: textDirection),
      side.toPaint(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DeckleBorder &&
      other.side == side &&
      other.edge == edge &&
      other.radius == radius &&
      other.amplitude == amplitude &&
      other.step == step &&
      other.seed == seed;

  @override
  int get hashCode => Object.hash(side, edge, radius, amplitude, step, seed);
}

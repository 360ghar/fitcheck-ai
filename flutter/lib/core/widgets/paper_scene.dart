import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'paper.dart';

/// One cut-paper layer of a [PaperScene].
@immutable
class PaperLayer {
  const PaperLayer({
    required this.color,
    required this.shape,
    this.depth = 0.5,
    this.stroke,
    this.sway = 0,
    this.pivot,
    this.slab = true,
  });

  final Color color;

  /// The layer outline for a scene of the given size.
  final Path Function(Size size) shape;

  /// 0 = far back (moves least with scroll), 1 = front.
  final double depth;

  /// Paints the outline as a line of this width instead of a fill.
  final double? stroke;

  /// Maximum sway angle in radians. The layer rocks slowly on [pivot].
  final double sway;
  final Offset Function(Size size)? pivot;

  /// Draws a solid offset slab under the layer.
  final bool slab;
}

/// Builds the layers of a scene from the current paper tokens.
typedef PaperScenePreset = List<PaperLayer> Function(PaperTokens tokens);

/// A diorama of stacked paper layers.
///
/// Layers are painted back to front, each over its own solid slab. Inside a
/// scroll view the back layers trail the front ones (parallax). Swaying
/// layers rock slowly. Motion stops when the platform asks for reduced
/// motion. The scene is always fully painted: nothing waits on an animation.
class PaperScene extends StatefulWidget {
  const PaperScene({
    super.key,
    required this.preset,
    this.height = 200,
    this.parallax = 0.35,
    this.background,
    this.grain = true,
    this.child,
  });

  final PaperScenePreset preset;

  /// Paints the paper grain over the scene. Turn it off when the parent
  /// already lays grain across the scene and the page around it.
  final bool grain;

  /// Sky colour behind the layers. Defaults to the stock's page colour, so
  /// the scene and the page around it carry one even grain with no seam.
  final Color? background;

  /// Scene height. Null fills the parent.
  final double? height;
  final double parallax;

  /// Content painted over the scene.
  final Widget? child;

  @override
  State<PaperScene> createState() => _PaperSceneState();
}

class _PaperSceneState extends State<PaperScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sway = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = !MediaQuery.disableAnimationsOf(context);
    if (animate && !_sway.isAnimating) {
      _sway.repeat(reverse: true);
    } else if (!animate && _sway.isAnimating) {
      _sway.stop();
    }
  }

  @override
  void dispose() {
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final layers = widget.preset(tokens);
    final animate = !MediaQuery.disableAnimationsOf(context);
    final scroll = animate ? Scrollable.maybeOf(context)?.position : null;
    final swaying = animate && layers.any((l) => l.sway != 0);
    final grain = widget.grain ? paperGrain(context) : null;

    final scene = RepaintBoundary(
      child: CustomPaint(
        painter: _SkyPainter(widget.background ?? tokens.stock.page),
        child: CustomPaint(
          painter: _ScenePainter(
            layers: layers,
            shadow: tokens.stock.shadow,
            scroll: scroll,
            parallax: widget.parallax,
            sway: swaying ? _sway : null,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(image: grain),
            child: widget.child ?? const SizedBox.expand(),
          ),
        ),
      ),
    );
    return widget.height == null
        ? scene
        : SizedBox(height: widget.height, width: double.infinity, child: scene);
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawRect(Offset.zero & size, Paint()..color = color);

  @override
  bool shouldRepaint(_SkyPainter old) => old.color != color;
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.layers,
    required this.shadow,
    required this.scroll,
    required this.parallax,
    required this.sway,
  }) : super(repaint: Listenable.merge([scroll, sway]));

  final List<PaperLayer> layers;
  final Color shadow;
  final ScrollPosition? scroll;
  final double parallax;
  final Animation<double>? sway;

  Size? _cachedFor;
  List<Path> _paths = const [];

  static const _slabOffset = Offset(1.5, 3);

  @override
  void paint(Canvas canvas, Size size) {
    if (_cachedFor != size) {
      _paths = [for (final l in layers) l.shape(size)];
      _cachedFor = size;
    }
    final pixels = scroll?.hasPixels == true
        ? scroll!.pixels.clamp(-80.0, 400.0)
        : 0.0;
    final t = sway == null ? 0.5 : Curves.easeInOut.transform(sway!.value);

    canvas.save();
    // A hard clip: an anti-aliased one fades each layer separately on a
    // fractional bottom row, and the back layers show through as a line.
    canvas.clipRect(Offset.zero & size, doAntiAlias: false);
    for (var i = 0; i < layers.length; i++) {
      final layer = layers[i];
      canvas.save();
      canvas.translate(0, pixels * (1 - layer.depth) * parallax);
      if (layer.sway != 0 && layer.pivot != null) {
        final pivot = layer.pivot!(size);
        canvas.translate(pivot.dx, pivot.dy);
        canvas.rotate((t * 2 - 1) * layer.sway);
        canvas.translate(-pivot.dx, -pivot.dy);
      }
      final paint = Paint()..isAntiAlias = true;
      if (layer.stroke != null) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = layer.stroke!
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
      }
      if (layer.slab) {
        canvas.drawPath(
          _paths[i].shift(_slabOffset),
          Paint.from(paint)..color = shadow.withValues(alpha: 0.55),
        );
      }
      canvas.drawPath(_paths[i], paint..color = layer.color);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.layers.length != layers.length ||
      old.shadow != shadow ||
      old.scroll != scroll ||
      old.sway != sway ||
      !_sameColors(old.layers, layers);

  static bool _sameColors(List<PaperLayer> a, List<PaperLayer> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i].color != b[i].color) return false;
    }
    return true;
  }
}

// ---------------------------------------------------------------------------
// Cut-paper shapes. All take the scene size and fractional coordinates.
// ---------------------------------------------------------------------------

/// A hill band with a torn top edge, filled to the bottom of the scene.
Path paperRidge(
  Size s, {
  required double y,
  double amp = 10,
  double waves = 1.3,
  int seed = 1,
}) {
  final rng = math.Random(seed);
  final phase = rng.nextDouble() * math.pi * 2;
  const steps = 56;
  final p = Path()..moveTo(-4, s.height + 4);
  for (var i = 0; i <= steps; i++) {
    final f = i / steps;
    final wave = math.sin(phase + f * math.pi * 2 * waves) * amp;
    final tear = (rng.nextDouble() - 0.5) * 2.4;
    p.lineTo(-4 + f * (s.width + 8), y * s.height + wave + tear);
  }
  return p
    ..lineTo(s.width + 4, s.height + 4)
    ..close();
}

/// A disc (sun, moon, spotlight). [radius] is a fraction of the shorter
/// side, so a disc keeps its size in a tall scene.
Path paperDisc(Size s, Offset centre, double radius) => Path()
  ..addOval(
    Rect.fromCircle(
      center: Offset(centre.dx * s.width, centre.dy * s.height),
      radius: radius * s.shortestSide,
    ),
  );

/// A sagging line between the scene edges, lowest at the middle.
Path paperLine(Size s, {required double y, required double sag}) => Path()
  ..moveTo(-8, y * s.height)
  ..quadraticBezierTo(
    s.width / 2,
    (y + sag * 2) * s.height,
    s.width + 8,
    y * s.height,
  );

/// Height (fraction) of [paperLine] at horizontal fraction [x].
double paperLineY(double x, {required double y, required double sag}) {
  final t = x.clamp(0.0, 1.0);
  return y + 2 * (1 - t) * t * sag * 2;
}

Path _normalised(Size s, Rect box, List<Offset> points, {Offset? neck}) {
  Offset at(Offset p) =>
      Offset(box.left + p.dx * box.width, box.top + p.dy * box.height);
  final p = Path()..moveTo(at(points.first).dx, at(points.first).dy);
  for (final pt in points.skip(1)) {
    final o = at(pt);
    p.lineTo(o.dx, o.dy);
  }
  if (neck != null) {
    final c = at(neck);
    final start = at(points.first);
    p.quadraticBezierTo(c.dx, c.dy, start.dx, start.dy);
  }
  return p..close();
}

Rect _box(Size s, Offset topCentre, double width, double aspect) {
  final w = width * s.width;
  final h = w * aspect;
  return Rect.fromLTWH(
    topCentre.dx * s.width - w / 2,
    topCentre.dy * s.height,
    w,
    h,
  );
}

/// A T-shirt cut-out hanging from [topCentre].
Path paperTee(Size s, Offset topCentre, double width) =>
    _normalised(s, _box(s, topCentre, width, 1.0), const [
      Offset(0.64, 0.00),
      Offset(0.90, 0.09),
      Offset(1.00, 0.33),
      Offset(0.84, 0.41),
      Offset(0.78, 0.33),
      Offset(0.78, 1.00),
      Offset(0.22, 1.00),
      Offset(0.22, 0.33),
      Offset(0.16, 0.41),
      Offset(0.00, 0.33),
      Offset(0.10, 0.09),
      Offset(0.36, 0.00),
    ], neck: const Offset(0.50, 0.15));

/// A sleeveless A-line dress cut-out hanging from [topCentre].
Path paperDress(Size s, Offset topCentre, double width) =>
    _normalised(s, _box(s, topCentre, width, 1.55), const [
      Offset(0.66, 0.00),
      Offset(0.72, 0.24),
      Offset(0.62, 0.36),
      Offset(1.00, 1.00),
      Offset(0.00, 1.00),
      Offset(0.38, 0.36),
      Offset(0.28, 0.24),
      Offset(0.34, 0.00),
    ], neck: const Offset(0.50, 0.14));

/// A long coat with sleeves and an open front, hanging from [topCentre].
Path paperCoat(Size s, Offset topCentre, double width) {
  final box = _box(s, topCentre, width, 1.05);
  final coat = _normalised(s, box, const [
    Offset(0.62, 0.00),
    Offset(0.88, 0.07),
    Offset(1.00, 0.72),
    Offset(0.86, 0.74),
    Offset(0.80, 0.40),
    Offset(0.80, 1.00),
    Offset(0.20, 1.00),
    Offset(0.20, 0.40),
    Offset(0.14, 0.74),
    Offset(0.00, 0.72),
    Offset(0.12, 0.07),
    Offset(0.38, 0.00),
  ], neck: const Offset(0.50, 0.30));
  // The open front: a slit from the collar down.
  final slit = Rect.fromLTWH(
    box.left + box.width * 0.485,
    box.top + box.height * 0.28,
    box.width * 0.03,
    box.height * 0.72,
  );
  return Path.combine(PathOperation.difference, coat, Path()..addRect(slit));
}

/// Straight-leg trousers cut-out hanging from [topCentre].
Path paperTrousers(Size s, Offset topCentre, double width) =>
    _normalised(s, _box(s, topCentre, width, 1.7), const [
      Offset(0.00, 0.00),
      Offset(1.00, 0.00),
      Offset(0.98, 1.00),
      Offset(0.58, 1.00),
      Offset(0.50, 0.30),
      Offset(0.42, 1.00),
      Offset(0.02, 1.00),
    ]);

/// A loafer in profile, toe to the right, resting on [topCentre]'s row.
Path paperShoe(Size s, Offset topCentre, double width) =>
    _normalised(s, _box(s, topCentre, width, 0.5), const [
      Offset(0.00, 0.20),
      Offset(0.30, 0.10),
      Offset(0.52, 0.34),
      Offset(0.80, 0.46),
      Offset(1.00, 0.70),
      Offset(1.00, 1.00),
      Offset(0.00, 1.00),
    ]);

/// A tote bag with a looped handle.
Path paperBag(Size s, Offset topCentre, double width) {
  final b = _box(s, topCentre, width, 0.95);
  final body = Rect.fromLTRB(b.left, b.top + b.height * 0.3, b.right, b.bottom);
  final handle = Rect.fromLTRB(
    b.left + b.width * 0.25,
    b.top,
    b.right - b.width * 0.25,
    b.top + b.height * 0.6,
  );
  return Path.combine(
    PathOperation.union,
    Path()..addRRect(
      RRect.fromRectAndRadius(body, Radius.circular(b.width * 0.08)),
    ),
    Path.combine(
      PathOperation.difference,
      Path()..addOval(handle),
      Path()..addOval(handle.deflate(b.width * 0.07)),
    ),
  );
}

/// A wire hanger outline hanging from [topCentre]; paint with a stroke.
Path paperHanger(Size s, Offset topCentre, double width) {
  final b = _box(s, topCentre, width, 0.55);
  final cx = b.center.dx;
  return Path()
    ..moveTo(cx + b.width * 0.08, b.top)
    ..quadraticBezierTo(cx, b.top - b.height * 0.1, cx, b.top + b.height * 0.2)
    ..lineTo(cx, b.top + b.height * 0.32)
    ..lineTo(b.right, b.bottom)
    ..lineTo(b.left, b.bottom)
    ..close();
}

/// A cloud cut-out centred on [centre].
Path paperCloud(Size s, Offset centre, double width) {
  final w = width * s.width;
  final c = Offset(centre.dx * s.width, centre.dy * s.height);
  return Path()
    ..addOval(
      Rect.fromCircle(
        center: c.translate(-w * 0.22, w * 0.05),
        radius: w * 0.2,
      ),
    )
    ..addOval(
      Rect.fromCircle(
        center: c.translate(w * 0.02, -w * 0.08),
        radius: w * 0.27,
      ),
    )
    ..addOval(
      Rect.fromCircle(
        center: c.translate(w * 0.27, w * 0.06),
        radius: w * 0.18,
      ),
    )
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(c.dx - w * 0.4, c.dy, c.dx + w * 0.44, c.dy + w * 0.24),
        Radius.circular(w * 0.12),
      ),
    );
}

/// A torn paper scrap, slightly rotated.
Path paperScrap(Size s, Offset centre, double width, double angle, int seed) {
  final w = width * s.width;
  final h = w * 0.72;
  final rng = math.Random(seed);
  final pts = <Offset>[];
  const n = 10;
  for (var i = 0; i <= n; i++) {
    pts.add(Offset(-w / 2 + w * i / n, -h / 2 + (rng.nextDouble() - 0.5) * 3));
  }
  for (var i = n; i >= 0; i--) {
    pts.add(Offset(-w / 2 + w * i / n, h / 2 + (rng.nextDouble() - 0.5) * 5));
  }
  final m = Matrix4.identity()
    ..translateByDouble(centre.dx * s.width, centre.dy * s.height, 0, 1)
    ..rotateZ(angle);
  // Path.transform returns a new path; a cascade would drop it.
  return (Path()..addPolygon(pts, true)).transform(m.storage);
}

// ---------------------------------------------------------------------------
// Scene presets.
// ---------------------------------------------------------------------------

/// Garments pinned to a line: [x] fractions along the line.
List<PaperLayer> _washingLine(
  PaperTokens t, {
  required double y,
  required double sag,
  required List<(double, Color, Path Function(Size, Offset, double), double)>
  garments,
  required double depth,
}) => [
  PaperLayer(
    color: t.isDark ? t.textMuted : t.stock.shadow,
    shape: (s) => paperLine(s, y: y, sag: sag),
    stroke: 1.6,
    depth: depth,
    slab: false,
  ),
  for (final (i, g) in garments.indexed)
    PaperLayer(
      color: g.$2,
      depth: depth,
      sway: 0.05 + i * 0.012,
      pivot: (s) =>
          Offset(g.$1 * s.width, paperLineY(g.$1, y: y, sag: sag) * s.height),
      shape: (s) =>
          g.$3(s, Offset(g.$1, paperLineY(g.$1, y: y, sag: sag)), g.$4),
    ),
];

abstract final class PaperScenes {
  /// Home: hills under a low sun, a washing line of today's pieces.
  static List<PaperLayer> home(PaperTokens t) => [
    PaperLayer(
      color: t.cutOf(PaperStockId.marigold, light: true),
      shape: (s) => paperDisc(s, const Offset(0.8, 0.56), 0.13),
      depth: 0.1,
    ),
    PaperLayer(
      color: t.stock.tint,
      shape: (s) => paperRidge(s, y: 0.6, amp: 12, seed: 3),
      depth: 0.2,
    ),
    ..._washingLine(
      t,
      y: 0.16,
      sag: 0.08,
      depth: 0.45,
      garments: [
        (0.24, t.cutOf(PaperStockId.clay), paperTee, 0.16),
        (0.44, t.cutOf(PaperStockId.moss), paperDress, 0.11),
        (0.62, t.cutOf(PaperStockId.marigold), paperTrousers, 0.09),
      ],
    ),
    PaperLayer(
      color: t.stock.edge,
      shape: (s) => paperRidge(s, y: 0.8, amp: 7, waves: 1.8, seed: 5),
      depth: 0.6,
    ),
    PaperLayer(
      color: t.stock.page,
      shape: (s) => paperRidge(s, y: 0.93, amp: 4, waves: 2.4, seed: 9),
      depth: 1,
    ),
  ];

  /// Closet: a rail of hangers over a low ridge.
  static List<PaperLayer> closet(PaperTokens t) => [
    PaperLayer(
      color: t.stock.tint,
      shape: (s) => paperRidge(s, y: 0.66, amp: 9, seed: 11),
      depth: 0.2,
    ),
    PaperLayer(
      color: t.isDark ? t.textMuted : t.stock.shadow,
      shape: (s) => Path()
        ..moveTo(s.width * 0.06, s.height * 0.2)
        ..lineTo(s.width * 0.94, s.height * 0.2),
      stroke: 3,
      depth: 0.45,
      slab: false,
    ),
    for (final (i, x) in const [0.22, 0.4, 0.58, 0.76].indexed)
      PaperLayer(
        color: [
          t.cutOf(PaperStockId.clay),
          t.cutOf(PaperStockId.moss),
          t.cutOf(PaperStockId.marigold),
          t.cutOf(PaperStockId.ink),
        ][i],
        depth: 0.45,
        sway: 0.04,
        pivot: (s) => Offset(x * s.width, s.height * 0.2),
        shape: (s) => i.isEven
            ? paperTee(s, Offset(x, 0.2), 0.13)
            : paperDress(s, Offset(x, 0.2), 0.1),
      ),
    PaperLayer(
      color: t.stock.page,
      shape: (s) => paperRidge(s, y: 0.9, amp: 4, waves: 2.2, seed: 13),
      depth: 1,
    ),
  ];

  /// Outfits: a paired look pinned side by side.
  static List<PaperLayer> outfits(PaperTokens t) => [
    PaperLayer(
      color: t.stock.tint,
      shape: (s) => paperDisc(s, const Offset(0.5, 0.42), 0.32),
      depth: 0.1,
    ),
    PaperLayer(
      color: t.cutOf(PaperStockId.ink),
      shape: (s) => paperTee(s, const Offset(0.42, 0.18), 0.2),
      depth: 0.4,
      sway: 0.03,
      pivot: (s) => Offset(s.width * 0.42, s.height * 0.18),
    ),
    PaperLayer(
      color: t.cutOf(PaperStockId.clay),
      shape: (s) => paperTrousers(s, const Offset(0.6, 0.3), 0.12),
      depth: 0.5,
      sway: 0.035,
      pivot: (s) => Offset(s.width * 0.6, s.height * 0.3),
    ),
    PaperLayer(
      color: t.stock.edge,
      shape: (s) => paperRidge(s, y: 0.82, amp: 6, waves: 1.6, seed: 17),
      depth: 0.6,
    ),
    PaperLayer(
      color: t.stock.page,
      shape: (s) => paperRidge(s, y: 0.94, amp: 3.5, waves: 2.6, seed: 19),
      depth: 1,
    ),
  ];

  /// Studio: a paper backdrop sweep under a spotlight.
  static List<PaperLayer> studio(PaperTokens t) => [
    PaperLayer(
      color: t.stock.tint,
      shape: (s) => Path()
        ..moveTo(s.width * 0.14, 0)
        ..lineTo(s.width * 0.86, 0)
        ..lineTo(s.width * 0.86, s.height * 0.62)
        ..quadraticBezierTo(
          s.width * 0.86,
          s.height * 0.86,
          s.width,
          s.height * 0.86,
        )
        ..lineTo(0, s.height * 0.86)
        ..quadraticBezierTo(
          s.width * 0.14,
          s.height * 0.86,
          s.width * 0.14,
          s.height * 0.62,
        )
        ..close(),
      depth: 0.2,
    ),
    PaperLayer(
      color: t.cutOf(PaperStockId.marigold, light: true),
      shape: (s) => paperDisc(s, const Offset(0.5, 0.2), 0.11),
      depth: 0.3,
    ),
    PaperLayer(
      color: t.cutOf(PaperStockId.moss),
      shape: (s) => paperDress(s, const Offset(0.5, 0.34), 0.13),
      depth: 0.5,
      sway: 0.025,
      pivot: (s) => Offset(s.width * 0.5, s.height * 0.34),
    ),
    PaperLayer(
      color: t.stock.page,
      shape: (s) => paperRidge(s, y: 0.92, amp: 3, waves: 2, seed: 23),
      depth: 1,
    ),
  ];

  /// Offline: a cloud with the line cut.
  static List<PaperLayer> offline(PaperTokens t) => [
    PaperLayer(
      color: t.stock.tint,
      shape: (s) => paperRidge(s, y: 0.72, amp: 8, seed: 29),
      depth: 0.2,
    ),
    PaperLayer(
      color: t.stock.card,
      shape: (s) => paperCloud(s, const Offset(0.5, 0.38), 0.34),
      depth: 0.4,
    ),
    PaperLayer(
      color: t.textMuted,
      shape: (s) => Path()
        ..moveTo(s.width * 0.36, s.height * 0.16)
        ..lineTo(s.width * 0.64, s.height * 0.66),
      stroke: 3,
      depth: 0.4,
      slab: false,
    ),
    PaperLayer(
      color: t.stock.page,
      shape: (s) => paperRidge(s, y: 0.92, amp: 3.5, waves: 2.2, seed: 31),
      depth: 1,
    ),
  ];

  /// Something went wrong: torn scraps of paper.
  static List<PaperLayer> oops(PaperTokens t) => [
    PaperLayer(
      color: t.stock.tint,
      shape: (s) => paperRidge(s, y: 0.7, amp: 9, seed: 37),
      depth: 0.2,
    ),
    PaperLayer(
      color: t.cutOf(PaperStockId.ink),
      shape: (s) => paperScrap(s, const Offset(0.42, 0.44), 0.24, -0.2, 41),
      depth: 0.4,
    ),
    PaperLayer(
      color: t.cutOf(PaperStockId.clay),
      shape: (s) => paperScrap(s, const Offset(0.58, 0.5), 0.2, 0.24, 43),
      depth: 0.5,
    ),
    PaperLayer(
      color: t.cutOf(PaperStockId.marigold),
      shape: (s) => paperScrap(s, const Offset(0.5, 0.3), 0.12, 0.5, 47),
      depth: 0.45,
    ),
    PaperLayer(
      color: t.stock.page,
      shape: (s) => paperRidge(s, y: 0.92, amp: 3.5, waves: 2.4, seed: 47),
      depth: 1,
    ),
  ];

  /// Sign-in: a washing line over layered hills, filling its whole band.
  static List<PaperLayer> auth(PaperTokens t) => [
    PaperLayer(
      color: t.cutOf(PaperStockId.marigold, light: true),
      shape: (s) => paperDisc(s, const Offset(0.8, 0.5), 0.1),
      depth: 0.05,
    ),
    PaperLayer(
      color: t.stock.tint,
      shape: (s) => paperRidge(s, y: 0.52, amp: 14, waves: 1.1, seed: 53),
      depth: 0.15,
    ),
    ..._washingLine(
      t,
      y: 0.1,
      sag: 0.05,
      depth: 0.3,
      garments: [
        (0.16, t.cutOf(PaperStockId.clay), paperTee, 0.18),
        (0.38, t.cutOf(PaperStockId.moss), paperDress, 0.12),
        (0.58, t.cutOf(PaperStockId.marigold), paperTrousers, 0.1),
      ],
    ),
    PaperLayer(
      color: t.stock.edge,
      shape: (s) => paperRidge(s, y: 0.74, amp: 9, waves: 1.7, seed: 59),
      depth: 0.4,
    ),
    PaperLayer(
      color: t.stock.page,
      shape: (s) => paperRidge(s, y: 0.9, amp: 5, waves: 2.3, seed: 61),
      depth: 1,
    ),
  ];
}

/// Page header for a main tab: a display title over an optional scene.
class AppTabHeader extends StatelessWidget {
  const AppTabHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.scene,
    this.sceneHeight = 132,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final PaperScenePreset? scene;
  final double sceneHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final heading = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing20,
        AppConstants.spacing12,
        AppConstants.spacing8,
        AppConstants.spacing12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: text.displaySmall?.copyWith(fontSize: 34),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    subtitle!,
                    style: text.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
    if (scene == null) return SafeArea(bottom: false, child: heading);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SafeArea(bottom: false, child: heading),
        PaperScene(preset: scene!, height: sceneHeight),
      ],
    );
  }
}

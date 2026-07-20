import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

/// Convert a raw box map into a [Rect] in the given painter [size].
///
/// Accepts API format `{x, y, width, height}` as percentages 0–100
/// (canonical backend shape), or legacy `{x1, y1, x2, y2}` in 0–1.
/// Returns null for malformed boxes (never a silent full-frame rect).
Rect? rectFromBoundingBox(Map<String, dynamic> box, Size size) {
  final hasXywh = box.containsKey('x') &&
      box.containsKey('y') &&
      box.containsKey('width') &&
      box.containsKey('height');

  double left;
  double top;
  double right;
  double bottom;

  if (hasXywh) {
    var x = (box['x'] as num?)?.toDouble() ?? 0.0;
    var y = (box['y'] as num?)?.toDouble() ?? 0.0;
    var w = (box['width'] as num?)?.toDouble() ?? 0.0;
    var h = (box['height'] as num?)?.toDouble() ?? 0.0;

    // The API contract is percent 0–100 (backend normalizer owns the
    // conversion). Only rescale unambiguous legacy 0–1000 rows (Gemini
    // style). Values slightly over 100 are percent overflow and get clamped
    // below — NOT shrunk. Never multiply sub-1 values by 100: legitimate
    // sub-1% boxes (tiny accessories) became near-full-frame rects.
    final maxV = [x.abs(), y.abs(), w.abs(), h.abs()].reduce(
      (a, b) => a > b ? a : b,
    );
    if (maxV > 150.0) {
      x *= 0.1;
      y *= 0.1;
      w *= 0.1;
      h *= 0.1;
    }

    left = (x / 100.0) * size.width;
    top = (y / 100.0) * size.height;
    right = ((x + w) / 100.0) * size.width;
    bottom = ((y + h) / 100.0) * size.height;
  } else {
    // Legacy normalized 0–1 corners. Require all four keys — a box missing
    // one is malformed, and defaulting it to the full frame hid bad data.
    final x1 = (box['x1'] as num?)?.toDouble();
    final y1 = (box['y1'] as num?)?.toDouble();
    final x2 = (box['x2'] as num?)?.toDouble();
    final y2 = (box['y2'] as num?)?.toDouble();
    if (x1 == null || y1 == null || x2 == null || y2 == null) return null;

    left = x1 * size.width;
    top = y1 * size.height;
    right = x2 * size.width;
    bottom = y2 * size.height;
  }

  if (right - left < 1 || bottom - top < 1) {
    return null;
  }

  return Rect.fromLTRB(
    left.clamp(0.0, size.width),
    top.clamp(0.0, size.height),
    right.clamp(0.0, size.width),
    bottom.clamp(0.0, size.height),
  );
}

/// Destination rect for [BoxFit.contain] of an image of [imageSize] in [box].
Rect containDestRect(Size imageSize, Size box) {
  if (imageSize.width <= 0 || imageSize.height <= 0) {
    return Offset.zero & box;
  }
  final sx = box.width / imageSize.width;
  final sy = box.height / imageSize.height;
  final scale = sx < sy ? sx : sy;
  final w = imageSize.width * scale;
  final h = imageSize.height * scale;
  final left = (box.width - w) / 2;
  final top = (box.height - h) / 2;
  return Rect.fromLTWH(left, top, w, h);
}

/// CustomPainter for drawing bounding boxes on images.
class BoundingBoxPainter extends CustomPainter {
  const BoundingBoxPainter({
    required this.boundingBoxes,
    this.strokeWidth = 2.0,
    this.color,
    this.showLabels = true,
    this.labelFontSize = 10.0,
    /// When set, boxes are mapped into this dest rect (e.g. contain letterbox).
    this.imageRect,
  });

  /// Bounding boxes: prefer API `{x,y,width,height}` (0–100).
  /// Also accepts `{x1,y1,x2,y2}` (0–1) for legacy callers.
  final List<Map<String, dynamic>> boundingBoxes;
  final double strokeWidth;
  final Color? color;
  final bool showLabels;
  final double labelFontSize;
  final Rect? imageRect;

  static const List<Color> _defaultColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final dest = imageRect ?? (Offset.zero & size);

    for (var i = 0; i < boundingBoxes.length; i++) {
      final box = boundingBoxes[i];
      final boxColor = color ?? _defaultColors[i % _defaultColors.length];
      _drawBoundingBox(canvas, dest, box, boxColor, i + 1);
    }
  }

  void _drawBoundingBox(
    Canvas canvas,
    Rect dest,
    Map<String, dynamic> box,
    Color color,
    int index,
  ) {
    final local = rectFromBoundingBox(box, dest.size);
    if (local == null) return;

    final rect = local.shift(dest.topLeft);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRect(rect, paint);

    if (showLabels) {
      final label = box['label'] as String? ?? '$index';
      _drawLabel(canvas, rect, label, color);
    }
  }

  void _drawLabel(Canvas canvas, Rect rect, String label, Color color) {
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: Colors.white,
        fontSize: labelFontSize,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    const padding = 4.0;
    final labelWidth = textPainter.width + padding * 2;
    final labelHeight = textPainter.height + padding * 2;

    final labelRect = Rect.fromLTWH(
      rect.left,
      rect.top - labelHeight,
      labelWidth,
      labelHeight,
    );

    final adjustedRect = labelRect.top < 0
        ? Rect.fromLTWH(rect.left, rect.top, labelWidth, labelHeight)
        : labelRect;

    final bgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(adjustedRect, bgPaint);

    textPainter.paint(
      canvas,
      Offset(adjustedRect.left + padding, adjustedRect.top + padding),
    );
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) {
    return boundingBoxes != oldDelegate.boundingBoxes ||
        strokeWidth != oldDelegate.strokeWidth ||
        color != oldDelegate.color ||
        imageRect != oldDelegate.imageRect;
  }
}

/// Overlay that paints boxes aligned to [BoxFit.contain] for a file image.
class BoundingBoxOverlay extends StatefulWidget {
  const BoundingBoxOverlay({
    super.key,
    required this.child,
    required this.boundingBoxes,
    this.strokeWidth = 2.0,
    this.color,
    this.showLabels = true,
    /// Optional local file path used to resolve intrinsic size for contain math.
    this.imageFilePath,
  });

  final Widget child;
  final List<Map<String, dynamic>> boundingBoxes;
  final double strokeWidth;
  final Color? color;
  final bool showLabels;
  final String? imageFilePath;

  @override
  State<BoundingBoxOverlay> createState() => _BoundingBoxOverlayState();
}

class _BoundingBoxOverlayState extends State<BoundingBoxOverlay> {
  Size? _imageSize;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  @override
  void didUpdateWidget(covariant BoundingBoxOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageFilePath != widget.imageFilePath) {
      // Keep the previous size until the new one resolves (the generation
      // guard discards stale results): one frame slightly off beats several
      // frames of full-area boxes over a letterboxed image.
      _loadImageSize();
    }
  }

  Future<void> _loadImageSize() async {
    final path = widget.imageFilePath;
    if (path == null || path.isEmpty) return;
    final generation = ++_loadGeneration;
    // Prefer FileImage resolution so size matches Image.file painting
    // (includes EXIF orientation). Raw codec bytes can report unrotated dims.
    try {
      final provider = FileImage(File(path));
      final stream = provider.resolve(ImageConfiguration.empty);
      final completer = Completer<Size>();
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo info, bool _) {
          stream.removeListener(listener);
          final size = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
          // Release our reference-counted handle on the decoded image, or
          // every resolved card pins a full-size decode outside ImageCache
          // accounting for the process lifetime. The cache keeps its own
          // handle, so Image.file painting is unaffected.
          info.image.dispose();
          if (!completer.isCompleted) {
            completer.complete(size);
          }
        },
        onError: (Object error, StackTrace? stackTrace) {
          stream.removeListener(listener);
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        },
      );
      stream.addListener(listener);
      final size = await completer.future;
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _imageSize = size);
    } catch (_) {
      // Best-effort: paint over full area if decode fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.boundingBoxes.isEmpty) {
      return widget.child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final box = Size(constraints.maxWidth, constraints.maxHeight);
        final imageRect = _imageSize != null
            ? containDestRect(_imageSize!, box)
            : Offset.zero & box;

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            CustomPaint(
              painter: BoundingBoxPainter(
                boundingBoxes: widget.boundingBoxes,
                strokeWidth: widget.strokeWidth,
                color: widget.color,
                showLabels: widget.showLabels,
                imageRect: imageRect,
              ),
            ),
          ],
        );
      },
    );
  }
}

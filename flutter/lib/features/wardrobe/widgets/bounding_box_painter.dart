import 'package:flutter/material.dart';

/// CustomPainter for drawing bounding boxes on images
class BoundingBoxPainter extends CustomPainter {
  const BoundingBoxPainter({
    required this.boundingBoxes,
    this.strokeWidth = 2.0,
    this.color,
    this.showLabels = true,
    this.labelFontSize = 10.0,
  });

  /// List of bounding boxes with format: {x1, y1, x2, y2, label?}
  /// Coordinates are normalized (0.0 to 1.0)
  final List<Map<String, dynamic>> boundingBoxes;
  final double strokeWidth;
  final Color? color;
  final bool showLabels;
  final double labelFontSize;

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
    for (var i = 0; i < boundingBoxes.length; i++) {
      final box = boundingBoxes[i];
      final boxColor = color ?? _defaultColors[i % _defaultColors.length];

      _drawBoundingBox(canvas, size, box, boxColor, i + 1);
    }
  }

  void _drawBoundingBox(
    Canvas canvas,
    Size size,
    Map<String, dynamic> box,
    Color color,
    int index,
  ) {
    // Get normalized coordinates
    final x1 = (box['x1'] as num?)?.toDouble() ?? 0.0;
    final y1 = (box['y1'] as num?)?.toDouble() ?? 0.0;
    final x2 = (box['x2'] as num?)?.toDouble() ?? 1.0;
    final y2 = (box['y2'] as num?)?.toDouble() ?? 1.0;

    // Convert to actual coordinates
    final left = x1 * size.width;
    final top = y1 * size.height;
    final right = x2 * size.width;
    final bottom = y2 * size.height;

    final rect = Rect.fromLTRB(left, top, right, bottom);

    // Draw rectangle border
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRect(rect, paint);

    // Draw label background and text
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

    final padding = 4.0;
    final labelWidth = textPainter.width + padding * 2;
    final labelHeight = textPainter.height + padding * 2;

    // Position label at top-left of bounding box
    final labelRect = Rect.fromLTWH(
      rect.left,
      rect.top - labelHeight,
      labelWidth,
      labelHeight,
    );

    // Adjust if label would be above canvas
    final adjustedRect = labelRect.top < 0
        ? Rect.fromLTWH(
            rect.left,
            rect.top,
            labelWidth,
            labelHeight,
          )
        : labelRect;

    // Draw background
    final bgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(adjustedRect, bgPaint);

    // Draw text
    textPainter.paint(
      canvas,
      Offset(
        adjustedRect.left + padding,
        adjustedRect.top + padding,
      ),
    );
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) {
    return boundingBoxes != oldDelegate.boundingBoxes ||
        strokeWidth != oldDelegate.strokeWidth ||
        color != oldDelegate.color;
  }
}

/// Widget that overlays bounding boxes on an image
class BoundingBoxOverlay extends StatelessWidget {
  const BoundingBoxOverlay({
    super.key,
    required this.child,
    required this.boundingBoxes,
    this.strokeWidth = 2.0,
    this.color,
    this.showLabels = true,
  });

  final Widget child;
  final List<Map<String, dynamic>> boundingBoxes;
  final double strokeWidth;
  final Color? color;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    if (boundingBoxes.isEmpty) {
      return child;
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: CustomPaint(
            painter: BoundingBoxPainter(
              boundingBoxes: boundingBoxes,
              strokeWidth: strokeWidth,
              color: color,
              showLabels: showLabels,
            ),
          ),
        ),
      ],
    );
  }
}

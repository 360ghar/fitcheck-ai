import 'package:flutter/widgets.dart';

/// An icon whose glyph carries a reading direction.
///
/// Flutter mirrors *layout* under a right-to-left locale — a `Row` reverses, an
/// `Align(centerStart)` moves — but it draws `IconData` exactly as authored. A
/// disclosure chevron therefore keeps pointing right inside an Arabic or Hebrew
/// screen, where "go deeper" reads toward the left, and a back arrow keeps
/// pointing at the text instead of away from it.
///
/// Wrap any glyph that means "next", "previous", "back" or "forward" in this
/// widget and it flips under RTL. Do not wrap glyphs that are direction-neutral
/// (`Icons.search`, `Icons.close`) or glyphs whose meaning is absolute
/// (`Icons.thumb_up`, a play button on media that always plays forward).
///
/// The App Store listing promises right-to-left layouts for Arabic, Hebrew and
/// Urdu, so these flips are part of the shipped promise, not decoration.
///
/// ```dart
/// DirectionalIcon(Icons.chevron_right_rounded, size: 20, color: tokens.textMuted)
/// ```
class DirectionalIcon extends StatelessWidget {
  const DirectionalIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// The glyph as it appears in a left-to-right layout.
  final IconData icon;

  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
    return Transform.flip(
      flipX: textDirection == TextDirection.rtl,
      child: Icon(icon, size: size, color: color, semanticLabel: semanticLabel),
    );
  }
}

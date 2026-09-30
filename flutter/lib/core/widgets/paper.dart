import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/paper_borders.dart';
import '../theme/paper_theme.dart';
import '../theme/paper_tokens.dart';

export '../theme/paper_borders.dart';
export '../theme/paper_tokens.dart';

const AssetImage _grainImage = AssetImage('assets/textures/paper_grain.png');

/// The shared paper grain tile, or null when grain is off (opacity 0 or the
/// platform high-contrast setting).
DecorationImage? paperGrain(BuildContext context, {double scale = 1}) {
  final opacity = PaperTokens.of(context).grainOpacity * scale;
  if (opacity <= 0 || MediaQuery.maybeHighContrastOf(context) == true) {
    return null;
  }
  return DecorationImage(
    image: _grainImage,
    repeat: ImageRepeat.repeat,
    scale: 2,
    opacity: opacity,
    filterQuality: FilterQuality.low,
  );
}

/// Loads the grain tile before first use so surfaces do not paint without it.
Future<void> precachePaperGrain(BuildContext context) =>
    precacheImage(_grainImage, context);

/// Re-themes [child] with one paper stock. Each shell tab and each pushed
/// route is wrapped in the stock of the feature it belongs to.
class PaperStockScope extends StatelessWidget {
  const PaperStockScope({super.key, required this.stock, required this.child});

  final PaperStockId stock;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (PaperTokens.of(context).current == stock) return child;
    return Theme(data: paperTheme(theme.brightness, stock), child: child);
  }
}

/// A sheet of paper: a face in the stock's card colour over a solid offset
/// slab, with grain under the content.
///
/// With [onTap], a press sinks the face onto its slab. [lift] scales the slab
/// offset; 0 lays the sheet flat. [deckle] tears one edge.
class PaperSurface extends StatefulWidget {
  const PaperSurface({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.stock,
    this.color,
    this.lift = 1,
    this.deckle = PaperEdge.none,
    this.grain = true,
    this.onTap,
    this.onLongPress,
    this.clipBehavior = Clip.none,
    this.semanticLabel,
  });

  final Widget child;

  /// Inner padding. Defaults to 16 on all sides.
  final EdgeInsetsGeometry? padding;

  /// Corner radius. Defaults to 12.
  final double? borderRadius;

  /// Paper stock. Defaults to the stock of the surrounding scope.
  final PaperStockId? stock;

  /// Face colour. Defaults to the stock's card colour.
  final Color? color;
  final double lift;
  final PaperEdge deckle;

  /// Paints the grain texture. Turn off when an image covers the face.
  final bool grain;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Clip clipBehavior;
  final String? semanticLabel;

  @override
  State<PaperSurface> createState() => _PaperSurfaceState();
}

class _PaperSurfaceState extends State<PaperSurface> {
  bool _pressed = false;

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final stock = widget.stock == null
        ? tokens.stock
        : tokens.stockOf(widget.stock!);
    final radius = widget.borderRadius ?? AppConstants.radius12;
    final ShapeBorder shape = widget.deckle == PaperEdge.none
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: stock.edge, width: 0.5),
          )
        : DeckleBorder(edge: widget.deckle, radius: radius);

    final rest = tokens.shadowOffset * widget.lift;
    final pressed = tokens.pressedOffset * widget.lift;
    final slab = _pressed ? pressed : rest;
    final shift = _pressed ? rest - pressed : Offset.zero;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 90);

    Widget content = Padding(
      padding: widget.padding ?? const EdgeInsets.all(AppConstants.spacing16),
      child: widget.child,
    );
    if (_interactive) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: shape,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onHighlightChanged: _setPressed,
          child: content,
        ),
      );
    }

    final surface = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(shift.dx, shift.dy, 0),
      clipBehavior: widget.clipBehavior,
      decoration: ShapeDecoration(
        color: widget.color ?? stock.card,
        image: widget.grain ? paperGrain(context) : null,
        shape: shape,
        shadows: widget.lift <= 0
            ? null
            : [BoxShadow(color: stock.shadow, offset: slab)],
      ),
      child: content,
    );

    if (widget.semanticLabel == null) return surface;
    return Semantics(
      label: widget.semanticLabel,
      button: _interactive,
      child: surface,
    );
  }
}

/// Text for a large display figure. The display face draws a slashed zero,
/// which reads as a symbol on its own, so zero and unknown show a dash.
String paperFigure(num? value) =>
    value == null || value == 0 ? '–' : value.toString();

/// A torn paper strip pinned under a page's content, holding its main
/// action. Content that scrolls under it ends at the torn edge.
class PaperActionBar extends StatelessWidget {
  const PaperActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final stock = PaperTokens.of(context).stock;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: stock.card,
        image: paperGrain(context),
        shape: const DeckleBorder(edge: PaperEdge.top, radius: 0, amplitude: 2),
        shadows: [BoxShadow(color: stock.shadow, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppConstants.spacing8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacing16,
            AppConstants.spacing16,
            AppConstants.spacing16,
            AppConstants.spacing8,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The page colour with its grain. Fills bars that sit over scrolling
/// content, such as a pinned `SliverAppBar`'s `flexibleSpace`.
class PaperGrainFill extends StatelessWidget {
  const PaperGrainFill({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: PaperTokens.of(context).stock.page,
      image: paperGrain(context),
    ),
    child: const SizedBox.expand(),
  );
}

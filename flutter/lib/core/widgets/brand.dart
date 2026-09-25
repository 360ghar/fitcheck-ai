import 'package:flutter/material.dart';
import 'paper.dart';

/// The brand mark: three paper tees fanned from the hem. Drawn bare, never
/// on a tile. Rendered from docs/brand/mark.svg by
/// scripts/render_brand_assets.sh.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, required this.width});

  final double width;

  /// Width / height of the rendered mark.
  static const aspectRatio = 480 / 355;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/brand_mark.png',
    width: width,
    height: width / aspectRatio,
    excludeFromSemantics: true,
    filterQuality: FilterQuality.medium,
  );
}

/// The "FitCheck ai" wordmark in the display face, optionally led by the
/// mark.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.size = 22, this.showMark = true});

  final double size;
  final bool showMark;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'FitCheck'),
          TextSpan(
            text: ' ai',
            style: TextStyle(color: tokens.stock.accent),
          ),
        ],
      ),
      style: Theme.of(
        context,
      ).textTheme.displaySmall?.copyWith(fontSize: size, height: 1),
    );
    return Semantics(
      label: 'FitCheck AI',
      header: true,
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: showMark
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandMark(width: size * 1.5),
                  SizedBox(width: size * 0.3),
                  text,
                ],
              )
            : text,
      ),
    );
  }
}

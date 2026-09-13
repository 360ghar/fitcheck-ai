import 'package:flutter/material.dart';

/// Shared column logic for Closet + Outfits product grids.
///
/// Phones (<600px) render 3 columns, including <360px small phones (approved
/// spec: image tiles stay usable at ~90-114px, full-tile InkWell keeps the
/// 48px touch floor). Large/tablet portrait (600-840px) renders 4 columns;
/// past the 840px navigation rail, image-only grids render 5 and captioned
/// grids render 4. Text-scaler guard preserved: captioned grids collapse to
/// 1 column at >=1.6 scale; image-only tiles ignore text scale by design.
int productGridColumns(
  double width, {
  bool imageOnly = false,
  double textScale14 = 1.0,
}) {
  if (width < 600) {
    if (!imageOnly && textScale14 >= 1.6) return 1;
    return 3;
  }
  if (width < 840) return 4;
  return imageOnly ? 5 : 4;
}

/// Lazy rows let product captions grow with text size instead of covering photos.
class SliverProductGrid extends StatelessWidget {
  const SliverProductGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.imageOnly = false,
    this.rowGap = 12,
    this.columnGap = 8,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// True for image-only tiles (Closet): ignores text-scale collapse and,
  /// past the rail, renders 5 columns instead of 4.
  final bool imageOnly;
  final double rowGap;
  final double columnGap;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final columns = productGridColumns(
          width,
          imageOnly: imageOnly,
          textScale14: scale,
        );
        return SliverList.builder(
          itemCount: (itemCount / columns).ceil(),
          itemBuilder: (context, row) => Padding(
            padding: EdgeInsets.only(bottom: rowGap),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var column = 0; column < columns; column++) ...[
                  if (column > 0) SizedBox(width: columnGap),
                  Expanded(
                    child: row * columns + column < itemCount
                        ? itemBuilder(context, row * columns + column)
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

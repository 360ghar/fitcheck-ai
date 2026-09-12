import 'package:flutter/material.dart';

/// Lazy rows let product captions grow with text size instead of covering photos.
class SliverProductGrid extends StatelessWidget {
  const SliverProductGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final columns = width < 600
            ? (scale >= 1.6 ? 1 : 2)
            : (width / (200 * scale.clamp(1, 1.4))).floor().clamp(2, 4);
        return SliverList.builder(
          itemCount: (itemCount / columns).ceil(),
          itemBuilder: (context, row) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var column = 0; column < columns; column++) ...[
                  if (column > 0) const SizedBox(width: 12),
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

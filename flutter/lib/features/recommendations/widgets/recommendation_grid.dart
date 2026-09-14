import 'package:flutter/material.dart';

/// Natural-height cards keep recommendation details readable at large text sizes.
class RecommendationGrid extends StatelessWidget {
  const RecommendationGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minWidth = MediaQuery.textScalerOf(context).scale(14) > 20
              ? 280
              : 160;
          final columns = ((constraints.maxWidth + 12) / (minWidth + 12))
              .floor()
              .clamp(1, 3);
          final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var index = 0; index < itemCount; index++)
                SizedBox(width: width, child: itemBuilder(context, index)),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_ui.dart';

/// Paper strips, one per step. The current one is a longer strip of brand
/// red on its slab; the rest are short strips of the stock's accent.
class PaperProgress extends StatelessWidget {
  const PaperProgress({super.key, required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 260);
    return Semantics(
      label: 'Step ${index + 1} of $count',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.only(right: AppConstants.spacing8),
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                width: i == index ? 36 : 14,
                height: 8,
                decoration: BoxDecoration(
                  color: i == index
                      ? tokens.brand
                      : tokens.stock.accent.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: i == index
                      ? [
                          BoxShadow(
                            color: tokens.brandSlab,
                            offset: tokens.pressedOffset,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

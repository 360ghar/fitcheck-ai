import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_ui.dart';

/// One monthly allowance: label, count and a bar. The bar turns to the
/// warning tone above 80 percent.
class UsageProgress extends StatelessWidget {
  const UsageProgress({
    super.key,
    required this.label,
    required this.current,
    required this.max,
    required this.icon,
  });

  final String label;
  final int current;
  final int max;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final share = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final color = share > 0.8 ? tokens.warning : tokens.stock.accent;

    return Semantics(
      label: '$label: $current of $max used',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: tokens.textSecondary),
                const SizedBox(width: AppConstants.spacing8),
                Expanded(child: Text(label, style: text.bodyMedium)),
                Text(
                  '$current / $max',
                  style: text.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing8),
            LinearProgressIndicator(
              value: share,
              minHeight: 8,
              color: color,
              backgroundColor: tokens.stock.sunk,
              borderRadius: BorderRadius.circular(AppConstants.radius8),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Widget showing usage progress with a progress bar
class UsageProgress extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final IconData icon;

  const UsageProgress({
    super.key,
    required this.label,
    required this.current,
    required this.max,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final isNearLimit = percentage > 0.8;
    final color = isNearLimit ? Colors.orange : theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$current / $max',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withAlpha(51),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

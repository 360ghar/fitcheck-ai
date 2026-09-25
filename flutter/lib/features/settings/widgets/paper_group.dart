import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';

/// A labelled sheet of paper holding list rows (ListTile, SwitchListTile),
/// with hairline dividers between them.
class PaperGroup extends StatelessWidget {
  const PaperGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final title = this.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing4,
              0,
              AppConstants.spacing4,
              AppConstants.spacing8,
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: tokens.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        PaperSurface(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          // Rows draw their ink on this sheet, not on the page behind it.
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                for (final (i, child) in children.indexed) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: AppConstants.spacing16,
                      endIndent: AppConstants.spacing16,
                    ),
                  child,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A navigation row: bare leading icon, title, optional subtitle, chevron.
class PaperNavRow extends StatelessWidget {
  const PaperNavRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// Colour for the icon and title (for example the error colour).
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final subtitle = this.subtitle;
    return ListTile(
      minTileHeight: 56,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: color == null ? null : TextStyle(color: color),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: tokens.textMuted),
            ),
      trailing:
          trailing ??
          Icon(Icons.chevron_right_rounded, color: tokens.textMuted),
      onTap: onTap,
    );
  }
}

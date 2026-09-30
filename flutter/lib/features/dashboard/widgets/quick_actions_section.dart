import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';

/// Four shortcuts, each cut from the paper of the feature it opens.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const actions = [
      (
        'Add a piece',
        'Photograph and tag',
        Icons.add_a_photo_outlined,
        PaperStockId.moss,
        Routes.wardrobeAdd,
      ),
      (
        'Build an outfit',
        'Mix your pieces',
        Icons.style_outlined,
        PaperStockId.marigold,
        Routes.outfitBuilder,
      ),
      (
        'For you',
        'Picks for today',
        Icons.explore_outlined,
        PaperStockId.ink,
        Routes.recommendations,
      ),
      (
        'Plan the week',
        'Outfits by date',
        Icons.calendar_month_outlined,
        PaperStockId.clay,
        Routes.calendar,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 4 : 2;
        const gap = AppConstants.spacing12;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap + 3, // Room for the paper slab.
          children: [
            for (final (title, subtitle, icon, stock, route) in actions)
              SizedBox(
                width: width,
                child: _ActionCard(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                  stock: stock,
                  onTap: () => context.push(route),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.stock,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final PaperStockId stock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final paper = tokens.stockOf(stock);
    final text = Theme.of(context).textTheme;
    return PaperSurface(
      stock: stock,
      color: paper.tint,
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: paper.accent, size: 26),
          const SizedBox(height: AppConstants.spacing16),
          Text(title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          Text(
            subtitle,
            style: text.bodySmall?.copyWith(color: tokens.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

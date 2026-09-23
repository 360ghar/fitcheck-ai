import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../providers/wardrobe_providers.dart';
import '../widgets/garment_glyph.dart';

/// Closet statistics: totals, category mix and wear counts.
class WardrobeStatsPage extends ConsumerWidget {
  const WardrobeStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(wardrobeStatsProvider);
    Future<void> refresh() => ref.refresh(wardrobeStatsProvider.future);

    return PaperStockScope(
      stock: PaperStockId.moss,
      child: Scaffold(
        appBar: AppBar(title: const Text('Closet stats')),
        body: AppPageBackground(
          child: RefreshIndicator(
            onRefresh: () => refresh().catchError((_) => <String, dynamic>{}),
            child: switch (stats) {
              AsyncValue(:final value?) => _StatsBody(stats: value),
              AsyncValue(:final error?) => ListView(
                children: [
                  AppErrorState(error: error, onRetry: () => refresh()),
                ],
              ),
              _ => ListView(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                children: const [
                  SkeletonCard(height: 120),
                  SizedBox(height: AppConstants.spacing16),
                  SkeletonCard(height: 220),
                ],
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final byCategory = <Category, int>{};
    final rawCategories = stats['items_by_category'];
    if (rawCategories is Map) {
      for (final entry in rawCategories.entries) {
        final category = Category.values
            .where((c) => c.name == entry.key.toString().toLowerCase())
            .firstOrNull;
        final count = (entry.value as num?)?.toInt() ?? 0;
        if (category != null && count > 0) byCategory[category] = count;
      }
    }
    final total =
        (stats['total_items'] as num?)?.toInt() ??
        byCategory.values.fold<int>(0, (a, b) => a + b);
    final value = (stats['total_value'] as num?)?.toDouble() ?? 0;
    final mostWorn = (stats['most_worn_items'] as List?) ?? const [];
    final leastWorn = (stats['least_worn_items'] as List?) ?? const [];

    if (total == 0) {
      return ListView(
        children: [
          AppEmptyState(
            scene: PaperScenes.closet,
            title: 'No stats yet',
            message: 'Add a few pieces and your closet mix shows up here.',
            actionLabel: 'Add a piece',
            onAction: () => context.push(Routes.wardrobeAdd),
          ),
        ],
      );
    }

    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final peak = sorted.isEmpty ? 1 : sorted.first.value;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: [
        PaperSurface(
          child: Row(
            children: [
              _Figure(
                value: paperFigure(total),
                label: total == 1 ? 'piece' : 'pieces',
              ),
              if (value > 0)
                _Figure(value: value.toStringAsFixed(0), label: 'total value'),
            ],
          ),
        ),
        if (sorted.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacing16),
          PaperSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('By category', style: text.headlineSmall),
                const SizedBox(height: AppConstants.spacing12),
                for (final (i, e) in sorted.indexed)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacing6,
                    ),
                    child: Row(
                      children: [
                        GarmentGlyph(category: e.key, size: 28),
                        const SizedBox(width: AppConstants.spacing12),
                        SizedBox(
                          width: 88,
                          child: Text(
                            e.key.displayName,
                            style: text.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, c) => Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 12,
                                width: c.maxWidth * e.value / peak,
                                decoration: BoxDecoration(
                                  color: tokens.cutOf(
                                    tabStocks[i % tabStocks.length],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${e.value}',
                            style: text.labelLarge,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (mostWorn.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacing16),
          _WearList(title: 'Worn the most', items: mostWorn),
        ],
        if (leastWorn.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacing16),
          _WearList(title: 'Waiting for a turn', items: leastWorn),
        ],
        const SizedBox(height: AppConstants.spacing32),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: text.displaySmall?.copyWith(fontSize: 38)),
          Text(
            label,
            style: text.bodyMedium?.copyWith(
              color: PaperTokens.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WearList extends StatelessWidget {
  const _WearList({required this.title, required this.items});

  final String title;
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing8),
          for (final item in items.take(5))
            if (item is Map)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacing6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name']?.toString() ?? 'Unnamed piece',
                        style: text.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(item['times_worn'] as num?)?.toInt() ?? 0}×',
                      style: text.labelLarge?.copyWith(
                        color: tokens.stock.accent,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

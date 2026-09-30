import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/style.dart';
import '../providers/recommendations_providers.dart';
import 'recommendation_widgets.dart';

/// Pieces worth buying to fill gaps in the closet.
class ShoppingTab extends ConsumerStatefulWidget {
  const ShoppingTab({super.key});

  @override
  ConsumerState<ShoppingTab> createState() => _ShoppingTabState();
}

class _ShoppingTabState extends ConsumerState<ShoppingTab>
    with AutomaticKeepAliveClientMixin {
  Category? _category;
  Style? _style;
  double _budget = 100;

  @override
  bool get wantKeepAlive => true;

  ShoppingNotifier get _shopping => ref.read(shoppingProvider.notifier);

  void _fetch() => _shopping.fetch(
    category: _category?.name,
    style: _style?.name,
    budget: _budget,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final results = ref.watch(shoppingProvider);
    return RefreshIndicator(
      onRefresh: _shopping.retry,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing16,
              AppConstants.spacing16,
              AppConstants.spacing8,
            ),
            sliver: SliverToBoxAdapter(child: _filters(results.isLoading)),
          ),
          ..._results(results),
        ],
      ),
    );
  }

  Widget _filters(bool loading) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Category?>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any')),
                  for (final c in Category.values)
                    DropdownMenuItem(value: c, child: Text(c.displayName)),
                ],
                onChanged: (c) => setState(() => _category = c),
              ),
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: DropdownButtonFormField<Style?>(
                initialValue: _style,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Style'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any')),
                  for (final s in Style.values)
                    DropdownMenuItem(value: s, child: Text(s.displayName)),
                ],
                onChanged: (s) => setState(() => _style = s),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing16),
        Row(
          children: [
            Expanded(child: Text('Budget up to', style: text.bodyLarge)),
            Text('\$${_budget.round()}', style: text.titleMedium),
          ],
        ),
        Slider(
          value: _budget,
          min: 20,
          max: 500,
          divisions: 24,
          label: '\$${_budget.round()}',
          onChanged: (v) => setState(() => _budget = v),
        ),
        const SizedBox(height: AppConstants.spacing8),
        ElevatedButton(
          onPressed: loading ? null : _fetch,
          child: Text(loading ? 'Looking' : 'Find what to buy'),
        ),
      ],
    );
  }

  List<Widget> _results(AsyncValue<List<Map<String, dynamic>>?> results) {
    if (results.isLoading) {
      return const [
        SliverPadding(
          padding: tabPadding,
          sliver: SliverToBoxAdapter(
            child: SkeletonListLoaderBox(itemCount: 3, hasLeading: false),
          ),
        ),
      ];
    }
    final value = results.value;
    if (results.hasError && (value == null || value.isEmpty)) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorState(error: results.error, onRetry: _shopping.retry),
        ),
      ];
    }
    if (value == null) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            scene: PaperScenes.closet,
            title: 'Fill the gaps',
            message:
                "Set a budget and we'll suggest what your closet is missing.",
          ),
        ),
      ];
    }
    if (value.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            scene: PaperScenes.closet,
            title: 'No gaps found',
            message: 'Try a bigger budget or another category.',
          ),
        ),
      ];
    }
    return [
      if (results.hasError)
        SliverToBoxAdapter(
          child: AppErrorBanner(error: results.error, onRetry: _shopping.retry),
        ),
      SliverPadding(
        padding: tabPadding,
        sliver: SliverList.separated(
          itemCount: value.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppConstants.spacing12),
          itemBuilder: (context, i) => _GapCard(gap: value[i]),
        ),
      ),
    ];
  }
}

class _GapCard extends StatelessWidget {
  const _GapCard({required this.gap});

  final Map<String, dynamic> gap;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final description = gap['description']?.toString();
    final priority = gap['priority']?.toString().toLowerCase();
    final completes = gap['would_complete'] as num?;
    final cpw = gap['estimated_cpw'] as num?;
    final footnote = [
      if (completes != null)
        completes == 1 ? 'Adds 1 outfit' : 'Adds $completes outfits',
      if (cpw != null) '\$${cpw.toStringAsFixed(2)} per wear',
    ].join(' · ');
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  capitalizeWords(gap['category']?.toString() ?? 'Piece'),
                  style: text.titleMedium,
                ),
              ),
              if (priority == 'high' ||
                  priority == 'medium' ||
                  priority == 'low')
                Text(
                  '${capitalizeWords(priority!)} priority',
                  style: text.labelLarge?.copyWith(
                    color: priority == 'high'
                        ? tokens.stock.accent
                        : tokens.textSecondary,
                  ),
                ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacing4),
            Text(
              description,
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
          ],
          if (footnote.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacing8),
            Text(footnote, style: text.bodySmall),
          ],
        ],
      ),
    );
  }
}

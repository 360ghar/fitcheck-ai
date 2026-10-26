import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/i18n/taxonomy_l10n.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/style.dart';
import '../providers/recommendations_providers.dart';
import 'recommendation_widgets.dart';

/// Whole looks built around the chosen pieces.
class CompleteLookTab extends ConsumerStatefulWidget {
  const CompleteLookTab({super.key});

  @override
  ConsumerState<CompleteLookTab> createState() => _CompleteLookTabState();
}

class _CompleteLookTabState extends ConsumerState<CompleteLookTab>
    with AutomaticKeepAliveClientMixin {
  Style _style = Style.casual;

  @override
  bool get wantKeepAlive => true;

  CompleteLookNotifier get _looks => ref.read(completeLookProvider.notifier);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final selection = ref.watch(recommendationSelectionProvider);
    final looks = ref.watch(completeLookProvider);

    return RefreshIndicator(
      onRefresh: _looks.retry,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: selection.isEmpty
            ? [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    scene: PaperScenes.outfits,
                    title: context.l10n.recommendCompleteTitle,
                    message: context.l10n.recommendCompleteBody,
                    actionLabel: context.l10n.recommendPickPiece,
                    onAction: () => showPiecePicker(context),
                  ),
                ),
              ]
            : [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spacing16,
                    AppConstants.spacing16,
                    AppConstants.spacing16,
                    AppConstants.spacing8,
                  ),
                  sliver: SliverToBoxAdapter(child: _controls(looks.isLoading)),
                ),
                ..._results(looks),
              ],
      ),
    );
  }

  Widget _controls(bool loading) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SelectionBar(),
      const SizedBox(height: AppConstants.spacing16),
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<Style>(
              initialValue: _style,
              decoration: InputDecoration(
                labelText: context.l10n.filterStyle,
              ),
              items: [
                for (final s in Style.values)
                  DropdownMenuItem(
                    value: s,
                    child: Text(s.label(context.l10n)),
                  ),
              ],
              onChanged: (s) => setState(() => _style = s ?? _style),
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          ElevatedButton(
            onPressed: loading
                ? null
                : () => _looks.generate(style: _style.name),
            child: Text(
              loading
                  ? context.l10n.recommendWorking
                  : context.l10n.recommendGenerate,
            ),
          ),
        ],
      ),
    ],
  );

  List<Widget> _results(AsyncValue<List<CompleteLook>?> looks) {
    if (looks.isLoading) {
      return [
        SliverPadding(
          padding: tabPadding,
          sliver: SliverList.separated(
            itemCount: 2,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppConstants.spacing12),
            itemBuilder: (_, _) => const SkeletonCard(height: 200),
          ),
        ),
      ];
    }
    final value = looks.value;
    if (looks.hasError && (value == null || value.isEmpty)) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorState(error: looks.error, onRetry: _looks.retry),
        ),
      ];
    }
    if (value == null) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: tabPadding,
            child: Text(
              context.l10n.recommendChooseStyleBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PaperTokens.of(context).textSecondary,
              ),
            ),
          ),
        ),
      ];
    }
    if (value.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            scene: PaperScenes.outfits,
            title: context.l10n.recommendNoLooksTitle,
            message: context.l10n.recommendNoLooksBody,
          ),
        ),
      ];
    }
    return [
      if (looks.hasError)
        SliverToBoxAdapter(
          child: AppErrorBanner(error: looks.error, onRetry: _looks.retry),
        ),
      SliverPadding(
        padding: tabPadding,
        sliver: SliverList.separated(
          itemCount: value.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppConstants.spacing16),
          itemBuilder: (context, i) => _LookCard(look: value[i]),
        ),
      ),
    ];
  }
}

class _LookCard extends StatelessWidget {
  const _LookCard({required this.look});

  final CompleteLook look;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final score = look.score;
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  look.description ?? context.l10n.recommendDefaultLook,
                  style: text.titleMedium,
                ),
              ),
              if (score != null) ...[
                const SizedBox(width: AppConstants.spacing12),
                Text(
                  context.l10n.recommendMatchPercent(score.round()),
                  style: text.labelLarge?.copyWith(color: tokens.stock.accent),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          if (look.items.isEmpty)
            Text(
              context.l10n.recommendNoPiecesBody,
              style: text.bodySmall?.copyWith(color: tokens.textSecondary),
            )
          else
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: look.items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppConstants.spacing12),
                itemBuilder: (context, i) =>
                    SizedBox(width: 112, child: PieceCard.item(look.items[i])),
              ),
            ),
        ],
      ),
    );
  }
}

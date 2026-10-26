import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/widgets/app_ui.dart';
import '../providers/recommendations_providers.dart';
import 'recommendation_widgets.dart';

/// Pieces from the closet that go with the chosen ones.
class FindMatchesTab extends ConsumerStatefulWidget {
  const FindMatchesTab({super.key});

  @override
  ConsumerState<FindMatchesTab> createState() => _FindMatchesTabState();
}

class _FindMatchesTabState extends ConsumerState<FindMatchesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final selection = ref.watch(recommendationSelectionProvider);
    final matches = ref.watch(findMatchesProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(findMatchesProvider.future),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (selection.isNotEmpty)
            const SliverPadding(
              padding: EdgeInsetsDirectional.only(
                start: AppConstants.spacing16,
                top: AppConstants.spacing16,
                end: AppConstants.spacing8,
                bottom: AppConstants.spacing4,
              ),
              sliver: SliverToBoxAdapter(child: SelectionBar()),
            ),
          ..._results(selection.isEmpty, matches),
        ],
      ),
    );
  }

  List<Widget> _results(
    bool nothingPicked,
    AsyncValue<List<RecommendationMatch>> matches,
  ) {
    void retry() => ref.invalidate(findMatchesProvider);
    if (nothingPicked) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            scene: PaperScenes.closet,
            title: context.l10n.recommendNoMatchesTitle,
            message: context.l10n.recommendNoMatchesBody,
            actionLabel: context.l10n.recommendPickPiece,
            onAction: () => showPiecePicker(context),
          ),
        ),
      ];
    }
    if (matches.isLoading) {
      return const [
        SliverPadding(
          padding: tabPadding,
          sliver: SkeletonGridLoader(itemCount: 4, childAspectRatio: 0.78),
        ),
      ];
    }
    final value = matches.value ?? const [];
    if (matches.hasError && value.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorState(error: matches.error, onRetry: retry),
        ),
      ];
    }
    if (value.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            scene: PaperScenes.closet,
            title: context.l10n.recommendNothingMatchesTitle,
            message: context.l10n.recommendNothingMatchesBody,
            actionLabel: context.l10n.recommendChangePieces,
            onAction: () => showPiecePicker(context),
          ),
        ),
      ];
    }
    return [
      if (matches.hasError)
        SliverToBoxAdapter(
          child: AppErrorBanner(error: matches.error, onRetry: retry),
        ),
      SliverPadding(
        padding: tabPadding,
        sliver: SliverGrid.builder(
          gridDelegate: pieceGridDelegate,
          itemCount: value.length,
          itemBuilder: (context, i) {
            final match = value[i];
            return PieceCard(
              title: match.name,
              caption: match.score > 0
                  ? '${(match.score * 100).round()}% match'
                  : match.brand,
              accentCaption: match.score > 0,
              imageUrl: match.imageUrl,
              storagePath: match.storagePath,
              category: match.category,
              onTap: () => _showReason(match),
            );
          },
        ),
      ),
    ];
  }

  void _showReason(RecommendationMatch match) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final tokens = PaperTokens.of(context);
        final text = Theme.of(context).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(match.name, style: text.headlineSmall),
                if (match.brand != null)
                  Text(
                    match.brand!,
                    style: text.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                const SizedBox(height: AppConstants.spacing16),
                Text(
                  match.reason ?? context.l10n.recommendDefaultReason,
                  style: text.bodyLarge,
                ),
                const SizedBox(height: AppConstants.spacing20),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.actionClose),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

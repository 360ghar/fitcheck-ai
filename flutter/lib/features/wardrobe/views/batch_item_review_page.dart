import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/batch_extraction_models.dart';
import '../providers/batch_extraction_provider.dart';
import '../widgets/ai_extraction_widget.dart'
    show PersonGroupList, personGroups;
import '../widgets/extracted_item_card.dart';
import '../widgets/manual_entry_form.dart' show UseCasePicker;

/// Review the pieces found in a batch and save the chosen ones.
class BatchItemReviewPage extends ConsumerWidget {
  const BatchItemReviewPage({super.key});

  /// Leaves the flow. Popping every route disposes the session.
  static void _exitFlow(BuildContext context, WidgetRef ref) =>
      Navigator.of(context).popUntil((route) => route.isFirst);

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(batchExtractionProvider.notifier);
    final saved = await notifier.saveSelectedItems();
    if (!context.mounted) return;
    final failures = ref.read(batchExtractionProvider).saveFailures;
    if (failures.isEmpty && saved.isNotEmpty) {
      ErrorHandler.showSuccess(
        ErrorHandler.l10n?.itemAddPiecesSavedBody(saved.length) ??
            (saved.length == 1
                ? '1 piece is in your closet.'
                : '${saved.length} pieces are in your closet.'),
        title: context.l10n.itemManualSavedTitle,
      );
      _exitFlow(context, ref);
    } else if (failures.isNotEmpty && saved.isEmpty) {
      ErrorHandler.showError(
        context.l10n.batchNothingSavedRetryBody,
        title: context.l10n.batchNotSavedTitle,
      );
    }
    // A partial save stays on the page: the banner names what is left.
  }

  Future<void> _confirmDiscard(BuildContext context, WidgetRef ref) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.batchDiscardPiecesTitle),
        content: Text(context.l10n.batchDiscardPiecesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.batchKeepAction),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: PaperTokens.of(context).error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.batchDiscardAction),
          ),
        ],
      ),
    );
    if (discard == true && context.mounted) _exitFlow(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (empty, saving, allIncluded) = ref.watch(
      batchExtractionProvider.select(
        (s) => (
          s.items.isEmpty,
          s.saving,
          s.items.isNotEmpty &&
              s.items.every((i) => i.includeInWardrobe && i.isSelected),
        ),
      ),
    );
    final notifier = ref.read(batchExtractionProvider.notifier);

    return PaperStockScope(
      stock: PaperStockId.moss,
      child: PopScope(
        canPop: !saving,
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.batchReviewPiecesTitle),
            actions: [
              if (!empty)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppConstants.spacing8),
                  child: TextButton(
                    onPressed: saving
                        ? null
                        : () => notifier.setAllIncluded(!allIncluded),
                    child: Text(
                      allIncluded
                          ? context.l10n.batchSkipAllAction
                          : context.l10n.batchIncludeAllAction,
                    ),
                  ),
                ),
            ],
          ),
          body: AppPageBackground(
            child: SafeArea(
              top: false,
              child: empty
                  ? AppEmptyState(
                      scene: PaperScenes.closet,
                      title: context.l10n.batchNoPiecesFoundTitle,
                      message: context.l10n.batchNoPiecesFoundBody,
                      actionLabel: context.l10n.batchChooseOtherPhotosAction,
                      onAction: () {
                        notifier.reset();
                        Navigator.pop(context);
                      },
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              const SliverToBoxAdapter(
                                child: _StillGeneratingBanner(),
                              ),
                              SliverToBoxAdapter(
                                child: _SaveFailures(
                                  onRetry: () => _save(context, ref),
                                ),
                              ),
                              const SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  AppConstants.spacing16,
                                  AppConstants.spacing8,
                                  AppConstants.spacing16,
                                  0,
                                ),
                                sliver: SliverToBoxAdapter(child: _Summary()),
                              ),
                              const SliverToBoxAdapter(child: _People()),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: AppConstants.spacing16),
                              ),
                              const _Grid(),
                              SliverPadding(
                                padding: const EdgeInsets.all(
                                  AppConstants.spacing16,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: PaperSurface(
                                    child: Consumer(
                                      builder: (context, ref, _) =>
                                          UseCasePicker(
                                            selected: ref.watch(
                                              batchExtractionProvider.select(
                                                (s) => s.useCases,
                                              ),
                                            ),
                                            onToggle: notifier.toggleUseCase,
                                            helper:
                                                context.l10n.batchUseCaseHelper,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _SaveBar(
                          onSave: () => _save(context, ref),
                          onDiscard: () => _confirmDiscard(context, ref),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown while the scan still runs behind the review: pending pieces keep
/// arriving, and leaving never stops the job (the registry owns it).
class _StillGeneratingBanner extends ConsumerWidget {
  const _StillGeneratingBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (processing, pending) = ref.watch(
      batchExtractionProvider.select(
        (s) => (
          s.isProcessing,
          s.items
              .where((i) => i.status != BatchItemStatus.generated)
              .length,
        ),
      ),
    );
    if (!processing || pending <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing16,
        0,
      ),
      child: PaperSurface(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing16,
          AppConstants.spacing12,
          AppConstants.spacing16,
          AppConstants.spacing12,
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: PaperTokens.of(context).stock.accent,
                strokeCap: StrokeCap.round,
              ),
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: Text(
                context.l10n.batchMoreStudioPhotosBody(pending),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveFailures extends ConsumerWidget {  const _SaveFailures({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failures = ref.watch(
      batchExtractionProvider.select((s) => s.saveFailures),
    );
    if (failures.isEmpty) return const SizedBox.shrink();
    return AppErrorBanner(
      message: context.l10n.batchNotSavedYetBody(failures.join(', ')),
      onRetry: onRetry,
    );
  }
}

class _Summary extends ConsumerWidget {
  const _Summary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (total, photos, selected) = ref.watch(
      batchExtractionProvider.select(
        (s) => (s.items.length, s.images.length, s.selectedItemCount),
      ),
    );
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.batchPiecesFromPhotos(total, photos),
          style: text.headlineSmall,
        ),
        const SizedBox(height: AppConstants.spacing4),
        Text(
          context.l10n.batchSelectedChosen(selected),
          style: text.bodyMedium?.copyWith(
            color: PaperTokens.of(context).textSecondary,
          ),
        ),
      ],
    );
  }
}

class _People extends ConsumerWidget {
  const _People();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(batchExtractionProvider.select((s) => s.items));
    final groups = personGroups([
      for (final i in items)
        (
          key: i.personId ?? 'unassigned',
          label: i.personLabel,
          you: i.isCurrentUserPerson,
          included: i.includeInWardrobe,
        ),
    ]);
    if (groups.length < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing16,
        0,
      ),
      child: PersonGroupList(
        groups: groups,
        onSet: ref.read(batchExtractionProvider.notifier).setPersonInclusion,
      ),
    );
  }
}

class _Grid extends ConsumerWidget {
  const _Grid();

  Future<void> _remove(BuildContext context, WidgetRef ref, String id) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.batchRemovePieceTitle),
        content: Text(context.l10n.batchRemovePieceBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.batchKeepAction),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: PaperTokens.of(context).error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.batchRemoveAction),
          ),
        ],
      ),
    );
    if (remove == true) {
      ref.read(batchExtractionProvider.notifier).removeItem(id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (items, images) = ref.watch(
      batchExtractionProvider.select((s) => (s.items, s.images)),
    );
    final paths = {for (final i in images) i.id: i.filePath};
    final notifier = ref.read(batchExtractionProvider.notifier);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          crossAxisSpacing: AppConstants.spacing12,
          mainAxisSpacing: AppConstants.spacing12,
          mainAxisExtent: 288,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return ExtractedItemCard(
            item: item,
            sourceImagePath: paths[item.sourceImageId] ?? '',
            onToggleSelection: () => notifier.toggleItemInclude(item.id),
            onRemove: () => _remove(context, ref, item.id),
          );
        },
      ),
    );
  }
}

class _SaveBar extends ConsumerWidget {
  const _SaveBar({required this.onSave, required this.onDiscard});

  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (count, saving) = ref.watch(
      batchExtractionProvider.select((s) => (s.selectedItemCount, s.saving)),
    );
    return PaperActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: saving || count == 0 ? null : onSave,
            child: Text(
              saving
                  ? context.l10n.batchSavingPiecesLabel(count)
                  : count == 0
                  ? context.l10n.batchChoosePiecesToSave
                  : context.l10n.batchSavePiecesLabel(count),
            ),
          ),
          TextButton(
            onPressed: saving ? null : onDiscard,
            child: Text(context.l10n.batchDiscardAllAction),
          ),
        ],
      ),
    );
  }
}

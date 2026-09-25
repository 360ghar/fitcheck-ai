import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/app_ui.dart';
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
        saved.length == 1
            ? '1 piece is in your closet.'
            : '${saved.length} pieces are in your closet.',
        title: 'Saved',
      );
      _exitFlow(context, ref);
    } else if (failures.isNotEmpty && saved.isEmpty) {
      ErrorHandler.showError(
        'Nothing was saved. Try again.',
        title: 'Not saved',
      );
    }
    // A partial save stays on the page: the banner names what is left.
  }

  Future<void> _confirmDiscard(BuildContext context, WidgetRef ref) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard these pieces?'),
        content: const Text('Nothing from this batch is saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: PaperTokens.of(context).error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
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
            title: const Text('Review pieces'),
            actions: [
              if (!empty)
                Padding(
                  padding: const EdgeInsets.only(right: AppConstants.spacing8),
                  child: TextButton(
                    onPressed: saving
                        ? null
                        : () => notifier.setAllIncluded(!allIncluded),
                    child: Text(allIncluded ? 'Skip all' : 'Include all'),
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
                      title: 'No pieces found',
                      message: 'We found no clothes in these photos.',
                      actionLabel: 'Choose other photos',
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
                                                'Added to every piece you save.',
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

class _SaveFailures extends ConsumerWidget {
  const _SaveFailures({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failures = ref.watch(
      batchExtractionProvider.select((s) => s.saveFailures),
    );
    if (failures.isEmpty) return const SizedBox.shrink();
    return AppErrorBanner(
      message: 'Not saved yet: ${failures.join(', ')}.',
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
          '$total ${total == 1 ? 'piece' : 'pieces'} from $photos ${photos == 1 ? 'photo' : 'photos'}',
          style: text.headlineSmall,
        ),
        const SizedBox(height: AppConstants.spacing4),
        Text(
          '$selected chosen. Tap a piece to skip it.',
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
        title: const Text('Remove this piece?'),
        content: const Text('It is not saved to your closet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: PaperTokens.of(context).error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
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
                  ? 'Saving $count ${count == 1 ? 'piece' : 'pieces'}'
                  : count == 0
                  ? 'Choose pieces to save'
                  : 'Save $count ${count == 1 ? 'piece' : 'pieces'}',
            ),
          ),
          TextButton(
            onPressed: saving ? null : onDiscard,
            child: const Text('Discard all'),
          ),
        ],
      ),
    );
  }
}

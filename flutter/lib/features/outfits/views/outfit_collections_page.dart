import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/outfit_model.dart';
import '../providers/outfit_providers.dart';

/// Named groups of outfits.
class OutfitCollectionsPage extends ConsumerWidget {
  const OutfitCollectionsPage({super.key});

  static String _name(Map<String, dynamic> c) =>
      (c['name'] as String?)?.trim().isNotEmpty == true
      ? c['name'] as String
      : 'Untitled';

  static int _count(Map<String, dynamic> c) =>
      (c['outfit_count'] as num?)?.toInt() ??
      (c['outfit_ids'] as List?)?.length ??
      0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    final notifier = ref.read(collectionsProvider.notifier);

    return PaperStockScope(
      stock: PaperStockId.marigold,
      child: Scaffold(
        appBar: AppBar(title: const Text('Collections')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New collection'),
        ),
        body: AppPageBackground(
          child: RefreshIndicator(
            onRefresh: notifier.refresh,
            child: switch (collections) {
              AsyncValue(:final value?) when value.isEmpty => ListView(
                children: [
                  AppEmptyState(
                    scene: PaperScenes.outfits,
                    title: 'No collections yet',
                    message: 'Group outfits by trip, season or mood.',
                    actionLabel: 'Create a collection',
                    onAction: () => _edit(context, ref),
                  ),
                ],
              ),
              AsyncValue(:final value?) => GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacing16,
                  AppConstants.spacing16,
                  AppConstants.spacing16,
                  96,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  mainAxisSpacing: AppConstants.spacing12 + 3,
                  crossAxisSpacing: AppConstants.spacing12,
                  childAspectRatio: 1.15,
                ),
                itemCount: value.length,
                itemBuilder: (context, i) => _CollectionCard(
                  collection: value[i],
                  onTap: () => _showCollection(context, ref, value[i]),
                ),
              ),
              AsyncValue(:final error?) => ListView(
                children: [
                  AppErrorState(error: error, onRetry: notifier.refresh),
                ],
              ),
              _ => ListView(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                children: const [
                  SkeletonGridLoaderBox(itemCount: 4, childAspectRatio: 1.15),
                ],
              ),
            },
          ),
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    Map<String, dynamic>? collection,
  ]) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => _CollectionDialog(collection: collection),
    );
    if (result == null) return;
    final notifier = ref.read(collectionsProvider.notifier);
    if (collection == null) {
      await notifier.create(result.$1, result.$2);
    } else {
      await notifier.rename(collection, result.$1, result.$2);
    }
  }

  Future<void> _showCollection(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> collection,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        final tokens = PaperTokens.of(context);
        final text = Theme.of(context).textTheme;
        final description = collection['description'] as String?;
        final count = _count(collection);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_name(collection), style: text.headlineSmall),
                if (description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    description!,
                    style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
                  ),
                ],
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  count == 1 ? '1 outfit' : '$count outfits',
                  style: text.bodySmall?.copyWith(color: tokens.textMuted),
                ),
                const SizedBox(height: AppConstants.spacing20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, 'add'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add outfits'),
                ),
                const SizedBox(height: AppConstants.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'edit'),
                      child: const Text('Rename'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: tokens.error),
                      onPressed: () => Navigator.pop(context, 'delete'),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!context.mounted) return;
    switch (action) {
      case 'add':
        await _addOutfits(context, ref, collection);
      case 'edit':
        await _edit(context, ref, collection);
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete "${_name(collection)}"?'),
            content: const Text('The outfits in it are kept.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: PaperTokens.of(context).error,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(collectionsProvider.notifier).delete(collection);
        }
    }
  }

  Future<void> _addOutfits(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> collection,
  ) async {
    final notifier = ref.read(collectionsProvider.notifier);
    final existing = {
      for (final id in (collection['outfit_ids'] as List? ?? const [])) '$id',
    };
    final List<OutfitModel> candidates;
    try {
      candidates = [
        for (final o in await notifier.allOutfits())
          if (!existing.contains(o.id)) o,
      ];
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Outfits not loaded', stackTrace: stack);
      return;
    }
    if (!context.mounted) return;
    final chosen = await showDialog<List<String>>(
      context: context,
      builder: (_) => _PickOutfitsDialog(
        title: 'Add to "${_name(collection)}"',
        outfits: candidates,
      ),
    );
    if (chosen == null || chosen.isEmpty) return;
    await notifier.addOutfits(collection['id'].toString(), chosen);
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection, required this.onTap});

  final Map<String, dynamic> collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final count = OutfitCollectionsPage._count(collection);
    final description = collection['description'] as String?;
    return PaperSurface(
      onTap: onTap,
      deckle: PaperEdge.bottom,
      semanticLabel: '${OutfitCollectionsPage._name(collection)}, $count outfits',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            OutfitCollectionsPage._name(collection),
            style: text.headlineSmall?.copyWith(fontSize: 22),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.spacing4),
          if (description?.isNotEmpty ?? false)
            Expanded(
              child: Text(
                description!,
                style: text.bodySmall?.copyWith(color: tokens.textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          Text(
            count == 1 ? '1 outfit' : '$count outfits',
            style: text.labelLarge?.copyWith(color: tokens.stock.accent),
          ),
        ],
      ),
    );
  }
}

/// Name and description for a new or renamed collection.
class _CollectionDialog extends StatefulWidget {
  const _CollectionDialog({this.collection});

  final Map<String, dynamic>? collection;

  @override
  State<_CollectionDialog> createState() => _CollectionDialogState();
}

class _CollectionDialogState extends State<_CollectionDialog> {
  late final _name = TextEditingController(
    text: widget.collection?['name'] as String? ?? '',
  );
  late final _description = TextEditingController(
    text: widget.collection?['description'] as String? ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, (name, _description.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.collection == null ? 'New collection' : 'Rename collection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Name'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _description,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

class _PickOutfitsDialog extends StatefulWidget {
  const _PickOutfitsDialog({required this.title, required this.outfits});

  final String title;
  final List<OutfitModel> outfits;

  @override
  State<_PickOutfitsDialog> createState() => _PickOutfitsDialogState();
}

class _PickOutfitsDialogState extends State<_PickOutfitsDialog> {
  final Set<String> _chosen = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.outfits.isEmpty
            ? const Text('Every outfit is already in this collection.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.outfits.length,
                itemBuilder: (context, i) {
                  final outfit = widget.outfits[i];
                  return CheckboxListTile(
                    value: _chosen.contains(outfit.id),
                    title: Text(outfit.name),
                    subtitle: Text('${outfit.itemIds.length} pieces'),
                    onChanged: (on) => setState(
                      () => on == true
                          ? _chosen.add(outfit.id)
                          : _chosen.remove(outfit.id),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _chosen.isEmpty
              ? null
              : () => Navigator.pop(context, _chosen.toList()),
          child: Text(_chosen.isEmpty ? 'Add' : 'Add ${_chosen.length}'),
        ),
      ],
    );
  }
}

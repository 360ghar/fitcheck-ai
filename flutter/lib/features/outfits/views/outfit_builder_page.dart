import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/season.dart';
import '../../../domain/enums/style.dart';
import '../../wardrobe/models/item_model.dart';
import '../../wardrobe/providers/wardrobe_providers.dart';
import '../../wardrobe/widgets/garment_glyph.dart';
import '../providers/outfit_builder_provider.dart';

/// Builds a new outfit: pick pieces, name it, preview it with AI, save.
class OutfitBuilderPage extends ConsumerStatefulWidget {
  const OutfitBuilderPage({super.key});

  @override
  ConsumerState<OutfitBuilderPage> createState() => _OutfitBuilderPageState();
}

class _OutfitBuilderPageState extends ConsumerState<OutfitBuilderPage> {
  final _search = TextEditingController();
  Category? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final outfit = await ref.read(outfitBuilderProvider.notifier).save();
    if (outfit != null && mounted) Navigator.pop(context, outfit);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(outfitBuilderProvider);
    final picker = ref.watch(builderPickerItemsProvider);

    return PaperStockScope(
      stock: PaperStockId.marigold,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Build an outfit'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppConstants.spacing8),
              child: TextButton(
                onPressed: draft.saving || draft.pieces.isEmpty ? null : _save,
                child: draft.saving
                    ? const InlineProcessingStatus(
                        phase: ProcessingPhase.processing,
                        processingLabel: 'Saving',
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
        body: AppPageBackground(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              const SliverToBoxAdapter(child: _DetailsCard()),
              if (draft.previewUrl != null || draft.generating)
                SliverToBoxAdapter(child: _Preview(draft: draft)),
              SliverToBoxAdapter(child: _ChosenRow(pieces: draft.pieces)),
              SliverToBoxAdapter(child: _pickerControls()),
              ..._picker(picker, draft),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacing24),
              ),
            ],
          ),
        ),
        bottomNavigationBar: draft.pieces.isEmpty
            ? null
            : PaperActionBar(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: draft.generating
                        ? null
                        : ref
                              .read(outfitBuilderProvider.notifier)
                              .generatePreview,
                    icon: draft.generating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_outlined),
                    label: Text(
                      draft.previewUrl == null
                          ? 'Preview with AI'
                          : 'Make a new preview',
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _pickerControls() {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing16,
            ),
            child: Text(
              'Your closet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing16,
            ),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search pieces',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(_search.clear),
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppConstants.spacing8).copyWith(
                left: AppConstants.spacing16,
                right: AppConstants.spacing16,
              ),
              children: [
                for (final c in <Category?>[null, ...Category.values])
                  Padding(
                    padding: const EdgeInsets.only(
                      right: AppConstants.spacing8,
                    ),
                    child: FilterChip(
                      label: Text(c?.displayName ?? 'All'),
                      selected: _category == c,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _picker(AsyncValue<List<ItemModel>> picker, OutfitDraft draft) {
    const padding = EdgeInsets.symmetric(horizontal: AppConstants.spacing16);
    const gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 90,
      mainAxisSpacing: AppConstants.spacing8,
      crossAxisSpacing: AppConstants.spacing8,
      childAspectRatio: 0.72,
    );
    return switch (picker) {
      AsyncValue(:final value?) when value.isEmpty => [
        SliverToBoxAdapter(
          child: AppEmptyState(
            scene: PaperScenes.closet,
            title: 'Add pieces first',
            message: 'Outfits are made from the pieces in your closet.',
            actionLabel: 'Add a piece',
            onAction: () async {
              await context.push(Routes.wardrobeAdd);
              // The picker caches one result per builder session; without a
              // refresh the piece just added stays invisible.
              if (context.mounted) ref.invalidate(builderPickerItemsProvider);
            },
          ),
        ),
      ],
      AsyncValue(:final value?) => () {
        final query = _search.text.trim().toLowerCase();
        final shown = [
          for (final item in value)
            if ((_category == null || item.category == _category) &&
                (query.isEmpty ||
                    item.name.toLowerCase().contains(query) ||
                    (item.brand?.toLowerCase().contains(query) ?? false)))
              item,
        ];
        if (shown.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing24),
                child: Text(
                  'No pieces match.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PaperTokens.of(context).textSecondary,
                  ),
                ),
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: padding,
            sliver: SliverGrid.builder(
              gridDelegate: gridDelegate,
              itemCount: shown.length,
              itemBuilder: (context, i) => _PickTile(
                item: shown[i],
                selected: draft.contains(shown[i].id),
              ),
            ),
          ),
        ];
      }(),
      AsyncValue(:final error?) => [
        SliverToBoxAdapter(
          child: AppErrorState(
            error: error,
            onRetry: () => ref.invalidate(builderPickerItemsProvider),
          ),
        ),
      ],
      _ => [
        SliverPadding(
          padding: padding,
          sliver: SkeletonPulse(
            child: SliverGrid.builder(
              gridDelegate: gridDelegate,
              itemCount: 12,
              itemBuilder: (context, index) => const SkeletonGridItem(),
            ),
          ),
        ),
      ],
    };
  }
}

class _DetailsCard extends ConsumerStatefulWidget {
  const _DetailsCard();

  @override
  ConsumerState<_DetailsCard> createState() => _DetailsCardState();
}

class _DetailsCardState extends ConsumerState<_DetailsCard> {
  late final _name = TextEditingController(
    text: ref.read(outfitBuilderProvider).name,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(outfitBuilderProvider);
    final notifier = ref.read(outfitBuilderProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: PaperSurface(
        child: Column(
          children: [
            TextField(
              controller: _name,
              onChanged: notifier.setName,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Outfit name',
                hintText: 'For example, Weekend linen',
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Style>(
                    initialValue: draft.style,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Style'),
                    items: [
                      for (final s in Style.values)
                        DropdownMenuItem(value: s, child: Text(s.displayName)),
                    ],
                    onChanged: (v) => v == null ? null : notifier.setStyle(v),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: DropdownButtonFormField<Season>(
                    initialValue: draft.season,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Season'),
                    items: [
                      for (final s in Season.values)
                        DropdownMenuItem(value: s, child: Text(s.displayName)),
                    ],
                    onChanged: (v) => v == null ? null : notifier.setSeason(v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.draft});

  final OutfitDraft draft;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final url = draft.previewUrl;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: PaperSurface(
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        grain: false,
        color: tokens.stock.sunk,
        child: AspectRatio(
          aspectRatio: 1,
          child: url == null
              ? const SkeletonPulse(child: SkeletonBox(borderRadius: 0))
              : AppImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  backgroundColor: tokens.stock.sunk,
                  semanticLabel: 'AI preview of the outfit',
                ),
        ),
      ),
    );
  }
}

class _ChosenRow extends ConsumerWidget {
  const _ChosenRow({required this.pieces});

  final List<ItemModel> pieces;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pieces.isEmpty
                ? 'Choose pieces'
                : pieces.length == 1
                ? '1 piece chosen'
                : '${pieces.length} pieces chosen',
            style: text.titleMedium,
          ),
          const SizedBox(height: AppConstants.spacing4),
          if (pieces.isEmpty)
            Text(
              'Tap pieces below to add them.',
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            )
          else
            SizedBox(
              height: 84,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(top: AppConstants.spacing8),
                children: [
                  for (final p in pieces)
                    Padding(
                      padding: const EdgeInsets.only(
                        right: AppConstants.spacing8,
                      ),
                      child: SizedBox.square(
                        dimension: 72,
                        child: Stack(
                          fit: StackFit.expand,
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radius8,
                              ),
                              child: _PieceImage(item: p),
                            ),
                            // The 44px target overhangs the tile corner;
                            // the row's top padding keeps it unclipped.
                            Positioned(
                              top: -8,
                              right: -8,
                              child: IconButton(
                                tooltip: 'Remove ${p.name}',
                                onPressed: () => ref
                                    .read(outfitBuilderProvider.notifier)
                                    .toggle(p),
                                icon: Icon(
                                  Icons.cancel_rounded,
                                  size: 20,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
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

class _PickTile extends ConsumerWidget {
  const _PickTile({required this.item, required this.selected});

  final ItemModel item;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    return PaperSurface(
      padding: EdgeInsets.zero,
      grain: false,
      clipBehavior: Clip.antiAlias,
      color: selected ? tokens.stock.tint : null,
      onTap: () => ref.read(outfitBuilderProvider.notifier).toggle(item),
      semanticLabel: '${item.name}${selected ? ', chosen' : ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _PieceImage(item: item),
                if (selected)
                  Positioned(
                    top: AppConstants.spacing4,
                    right: AppConstants.spacing4,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: tokens.stock.accent,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing6),
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _PieceImage extends ConsumerWidget {
  const _PieceImage({required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final image = item.primaryImage;
    return ColoredBox(
      color: tokens.stock.sunk,
      child: image == null
          ? Center(child: GarmentGlyph(category: item.category, size: 36))
          : AppImage(
              imageUrl: image.url,
              fit: BoxFit.contain,
              enableZoom: false,
              memCacheWidth: 300,
              backgroundColor: tokens.stock.sunk,
              storagePath: image.storagePath,
              remintUrl: ref.read(itemRepositoryProvider).remintImageUrl,
              semanticLabel: item.name,
            ),
    );
  }
}

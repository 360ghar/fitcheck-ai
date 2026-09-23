import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/paged_state.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/season.dart';
import '../../../domain/enums/style.dart';
import '../../wardrobe/models/item_model.dart';
import '../../wardrobe/widgets/garment_glyph.dart';
import '../models/outfit_model.dart';
import '../providers/outfit_providers.dart';
import 'outfit_detail_page.dart';

/// Outfits tab. The shell supplies the Scaffold, the create button and the
/// marigold paper stock.
class OutfitsContent extends ConsumerStatefulWidget {
  const OutfitsContent({super.key});

  @override
  ConsumerState<OutfitsContent> createState() => _OutfitsContentState();
}

class _OutfitsContentState extends ConsumerState<OutfitsContent> {
  bool _searching = false;
  final _search = TextEditingController();
  Timer? _searchDebounce;

  OutfitsNotifier get _outfits => ref.read(outfitsProvider.notifier);

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      AppConstants.searchDebounceDuration,
      () => ref.read(outfitFiltersProvider.notifier).setSearch(value),
    );
  }

  void _closeSearch() {
    _searchDebounce?.cancel();
    _search.clear();
    ref.read(outfitFiltersProvider.notifier).setSearch('');
    setState(() => _searching = false);
  }

  /// Opens the outfit in a tall sheet over the grid.
  void _openDetail(OutfitModel outfit) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.94,
        child: OutfitDetailPage(outfitId: outfit.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final outfits = ref.watch(outfitsProvider);
    final filters = ref.watch(outfitFiltersProvider);
    final page = outfits.value;
    final showScene =
        !_searching && (page == null ? !outfits.hasError : !page.isEmpty);

    return AppPageBackground(
      child: RefreshIndicator(
        onRefresh: _outfits.refresh,
        child: InfiniteScrollWrapper(
          onLoadMore: _outfits.loadMore,
          canLoadMore: () {
            final s = ref.read(outfitsProvider);
            return !s.isLoading && (s.value?.canLoadMore ?? false);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _header(page, failed: outfits.hasError),
              ),
              if (showScene)
                const SliverToBoxAdapter(
                  child: PaperScene(preset: PaperScenes.outfits, height: 112),
                ),
              SliverToBoxAdapter(child: _FilterChips(filters: filters)),
              if (page != null && outfits.hasError)
                SliverToBoxAdapter(
                  child: AppErrorBanner(
                    error: outfits.error,
                    onRetry: _outfits.refresh,
                  ),
                ),
              ..._content(outfits, filters),
              if (page != null)
                SliverLoadingMoreIndicator(
                  isLoading: page.isLoadingMore,
                  error: page.loadMoreError,
                  onRetry: _outfits.retryLoadMore,
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    AsyncValue<PagedState<OutfitModel>> outfits,
    OutfitFilters filters,
  ) {
    const padding = EdgeInsets.fromLTRB(
      AppConstants.spacing16,
      AppConstants.spacing8,
      AppConstants.spacing16,
      AppConstants.spacing8,
    );
    final page = outfits.value;
    if (page == null) {
      if (outfits.hasError) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorState(
              error: outfits.error,
              onRetry: _outfits.refresh,
            ),
          ),
        ];
      }
      return const [
        SliverPadding(
          padding: padding,
          sliver: SkeletonGridLoader(itemCount: 6, childAspectRatio: 0.8),
        ),
      ];
    }
    if (page.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: filters.isFiltered
              ? AppEmptyState(
                  scene: PaperScenes.outfits,
                  title: 'No outfits match',
                  message: 'Try fewer filters or another search.',
                  actionLabel: 'Clear filters',
                  onAction: () {
                    _closeSearch();
                    ref.read(outfitFiltersProvider.notifier).clear();
                  },
                )
              : AppEmptyState(
                  scene: PaperScenes.outfits,
                  title: 'No outfits yet',
                  message: 'Pair pieces from your closet and save the look.',
                  actionLabel: 'Build an outfit',
                  actionIcon: Icons.style_outlined,
                  onAction: () => context.push(Routes.outfitBuilder),
                ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: padding,
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: AppConstants.spacing12 + 3,
            crossAxisSpacing: AppConstants.spacing12,
            childAspectRatio: 0.8,
          ),
          itemCount: page.items.length,
          itemBuilder: (context, i) => _OutfitCard(
            outfit: page.items[i],
            onTap: _openDetail,
            onLongPress: _showOptions,
          ),
        ),
      ),
    ];
  }

  Widget _header(PagedState<OutfitModel>? page, {required bool failed}) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final Widget title = _searching
        ? TextField(
            controller: _search,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Search your outfits',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Outfits', style: text.displaySmall?.copyWith(fontSize: 34)),
              Text(
                page == null
                    ? (failed ? ' ' : 'Loading your outfits')
                    : page.total == 1
                    ? '1 outfit'
                    : '${page.total} outfits',
                style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
            ],
          );
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing20,
          AppConstants.spacing12,
          AppConstants.spacing8,
          AppConstants.spacing8,
        ),
        child: Row(
          children: [
            Expanded(child: title),
            if (_searching)
              IconButton(
                tooltip: 'Close search',
                icon: const Icon(Icons.close_rounded),
                onPressed: _closeSearch,
              )
            else ...[
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search_rounded),
                onPressed: () => setState(() => _searching = true),
              ),
              PopupMenuButton<String>(
                tooltip: 'More',
                icon: const Icon(Icons.tune_rounded),
                onSelected: (value) => value == 'filter'
                    ? showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const _FilterSheet(),
                      )
                    : context.push(Routes.outfitCollections),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'filter',
                    child: Text('Style and season'),
                  ),
                  PopupMenuItem(
                    value: 'collections',
                    child: Text('Collections'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showOptions(OutfitModel outfit) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacing20,
                AppConstants.spacing20,
                AppConstants.spacing20,
                AppConstants.spacing8,
              ),
              child: Text(
                outfit.name,
                style: Theme.of(context).textTheme.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ListTile(
              leading: Icon(
                outfit.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
              ),
              title: Text(outfit.isFavorite ? 'Remove favourite' : 'Favourite'),
              onTap: () => Navigator.pop(context, 'favorite'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.copy_all_outlined),
              title: const Text('Duplicate'),
              onTap: () => Navigator.pop(context, 'duplicate'),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: PaperTokens.of(context).error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: PaperTokens.of(context).error),
              ),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case 'favorite':
        await _outfits.toggleFavorite(outfit.id);
      case 'edit':
        context.push(Routes.outfitEdit(outfit.id));
      case 'duplicate':
        await _outfits.duplicate(outfit.id);
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete this outfit?'),
            content: const Text('Its pieces stay in your closet.'),
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
        if (confirmed == true) await _outfits.delete(outfit.id);
    }
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.filters});

  final OutfitFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(outfitFiltersProvider.notifier);
    Widget chip(String label, bool selected, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(right: AppConstants.spacing8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
      ),
    );
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing8,
        ),
        children: [
          chip(
            'All',
            filters.styles.isEmpty &&
                filters.seasons.isEmpty &&
                !filters.favoritesOnly &&
                !filters.draftsOnly,
            notifier.clearChips,
          ),
          chip(
            'Favourites',
            filters.favoritesOnly,
            () => notifier.setFavoritesOnly(!filters.favoritesOnly),
          ),
          chip(
            'Drafts',
            filters.draftsOnly,
            () => notifier.setDraftsOnly(!filters.draftsOnly),
          ),
          for (final s in Style.values)
            chip(
              s.displayName,
              filters.styles.contains(s),
              () => notifier.toggleStyle(s),
            ),
        ],
      ),
    );
  }
}

class _OutfitCard extends ConsumerWidget {
  const _OutfitCard({
    required this.outfit,
    required this.onTap,
    required this.onLongPress,
  });

  final OutfitModel outfit;
  final void Function(OutfitModel) onTap;
  final void Function(OutfitModel) onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final image = outfit.outfitImages?.firstOrNull;
    final pieces = outfit.items ?? const <ItemModel>[];
    final details = [
      if (outfit.style != null) outfit.style!.displayName,
      if (outfit.isDraft) 'Draft',
    ].join(' · ');

    return PaperSurface(
      padding: EdgeInsets.zero,
      grain: false,
      clipBehavior: Clip.antiAlias,
      onTap: () => onTap(outfit),
      onLongPress: () => onLongPress(outfit),
      semanticLabel: '${outfit.name}${outfit.isFavorite ? ', favourite' : ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ColoredBox(
              color: tokens.stock.sunk,
              child: image != null
                  ? AppImage(
                      imageUrl: image.url,
                      fit: BoxFit.contain,
                      enableZoom: false,
                      memCacheWidth: 480,
                      backgroundColor: tokens.stock.sunk,
                      storagePath: image.storagePath,
                      remintUrl: ref
                          .read(outfitRepositoryProvider)
                          .remintImageUrl,
                      semanticLabel: outfit.name,
                    )
                  : _MiniCollage(pieces: pieces),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing12,
              AppConstants.spacing8,
              AppConstants.spacing8,
              AppConstants.spacing8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outfit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall,
                      ),
                      if (details.isNotEmpty)
                        Text(
                          details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (outfit.isFavorite)
                  Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: tokens.stock.accent,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Garment glyphs for an outfit without its own image.
class _MiniCollage extends StatelessWidget {
  const _MiniCollage({required this.pieces});

  final List<ItemModel> pieces;

  @override
  Widget build(BuildContext context) {
    if (pieces.isEmpty) {
      return Center(
        child: Icon(
          Icons.style_outlined,
          size: 40,
          color: PaperTokens.of(context).textMuted,
        ),
      );
    }
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppConstants.spacing8,
        runSpacing: AppConstants.spacing8,
        children: [
          for (final p in pieces.take(4))
            GarmentGlyph(category: p.category, size: 40),
        ],
      ),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(outfitFiltersProvider);
    final notifier = ref.read(outfitFiltersProvider.notifier);
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Style and season', style: text.headlineSmall),
            const SizedBox(height: AppConstants.spacing16),
            Text('Style', style: text.titleSmall),
            const SizedBox(height: AppConstants.spacing8),
            Wrap(
              spacing: AppConstants.spacing8,
              runSpacing: AppConstants.spacing8,
              children: [
                for (final s in Style.values)
                  FilterChip(
                    label: Text(s.displayName),
                    selected: filters.styles.contains(s),
                    onSelected: (_) => notifier.toggleStyle(s),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Text('Season', style: text.titleSmall),
            const SizedBox(height: AppConstants.spacing8),
            Wrap(
              spacing: AppConstants.spacing8,
              runSpacing: AppConstants.spacing8,
              children: [
                for (final s in Season.values)
                  FilterChip(
                    label: Text(s.displayName),
                    selected: filters.seasons.contains(s),
                    onSelected: (_) => notifier.toggleSeason(s),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    notifier.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear all'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

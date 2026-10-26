import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/i18n/taxonomy_l10n.dart';
import '../../../core/state/paged_state.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/constants/use_cases.dart';
import '../../../domain/enums/category.dart';
import '../models/item_model.dart';
import '../providers/wardrobe_providers.dart';
import '../widgets/active_job_banner.dart';
import '../widgets/garment_glyph.dart';

/// Localized label for a closet sort order. The enum stays context-free so the
/// provider layer can keep using it; only the label a person reads moves here.
///
/// `labelOf` rather than `label`: the enum already has a `label` field holding
/// the English string, and an instance member always wins over an extension, so
/// `sort.label(l10n)` would not compile.
extension LocalizedWardrobeSort on WardrobeSort {
  String labelOf(AppLocalizations l10n) => switch (this) {
    WardrobeSort.newest => l10n.sortNewest,
    WardrobeSort.oldest => l10n.sortOldest,
    WardrobeSort.name => l10n.sortName,
    WardrobeSort.mostWorn => l10n.sortMostWorn,
  };
}

/// Closet tab. The shell supplies the Scaffold, the add button and the moss
/// paper stock.
class WardrobeContent extends ConsumerStatefulWidget {
  const WardrobeContent({super.key});

  @override
  ConsumerState<WardrobeContent> createState() => _WardrobeContentState();
}

/// How the closet shows its pieces. Rows is the default; a filter or a
/// search always shows the flat grid or list of matches.
enum _ClosetView { rows, grid, list }

/// Row order: the order a user dresses in, then the rest.
const _shelfOrder = [
  Category.tops,
  Category.bottoms,
  Category.accessories,
  Category.shoes,
  Category.outerwear,
  Category.activewear,
  Category.swimwear,
  Category.other,
];

class _WardrobeContentState extends ConsumerState<WardrobeContent> {
  _ClosetView _view = _ClosetView.rows;
  bool _searching = false;
  final _search = TextEditingController();
  Timer? _searchDebounce;

  WardrobeNotifier get _wardrobe => ref.read(wardrobeProvider.notifier);

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
      () => ref.read(wardrobeFiltersProvider.notifier).setSearch(value),
    );
  }

  void _closeSearch() {
    _searchDebounce?.cancel();
    _search.clear();
    ref.read(wardrobeFiltersProvider.notifier).setSearch('');
    setState(() => _searching = false);
  }

  /// Clears every filter, including the search text kept in this widget's
  /// own controller (the filters notifier never sees it directly).
  void _clearAllFilters() {
    _searchDebounce?.cancel();
    _search.clear();
    ref.read(wardrobeFiltersProvider.notifier).clear();
  }

  void _open(ItemModel item) {
    final selection = ref.read(wardrobeSelectionProvider);
    if (selection.isNotEmpty) {
      ref.read(wardrobeSelectionProvider.notifier).toggle(item.id);
    } else {
      context.push(Routes.item(item.id));
    }
  }

  bool _showRows(WardrobeFilters filters) =>
      _view == _ClosetView.rows && !filters.isFiltered;

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeProvider);
    final filters = ref.watch(wardrobeFiltersProvider);
    final page = wardrobe.value;

    return AppPageBackground(
      child: RefreshIndicator(
        onRefresh: () => ref
            .refresh(wardrobeProvider.future)
            .then<void>((_) {}, onError: (_) {}),
        child: InfiniteScrollWrapper(
          onLoadMore: _wardrobe.loadMore,
          canLoadMore: () {
            final s = ref.read(wardrobeProvider);
            return !s.isLoading && (s.value?.canLoadMore ?? false);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _header(page, failed: wardrobe.hasError),
              ),
              // Scans running in the background stay resumable from here.
              const SliverToBoxAdapter(child: ActiveJobBanner()),
              // The empty and error states carry their own scene.
              if (!_searching &&
                  (page == null ? !wardrobe.hasError : !page.isEmpty))
                const SliverToBoxAdapter(
                  child: PaperScene(preset: PaperScenes.closet, height: 112),
                ),
              SliverToBoxAdapter(
                child: _CategoryChips(
                  filters: filters,
                  onClearAll: _clearAllFilters,
                ),
              ),
              if (page != null && wardrobe.hasError)
                SliverToBoxAdapter(
                  child: AppErrorBanner(
                    error: wardrobe.error,
                    onRetry: _wardrobe.refresh,
                  ),
                ),
              ..._content(wardrobe, filters),
              if (page != null)
                SliverLoadingMoreIndicator(
                  isLoading: page.isLoadingMore,
                  error: page.loadMoreError,
                  onRetry: _wardrobe.retryLoadMore,
                ),
              // Room for the add button over the last row.
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    AsyncValue<PagedState<ItemModel>> wardrobe,
    WardrobeFilters filters,
  ) {
    const padding = EdgeInsets.fromLTRB(
      AppConstants.spacing16,
      AppConstants.spacing4,
      AppConstants.spacing16,
      AppConstants.spacing8,
    );
    final page = wardrobe.value;
    if (page == null) {
      if (wardrobe.hasError) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorState(
              error: wardrobe.error,
              onRetry: _wardrobe.refresh,
            ),
          ),
        ];
      }
      return const [
        SliverPadding(
          padding: padding,
          sliver: SkeletonGridLoader(
            crossAxisCount: 4,
            itemCount: 12,
            childAspectRatio: 0.72,
          ),
        ),
      ];
    }
    if (page.isEmpty) {
      final l10n = context.l10n;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: filters.isFiltered
              ? AppEmptyState(
                  scene: PaperScenes.closet,
                  title: l10n.closetNoMatchesTitle,
                  message: l10n.closetNoMatchesBody,
                  actionLabel: l10n.closetClearFilters,
                  onAction: () {
                    _closeSearch();
                    ref.read(wardrobeFiltersProvider.notifier).clear();
                  },
                )
              : AppEmptyState(
                  scene: PaperScenes.closet,
                  title: l10n.wardrobeEmptyTitle,
                  message: l10n.wardrobeEmptyBody,
                  actionLabel: l10n.wardrobeAddFirst,
                  actionIcon: Icons.add_a_photo_outlined,
                  onAction: () => context.push(Routes.wardrobeAdd),
                ),
        ),
      ];
    }
    if (_showRows(filters)) return [_shelves(page)];
    return [
      SliverPadding(
        padding: padding,
        sliver: _view == _ClosetView.grid || _view == _ClosetView.rows
            ? SliverGrid.builder(
                // Item cutouts are cropped to the item plus a small pad
                // (backend `crop=True`), so a narrow tile still shows the
                // whole garment: 4 columns on a phone, 8 on a tablet.
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 96,
                  mainAxisSpacing: AppConstants.spacing8,
                  crossAxisSpacing: AppConstants.spacing8,
                  childAspectRatio: 0.72,
                ),
                itemCount: page.items.length,
                itemBuilder: (context, i) => _ItemTile(
                  item: page.items[i],
                  onTap: _open,
                  onLongPress: _showItemOptions,
                ),
              )
            : SliverList.separated(
                itemCount: page.items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppConstants.spacing12),
                itemBuilder: (context, i) => _ItemRow(
                  item: page.items[i],
                  onTap: _open,
                  onLongPress: _showItemOptions,
                ),
              ),
      ),
    ];
  }

  /// One horizontal row per category that has pieces, grouped from the
  /// single closet fetch. Every loaded row renders at once.
  Widget _shelves(PagedState<ItemModel> page) {
    final byCategory = <Category, List<ItemModel>>{};
    for (final item in page.items) {
      (byCategory[item.category] ??= []).add(item);
    }
    return SliverList.list(
      children: [
        for (final category in _shelfOrder)
          if (byCategory[category] case final items? when items.isNotEmpty)
            _Shelf(
              key: ValueKey(category),
              category: category,
              items: items,
              onTap: _open,
              onLongPress: _showItemOptions,
            ),
      ],
    );
  }

  Widget _header(PagedState<ItemModel>? page, {required bool failed}) {
    final tokens = PaperTokens.of(context);
    final l10n = context.l10n;
    final selection = ref.watch(wardrobeSelectionProvider);
    final text = Theme.of(context).textTheme;

    final Widget title;
    if (selection.isNotEmpty) {
      title = Text(
        l10n.closetSelectedCount(selection.length),
        style: text.headlineMedium,
      );
    } else if (_searching) {
      title = TextField(
        controller: _search,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: l10n.wardrobeSearchHint,
          prefixIcon: const Icon(Icons.search_rounded),
        ),
      );
    } else {
      title = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.wardrobeTitle,
            style: text.displaySmall?.copyWith(fontSize: 34),
          ),
          Text(
            page == null
                ? (failed ? ' ' : l10n.closetLoading)
                : l10n.closetPieceCount(page.total),
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
        ],
      );
    }

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppConstants.spacing20,
          AppConstants.spacing12,
          AppConstants.spacing8,
          AppConstants.spacing8,
        ),
        child: Row(
          children: [
            Expanded(child: title),
            if (selection.isNotEmpty) ...[
              IconButton(
                tooltip: l10n.closetDeleteSelected,
                icon: Icon(Icons.delete_outline_rounded, color: tokens.error),
                onPressed: _confirmDeleteSelected,
              ),
              IconButton(
                tooltip: l10n.closetCancelSelection,
                icon: const Icon(Icons.close_rounded),
                onPressed: ref.read(wardrobeSelectionProvider.notifier).clear,
              ),
            ] else if (_searching)
              IconButton(
                tooltip: l10n.closetCloseSearch,
                icon: const Icon(Icons.close_rounded),
                onPressed: _closeSearch,
              )
            else ...[
              IconButton(
                tooltip: l10n.actionSearch,
                icon: const Icon(Icons.search_rounded),
                onPressed: () => setState(() => _searching = true),
              ),
              IconButton(
                tooltip: switch (_view) {
                  _ClosetView.rows => l10n.closetShowGrid,
                  _ClosetView.grid => l10n.closetShowList,
                  _ClosetView.list => l10n.closetShowRows,
                },
                icon: Icon(switch (_view) {
                  _ClosetView.rows => Icons.grid_view_rounded,
                  _ClosetView.grid => Icons.view_agenda_outlined,
                  _ClosetView.list => Icons.view_day_outlined,
                }),
                onPressed: () => setState(
                  () => _view = _ClosetView
                      .values[(_view.index + 1) % _ClosetView.values.length],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: l10n.tabMore,
                icon: const Icon(Icons.tune_rounded),
                onSelected: (value) => switch (value) {
                  'filter' => _showFilterSheet(),
                  'sort' => _showSortSheet(),
                  _ => context.push(Routes.wardrobeStats),
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'filter',
                    child: Text(l10n.actionFilter),
                  ),
                  PopupMenuItem(value: 'sort', child: Text(l10n.actionSort)),
                  PopupMenuItem(
                    value: 'stats',
                    child: Text(l10n.closetStatsTitle),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteSelected() async {
    final l10n = context.l10n;
    final count = ref.read(wardrobeSelectionProvider).length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.closetDeleteTitle(count)),
        content: Text(l10n.closetDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: PaperTokens.of(context).error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) await _wardrobe.deleteSelected();
  }

  Future<void> _showItemOptions(ItemModel item) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppConstants.spacing20,
                  AppConstants.spacing20,
                  AppConstants.spacing20,
                  AppConstants.spacing8,
                ),
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ListTile(
                leading: Icon(
                  item.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
                title: Text(
                  item.isFavorite
                      ? l10n.closetUnfavourite
                      : l10n.closetFavourite,
                ),
                onTap: () => Navigator.pop(context, 'favorite'),
              ),
              ListTile(
                leading: const Icon(Icons.today_outlined),
                title: Text(l10n.closetWoreToday),
                onTap: () => Navigator.pop(context, 'worn'),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded),
                title: Text(l10n.actionSelect),
                onTap: () => Navigator.pop(context, 'select'),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.actionEdit),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: PaperTokens.of(context).error,
                ),
                title: Text(
                  l10n.actionDelete,
                  style: TextStyle(color: PaperTokens.of(context).error),
                ),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    switch (action) {
      case 'favorite':
        await _wardrobe.toggleFavorite(item.id);
      case 'worn':
        await _wardrobe.markAsWorn(item.id);
      case 'select':
        ref.read(wardrobeSelectionProvider.notifier).toggle(item.id);
      case 'edit':
        context.push(Routes.itemEdit(item.id));
      case 'delete':
        ref.read(wardrobeSelectionProvider.notifier)
          ..clear()
          ..toggle(item.id);
        await _confirmDeleteSelected();
        if (mounted) ref.read(wardrobeSelectionProvider.notifier).clear();
    }
  }

  void _showSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final current = ref.watch(
            wardrobeFiltersProvider.select((f) => f.sort),
          );
          return SafeArea(
            child: RadioGroup<WardrobeSort>(
              groupValue: current,
              onChanged: (sort) {
                if (sort != null) {
                  ref.read(wardrobeFiltersProvider.notifier).setSort(sort);
                }
                Navigator.pop(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacing20),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        context.l10n.closetSortBy,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  for (final sort in WardrobeSort.values)
                    RadioListTile<WardrobeSort>(
                      value: sort,
                      title: Text(sort.labelOf(context.l10n)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FilterSheet(),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.filters, required this.onClearAll});

  final WardrobeFilters filters;

  /// Clears the whole filter state (not just categories) and syncs the
  /// search field owned by the page.
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notifier = ref.read(wardrobeFiltersProvider.notifier);
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing8,
        ),
        children: [
          _Chip(
            label: l10n.actionAll,
            selected: !filters.isFiltered,
            onTap: onClearAll,
          ),
          _Chip(
            label: l10n.closetFavourites,
            selected: filters.favoritesOnly,
            onTap: () => notifier.setFavoritesOnly(!filters.favoritesOnly),
          ),
          for (final c in Category.values)
            _Chip(
              label: c.label(l10n),
              selected: filters.categories.contains(c),
              onTap: () => notifier.toggleCategory(c),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppConstants.spacing8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

/// A closet piece: the photo on a flat paper card with its name below.
class _ItemTile extends ConsumerWidget {
  const _ItemTile({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final ItemModel item;
  final void Function(ItemModel) onTap;
  final void Function(ItemModel) onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final selected = ref.watch(
      wardrobeSelectionProvider.select((s) => s.contains(item.id)),
    );
    return PaperSurface(
      padding: EdgeInsets.zero,
      grain: false,
      clipBehavior: Clip.antiAlias,
      color: selected ? tokens.stock.tint : null,
      onTap: () => onTap(item),
      onLongPress: () => onLongPress(item),
      semanticLabel: item.isFavorite
          ? '${item.name}, ${context.l10n.closetFavourite}'
          : item.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ItemImage(item: item),
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
            padding: const EdgeInsetsDirectional.only(
              start: AppConstants.spacing6,
              top: AppConstants.spacing4,
              end: AppConstants.spacing4,
              bottom: AppConstants.spacing4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                if (item.isFavorite)
                  Icon(
                    Icons.favorite_rounded,
                    size: 12,
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

class _ItemRow extends ConsumerWidget {
  const _ItemRow({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final ItemModel item;
  final void Function(ItemModel) onTap;
  final void Function(ItemModel) onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final selected = ref.watch(
      wardrobeSelectionProvider.select((s) => s.contains(item.id)),
    );
    final details = [
      item.category.label(context.l10n),
      if (item.brand?.isNotEmpty ?? false) item.brand!,
      if (item.wornCount > 0) context.l10n.closetWornTimes(item.wornCount),
    ].join(' · ');
    return PaperSurface(
      padding: const EdgeInsets.all(AppConstants.spacing8),
      grain: false,
      color: selected ? tokens.stock.tint : null,
      onTap: () => onTap(item),
      onLongPress: () => onLongPress(item),
      semanticLabel: item.name,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            child: SizedBox.square(
              dimension: 64,
              child: _ItemImage(item: item),
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  details,
                  style: text.bodySmall?.copyWith(color: tokens.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (selected)
            Icon(Icons.check_circle_rounded, color: tokens.stock.accent)
          else if (item.isFavorite)
            Icon(Icons.favorite_rounded, size: 18, color: tokens.stock.accent),
        ],
      ),
    );
  }
}

class _ItemImage extends ConsumerWidget {
  const _ItemImage({required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final image = item.primaryImage;
    if (image == null) {
      return ColoredBox(
        color: tokens.stock.tint,
        child: Center(child: GarmentGlyph(category: item.category, size: 44)),
      );
    }
    return AppImage(
      imageUrl: image.url,
      fit: BoxFit.contain,
      backgroundColor: tokens.stock.sunk,
      enableZoom: false,
      memCacheWidth: 360,
      storagePath: image.storagePath,
      remintUrl: ref.read(itemRepositoryProvider).remintImageUrl,
      semanticLabel: item.name,
    );
  }
}

/// Closet row sizes. At 390pt wide the 4th piece shows about 22pt at the
/// right edge, so the row reads as scrollable.
const _shelfPieceWidth = 80.0;
const _shelfHeight = 100.0;
const _shelfGap = AppConstants.spacing8;
const _shelfGutter = AppConstants.spacing20;

/// One category: its name and count, then its pieces in a horizontal row.
class _Shelf extends StatelessWidget {
  const _Shelf({
    super.key,
    required this.category,
    required this.items,
    required this.onTap,
    required this.onLongPress,
  });

  final Category category;
  final List<ItemModel> items;
  final void Function(ItemModel) onTap;
  final void Function(ItemModel) onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShelfHeader(category: category, count: items.length),
          SizedBox(
            height: _shelfHeight,
            child: ListView.separated(
              // Keeps the row's offset when it scrolls off screen and back.
              key: PageStorageKey('closet-row-${category.name}'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: _shelfGutter),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: _shelfGap),
              itemBuilder: (context, i) => _ShelfPiece(
                key: ValueKey(items[i].id),
                item: items[i],
                onTap: onTap,
                onLongPress: onLongPress,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row title: category name plus the pieces shown.
class _ShelfHeader extends StatelessWidget {
  const _ShelfHeader({required this.category, required this.count});

  final Category category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _shelfGutter,
        AppConstants.spacing8,
        _shelfGutter,
        AppConstants.spacing8,
      ),
      child: Text.rich(
        TextSpan(
          text: category.label(context.l10n),
          children: [
            TextSpan(
              text: '  $count',
              style: TextStyle(color: tokens.textSecondary),
            ),
          ],
        ),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

/// A closet piece in a row: only the image. No card, border or name.
class _ShelfPiece extends ConsumerStatefulWidget {
  const _ShelfPiece({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final ItemModel item;
  final void Function(ItemModel) onTap;
  final void Function(ItemModel) onLongPress;

  @override
  ConsumerState<_ShelfPiece> createState() => _ShelfPieceState();
}

class _ShelfPieceState extends ConsumerState<_ShelfPiece> {
  bool _pressed = false;

  void _press(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final tokens = PaperTokens.of(context);
    final selected = ref.watch(
      wardrobeSelectionProvider.select((s) => s.contains(item.id)),
    );
    final still = MediaQuery.disableAnimationsOf(context);
    final image = item.primaryImage;
    final glyph = Center(
      child: GarmentGlyph(category: item.category, size: 72),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: item.name,
      // The gesture detector's own actions are excluded with its subtree.
      excludeSemantics: true,
      onTap: () => widget.onTap(item),
      onLongPress: () => widget.onLongPress(item),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press(true),
        onTapUp: (_) => _press(false),
        onTapCancel: () => _press(false),
        onTap: () => widget.onTap(item),
        onLongPress: () {
          _press(false);
          widget.onLongPress(item);
        },
        child: SizedBox(
          width: _shelfPieceWidth,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedScale(
                scale: _pressed && !still ? 0.96 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: selected ? 0.55 : 1,
                  duration: still
                      ? Duration.zero
                      : const Duration(milliseconds: 120),
                  child: image == null
                      ? glyph
                      : AppImage(
                          imageUrl: image.url,
                          fit: BoxFit.contain,
                          backgroundColor: Colors.transparent,
                          enableZoom: false,
                          memCacheWidth: 312,
                          storagePath: image.storagePath,
                          remintUrl: ref
                              .read(itemRepositoryProvider)
                              .remintImageUrl,
                          placeholder: const SkeletonBox(
                            borderRadius: AppConstants.radius12,
                          ),
                          errorWidget: glyph,
                          semanticLabel: item.name,
                        ),
                ),
              ),
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
      ),
    );
  }
}

/// Category and use-case filters. Owns its text controller, so it is
/// disposed with the sheet.
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  final _customUseCase = TextEditingController();

  @override
  void dispose() {
    _customUseCase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = ref.watch(wardrobeFiltersProvider);
    final notifier = ref.read(wardrobeFiltersProvider.notifier);
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.actionFilter, style: text.headlineSmall),
              const SizedBox(height: AppConstants.spacing16),
              Text(l10n.closetCategoryLabel, style: text.titleSmall),
              const SizedBox(height: AppConstants.spacing8),
              Wrap(
                spacing: AppConstants.spacing8,
                runSpacing: AppConstants.spacing8,
                children: [
                  for (final c in Category.values)
                    FilterChip(
                      label: Text(c.label(l10n)),
                      selected: filters.categories.contains(c),
                      onSelected: (_) => notifier.toggleCategory(c),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing20),
              Text(l10n.closetUseCaseLabel, style: text.titleSmall),
              const SizedBox(height: AppConstants.spacing8),
              Wrap(
                spacing: AppConstants.spacing8,
                runSpacing: AppConstants.spacing8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.closetAnyUseCase),
                    selected: filters.occasion.isEmpty,
                    onSelected: (_) => notifier.setOccasion(''),
                  ),
                  for (final useCase in UseCases.defaults)
                    ChoiceChip(
                      label: Text(localizedTaxonomy(l10n, useCase)),
                      selected: filters.occasion == useCase,
                      onSelected: (_) => notifier.setOccasion(useCase),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing12),
              TextField(
                controller: _customUseCase,
                textInputAction: TextInputAction.done,
                onSubmitted: notifier.setOccasion,
                decoration: InputDecoration(
                  labelText: l10n.closetOtherUseCase,
                  hintText: l10n.closetOtherUseCaseHint,
                  suffixIcon: IconButton(
                    tooltip: l10n.closetUseUseCase,
                    icon: const Icon(Icons.check_rounded),
                    onPressed: () => notifier.setOccasion(_customUseCase.text),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing20),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      notifier.clear();
                      Navigator.pop(context);
                    },
                    child: Text(l10n.closetClearAll),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.actionDone),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

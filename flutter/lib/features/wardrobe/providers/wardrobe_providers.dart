import '../../../core/providers.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/haptic_service.dart';
import '../../../core/services/network_service.dart';
import '../../../core/state/paged_state.dart';
import '../../../core/utils/error_handler.dart';
import '../../../domain/constants/use_cases.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart' as domain;
import '../models/item_model.dart';
import '../repositories/item_repository.dart';

final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) => ItemRepository(),
);

enum WardrobeSort {
  newest('Newest first', 'created_at', 'desc'),
  oldest('Oldest first', 'created_at', 'asc'),
  name('Name (A–Z)', 'name', 'asc'),
  mostWorn('Most worn', 'worn_count', 'desc');

  const WardrobeSort(this.label, this.apiField, this.apiOrder);

  final String label;
  final String apiField;
  final String apiOrder;
}

/// Server-side closet filters.
@immutable
class WardrobeFilters {
  const WardrobeFilters({
    this.search = '',
    this.categories = const {},
    this.conditions = const {},
    this.colors = const {},
    this.occasion = '',
    this.sort = WardrobeSort.newest,
    this.favoritesOnly = false,
  });

  final String search;
  final Set<Category> categories;
  final Set<domain.Condition> conditions;
  final Set<String> colors;
  final String occasion;
  final WardrobeSort sort;
  final bool favoritesOnly;

  /// True when a filter narrows the list (sort order does not).
  bool get isFiltered =>
      search.isNotEmpty ||
      categories.isNotEmpty ||
      conditions.isNotEmpty ||
      colors.isNotEmpty ||
      occasion.isNotEmpty ||
      favoritesOnly;

  WardrobeFilters copyWith({
    String? search,
    Set<Category>? categories,
    Set<domain.Condition>? conditions,
    Set<String>? colors,
    String? occasion,
    WardrobeSort? sort,
    bool? favoritesOnly,
  }) => WardrobeFilters(
    search: search ?? this.search,
    categories: categories ?? this.categories,
    conditions: conditions ?? this.conditions,
    colors: colors ?? this.colors,
    occasion: occasion ?? this.occasion,
    sort: sort ?? this.sort,
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
  );

  @override
  bool operator ==(Object other) =>
      other is WardrobeFilters &&
      other.search == search &&
      setEquals(other.categories, categories) &&
      setEquals(other.conditions, conditions) &&
      setEquals(other.colors, colors) &&
      other.occasion == occasion &&
      other.sort == sort &&
      other.favoritesOnly == favoritesOnly;

  @override
  int get hashCode => Object.hash(
    search,
    Object.hashAllUnordered(categories),
    Object.hashAllUnordered(conditions),
    Object.hashAllUnordered(colors),
    occasion,
    sort,
    favoritesOnly,
  );
}

final wardrobeFiltersProvider =
    NotifierProvider<WardrobeFiltersNotifier, WardrobeFilters>(
      WardrobeFiltersNotifier.new,
    );

/// Each change rebuilds the closet list once (one request, even for
/// "clear all").
class WardrobeFiltersNotifier extends Notifier<WardrobeFilters> {
  @override
  WardrobeFilters build() {
    ref.watch(sessionUserIdProvider);
    return const WardrobeFilters();
  }

  void setSearch(String value) => state = state.copyWith(search: value.trim());

  void toggleCategory(Category c) => state = state.copyWith(
    categories: state.categories.contains(c)
        ? ({...state.categories}..remove(c))
        : {...state.categories, c},
  );

  void setOccasion(String value) =>
      state = state.copyWith(occasion: UseCases.normalize(value));

  void setSort(WardrobeSort sort) => state = state.copyWith(sort: sort);

  void setFavoritesOnly(bool value) =>
      state = state.copyWith(favoritesOnly: value);

  /// Clears every filter and keeps the sort order.
  void clear() => state = WardrobeFilters(sort: state.sort);
}

final wardrobeProvider =
    AsyncNotifierProvider<WardrobeNotifier, PagedState<ItemModel>>(
      WardrobeNotifier.new,
    );

final wardrobeBusyProvider = NotifierProvider<BusyIds, Set<String>>(
  BusyIds.new,
);

final wardrobeSelectionProvider = NotifierProvider<SelectedIds, Set<String>>(
  SelectedIds.new,
);

/// The closet list for the current filters. Alive for the session: the
/// Closet tab, the outfit builder and item flows share it.
class WardrobeNotifier extends PagedNotifier<ItemModel> {
  static const pageSize = 20;

  ItemRepository get _repository => ref.read(itemRepositoryProvider);
  late WardrobeFilters _filters;

  @override
  Future<PagedState<ItemModel>> build() {
    ref.watch(sessionUserIdProvider);
    _filters = ref.watch(wardrobeFiltersProvider);
    listenValue(ref, NetworkService.instance.isConnected, (connected) {
      if (connected && state.hasError) refresh();
    });
    return super.build();
  }

  @override
  Future<PageResult<ItemModel>> fetchPage(int page) async {
    final f = _filters;
    final response = await RetryHelper.execute(
      operation: () => _repository.getItems(
        page: page,
        limit: pageSize,
        search: f.search.isEmpty ? null : f.search,
        categories: f.categories.isEmpty
            ? null
            : [for (final c in f.categories) c.name.toLowerCase()],
        colors: f.colors.isEmpty ? null : f.colors.toList(),
        occasion: f.occasion.isEmpty ? null : f.occasion,
        conditions: f.conditions.isEmpty
            ? null
            : [for (final c in f.conditions) c.name.toLowerCase()],
        sortBy: f.sort.apiField,
        sortOrder: f.sort.apiOrder,
        isFavorite: f.favoritesOnly ? true : null,
      ),
    );
    return PageResult(
      items: response.items,
      total: response.total,
      hasMore: response.hasMore,
    );
  }

  ItemModel? cached(String id) {
    for (final item in state.value?.items ?? const <ItemModel>[]) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Replaces [item] wherever it is shown: the list and an open detail page.
  void replace(ItemModel item) {
    updateItems((items) => [for (final i in items) i.id == item.id ? item : i]);
    if (ref.exists(itemDetailProvider(item.id))) {
      ref.read(itemDetailProvider(item.id).notifier).set(item);
    }
  }

  /// Adds newly created items to the top. Upserts by id so a replayed save
  /// never shows a duplicate. Skipped while a filter is active: a new item
  /// may not match it, and the next refresh shows it if it does.
  void addItems(List<ItemModel> created) {
    if (created.isEmpty || _filters.isFiltered) return;
    final byId = {for (final i in created) i.id: i};
    final existing = state.value?.items ?? const <ItemModel>[];
    final fresh = [
      for (final i in byId.values)
        if (!existing.any((e) => e.id == i.id)) i,
    ];
    updateItems(
      (items) => [
        ...fresh,
        for (final i in items) byId[i.id] ?? i,
      ],
      totalDelta: fresh.length,
    );
  }

  Future<void> toggleFavorite(String id) async {
    HapticService.favorite();
    await ref.read(wardrobeBusyProvider.notifier).run(id, () async {
      try {
        final updated = await _repository.toggleFavorite(id);
        replace(updated);
        ErrorHandler.showInfo(
          updated.isFavorite ? 'Added to favourites' : 'Removed from favourites',
        );
      } catch (e, stack) {
        ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
      }
    });
  }

  Future<void> markAsWorn(String id) async {
    HapticService.lightImpact();
    await ref.read(wardrobeBusyProvider.notifier).run(id, () async {
      try {
        replace(await _repository.markAsWorn(id));
        ErrorHandler.showInfo('Logged as worn today.');
      } catch (e, stack) {
        ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
      }
    });
  }

  /// Returns true when the item was deleted.
  Future<bool> deleteItem(String id) async {
    HapticService.delete();
    final deleted = await ref.read(wardrobeBusyProvider.notifier).run(id, () async {
      try {
        await _repository.deleteItem(id);
        updateItems(
          (items) => [for (final i in items) if (i.id != id) i],
          totalDelta: -1,
        );
        ErrorHandler.showSuccess('Removed from your closet.', title: 'Deleted');
        return true;
      } catch (e, stack) {
        ErrorHandler.showError(e, title: 'Not deleted', stackTrace: stack);
        return false;
      }
    });
    return deleted ?? false;
  }

  /// Deletes the selected items. Returns true on success.
  Future<bool> deleteSelected() async {
    final ids = ref.read(wardrobeSelectionProvider);
    if (ids.isEmpty) return false;
    try {
      await _repository.batchDeleteItems(ids.toList());
      updateItems(
        (items) => [for (final i in items) if (!ids.contains(i.id)) i],
        totalDelta: -ids.length,
      );
      ref.read(wardrobeSelectionProvider.notifier).clear();
      ErrorHandler.showSuccess(
        '${ids.length} pieces removed from your closet.',
        title: 'Deleted',
      );
      return true;
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not deleted', stackTrace: stack);
      return false;
    }
  }
}

/// One item, always fetched fresh: image URLs are presigned and expire.
/// Screens show the cached list copy while this loads.
final itemDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ItemDetailNotifier, ItemModel, String>(ItemDetailNotifier.new);

class ItemDetailNotifier extends AsyncNotifier<ItemModel> {
  ItemDetailNotifier(this.id);

  final String id;

  @override
  Future<ItemModel> build() async {
    final item = await ref.read(itemRepositoryProvider).getItem(id);
    // The list copy keeps stale models and expired presigned URLs unless it
    // is synchronized here; refresh() covers pull-to-refresh, this covers
    // simply opening the detail.
    if (ref.mounted) {
      ref.read(wardrobeProvider.notifier).updateItems(
        (items) => [for (final i in items) i.id == item.id ? item : i],
      );
    }
    return item;
  }

  void set(ItemModel item) => state = AsyncData(item);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
    if (state.value case final item?) {
      ref.read(wardrobeProvider.notifier).updateItems(
        (items) => [for (final i in items) i.id == item.id ? item : i],
      );
    }
  }
}

/// Closet statistics from the server (totals, categories, most worn).
final wardrobeStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) => ref.read(itemRepositoryProvider).getStatistics(),
);

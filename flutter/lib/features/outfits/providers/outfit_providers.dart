import '../../../core/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/haptic_service.dart';
import '../../../core/services/network_service.dart';
import '../../../core/state/paged_state.dart';
import '../../../core/utils/error_handler.dart';
import '../../../domain/enums/season.dart';
import '../../../domain/enums/style.dart';
import '../models/outfit_model.dart';
import '../repositories/outfit_repository.dart';

final outfitRepositoryProvider = Provider<OutfitRepository>(
  (ref) => OutfitRepository(),
);

/// Server-side outfit filters.
@immutable
class OutfitFilters {
  const OutfitFilters({
    this.search = '',
    this.styles = const {},
    this.seasons = const {},
    this.favoritesOnly = false,
    this.draftsOnly = false,
  });

  final String search;
  final Set<Style> styles;
  final Set<Season> seasons;
  final bool favoritesOnly;
  final bool draftsOnly;

  bool get isFiltered =>
      search.isNotEmpty ||
      styles.isNotEmpty ||
      seasons.isNotEmpty ||
      favoritesOnly ||
      draftsOnly;

  OutfitFilters copyWith({
    String? search,
    Set<Style>? styles,
    Set<Season>? seasons,
    bool? favoritesOnly,
    bool? draftsOnly,
  }) => OutfitFilters(
    search: search ?? this.search,
    styles: styles ?? this.styles,
    seasons: seasons ?? this.seasons,
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    draftsOnly: draftsOnly ?? this.draftsOnly,
  );

  @override
  bool operator ==(Object other) =>
      other is OutfitFilters &&
      other.search == search &&
      setEquals(other.styles, styles) &&
      setEquals(other.seasons, seasons) &&
      other.favoritesOnly == favoritesOnly &&
      other.draftsOnly == draftsOnly;

  @override
  int get hashCode => Object.hash(
    search,
    Object.hashAllUnordered(styles),
    Object.hashAllUnordered(seasons),
    favoritesOnly,
    draftsOnly,
  );
}

final outfitFiltersProvider =
    NotifierProvider<OutfitFiltersNotifier, OutfitFilters>(
      OutfitFiltersNotifier.new,
    );

class OutfitFiltersNotifier extends Notifier<OutfitFilters> {
  @override
  OutfitFilters build() {
    ref.watch(sessionUserIdProvider);
    return const OutfitFilters();
  }

  void setSearch(String value) => state = state.copyWith(search: value.trim());

  void toggleStyle(Style s) => state = state.copyWith(
    styles: state.styles.contains(s)
        ? ({...state.styles}..remove(s))
        : {...state.styles, s},
  );

  void toggleSeason(Season s) => state = state.copyWith(
    seasons: state.seasons.contains(s)
        ? ({...state.seasons}..remove(s))
        : {...state.seasons, s},
  );

  void setFavoritesOnly(bool value) =>
      state = state.copyWith(favoritesOnly: value);

  void setDraftsOnly(bool value) => state = state.copyWith(draftsOnly: value);

  void clear() => state = const OutfitFilters();

  /// Clears the chip filters and keeps the search text.
  void clearChips() => state = OutfitFilters(search: state.search);
}

final outfitsProvider =
    AsyncNotifierProvider<OutfitsNotifier, PagedState<OutfitModel>>(
      OutfitsNotifier.new,
    );

final outfitsBusyProvider = NotifierProvider<BusyIds, Set<String>>(BusyIds.new);

/// The outfit list for the current filters. Alive for the session.
class OutfitsNotifier extends PagedNotifier<OutfitModel> {
  OutfitRepository get _repository => ref.read(outfitRepositoryProvider);
  late OutfitFilters _filters;

  @override
  Future<PagedState<OutfitModel>> build() {
    ref.watch(sessionUserIdProvider);
    _filters = ref.watch(outfitFiltersProvider);
    listenValue(ref, NetworkService.instance.isConnected, (connected) {
      if (connected && state.hasError) refresh();
    });
    return super.build();
  }

  @override
  Future<PageResult<OutfitModel>> fetchPage(int page) async {
    final f = _filters;
    final response = await RetryHelper.execute(
      operation: () => _repository.getOutfits(
        page: page,
        search: f.search.isEmpty ? null : f.search,
        styles: f.styles.isEmpty
            ? null
            : [for (final s in f.styles) s.name.toLowerCase()],
        seasons: f.seasons.isEmpty
            ? null
            : [for (final s in f.seasons) s.seasonApiValue],
        favoritesOnly: f.favoritesOnly ? true : null,
        draftsOnly: f.draftsOnly ? true : null,
      ),
    );
    return PageResult(
      items: response.outfits,
      total: response.total,
      hasMore: response.hasMore,
    );
  }

  OutfitModel? cached(String id) {
    for (final o in state.value?.items ?? const <OutfitModel>[]) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Replaces [outfit] in the list and in an open detail page.
  void replace(OutfitModel outfit) {
    updateItems(
      (items) => [for (final o in items) o.id == outfit.id ? outfit : o],
    );
    if (ref.exists(outfitDetailProvider(outfit.id))) {
      ref.read(outfitDetailProvider(outfit.id).notifier).set(outfit);
    }
  }

  /// Adds a new outfit to the top unless a filter is active (it may not
  /// match; the next refresh shows it if it does).
  void add(OutfitModel outfit) {
    if (_filters.isFiltered || cached(outfit.id) != null) return;
    updateItems((items) => [outfit, ...items], totalDelta: 1);
  }

  Future<void> toggleFavorite(String id) async {
    HapticService.favorite();
    await ref.read(outfitsBusyProvider.notifier).run(id, () async {
      try {
        final updated = await _repository.toggleFavorite(id);
        replace(updated);
        // In a favourites-only result an unfavourited outfit no longer
        // matches: drop the row and correct the total instead of leaving a
        // non-favourite visible with an inflated count.
        if (_filters.favoritesOnly && !updated.isFavorite) {
          updateItems(
            (items) => [for (final o in items) if (o.id != id) o],
            totalDelta: -1,
          );
        }
        ErrorHandler.showInfo(
          updated.isFavorite
              ? 'Saved to favourites'
              : 'Removed from favourites',
        );
      } catch (e, stack) {
        ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
      }
    });
  }

  Future<void> markAsWorn(String id) async {
    HapticService.lightImpact();
    await ref.read(outfitsBusyProvider.notifier).run(id, () async {
      try {
        replace(await _repository.markAsWorn(id));
        if (ref.exists(wearHistoryProvider(id))) {
          ref.invalidate(wearHistoryProvider(id));
        }
        ErrorHandler.showSuccess('Logged as worn today.', title: 'Nice pick');
      } catch (e, stack) {
        ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
      }
    });
  }

  /// Returns true when the outfit was deleted.
  Future<bool> delete(String id) async {
    HapticService.delete();
    final ok = await ref.read(outfitsBusyProvider.notifier).run(id, () async {
      try {
        await _repository.deleteOutfit(id);
        updateItems(
          (items) => [
            for (final o in items)
              if (o.id != id) o,
          ],
          totalDelta: -1,
        );
        ErrorHandler.showSuccess('Outfit removed.', title: 'Deleted');
        return true;
      } catch (e, stack) {
        ErrorHandler.showError(e, title: 'Not deleted', stackTrace: stack);
        return false;
      }
    });
    return ok ?? false;
  }

  Future<OutfitModel?> duplicate(String id) async {
    return ref.read(outfitsBusyProvider.notifier).run<OutfitModel?>(
      id,
      () async {
        try {
          final copy = await _repository.duplicateOutfit(id);
          add(copy);
          ErrorHandler.showSuccess(
            'A copy is in your outfits.',
            title: 'Duplicated',
          );
          return copy;
        } catch (e, stack) {
          ErrorHandler.showError(e, title: 'Not duplicated', stackTrace: stack);
          return null;
        }
      },
    );
  }

  /// Saves edits. Rethrows on failure so the edit page stays open.
  Future<OutfitModel> save(String id, UpdateOutfitRequest request) async {
    try {
      final updated = await _repository.updateOutfit(id, request);
      replace(updated);
      return updated;
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
      rethrow;
    }
  }

  /// Creates a public link. Returns null (after showing the error) on failure.
  Future<String?> share(String id) async {
    try {
      return await _repository.shareOutfit(id);
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not shared', stackTrace: stack);
      return null;
    }
  }
}

/// One outfit, fetched fresh (image URLs expire). Screens show the cached
/// list copy while it loads.
final outfitDetailProvider = AsyncNotifierProvider.autoDispose
    .family<OutfitDetailNotifier, OutfitModel, String>(
      OutfitDetailNotifier.new,
    );

class OutfitDetailNotifier extends AsyncNotifier<OutfitModel> {
  OutfitDetailNotifier(this.id);

  final String id;

  @override
  Future<OutfitModel> build() =>
      ref.read(outfitRepositoryProvider).getOutfit(id);

  void set(OutfitModel outfit) => state = AsyncData(outfit);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

/// Wear history for one outfit.
final wearHistoryProvider = FutureProvider.autoDispose
    .family<List<WearHistoryEntry>, String>(
      (ref, id) => ref.read(outfitRepositoryProvider).getWearHistory(id),
    );

/// Outfit collections. The server returns loosely typed maps.
final collectionsProvider =
    AsyncNotifierProvider.autoDispose<
      CollectionsNotifier,
      List<Map<String, dynamic>>
    >(CollectionsNotifier.new);

class CollectionsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  OutfitRepository get _repository => ref.read(outfitRepositoryProvider);

  @override
  Future<List<Map<String, dynamic>>> build() => _repository.getCollections();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  /// Runs [action], shows the result, and reloads. Returns true on success.
  Future<bool> _mutate(
    Future<void> Function() action, {
    required String success,
    required String failure,
  }) async {
    try {
      await action();
      ErrorHandler.showSuccess(success);
      return true;
    } catch (e, stack) {
      ErrorHandler.showError(e, title: failure, stackTrace: stack);
      return false;
    } finally {
      // A batch can partly succeed even when it fails; reload either way.
      if (ref.mounted) await refresh();
    }
  }

  Future<bool> create(String name, String description) => _mutate(
    () =>
        _repository.createCollection(name, const [], description: description),
    success: '"$name" is ready.',
    failure: 'Collection not created',
  );

  Future<bool> rename(
    Map<String, dynamic> collection,
    String name,
    String description,
  ) => _mutate(
    () => _repository.updateCollection(collection['id'].toString(), name, [
      for (final id in (collection['outfit_ids'] as List? ?? const [])) '$id',
    ], description: description),
    success: 'Collection updated.',
    failure: 'Collection not updated',
  );

  Future<bool> delete(Map<String, dynamic> collection) => _mutate(
    () => _repository.deleteCollection(collection['id'].toString()),
    success: 'Collection deleted.',
    failure: 'Collection not deleted',
  );

  Future<bool> addOutfits(String collectionId, List<String> outfitIds) =>
      _mutate(
        () => _repository.addOutfitsToCollection(collectionId, outfitIds),
        success: outfitIds.length == 1
            ? '1 outfit added.'
            : '${outfitIds.length} outfits added.',
        failure: 'Outfits not added',
      );

  /// Every outfit for the add picker, capped at 10 pages of 100 so a bad
  /// `has_more` can never loop forever.
  Future<List<OutfitModel>> allOutfits() async {
    final outfits = <OutfitModel>[];
    for (var page = 1; page <= 10; page++) {
      final response = await _repository.getOutfits(page: page, limit: 100);
      outfits.addAll(response.outfits);
      if (!response.hasMore) break;
    }
    return outfits;
  }
}

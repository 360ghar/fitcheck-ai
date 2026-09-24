import '../providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/error_handler.dart';

/// One page from a paged endpoint.
@immutable
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.total,
    required this.hasMore,
  });

  final List<T> items;
  final int total;
  final bool hasMore;
}

/// A paged list: the loaded items plus the state of the next page.
@immutable
class PagedState<T> {
  const PagedState({
    this.items = const [],
    this.nextPage = 1,
    this.hasMore = true,
    this.total = 0,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<T> items;
  final int nextPage;
  final bool hasMore;
  final int total;
  final bool isLoadingMore;

  /// Set when the last load-more failed. Automatic loading stops until
  /// [PagedNotifier.retryLoadMore].
  final String? loadMoreError;

  bool get isEmpty => items.isEmpty;

  /// True when the list end may fetch another page now.
  bool get canLoadMore => hasMore && !isLoadingMore && loadMoreError == null;

  PagedState<T> copyWith({
    List<T>? items,
    int? nextPage,
    bool? hasMore,
    int? total,
    bool? isLoadingMore,
    String? Function()? loadMoreError,
  }) => PagedState<T>(
    items: items ?? this.items,
    nextPage: nextPage ?? this.nextPage,
    hasMore: hasMore ?? this.hasMore,
    total: total ?? this.total,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreError: loadMoreError == null ? this.loadMoreError : loadMoreError(),
  );
}

/// Paging for list screens.
///
/// [build] loads page 1. A rebuild (for example a filter change) discards
/// results of requests that started before it. [refresh] keeps the current
/// items on screen until the new first page arrives, and keeps them (and the
/// paging position) when it fails.
abstract class PagedNotifier<T> extends AsyncNotifier<PagedState<T>> {
  int _generation = 0;

  /// Fetches one page (1-based).
  Future<PageResult<T>> fetchPage(int page);

  @override
  Future<PagedState<T>> build() {
    _generation++;
    return _firstPage();
  }

  Future<PagedState<T>> _firstPage() async {
    final result = await fetchPage(1);
    return PagedState<T>(
      items: result.items,
      nextPage: 2,
      hasMore: result.hasMore,
      total: result.total,
    );
  }

  Future<void> refresh() async {
    // A newer refresh cancels an in-flight load-more below.
    ++_generation;
    // A rebuild (not a manual state write) so Riverpod keeps the current
    // items on screen while loading and retains them on failure.
    ref.invalidateSelf();
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || state.isLoading || !current.canLoadMore) return;
    final generation = _generation;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final result = await fetchPage(current.nextPage);
      if (generation != _generation || !ref.mounted) return;
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          items: [...latest.items, ...result.items],
          nextPage: current.nextPage + 1,
          hasMore: result.hasMore,
          total: result.total,
          isLoadingMore: false,
        ),
      );
    } catch (e, stack) {
      if (generation != _generation || !ref.mounted) return;
      ErrorHandler.reportError(e, 'Load more failed', stackTrace: stack);
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          isLoadingMore: false,
          loadMoreError: () => ErrorHandler.extractMessage(e),
        ),
      );
    }
  }

  Future<void> retryLoadMore() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(loadMoreError: () => null));
    await loadMore();
  }

  /// Applies [change] to the loaded items without a request.
  void updateItems(List<T> Function(List<T> items) change, {int totalDelta = 0}) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: change(current.items),
        total: (current.total + totalDelta).clamp(0, 1 << 31),
      ),
    );
  }
}

/// Ids with an action in flight (favourite, delete, …), for per-row spinners.
class BusyIds extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  bool contains(String id) => state.contains(id);

  /// Runs [action] with [id] marked busy. Returns null when [id] is already
  /// busy, so a double tap never sends two requests.
  Future<R?> run<R>(String id, Future<R> Function() action) async {
    if (state.contains(id)) return null;
    state = {...state, id};
    try {
      return await action();
    } finally {
      if (ref.mounted) state = {...state}..remove(id);
    }
  }
}

/// A set of selected ids for multi-select.
class SelectedIds extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    ref.watch(sessionUserIdProvider);
    return const {};
  }

  void toggle(String id) => state = state.contains(id)
      ? ({...state}..remove(id))
      : {...state, id};

  void clear() => state = const {};
}

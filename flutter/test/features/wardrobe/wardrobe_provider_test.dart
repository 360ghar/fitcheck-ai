import 'dart:async';

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/wardrobe_providers.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ItemModel item(String id) => ItemModel(
  id: id,
  userId: 'user-1',
  name: 'Item $id',
  category: Category.tops,
  condition: domain.Condition.clean,
);

ItemsListResponse page(List<String> ids, {bool hasMore = false, int? total}) =>
    ItemsListResponse(
      items: [for (final id in ids) item(id)],
      total: total ?? ids.length,
      page: 1,
      limit: 20,
      hasMore: hasMore,
    );

/// Answers getItems from a queue of handlers and records each request.
class FakeItemRepository extends ItemRepository {
  final requests = <({int page, List<String>? categories, String? search})>[];
  final responses = <Future<ItemsListResponse> Function()>[];
  Future<void> Function(String id)? onDelete;

  @override
  Future<ItemsListResponse> getItems({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? categories,
    List<String>? colors,
    String? occasion,
    List<String>? conditions,
    bool? isFavorite,
    String? sortBy,
    String? sortOrder,
  }) {
    requests.add((page: page, categories: categories, search: search));
    if (responses.isEmpty) {
      return Future.value(
        const ItemsListResponse(
          items: [],
          total: 0,
          page: 1,
          limit: 20,
          hasMore: false,
        ),
      );
    }
    return responses.removeAt(0)();
  }

  @override
  Future<void> deleteItem(String itemId) =>
      onDelete?.call(itemId) ?? Future.value();
}

const serverError = ServerException(message: 'boom', statusCode: 500);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeItemRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeItemRepository();
    container = ProviderContainer(
      retry: noRetry,
      overrides: [itemRepositoryProvider.overrideWithValue(repo)],
    );
  });
  tearDown(() => container.dispose());

  /// Starts the list the way the Closet tab does: by listening to it.
  Future<void> start() async {
    container.listen(wardrobeProvider, (_, _) {});
    await container.read(wardrobeProvider.future);
  }

  WardrobeNotifier notifier() => container.read(wardrobeProvider.notifier);
  List<String> ids() =>
      [for (final i in container.read(wardrobeProvider).value!.items) i.id];

  test('a filter change refetches, and a stale response is dropped', () async {
    final slow = Completer<ItemsListResponse>();
    repo.responses
      ..add(() => slow.future)
      ..add(() async => page(['shoe']));

    container.listen(wardrobeProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    container
        .read(wardrobeFiltersProvider.notifier)
        .toggleCategory(Category.shoes);
    await container.read(wardrobeProvider.future);
    slow.complete(page(['stale']));
    await Future<void>.delayed(Duration.zero);

    expect(ids(), ['shoe']);
    expect(repo.requests.last.categories, ['shoes']);
  });

  test('clearing many filters sends one request', () async {
    await start();
    final filters = container.read(wardrobeFiltersProvider.notifier)
      ..toggleCategory(Category.tops)
      ..setFavoritesOnly(true)
      ..setSearch('linen');
    await container.read(wardrobeProvider.future);
    final before = repo.requests.length;

    filters.clear();
    await container.read(wardrobeProvider.future);

    expect(repo.requests.length, before + 1);
  });

  test('a failed refresh keeps the items and the paging position', () async {
    repo.responses
      ..add(() async => page(['a', 'b'], hasMore: true, total: 30))
      ..add(() async => page(['c'], hasMore: true, total: 30))
      ..add(() async => throw serverError);
    await start();
    await notifier().loadMore();

    await notifier().refresh();
    // Refresh is fire-and-forget; observe the rebuild from outside.
    await expectLater(container.read(wardrobeProvider.future), throwsException);

    final state = container.read(wardrobeProvider);
    expect(state.hasError, isTrue);
    expect(ids(), ['a', 'b', 'c']);
    expect(state.value!.nextPage, 3);
  });

  test('a failed load-more keeps items, stops, and retries on demand', () async {
    repo.responses
      ..add(() async => page(['a'], hasMore: true, total: 2))
      ..add(() async => throw serverError)
      ..add(() async => page(['b'], total: 2));
    await start();

    await notifier().loadMore();
    var state = container.read(wardrobeProvider).value!;
    expect(state.loadMoreError, isNotNull);
    expect(state.canLoadMore, isFalse);
    expect(ids(), ['a']);

    await notifier().retryLoadMore();
    state = container.read(wardrobeProvider).value!;
    expect(state.loadMoreError, isNull);
    expect(ids(), ['a', 'b']);
  });

  test('delete removes the item; a failed delete keeps it', () async {
    repo.responses.add(() async => page(['a', 'b']));
    await start();

    expect(await notifier().deleteItem('a'), isTrue);
    expect(container.read(wardrobeProvider).value!.total, 1);

    repo.onDelete = (_) async => throw serverError;
    expect(await notifier().deleteItem('b'), isFalse);
    expect(ids(), ['b']);
  });

  test('new items are upserted once, and skipped under a filter', () async {
    repo.responses.add(() async => page(['a']));
    await start();

    notifier().addItems([item('n'), item('n'), item('a')]);
    expect(ids(), ['n', 'a']);
    expect(container.read(wardrobeProvider).value!.total, 2);

    container.read(wardrobeFiltersProvider.notifier).setFavoritesOnly(true);
    await container.read(wardrobeProvider.future);
    notifier().addItems([item('x')]);
    expect(ids().contains('x'), isFalse);
  });
}

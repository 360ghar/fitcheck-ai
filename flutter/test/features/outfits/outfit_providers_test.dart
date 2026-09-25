import 'dart:async';

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:fitcheck_ai/features/outfits/providers/outfit_builder_provider.dart';
import 'package:fitcheck_ai/features/outfits/providers/outfit_providers.dart';
import 'package:fitcheck_ai/features/outfits/repositories/outfit_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

OutfitModel outfit(String id) =>
    OutfitModel(id: id, userId: 'u', name: 'Outfit $id', itemIds: const ['i']);

OutfitsListResponse page(List<String> ids, {bool hasMore = false, int? total}) =>
    OutfitsListResponse(
      outfits: [for (final id in ids) outfit(id)],
      total: total ?? ids.length,
      page: 1,
      limit: 20,
      hasMore: hasMore,
    );

ItemModel piece(String id) => ItemModel(
  id: id,
  userId: 'u',
  name: id,
  category: Category.tops,
  condition: domain.Condition.clean,
);

const serverError = ServerException(message: 'boom', statusCode: 500);

class FakeOutfitRepository extends OutfitRepository {
  final responses = <Future<OutfitsListResponse> Function()>[];
  Future<OutfitModel> Function(String id)? onUpdate;
  int creates = 0;
  Completer<void>? createGate;
  final base64Uploads = <String>[];
  final urlUploads = <String>[];

  @override
  Future<OutfitsListResponse> getOutfits({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? styles,
    List<String>? seasons,
    bool? favoritesOnly,
    bool? draftsOnly,
  }) => responses.isEmpty ? Future.value(page1Empty) : responses.removeAt(0)();

  static final page1Empty = page(const []);

  @override
  Future<OutfitModel> updateOutfit(String outfitId, UpdateOutfitRequest request) =>
      onUpdate?.call(outfitId) ?? Future.value(outfit(outfitId));

  @override
  Future<OutfitModel> createOutfit(CreateOutfitRequest request) async {
    creates++;
    await createGate?.future;
    return OutfitModel(
      id: 'new',
      userId: 'u',
      name: request.name,
      itemIds: request.itemIds,
    );
  }

  @override
  Future<OutfitImage?> uploadOutfitImageFromBase64(
    String outfitId,
    String base64Image, {
    bool isPrimary = true,
    String? pose,
  }) async {
    base64Uploads.add(base64Image);
    return null;
  }

  @override
  Future<OutfitImage?> uploadOutfitImageFromUrl(
    String outfitId,
    String imageUrl, {
    bool isPrimary = true,
    String? pose,
  }) async {
    urlUploads.add(imageUrl);
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeOutfitRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeOutfitRepository();
    container = ProviderContainer(
      retry: noRetry,
      overrides: [outfitRepositoryProvider.overrideWithValue(repo)],
    );
  });
  tearDown(() => container.dispose());

  Future<void> start() async {
    container.listen(outfitsProvider, (_, _) {});
    await container.read(outfitsProvider.future);
  }

  OutfitsNotifier outfits() => container.read(outfitsProvider.notifier);
  List<String> ids() =>
      [for (final o in container.read(outfitsProvider).value!.items) o.id];

  group('outfit list', () {
    test('a filter change drops a stale response', () async {
      final slow = Completer<OutfitsListResponse>();
      repo.responses
        ..add(() => slow.future)
        ..add(() async => page(['fav']));
      container.listen(outfitsProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);

      container.read(outfitFiltersProvider.notifier).setFavoritesOnly(true);
      await container.read(outfitsProvider.future);
      slow.complete(page(['stale']));
      await Future<void>.delayed(Duration.zero);

      expect(ids(), ['fav']);
    });

    test('a failed refresh keeps outfits and the paging position', () async {
      repo.responses
        ..add(() async => page(['a'], hasMore: true, total: 3))
        ..add(() async => page(['b'], hasMore: true, total: 3))
        ..add(() async => throw serverError);
      await start();
      await outfits().loadMore();

      await outfits().refresh();
      // Refresh is fire-and-forget; observe the rebuild from outside.
      await expectLater(container.read(outfitsProvider.future), throwsException);

      final state = container.read(outfitsProvider);
      expect(state.hasError, isTrue);
      expect(ids(), ['a', 'b']);
      expect(state.value!.nextPage, 3, reason: 'the next scroll fetches page 3');
    });

    test('a failed save rethrows so the edit page stays open', () async {
      repo.responses.add(() async => page(['a']));
      await start();
      repo.onUpdate = (_) async => throw serverError;

      expect(
        () => outfits().save('a', const UpdateOutfitRequest(name: 'x')),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('outfit builder', () {
    OutfitBuilderNotifier builder() {
      container.listen(outfitBuilderProvider, (_, _) {});
      return container.read(outfitBuilderProvider.notifier)
        ..setName('Weekend')
        ..toggle(piece('p1'));
    }

    // toggle() clears the preview, so it is set after choosing pieces.
    void setPreview(String url) => container
        .read(outfitBuilderProvider.notifier)
        .state = container.read(outfitBuilderProvider).copyWith(
      previewUrl: () => url,
    );

    test('a URL preview is re-uploaded from its URL', () async {
      final b = builder();
      setPreview('https://cdn.example.com/p.png');

      expect(await b.save(), isNotNull);
      expect(repo.urlUploads, ['https://cdn.example.com/p.png']);
      expect(repo.base64Uploads, isEmpty);
    });

    test('a data-URI preview uploads its bytes', () async {
      final b = builder();
      setPreview('data:image/png;base64,QUJD');

      await b.save();
      expect(repo.base64Uploads, ['QUJD']);
    });

    test('a double tap on save creates one outfit', () async {
      repo.createGate = Completer();
      final b = builder();

      final first = b.save();
      final second = b.save();
      repo.createGate!.complete();

      expect(await second, isNull);
      expect(await first, isNotNull);
      expect(repo.creates, 1);
    });
  });
}

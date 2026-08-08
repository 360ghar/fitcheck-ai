import 'dart:async';

import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/features/outfits/controllers/outfit_list_controller.dart';
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:fitcheck_ai/features/outfits/repositories/outfit_repository.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeOutfitNetworkService extends NetworkService {
  FakeOutfitNetworkService({bool connected = true}) {
    isConnected.value = connected;
  }

  @override
  // ignore: must_call_super
  void onInit() {}
}

class FakeOutfitListRepository extends OutfitRepository {
  int getOutfitsCalls = 0;
  Future<OutfitsListResponse> Function()? onGetOutfits;

  @override
  Future<OutfitsListResponse> getOutfits({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? styles,
    List<String>? seasons,
    bool? favoritesOnly,
    bool? draftsOnly,
  }) {
    getOutfitsCalls++;
    return onGetOutfits?.call() ??
        Future.value(
          const OutfitsListResponse(
            outfits: [],
            total: 0,
            page: 1,
            limit: 20,
            hasMore: false,
          ),
        );
  }
}

/// Fake that also fakes the single-outfit endpoint, so detail-page tests can
/// assert the refresh-on-open behaviour without any network.
class FakeOutfitDetailRepository extends FakeOutfitListRepository {
  int getOutfitCalls = 0;
  Future<OutfitModel> Function(String outfitId)? onGetOutfit;

  @override
  Future<OutfitModel> getOutfit(String outfitId) {
    getOutfitCalls++;
    return onGetOutfit?.call(outfitId) ?? Future.value(outfit(outfitId));
  }
}

OutfitModel outfit(String id) =>
    OutfitModel(id: id, userId: 'user-1', name: id, itemIds: const []);

void main() {
  setUp(Get.reset);
  tearDown(Get.reset);

  testWidgets('stale outfit refresh response cannot overwrite newer results', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final network = FakeOutfitNetworkService();
    Get.put<NetworkService>(network);
    final first = Completer<OutfitsListResponse>();
    final second = Completer<OutfitsListResponse>();
    final repository = FakeOutfitListRepository();
    repository.onGetOutfits = () =>
        repository.getOutfitsCalls == 1 ? first.future : second.future;
    final controller = OutfitListController(
      networkService: network,
      repository: repository,
    );
    final firstRequest = controller.fetchOutfits(refresh: true);
    await tester.pump();
    final secondRequest = controller.fetchOutfits(refresh: true);
    await tester.pump();

    second.complete(
      const OutfitsListResponse(
        outfits: [
          OutfitModel(id: 'new', userId: 'user-1', name: 'new', itemIds: []),
        ],
        total: 1,
        page: 1,
        limit: 20,
        hasMore: false,
      ),
    );
    await tester.pump();
    first.complete(
      const OutfitsListResponse(
        outfits: [
          OutfitModel(id: 'old', userId: 'user-1', name: 'old', itemIds: []),
        ],
        total: 1,
        page: 1,
        limit: 20,
        hasMore: false,
      ),
    );
    await Future.wait([firstRequest, secondRequest]);
    await tester.pump();

    expect(controller.outfits.single.id, 'new');
    controller.onClose();
  });

  testWidgets('does not call the outfit repository while offline', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final network = FakeOutfitNetworkService(connected: false);
    Get.put<NetworkService>(network);
    final repository = FakeOutfitListRepository();
    final controller = OutfitListController(
      networkService: network,
      repository: repository,
    );

    await controller.fetchOutfits(refresh: true);

    expect(repository.getOutfitsCalls, 0);
    expect(controller.isOffline.value, isTrue);
    controller.onClose();
  });

  group('OutfitDetailPage refresh-on-open', () {
    testWidgets(
      'refreshes a cached outfit from the server instead of serving it blind',
      (tester) async {
        final network = FakeOutfitNetworkService();
        Get.put<NetworkService>(network);
        final repository = FakeOutfitDetailRepository()
          ..onGetOutfit = (_) async => const OutfitModel(
            id: 'outfit-1',
            userId: 'user-1',
            name: 'refreshed-name',
            itemIds: [],
          );
        final controller = OutfitListController(
          networkService: network,
          repository: repository,
        );
        // Simulate the app state before the fix: the list already holds the
        // outfit from an earlier fetch, with presigned image URLs that may
        // have expired since.
        controller.outfits.add(outfit('outfit-1'));
        Get.put(controller);

        await tester.pumpWidget(
          const GetMaterialApp(home: OutfitDetailPage(outfitId: 'outfit-1')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          repository.getOutfitCalls,
          1,
          reason: 'opening a detail page must re-mint fresh presigned image '
              'URLs (refreshOutfitById) instead of rendering the cached model '
              'blind — an expired URL otherwise leaves a permanently broken '
              'image tile',
        );
        expect(
          find.text('refreshed-name'),
          findsOneWidget,
          reason: 'the page must render the freshly fetched outfit',
        );
        controller.onClose();
      },
    );

    testWidgets('falls back to the cached outfit when the refresh fails', (
      tester,
    ) async {
      final network = FakeOutfitNetworkService();
      Get.put<NetworkService>(network);
      final repository = FakeOutfitDetailRepository()
        ..onGetOutfit = (_) async => throw Exception('network down');
      final controller = OutfitListController(
        networkService: network,
        repository: repository,
      );
      controller.outfits.add(outfit('outfit-1'));
      Get.put(controller);

      await tester.pumpWidget(
        const GetMaterialApp(home: OutfitDetailPage(outfitId: 'outfit-1')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        repository.getOutfitCalls,
        1,
        reason: 'the refresh attempt must still happen on open',
      );
      expect(
        find.text('outfit-1'),
        findsOneWidget,
        reason: 'a failed refresh must not blank the page — the cached '
            'model is shown',
      );

      // Flush the error snackbar: advance past its auto-dismiss duration,
      // then let the dismiss animation finish so no ticker is left running
      // when the tree is torn down.
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      controller.onClose();
    });
  });
}

import 'dart:async';

import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:fitcheck_ai/features/outfits/controllers/outfit_list_controller.dart';
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:fitcheck_ai/features/outfits/repositories/outfit_repository.dart';
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
}

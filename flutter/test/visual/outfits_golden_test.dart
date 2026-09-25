@Tags(['golden'])
library;

import 'package:fitcheck_ai/core/widgets/paper.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/domain/enums/season.dart';
import 'package:fitcheck_ai/domain/enums/style.dart';
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:fitcheck_ai/features/outfits/providers/outfit_providers.dart';
import 'package:fitcheck_ai/features/outfits/repositories/outfit_repository.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_builder_page.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_collections_page.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_detail_page.dart';
import 'package:fitcheck_ai/features/outfits/views/outfits_content.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/wardrobe_providers.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'visual_harness.dart';

ItemModel _piece(String id, String name, Category c) => ItemModel(
  id: id,
  userId: 'u',
  name: name,
  category: c,
  condition: domain.Condition.clean,
);

final _pieces = [
  _piece('p1', 'Ecru oxford', Category.tops),
  _piece('p2', 'Charcoal trousers', Category.bottoms),
  _piece('p3', 'Tobacco loafers', Category.shoes),
  _piece('p4', 'Linen tote', Category.accessories),
];

final _outfits = [
  for (final (i, (name, style)) in [
    ('The weekend edit', Style.casual),
    ('Studio day', Style.minimalist),
    ('Dinner in town', Style.romantic),
    ('Rain check', Style.streetwear),
  ].indexed)
    OutfitModel(
      id: 'o$i',
      userId: 'u',
      name: name,
      itemIds: const ['p1', 'p2', 'p3'],
      items: _pieces.take(2 + i % 3).toList(),
      style: style,
      season: Season.spring,
      isFavorite: i == 0,
      isDraft: i == 3,
      wornCount: i,
    ),
];

class _Repo extends OutfitRepository {
  _Repo(this.outfits);

  final List<OutfitModel> outfits;

  @override
  Future<OutfitsListResponse> getOutfits({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? styles,
    List<String>? seasons,
    bool? favoritesOnly,
    bool? draftsOnly,
  }) async => OutfitsListResponse(
    outfits: outfits,
    total: outfits.length,
    page: 1,
    limit: 20,
    hasMore: false,
  );

  @override
  Future<OutfitModel> getOutfit(String outfitId) async =>
      outfits.firstWhere((o) => o.id == outfitId);

  @override
  Future<List<WearHistoryEntry>> getWearHistory(String outfitId) async => [
    WearHistoryEntry(id: 'w', outfitId: outfitId, wornAt: DateTime(2026, 9, 12)),
  ];

  @override
  Future<List<Map<String, dynamic>>> getCollections() async => [
    {
      'id': 'c1',
      'name': 'Lisbon trip',
      'description': 'Light layers for four days by the sea.',
      'outfit_ids': ['o0', 'o1'],
    },
    {'id': 'c2', 'name': 'Office', 'outfit_ids': ['o1']},
  ];
}

class _Items extends ItemRepository {
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
  }) async => ItemsListResponse(
    items: _pieces,
    total: _pieces.length,
    page: 1,
    limit: limit,
    hasMore: false,
  );
}

void main() {
  setUpAll(loadAppFonts);


  for (final (name, widget, repo) in [
    (
      'outfits',
      const PaperStockScope(
        stock: PaperStockId.marigold,
        child: Scaffold(body: OutfitsContent()),
      ),
      _Repo(_outfits),
    ),
    (
      'outfits_empty',
      const PaperStockScope(
        stock: PaperStockId.marigold,
        child: Scaffold(body: OutfitsContent()),
      ),
      _Repo(const []),
    ),
    ('outfit_detail', const OutfitDetailPage(outfitId: 'o0'), _Repo(_outfits)),
    ('outfit_builder', const OutfitBuilderPage(), _Repo(_outfits)),
    ('outfit_collections', const OutfitCollectionsPage(), _Repo(_outfits)),
  ]) {
    for (final dark in [false, true]) {
      if (dark && name != 'outfits') continue;
      final file = '${name}_${dark ? 'dark' : 'light'}';
      testWidgets(file, (tester) async {
        await pumpPhone(
          tester,
          widget,
          dark: dark,
          overrides: [
            itemRepositoryProvider.overrideWithValue(_Items()),
            outfitRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.pump(const Duration(milliseconds: 100));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/$file.png'),
        );
      });
    }
  }
}

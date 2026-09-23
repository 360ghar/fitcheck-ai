@Tags(['golden'])
library;

import 'dart:io';

import 'package:fitcheck_ai/core/widgets/paper.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/wardrobe_providers.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/views/item_detail_page.dart';
import 'package:fitcheck_ai/features/wardrobe/views/wardrobe_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'visual_harness.dart';

final _items = [
  for (final (i, (name, c)) in [
    ('Ecru oxford shirt', Category.tops),
    ('Charcoal trousers', Category.bottoms),
    ('Tobacco loafers', Category.shoes),
    ('Sage overshirt', Category.outerwear),
    ('Linen tote', Category.accessories),
    ('Navy swim shorts', Category.swimwear),
    ('Running tee', Category.activewear),
  ].indexed)
    ItemModel(
      id: 'i$i',
      userId: 'u',
      name: name,
      category: c,
      condition: domain.Condition.clean,
      brand: i.isEven ? 'Arket' : null,
      isFavorite: i == 1,
      wornCount: i * 2,
      colors: const ['Navy', 'White'],
      material: 'Cotton',
    ),
];

class _Repo extends ItemRepository {
  _Repo(this.items, {this.fail = false});

  final List<ItemModel> items;
  final bool fail;

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
  }) async {
    if (fail) throw const SocketException('offline');
    return ItemsListResponse(
      items: items,
      total: items.length,
      page: 1,
      limit: 20,
      hasMore: false,
    );
  }

  @override
  Future<ItemModel> getItem(String itemId) async =>
      items.firstWhere((i) => i.id == itemId);
}

void main() {
  setUpAll(loadAppFonts);

  for (final (name, repo) in [
    ('closet', _Repo(_items)),
    ('closet_empty', _Repo(const [])),
    ('closet_error', _Repo(const [], fail: true)),
  ]) {
    for (final dark in [false, true]) {
      final file = '${name}_${dark ? 'dark' : 'light'}';
      testWidgets(file, (tester) async {
        await pumpPhone(
          tester,
          const PaperStockScope(
            stock: PaperStockId.moss,
            child: Scaffold(body: WardrobeContent()),
          ),
          dark: dark,
          overrides: [itemRepositoryProvider.overrideWithValue(repo)],
        );
        await tester.pump(const Duration(milliseconds: 100));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/$file.png'),
        );
      });
    }
  }

  testWidgets('item_detail_light', (tester) async {
    await pumpPhone(
      tester,
      const ItemDetailPage(itemId: 'i1'),
      overrides: [itemRepositoryProvider.overrideWithValue(_Repo(_items))],
    );
    await tester.pump(const Duration(milliseconds: 100));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/item_detail_light.png'),
    );
  });
}

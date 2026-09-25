import 'dart:async';

import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/outfits/providers/outfit_builder_provider.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_builder_page.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [320.0, 390.0, 768.0]) {
    testWidgets('picker keeps its tile layout after loading at $width dp', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final items = Completer<List<ItemModel>>();
      await tester.pumpWidget(
        ProviderScope(
          retry: noRetry,
          overrides: [
            builderPickerItemsProvider.overrideWith((ref) => items.future),
          ],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: const OutfitBuilderPage(),
          ),
        ),
      );
      SliverGridRegularTileLayout layout() {
        final grid = tester.renderObject<RenderSliverGrid>(
          find.byType(SliverGrid),
        );
        return grid.gridDelegate.getLayout(grid.constraints)
            as SliverGridRegularTileLayout;
      }

      final loading = layout();
      items.complete([
        ItemModel(
          id: 'i1',
          userId: 'u1',
          name: 'Shirt',
          category: Category.tops,
          condition: domain.Condition.clean,
        ),
      ]);
      await tester.pump();
      await tester.pump();
      final loaded = layout();
      expect(loaded.crossAxisCount, loading.crossAxisCount);
      expect(loaded.childCrossAxisExtent, loading.childCrossAxisExtent);
      expect(loaded.mainAxisStride, loading.mainAxisStride);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

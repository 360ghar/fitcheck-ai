import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/widgets/app_image.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/outfits/widgets/outfit_collage.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/widgets/garment_glyph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A valid 1x1 transparent PNG. A data URL renders through Image.memory: a
/// network URL would go through the default cache manager, whose filesystem
/// needs path_provider (no host implementation in widget tests).
const _tinyPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8'
    'z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

ItemModel _piece(String id, {bool withImage = false}) => ItemModel(
  id: id,
  userId: 'u',
  name: id,
  category: Category.tops,
  condition: domain.Condition.clean,
  itemImages: withImage
      ? [ItemImage(id: 'i$id', url: 'data:image/png;base64,$_tinyPngBase64')]
      : null,
);

Future<void> _pump(WidgetTester tester, List<ItemModel> pieces) =>
    tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SizedBox(
              width: 172,
              height: 160,
              child: OutfitCollage(
                pieces: pieces,
                glyphSize: 40,
                memCacheWidth: 240,
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('piece with a photo renders AppImage, without one a glyph', (
    tester,
  ) async {
    await _pump(tester, [_piece('a', withImage: true), _piece('b')]);
    expect(find.byType(AppImage), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byType(GarmentGlyph), findsOneWidget);
  });

  testWidgets('five pieces show four; three leave no overflow', (tester) async {
    await _pump(tester, [for (final i in 'abcde'.split('')) _piece(i)]);
    expect(find.byType(GarmentGlyph), findsNWidgets(4));
    await _pump(tester, [for (final i in 'abc'.split('')) _piece(i)]);
    expect(find.byType(GarmentGlyph), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no pieces shows the empty icon', (tester) async {
    await _pump(tester, const []);
    expect(find.byIcon(Icons.style_outlined), findsOneWidget);
  });
}

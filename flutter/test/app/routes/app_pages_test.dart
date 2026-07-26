import 'package:fitcheck_ai/app/routes/app_pages.dart';
import 'package:fitcheck_ai/features/outfits/views/outfit_collections_page.dart';
import 'package:fitcheck_ai/features/wardrobe/views/wardrobe_stats_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// GetX resolves a route name with
/// `routes.firstWhereOrNull((r) => r.path.regex.hasMatch(name))` -- first
/// registration whose regex matches wins, with no preference for an exact
/// match. So a static path registered *after* a `:id` sibling is unreachable:
/// `/wardrobe/stats` resolves to `ItemDetailPage(itemId: 'stats')` instead.
///
/// Both of these were shadowed and silently 404ing. The order is load-bearing,
/// and nothing about the declaration site says so -- hence this test.
void main() {
  GetPage? pageFor(String name) {
    for (final route in AppPages.routes) {
      if (route.path.regex.hasMatch(name)) return route;
    }
    return null;
  }

  group('route registration order', () {
    test('/wardrobe/stats resolves to WardrobeStatsPage, not the item detail',
        () {
      expect(pageFor('/wardrobe/stats')?.page(), isA<WardrobeStatsPage>());
    });

    test(
        '/outfits/collections resolves to OutfitCollectionsPage, not the outfit detail',
        () {
      expect(
        pageFor('/outfits/collections')?.page(),
        isA<OutfitCollectionsPage>(),
      );
    });

    test('no static path is shadowed by an earlier :param sibling', () {
      final shadowed = <String>[];
      for (var i = 0; i < AppPages.routes.length; i++) {
        final path = AppPages.routes[i].name;
        if (path.contains(':')) continue;
        for (var j = 0; j < i; j++) {
          final earlier = AppPages.routes[j];
          if (!earlier.name.contains(':')) continue;
          if (earlier.path.regex.hasMatch(path)) {
            shadowed.add('$path is shadowed by ${earlier.name}');
          }
        }
      }
      expect(
        shadowed,
        isEmpty,
        reason: 'Move each static path above its :param sibling.\n'
            '${shadowed.join('\n')}',
      );
    });
  });
}

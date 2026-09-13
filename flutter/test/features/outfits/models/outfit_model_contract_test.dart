import 'package:fitcheck_ai/domain/enums/season.dart';
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression guard: the backend OutfitCreate/OutfitUpdate schemas
/// (backend/app/models/outfit.py) expect snake_case keys and silently drop
/// unknown ones. camelCase keys here mean created outfits persist with empty
/// item_ids and edit-page toggles no-op while reporting success.
void main() {
  group('outfit request JSON contract', () {
    test('CreateOutfitRequest.toJson emits backend snake_case keys', () {
      final json =
          CreateOutfitRequest(name: 'Look', itemIds: ['a', 'b']).toJson();

      expect(json['item_ids'], ['a', 'b']);
      expect(json.containsKey('itemIds'), isFalse,
          reason: 'camelCase key would be dropped by the backend');
    });

    test('UpdateOutfitRequest.toJson emits backend snake_case keys', () {
      final json = UpdateOutfitRequest(
        itemIds: ['a'],
        isFavorite: true,
        isDraft: false,
        isPublic: true,
      ).toJson();

      expect(json['item_ids'], ['a']);
      expect(json['is_favorite'], isTrue);
      expect(json['is_draft'], isFalse);
      expect(json['is_public'], isTrue);
      for (final camel in ['itemIds', 'isFavorite', 'isDraft', 'isPublic']) {
        expect(json.containsKey(camel), isFalse,
            reason: '$camel would be dropped by the backend');
      }
    });
  });

  group('tolerant enum decode', () {
    test('OutfitModel: unknown style + web all-season spelling parse, no throw',
        () {
      final outfit = OutfitModel.fromJson(const {
        'id': 'o1',
        'user_id': 'u1',
        'name': 'Legacy row',
        'item_ids': ['a'],
        'style': 'Old Money',
        'season': 'all-season',
      });

      expect(outfit.style, isNull,
          reason: 'unknown style must decode to null, not throw');
      expect(outfit.season, Season.allSeason);
    });

    test('OutfitModel: unknown season and nulls decode to null', () {
      final outfit = OutfitModel.fromJson(const {
        'id': 'o1',
        'user_id': 'u1',
        'name': 'Row',
        'item_ids': ['a'],
        'season': 'Monsoon',
      });

      expect(outfit.style, isNull);
      expect(outfit.season, isNull);
    });

    test('SharedOutfitModel: unknown style + all-season parse, no throw', () {
      final shared = SharedOutfitModel.fromJson(const {
        'id': 's1',
        'name': 'Public look',
        'item_images': <String>[],
        'created_at': '2026-01-01T00:00:00.000Z',
        'style': 'Old Money',
        'season': 'all-season',
      });

      expect(shared.style, isNull,
          reason: 'one legacy shared row must not blank the shared page');
      expect(shared.season, Season.allSeason);
    });

    test('SharedOutfitModel: legacy mobile allseason spelling decodes', () {
      final shared = SharedOutfitModel.fromJson(const {
        'id': 's1',
        'name': 'Public look',
        'item_images': <String>[],
        'created_at': '2026-01-01T00:00:00.000Z',
        'season': 'allseason',
      });

      expect(shared.season, Season.allSeason);
    });
  });

  group('season API spelling', () {
    test('filter payload value for Season.allSeason is the backend canonical',
        () {
      // OutfitListController.fetchOutfits builds the seasons query param via
      // selectedSeasons.map((s) => s.seasonApiValue); the backend list
      // filter is an exact match on the stored web spelling.
      expect(Season.allSeason.seasonApiValue, 'all-season');
    });

    test('other seasons emit lowercase enum names', () {
      expect(Season.spring.seasonApiValue, 'spring');
      expect(Season.fall.seasonApiValue, 'fall');
      expect(Season.winter.seasonApiValue, 'winter');
    });

    test('CreateOutfitRequest/UpdateOutfitRequest emit all-season', () {
      expect(
        CreateOutfitRequest(name: 'L', itemIds: ['a'], season: Season.allSeason)
            .toJson()['season'],
        'all-season',
      );
      expect(
        UpdateOutfitRequest(season: Season.allSeason).toJson()['season'],
        'all-season',
      );
      expect(
        CreateOutfitRequest(
          name: 'L',
          itemIds: ['a'],
          season: Season.spring,
        ).toJson()['season'],
        'spring',
      );
    });
  });
}

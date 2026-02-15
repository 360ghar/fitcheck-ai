import 'package:flutter_test/flutter_test.dart';

import 'package:fitcheck_ai/features/wardrobe/models/batch_extraction_models.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/batch_extraction_repository.dart';

void main() {
  group('Batch extraction mapping', () {
    test('parseExtractedItems maps SSE payload keys and include defaults', () {
      final repository = BatchExtractionRepository();
      final eventData = <String, dynamic>{
        'image_id': 'img_1',
        'items': [
          {
            'temp_id': 'tmp_1',
            'image_id': 'img_1',
            'category': 'tops',
            'sub_category': 'shirt',
            'colors': ['blue'],
            'confidence': 0.88,
            'person_id': 'person_1',
            'person_label': 'You',
            'is_current_user_person': true,
            'include_in_wardrobe': false,
          },
        ],
      };

      final items = repository.parseExtractedItems(eventData, 'fallback_image');

      expect(items, hasLength(1));
      expect(items.first.id, 'tmp_1');
      expect(items.first.sourceImageId, 'img_1');
      expect(items.first.category.name, 'tops');
      expect(items.first.subCategory, 'shirt');
      expect(items.first.personId, 'person_1');
      expect(items.first.isCurrentUserPerson, isTrue);
      expect(items.first.includeInWardrobe, isFalse);
      expect(items.first.isSelected, isFalse);
      expect(items.first.status, BatchItemStatus.detected);
    });

    test(
      'BatchExtractedItem.fromJson normalizes invalid category and status',
      () {
        final item = BatchExtractedItem.fromJson(<String, dynamic>{
          'temp_id': 'tmp_2',
          'image_id': 'img_2',
          'category': 'not-a-category',
          'status': 'unknown-status',
          'name': 'Item name',
        });

        expect(item.category.name, 'other');
        expect(item.status, BatchItemStatus.detected);
        expect(item.includeInWardrobe, isTrue);
        expect(item.isSelected, isTrue);
      },
    );
  });

  group('Single-flow extraction mapping', () {
    test('SyncExtractionResponse carries person/include and profile flags', () {
      final response = SyncExtractionResponse.fromJson(<String, dynamic>{
        'items': [
          {
            'temp_id': 'tmp_1',
            'category': 'tops',
            'sub_category': 'hoodie',
            'colors': ['black'],
            'confidence': 0.9,
            'person_id': 'person_1',
            'person_label': 'You',
            'is_current_user_person': true,
            'include_in_wardrobe': true,
          },
          {
            'temp_id': 'tmp_2',
            'category': 'tops',
            'sub_category': 'shirt',
            'colors': ['white'],
            'confidence': 0.82,
            'person_id': 'person_2',
            'person_label': 'Friend',
            'is_current_user_person': false,
            'include_in_wardrobe': false,
          },
        ],
        'overall_confidence': 0.86,
        'image_description': 'Two people wearing tops',
        'item_count': 2,
        'requires_review': false,
        'has_profile_reference': true,
        'profile_match_found': true,
      });

      expect(response.items, hasLength(2));
      expect(response.hasProfileReference, isTrue);
      expect(response.profileMatchFound, isTrue);
      expect(response.items.first.isCurrentUserPerson, isTrue);
      expect(response.items.first.includeInWardrobe, isTrue);
      expect(response.items.last.isCurrentUserPerson, isFalse);
      expect(response.items.last.includeInWardrobe, isFalse);
    });
  });
}

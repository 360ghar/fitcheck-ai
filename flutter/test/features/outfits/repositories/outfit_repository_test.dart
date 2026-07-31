import 'package:fitcheck_ai/features/outfits/repositories/outfit_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeOutfitRepository extends OutfitRepository {
  final added = <String>[];

  @override
  Future<Map<String, dynamic>> addOutfitToCollection(
    String collectionId,
    String outfitId,
  ) async {
    added.add('$collectionId:$outfitId');
    return const <String, dynamic>{};
  }
}

void main() {
  test('adds every selected outfit to a collection', () async {
    final repository = FakeOutfitRepository();

    await repository.addOutfitsToCollection('collection-1', [
      'outfit-1',
      'outfit-2',
    ]);

    expect(repository.added, [
      'collection-1:outfit-1',
      'collection-1:outfit-2',
    ]);
  });
}

import '../../wardrobe/models/item_model.dart';

/// Normalize recommendation API item payloads for [ItemModel.fromJson].
///
/// Backend wardrobe list returns `images` with `image_url`; recommendation
/// endpoints now match that after normalize, but may also send flat `image_url`
/// or raw Supabase `item_images`. ItemModel expects `item_images` with `url`.
Map<String, dynamic> normalizeRecommendationItemJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);

  if (normalized['category'] is String) {
    normalized['category'] = (normalized['category'] as String).toLowerCase();
  }
  if (normalized['condition'] == null) {
    normalized['condition'] = 'clean';
  }
  // ItemModel requires user_id; recommendation payloads may omit it
  if (normalized['user_id'] == null) {
    normalized['user_id'] = '';
  }

  final rawImages = normalized['item_images'] ?? normalized['images'];
  if (rawImages is List && rawImages.isNotEmpty) {
    var index = 0;
    normalized['item_images'] = rawImages.whereType<Map>().map((img) {
      final m = Map<String, dynamic>.from(img);
      final url = m['url']?.toString() ??
          m['image_url']?.toString() ??
          m['thumbnail_url']?.toString() ??
          '';
      m['url'] = url;
      m['id'] =
          m['id']?.toString() ?? '${normalized['id'] ?? 'item'}-img-${index++}';
      m['is_primary'] = m['is_primary'] == true;
      return m;
    }).toList();
  } else {
    final flat = normalized['image_url']?.toString();
    if (flat != null && flat.isNotEmpty) {
      normalized['item_images'] = [
        {
          'id': '${normalized['id'] ?? 'item'}-primary',
          'url': flat,
          'is_primary': true,
        },
      ];
    }
  }

  return normalized;
}

ItemModel itemModelFromRecommendationJson(Map<String, dynamic> json) {
  return ItemModel.fromJson(normalizeRecommendationItemJson(json));
}

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/item_model.dart';
import '../../../domain/constants/use_cases.dart';
import '../../../domain/enums/category.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';

/// Wardrobe item repository
class ItemRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get items list
  Future<ItemsListResponse> getItems({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? categories,
    List<String>? colors,
    String? occasion,
    List<String>? conditions,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'page_size': limit,
      };

      if (search != null) queryParams['search'] = search;
      if (categories != null && categories.isNotEmpty) {
        queryParams['category'] = categories.join(',');
      }
      if (colors != null && colors.isNotEmpty) {
        queryParams['color'] = colors.first;
      }
      if (occasion != null && occasion.trim().isNotEmpty) {
        queryParams['occasion'] = UseCases.normalize(occasion);
      }
      if (conditions != null && conditions.isNotEmpty) {
        queryParams['condition'] = conditions.first;
      }
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final response = await _apiClient.get(
        ApiConstants.items,
        queryParameters: queryParams,
      );

      return _parseItemsList(response.data, page: page, limit: limit);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get single item
  Future<ItemModel> getItem(String itemId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.items}/$itemId');
      return _parseItem(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Create new item
  Future<ItemModel> createItem(CreateItemRequest request) async {
    try {
      final payload = _normalizeCreateItemPayload(request.toJson());
      final response = await _apiClient.post(ApiConstants.items, data: payload);
      return _parseItem(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Create item with image
  Future<ItemModel> createItemWithImage({
    required File image,
    required CreateItemRequest request,
  }) async {
    try {
      final created = await createItem(request);
      await uploadImages(created.id, [image]);
      return getItem(created.id);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Update item
  Future<ItemModel> updateItem(String itemId, UpdateItemRequest request) async {
    try {
      final payload = _normalizeUpdateItemPayload(request.toJson());
      final response = await _apiClient.put(
        '${ApiConstants.items}/$itemId',
        data: payload,
      );
      return _parseItem(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Delete item
  Future<void> deleteItem(String itemId) async {
    try {
      await _apiClient.delete('${ApiConstants.items}/$itemId');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Batch delete items
  Future<void> batchDeleteItems(List<String> itemIds) async {
    try {
      await _apiClient.post(
        '${ApiConstants.items}/batch-delete',
        data: {'item_ids': itemIds},
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Batch create items with optional images
  /// Creates multiple items in parallel for efficiency
  Future<List<ItemModel>> batchCreateItems(
    List<CreateItemRequest> requests, {
    Map<String, String>? itemImageBase64s,
  }) async {
    try {
      final results = await Future.wait(
        requests.asMap().entries.map((entry) async {
          final index = entry.key;
          final request = entry.value;

          // Create the item first
          final item = await createItem(request);

          // If there's a corresponding base64 image, upload it
          if (itemImageBase64s != null &&
              itemImageBase64s.containsKey('$index')) {
            try {
              await _apiClient.post(
                '${ApiConstants.items}/${item.id}/images',
                data: {'image': itemImageBase64s['$index']},
              );
              // Return refreshed item with image
              return getItem(item.id);
            } catch (e) {
              // Return item even if image upload failed
              return item;
            }
          }

          return item;
        }),
        eagerError: false,
      );

      return results.whereType<ItemModel>().toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Toggle item favorite
  Future<ItemModel> toggleFavorite(String itemId) async {
    try {
      await _apiClient.post('${ApiConstants.items}/$itemId/favorite');
      return getItem(itemId);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Mark item as worn
  Future<ItemModel> markAsWorn(String itemId) async {
    try {
      await _apiClient.post('${ApiConstants.items}/$itemId/wear');
      return getItem(itemId);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Upload item images
  Future<List<ItemImage>> uploadImages(String itemId, List<File> images) async {
    try {
      final uploaded = <ItemImage>[];
      for (final image in images) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(image.path),
        });
        final response = await _apiClient.post(
          '${ApiConstants.items}/$itemId/images',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
        final dataMap = _extractDataMap(response.data);
        if (dataMap.isNotEmpty) {
          uploaded.add(ItemImage.fromJson(_normalizeItemImageJson(dataMap)));
        }
      }
      return uploaded;
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Upload an image from base64 string (for AI-generated product images)
  /// Converts base64 to bytes and sends as multipart/form-data with 'file' field
  Future<ItemImage?> uploadImageFromBase64(
    String itemId,
    String base64Image,
  ) async {
    try {
      // Convert base64 string to bytes
      final bytes = base64Decode(base64Image);

      // Create multipart form data with 'file' field (backend expects this name)
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: 'generated_image.png',
          contentType: DioMediaType.parse('image/png'),
        ),
      });

      final response = await _apiClient.post(
        '${ApiConstants.items}/$itemId/images',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final dataMap = _extractDataMap(response.data);
      if (dataMap.isNotEmpty) {
        return ItemImage.fromJson(_normalizeItemImageJson(dataMap));
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Delete item image
  Future<void> deleteItemImage(String itemId, String imageId) async {
    try {
      await _apiClient.delete('${ApiConstants.items}/$itemId/images/$imageId');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Check for duplicates
  Future<List<ItemModel>> checkDuplicates(CreateItemRequest request) async {
    try {
      final payload = _normalizeCreateItemPayload(request.toJson());
      final response = await _apiClient.post(
        '${ApiConstants.items}/check-duplicates',
        data: payload,
      );
      final data = _extractDataMap(response.data);
      final duplicates = data['duplicates'];
      if (duplicates is! List) {
        return [];
      }
      final ids = duplicates
          .whereType<Map<String, dynamic>>()
          .map((item) => item['id']?.toString())
          .whereType<String>()
          .toList();
      final results = <ItemModel>[];
      for (final id in ids) {
        results.add(await getItem(id));
      }
      return results;
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Find similar items
  Future<List<ItemModel>> findSimilarItems(String itemId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.items}/$itemId/similar',
      );
      final data = _extractDataMap(response.data);
      final items = data['items'];
      if (items is! List) {
        return [];
      }
      return items
          .whereType<Map<String, dynamic>>()
          .map(_normalizeItemJson)
          .map(ItemModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get item statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _apiClient.get('${ApiConstants.items}/stats');
      return _extractDataMap(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Extract items from image using AI (SYNCHRONOUS)
  /// Backend returns items immediately - no polling needed for single item extraction
  /// Use batch extraction endpoints for async processing with multiple images
  Future<SyncExtractionResponse> extractItemsFromImage(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final imageBase64 = base64Encode(bytes);

      final response = await _apiClient.post(
        ApiConstants.aiExtractItems,
        data: {'image': imageBase64},
      );

      // Backend returns { "data": { "items": [...], "overall_confidence": 0.8, ... }, "message": "..." }
      final data = _extractDataMap(response.data);

      return SyncExtractionResponse.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Generate a product image for a detected clothing item
  /// This creates an isolated product-style image of just the clothing item
  /// without the person/background, suitable for catalog display
  Future<ProductImageGenerationResponse> generateProductImage({
    required String itemDescription,
    required String category,
    String? subCategory,
    List<String>? colors,
    String? material,
    String? pattern,
    String background = 'white',
    String viewAngle = 'front',
    bool includeShadows = false,
    bool saveToStorage = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.aiGenerateProductImage,
        data: {
          'item_description': itemDescription,
          'category': category,
          if (subCategory != null) 'sub_category': subCategory,
          'colors': colors ?? [],
          if (material != null) 'material': material,
          if (pattern != null) 'pattern': pattern,
          'background': background,
          'view_angle': viewAngle,
          'include_shadows': includeShadows,
          'save_to_storage': saveToStorage,
        },
        options: Options(
          receiveTimeout: const Duration(
            minutes: 5,
          ), // AI generation can take time
        ),
      );

      final data = _extractDataMap(response.data);
      final result = ProductImageGenerationResponse.fromJson(data);

      return result;
    } on DioException catch (e) {
      throw handleDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Generate product images for all detected items sequentially
  /// Returns a list of DetectedItemDataWithImage with generated images
  Future<List<DetectedItemDataWithImage>> generateProductImagesForItems(
    List<DetectedItemData> items,
  ) async {
    final results = <DetectedItemDataWithImage>[];

    // Process items sequentially to avoid overwhelming the API
    // (parallel processing could be added later with rate limiting)
    for (final item in items) {
      try {
        final response = await generateProductImage(
          itemDescription:
              item.detailedDescription ?? item.subCategory ?? item.category,
          category: item.category,
          subCategory: item.subCategory,
          colors: item.colors,
          material: item.material,
          pattern: item.pattern,
        );

        // Convert base64 to data URL for display
        final dataUrl = 'data:image/png;base64,${response.imageBase64}';

        results.add(
          DetectedItemDataWithImage(
            tempId: item.tempId,
            category: item.category,
            subCategory: item.subCategory,
            colors: item.colors,
            material: item.material,
            pattern: item.pattern,
            brand: item.brand,
            confidence: item.confidence,
            detailedDescription: item.detailedDescription,
            personId: item.personId,
            personLabel: item.personLabel,
            isCurrentUserPerson: item.isCurrentUserPerson,
            includeInWardrobe: item.includeInWardrobe,
            status: 'generated',
            generatedImageUrl: dataUrl,
            name: item.subCategory ?? item.category,
          ),
        );
      } catch (e) {
        // Add item with error status
        results.add(
          DetectedItemDataWithImage(
            tempId: item.tempId,
            category: item.category,
            subCategory: item.subCategory,
            colors: item.colors,
            material: item.material,
            pattern: item.pattern,
            brand: item.brand,
            confidence: item.confidence,
            detailedDescription: item.detailedDescription,
            personId: item.personId,
            personLabel: item.personLabel,
            isCurrentUserPerson: item.isCurrentUserPerson,
            includeInWardrobe: item.includeInWardrobe,
            status: 'generation_failed',
            generationError: e.toString().replaceAll('Exception: ', ''),
            name: item.subCategory ?? item.category,
          ),
        );
      }
    }

    return results;
  }

  /// Get batch extraction job status
  /// ONLY use this for batch extraction jobs started via /api/v1/ai/batch-extract
  /// Single item extraction is synchronous and does not need polling
  Future<ExtractionResponse> getGenerationStatus(String generationId) async {
    try {
      // Try the batch extraction status endpoint first
      final response = await _apiClient.get(
        ApiConstants.aiBatchExtractStatus(generationId),
      );
      final data = _extractDataMap(response.data);
      return _parseExtractionResponse(data);
    } on DioException catch (e) {
      // If batch endpoint fails, try the extraction items endpoint
      try {
        final response = await _apiClient.get(
          '${ApiConstants.ai}/extract-items/$generationId', // interpolation needed here
        );
        final data = _extractDataMap(response.data);
        return _parseExtractionResponse(data);
      } catch (_) {
        throw handleDioException(e);
      }
    }
  }

  Map<String, dynamic> _extractDataMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return payload;
    }
    return <String, dynamic>{};
  }

  ItemsListResponse _parseItemsList(
    dynamic payload, {
    required int page,
    required int limit,
  }) {
    final data = _extractDataMap(payload);
    final itemsPayload = data['items'];
    final items = itemsPayload is List
        ? itemsPayload
              .whereType<Map<String, dynamic>>()
              .map(_normalizeItemJson)
              .map(ItemModel.fromJson)
              .toList()
        : <ItemModel>[];
    final total = _coerceInt(data['total']);
    final pageValue = _coerceInt(data['page'], fallback: page);
    final limitValue = _coerceInt(
      data['limit'] ?? data['page_size'],
      fallback: limit,
    );
    final hasMore =
        _coerceBool(data['has_more']) ??
        _coerceBool(data['has_next']) ??
        (limitValue > 0 ? (pageValue * limitValue) < total : false);
    return ItemsListResponse(
      items: items,
      total: total,
      page: pageValue,
      limit: limitValue,
      hasMore: hasMore,
    );
  }

  ItemModel _parseItem(dynamic payload) {
    final data = _extractDataMap(payload);
    return ItemModel.fromJson(_normalizeItemJson(data));
  }

  Map<String, dynamic> _normalizeItemJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    final category = normalized['category'];
    if (category is String) {
      normalized['category'] = category.toLowerCase();
    }
    if (normalized['description'] == null && normalized['notes'] != null) {
      normalized['description'] = normalized['notes'];
    }
    if (normalized['location'] == null &&
        normalized['purchase_location'] != null) {
      normalized['location'] = normalized['purchase_location'];
    }
    if (normalized['worn_count'] == null &&
        normalized['usage_times_worn'] != null) {
      normalized['worn_count'] = normalized['usage_times_worn'];
    }
    if (normalized['last_worn_at'] == null &&
        normalized['usage_last_worn'] != null) {
      normalized['last_worn_at'] = normalized['usage_last_worn'];
    }
    if (normalized['condition'] == null) {
      normalized['condition'] = 'clean';
    }
    final occasionTags = _coerceStringList(normalized['occasion_tags']);
    if (occasionTags != null) {
      normalized['occasion_tags'] = UseCases.normalizeList(occasionTags);
    }
    final images = normalized['item_images'] ?? normalized['images'];
    if (images is List) {
      normalized['item_images'] = images
          .whereType<Map<String, dynamic>>()
          .map(_normalizeItemImageJson)
          .toList();
    }
    return normalized;
  }

  Map<String, dynamic> _normalizeItemImageJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['url'] ??=
        normalized['image_url'] ?? normalized['thumbnail_url'];
    return normalized;
  }

  int _coerceInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  bool? _coerceBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    if (value is num) {
      return value != 0;
    }
    return null;
  }

  Map<String, dynamic> _normalizeCreateItemPayload(
    Map<String, dynamic> payload,
  ) {
    final normalized = Map<String, dynamic>.from(payload);
    _remapKey(normalized, 'location', 'purchase_location');
    _remapKey(normalized, 'description', 'notes');
    normalized.removeWhere((key, value) => value == null);
    return normalized;
  }

  Map<String, dynamic> _normalizeUpdateItemPayload(
    Map<String, dynamic> payload,
  ) {
    final normalized = Map<String, dynamic>.from(payload);
    if (normalized.containsKey('purchaseDate')) {
      normalized['purchase_date'] = normalized.remove('purchaseDate');
    }
    _remapKey(normalized, 'location', 'purchase_location');
    _remapKey(normalized, 'description', 'notes');
    normalized.removeWhere((key, value) => value == null);
    return normalized;
  }

  void _remapKey(Map<String, dynamic> payload, String from, String to) {
    if (!payload.containsKey(from)) return;
    final value = payload.remove(from);
    if (value != null) {
      payload[to] = value;
    }
  }

  ExtractionResponse _parseExtractionResponse(Map<String, dynamic> data) {
    final itemsPayload = data['items'];
    final items = itemsPayload is List
        ? itemsPayload
              .whereType<Map<String, dynamic>>()
              .map(_mapExtractedItem)
              .toList()
        : <ExtractedItem>[];
    final status = data['status']?.toString() ?? 'completed';
    final id =
        data['id']?.toString() ??
        data['extraction_id']?.toString() ??
        'extraction-${DateTime.now().millisecondsSinceEpoch}';
    return ExtractionResponse(
      id: id,
      status: status,
      items: items,
      imageUrl: data['image_url']?.toString(),
      error: data['error']?.toString(),
      createdAt: _parseDateTime(data['created_at']),
    );
  }

  ExtractedItem _mapExtractedItem(Map<String, dynamic> json) {
    final categoryValue = json['category']?.toString().toLowerCase() ?? 'other';
    final name =
        json['name']?.toString() ??
        json['sub_category']?.toString() ??
        categoryValue;
    return ExtractedItem(
      name: name,
      category: Category.fromString(categoryValue),
      colors: _coerceStringList(json['colors']),
      material: json['material']?.toString(),
      pattern: json['pattern']?.toString(),
      description:
          json['detailed_description']?.toString() ??
          json['description']?.toString(),
      boundingBox: json['bounding_box'] is Map<String, dynamic>
          ? json['bounding_box'] as Map<String, dynamic>
          : null,
    );
  }

  List<String>? _coerceStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      return [value];
    }
    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

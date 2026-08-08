import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/outfit_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/utils/error_handler.dart';

/// Outfit repository
class OutfitRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get outfits list
  Future<OutfitsListResponse> getOutfits({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? styles,
    List<String>? seasons,
    bool? favoritesOnly,
    bool? draftsOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'page_size': limit,
      };

      if (search != null) queryParams['search'] = search;
      if (styles != null && styles.isNotEmpty) {
        queryParams['styles'] = styles.join(',');
      }
      if (seasons != null && seasons.isNotEmpty) {
        queryParams['seasons'] = seasons.join(',');
      }
      if (favoritesOnly != null) {
        queryParams['favorites_only'] = favoritesOnly;
      }
      if (draftsOnly != null) {
        queryParams['drafts_only'] = draftsOnly;
      }

      final response = await _apiClient.get(
        ApiConstants.outfits,
        queryParameters: queryParams,
      );

      return _parseOutfitsList(response.data, page: page, limit: limit);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get single outfit
  Future<OutfitModel> getOutfit(String outfitId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.outfits}/$outfitId',
      );
      return _parseOutfit(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Create new outfit
  Future<OutfitModel> createOutfit(CreateOutfitRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.outfits,
        data: request
            .toNonNullJson(), // Use toNonNullJson to exclude null values
      );
      return _parseOutfit(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Update outfit
  Future<OutfitModel> updateOutfit(
    String outfitId,
    UpdateOutfitRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.outfits}/$outfitId',
        data: request.toJson(),
      );
      return _parseOutfit(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Delete outfit
  Future<void> deleteOutfit(String outfitId) async {
    try {
      await _apiClient.delete('${ApiConstants.outfits}/$outfitId');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Toggle outfit favorite
  Future<OutfitModel> toggleFavorite(String outfitId) async {
    try {
      await _apiClient.post('${ApiConstants.outfits}/$outfitId/favorite');
      return getOutfit(outfitId);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Mark outfit as worn
  Future<OutfitModel> markAsWorn(String outfitId) async {
    try {
      await _apiClient.post('${ApiConstants.outfits}/$outfitId/wear');
      return getOutfit(outfitId);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Duplicate outfit
  Future<OutfitModel> duplicateOutfit(String outfitId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.outfits}/$outfitId/duplicate',
      );
      return _parseOutfit(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Delete a single outfit image
  Future<void> deleteOutfitImage(String outfitId, String imageId) async {
    try {
      await _apiClient.delete(
        '${ApiConstants.outfits}/$outfitId/images/$imageId',
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Upload outfit images
  Future<List<OutfitImage>> uploadImages(
    String outfitId,
    List<File> images,
  ) async {
    try {
      final formData = FormData.fromMap({
        'images': await Future.wait(
          images.map((image) => MultipartFile.fromFile(image.path)),
        ),
      });

      final response = await _apiClient.post(
        '${ApiConstants.outfits}/$outfitId/images',
        data: formData,
      );

      final dataList = _extractDataList(response.data);
      if (dataList.isNotEmpty) {
        return dataList
            .whereType<Map<String, dynamic>>()
            .map(_normalizeOutfitImageJson)
            .map(OutfitImage.fromJson)
            .toList();
      }
      final dataMap = _extractDataMap(response.data);
      if (dataMap.isNotEmpty) {
        return [OutfitImage.fromJson(_normalizeOutfitImageJson(dataMap))];
      }
      return [];
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Upload outfit image from base64 (for AI-generated images)
  Future<OutfitImage?> uploadOutfitImageFromBase64(
    String outfitId,
    String base64Image, {
    bool isPrimary = true,
    String? pose,
  }) async {
    try {
      // Detect image format from data URL prefix and determine MIME type/extension
      final dataUrlRegex = RegExp(
        r'^data:image/(\w+);base64,',
        caseSensitive: false,
      );
      final match = dataUrlRegex.firstMatch(base64Image);
      final format = (match?.group(1) ?? 'png').toLowerCase();
      final isJpeg = format == 'jpeg' || format == 'jpg';
      final mimeType = isJpeg ? 'image/jpeg' : 'image/png';
      final extension = isJpeg ? 'jpg' : 'png';

      // Remove data URL prefix if present
      final cleanBase64 = base64Image.replaceFirst(dataUrlRegex, '');

      // Convert base64 string to bytes
      final bytes = base64Decode(cleanBase64);

      // Create multipart form data with 'file' field (backend expects this name)
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: 'generated_outfit_$outfitId.$extension',
          contentType: DioMediaType.parse(mimeType),
        ),
        'is_primary': isPrimary,
        if (pose != null) 'pose': pose,
        'is_generated': true,
      });

      final response = await _apiClient.post(
        '${ApiConstants.outfits}/$outfitId/images',
        data: formData,
      );

      final dataMap = _extractDataMap(response.data);
      if (dataMap.isNotEmpty) {
        return OutfitImage.fromJson(_normalizeOutfitImageJson(dataMap));
      }
      return null;
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Upload an outfit image from an HTTP(S) URL (for AI-generated
  /// visualizations saved by URL instead of base64). Downloads the bytes,
  /// then reuses the same multipart upload as
  /// [uploadOutfitImageFromBase64]. Best-effort: returns null on any
  /// download/upload failure so callers can fall back or surface the loss.
  Future<OutfitImage?> uploadOutfitImageFromUrl(
    String outfitId,
    String imageUrl, {
    bool isPrimary = true,
    String? pose,
  }) async {
    try {
      final response = await _apiClient.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes is! List<int> || bytes.isEmpty) {
        ErrorHandler.reportError(
          StateError('Empty image body'),
          'Outfit image upload failed: empty download from $imageUrl for '
          'outfit $outfitId',
        );
        return null;
      }

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: 'generated_outfit_$outfitId.png',
          contentType: DioMediaType.parse('image/png'),
        ),
        'is_primary': isPrimary,
        if (pose != null) 'pose': pose,
        'is_generated': true,
      });

      final uploadResponse = await _apiClient.post(
        '${ApiConstants.outfits}/$outfitId/images',
        data: formData,
      );

      final dataMap = _extractDataMap(uploadResponse.data);
      if (dataMap.isNotEmpty) {
        return OutfitImage.fromJson(_normalizeOutfitImageJson(dataMap));
      }
      return null;
    } on DioException catch (e) {
      ErrorHandler.reportError(
        e,
        'Outfit image upload failed: could not download $imageUrl for outfit '
        '$outfitId',
      );
      return null;
    } catch (e) {
      ErrorHandler.reportError(
        e,
        'Outfit image upload failed: could not download $imageUrl for outfit '
        '$outfitId',
      );
      return null;
    }
  }

  /// Generate AI outfit visualization
  Future<OutfitVisualizationResult> generateOutfitVisualization(
    List<dynamic> items, {
    String? style,
    String? background,
  }) async {
    try {
      // Use extended timeout for AI generation (can take up to 5 minutes)
      final response = await _apiClient.postWithExtendedTimeout(
        '${ApiConstants.ai}/generate-outfit',
        data: {
          'items': items,
          if (style != null) 'style': style,
          if (background != null) 'background': background,
        },
      );

      final data = _extractDataMap(response.data);
      return OutfitVisualizationResult.fromJson(
        _normalizeVisualizationJson(data),
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get generation status
  Future<GenerationStatus> getGenerationStatus(String taskId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.outfits}/generation/$taskId',
      );
      final data = _extractDataMap(response.data);
      final normalized = Map<String, dynamic>.from(data);
      normalized['id'] = taskId;
      final images = normalized['images'];
      if (images is List && images.isNotEmpty) {
        normalized['imageUrl'] = images.first.toString();
      }
      return GenerationStatus.fromJson(normalized);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Share outfit publicly
  Future<String> shareOutfit(String outfitId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.outfits}/$outfitId/share',
      );
      final data = _extractDataMap(response.data);
      final shareLink = data['share_link'];
      if (shareLink is Map<String, dynamic>) {
        final url = shareLink['url']?.toString();
        if (url != null && url.isNotEmpty) {
          return url;
        }
      }
      final url = data['share_url']?.toString();
      if (url != null && url.isNotEmpty) {
        return url;
      }
      throw Exception('Share URL unavailable');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get wear history for an outfit
  Future<List<WearHistoryEntry>> getWearHistory(String outfitId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.outfits}/$outfitId/wear-history',
      );
      final data = _extractDataMap(response.data);
      final historyList = data['wear_history'] as List? ?? [];
      return historyList
          .whereType<Map<String, dynamic>>()
          .map((e) => WearHistoryEntry.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get public shared outfit
  Future<SharedOutfitModel> getSharedOutfit(String shareId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.outfits}/shared/$shareId',
      );
      final data = _extractDataMap(response.data);
      return SharedOutfitModel.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get outfit collections
  Future<List<Map<String, dynamic>>> getCollections() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.outfits}/collections',
      );
      final data = _extractDataMap(response.data);
      final collections = data['collections'];
      if (collections is List) {
        return collections.whereType<Map<String, dynamic>>().toList();
      }
      final list = _extractDataList(response.data);
      return list.whereType<Map<String, dynamic>>().toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Create collection
  Future<Map<String, dynamic>> createCollection(
    String name,
    List<String> outfitIds, {
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.outfits}/collections',
        data: {
          'name': name,
          'outfit_ids': outfitIds,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
      return _extractDataMap(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Update collection
  Future<Map<String, dynamic>> updateCollection(
    String collectionId,
    String name,
    List<String> outfitIds, {
    String? description,
  }) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.outfits}/collections/$collectionId',
        data: {
          'name': name,
          'outfit_ids': outfitIds,
          if (description != null) 'description': description,
        },
      );
      return _extractDataMap(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Delete collection
  Future<void> deleteCollection(String collectionId) async {
    try {
      await _apiClient.delete(
        '${ApiConstants.outfits}/collections/$collectionId',
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Add outfit to collection
  Future<Map<String, dynamic>> addOutfitToCollection(
    String collectionId,
    String outfitId,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.outfits}/collections/$collectionId/outfits',
        data: {'outfit_id': outfitId},
      );
      return _extractDataMap(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Add a user-selected set of outfits to a collection in order.
  ///
  /// The endpoint is intentionally called once per outfit so partial failures
  /// remain observable and the API contract stays compatible with existing
  /// single-item collection writes. Adds run in small concurrent batches so a
  /// multi-outfit selection is no longer N serial RTT-bound round trips; a
  /// batch failure still surfaces to the caller after the batch completes.
  Future<void> addOutfitsToCollection(
    String collectionId,
    Iterable<String> outfitIds,
  ) async {
    const batchSize = 5;
    final ids = outfitIds.toList();
    for (var start = 0; start < ids.length; start += batchSize) {
      final batch = ids.skip(start).take(batchSize);
      final failures = <Object>[];
      await Future.wait(
        batch.map((outfitId) async {
          try {
            await addOutfitToCollection(collectionId, outfitId);
          } catch (e) {
            failures.add(e);
          }
        }),
      );
      if (failures.isNotEmpty) {
        throw failures.first;
      }
    }
  }

  /// Remove outfit from collection
  Future<void> removeOutfitFromCollection(
    String collectionId,
    String outfitId,
  ) async {
    try {
      await _apiClient.delete(
        '${ApiConstants.outfits}/collections/$collectionId/outfits/$outfitId',
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Re-mint a fresh client-fetchable URL for a durable storage key.
  ///
  /// The API serves short-lived presigned URLs materialized from
  /// `storage_path` at read time; a cached URL expires after
  /// OBJECT_STORAGE_PRESIGN_TTL (1h). Surfaces that render outfit images can
  /// call this when a load fails and retry with the fresh URL instead of
  /// showing a permanently broken tile. Returns null on any failure.
  Future<String?> remintImageUrl(String storagePath) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.imagesPresigned,
        queryParameters: {'storage_path': storagePath},
      );
      final data = _extractDataMap(response.data);
      final url = data['url']?.toString();
      if (url == null || url.isEmpty) {
        return null;
      }
      return url;
    } catch (_) {
      return null;
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

  List<dynamic> _extractDataList(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) {
        return data;
      }
    }
    if (payload is List) {
      return payload;
    }
    return const [];
  }

  OutfitsListResponse _parseOutfitsList(
    dynamic payload, {
    required int page,
    required int limit,
  }) {
    final data = _extractDataMap(payload);
    final outfitsPayload = data['outfits'];
    final outfits = outfitsPayload is List
        ? outfitsPayload
              .whereType<Map<String, dynamic>>()
              .map(_normalizeOutfitJson)
              .map(OutfitModel.fromJson)
              .toList()
        : <OutfitModel>[];
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
    return OutfitsListResponse(
      outfits: outfits,
      total: total,
      page: pageValue,
      limit: limitValue,
      hasMore: hasMore,
    );
  }

  OutfitModel _parseOutfit(dynamic payload) {
    final data = _extractDataMap(payload);
    return OutfitModel.fromJson(_normalizeOutfitJson(data));
  }

  Map<String, dynamic> _normalizeOutfitJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    final season = normalized['season'];
    if (season is String) {
      normalized['season'] = _normalizeSeasonValue(season);
    }
    final itemIds = normalized['item_ids'];
    if (itemIds == null) {
      normalized['item_ids'] = <String>[];
    } else if (itemIds is List) {
      normalized['item_ids'] = itemIds.map((id) => id.toString()).toList();
    }
    final images = normalized['outfit_images'] ?? normalized['images'];
    if (images is List) {
      normalized['outfit_images'] = images
          .whereType<Map<String, dynamic>>()
          .map(_normalizeOutfitImageJson)
          .toList();
    }
    return normalized;
  }

  Map<String, dynamic> _normalizeOutfitImageJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['url'] ??=
        normalized['image_url'] ?? normalized['thumbnail_url'];
    return normalized;
  }

  Map<String, dynamic> _normalizeVisualizationJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    final imageUrl = normalized['image_url'] ?? normalized['imageUrl'];
    if (imageUrl != null) {
      normalized['imageUrl'] = imageUrl;
    }
    final imageBase64 = normalized['image_base64'] ?? normalized['imageBase64'];
    if (imageBase64 != null) {
      normalized['image_base64'] = imageBase64;
    }
    normalized['id'] ??=
        normalized['generation_id'] ??
        'gen-${DateTime.now().millisecondsSinceEpoch}';
    normalized['status'] ??= (imageUrl != null || imageBase64 != null)
        ? 'completed'
        : 'processing';
    return normalized;
  }

  String _normalizeSeasonValue(String value) {
    if (value == 'all-season' || value == 'all_season') {
      return 'allSeason';
    }
    return value;
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
}

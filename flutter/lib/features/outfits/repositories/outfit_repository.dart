import 'dart:io';
import 'package:dio/dio.dart';
import '../models/outfit_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';

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
      final response = await _apiClient.get('${ApiConstants.outfits}/$outfitId');
      return _parseOutfit(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Create new outfit
  Future<OutfitModel> createOutfit(CreateOutfitRequest request) async {
    try {
      final payload = _normalizeOutfitPayload(request.toJson());
      final response = await _apiClient.post(
        ApiConstants.outfits,
        data: payload,
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
      final payload = _normalizeOutfitPayload(
        request.toJson(),
        allowNullKeys: {
          'description',
          'occasion',
          'tags',
          'style',
          'season',
        },
      );
      final response = await _apiClient.put(
        '${ApiConstants.outfits}/$outfitId',
        data: payload,
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
      await _apiClient.post(
        '${ApiConstants.outfits}/$outfitId/favorite',
      );
      return getOutfit(outfitId);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Mark outfit as worn
  Future<OutfitModel> markAsWorn(String outfitId) async {
    try {
      await _apiClient.post(
        '${ApiConstants.outfits}/$outfitId/wear',
      );
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

  /// Upload outfit images
  Future<List<OutfitImage>> uploadImages(
    String outfitId,
    List<File> images,
  ) async {
    try {
      final formData = FormData.fromMap({
        'images': await Future.wait(
          images.map(
            (image) => MultipartFile.fromFile(image.path),
          ),
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
        return [
          OutfitImage.fromJson(_normalizeOutfitImageJson(dataMap)),
        ];
      }
      return [];
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Generate AI outfit visualization
  Future<OutfitVisualizationResult> generateOutfitVisualization(
    List<dynamic> items, {
    String? style,
    String? background,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.ai}/generate-outfit',
        data: {
          'items': items,
          if (style != null) 'style': style,
          if (background != null) 'background': background,
        },
      );

      final data = _extractDataMap(response.data);
      return OutfitVisualizationResult.fromJson(_normalizeVisualizationJson(data));
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
      final response = await _apiClient.get('${ApiConstants.outfits}/$outfitId/wear-history');
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
      final response = await _apiClient.get('${ApiConstants.outfits}/collections');
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
    List<String> outfitIds,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.outfits}/collections',
        data: {
          'name': name,
          'outfit_ids': outfitIds,
        },
      );
      return _extractDataMap(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
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
    final limitValue = _coerceInt(data['limit'] ?? data['page_size'], fallback: limit);
    final hasMore = _coerceBool(data['has_more']) ??
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

  Map<String, dynamic> _normalizeOutfitPayload(
    Map<String, dynamic> payload, {
    Set<String>? allowNullKeys,
  }) {
    final normalized = Map<String, dynamic>.from(payload);
    _remapKey(normalized, 'itemIds', 'item_ids');
    _remapKey(normalized, 'isFavorite', 'is_favorite');
    _remapKey(normalized, 'isDraft', 'is_draft');
    _remapKey(normalized, 'isPublic', 'is_public');
    if (allowNullKeys == null || allowNullKeys.isEmpty) {
      normalized.removeWhere((key, value) => value == null);
    } else {
      normalized.removeWhere(
        (key, value) => value == null && !allowNullKeys.contains(key),
      );
    }
    return normalized;
  }

  void _remapKey(Map<String, dynamic> payload, String from, String to) {
    if (!payload.containsKey(from)) return;
    final value = payload.remove(from);
    if (value != null) {
      payload[to] = value;
    }
  }

  Map<String, dynamic> _normalizeOutfitImageJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['url'] ??= normalized['image_url'] ?? normalized['thumbnail_url'];
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
        normalized['generation_id'] ?? 'gen-${DateTime.now().millisecondsSinceEpoch}';
    normalized['status'] ??=
        (imageUrl != null || imageBase64 != null) ? 'completed' : 'processing';
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

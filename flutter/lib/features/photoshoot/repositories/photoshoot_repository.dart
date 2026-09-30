import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/sse_service.dart';
import '../../../core/widgets/app_network_image.dart' show authHeadersForUrl;
import '../models/photoshoot_models.dart';

/// Photoshoot API calls. Every Dio failure is mapped to an [AppException],
/// so callers can match on [RateLimitException] and friends.
class PhotoshootRepository {
  ApiClient get _apiClient => ApiClient.instance;

  static const String _baseEndpoint = '${ApiConstants.apiVersion}/photoshoot';

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Current user's photoshoot usage.
  Future<PhotoshootUsage> getUsage() => _guard(() async {
    final response = await _apiClient.get('$_baseEndpoint/usage');
    return PhotoshootUsage.fromJson(_extractDataMap(response.data));
  });

  /// Starts a generation job. Returns the job id for the SSE subscription.
  Future<PhotoshootJobResponse> startGeneration({
    required List<String> photos,
    required PhotoshootUseCase useCase,
    String? customPrompt,
    int numImages = 10,
    int batchSize = 10,
    PhotoshootAspectRatio aspectRatio = PhotoshootAspectRatio.square,
  }) => _guard(() async {
    final response = await _apiClient.post(
      '$_baseEndpoint/generate',
      data: {
        'photos': photos,
        'use_case': useCase.apiValue,
        if (customPrompt != null && customPrompt.isNotEmpty)
          'custom_prompt': customPrompt,
        'num_images': numImages,
        'batch_size': batchSize,
        'aspect_ratio': aspectRatio.apiValue,
      },
    );
    return PhotoshootJobResponse.fromJson(_extractDataMap(response.data));
  });

  /// Generates photos synchronously (used to retry a failed slot).
  Future<PhotoshootResult> generateSync({
    required List<String> photos,
    required PhotoshootUseCase useCase,
    String? customPrompt,
    int numImages = 1,
    PhotoshootAspectRatio aspectRatio = PhotoshootAspectRatio.square,
  }) => _guard(() async {
    final response = await _apiClient.postWithExtendedTimeout(
      '$_baseEndpoint/generate?sync=true',
      data: {
        'photos': photos,
        'use_case': useCase.apiValue,
        if (customPrompt != null && customPrompt.isNotEmpty)
          'custom_prompt': customPrompt,
        'num_images': numImages,
        'aspect_ratio': aspectRatio.apiValue,
      },
    );
    return PhotoshootResult.fromJson(_extractDataMap(response.data));
  });

  /// SSE events for real-time progress.
  Stream<ServerSentEvent> subscribeToEvents(String jobId) =>
      SSEService.instance.connect(ApiConstants.photoshootEvents(jobId));

  Future<void> cancelJob(String jobId) =>
      _guard(() => _apiClient.post(ApiConstants.photoshootCancel(jobId)));

  /// Job status (fallback when SSE fails).
  Future<PhotoshootJobStatusResponse> getJobStatus(
    String jobId,
  ) => _guard(() async {
    final response = await _apiClient.get(ApiConstants.photoshootStatus(jobId));
    return PhotoshootJobStatusResponse.fromJson(_extractDataMap(response.data));
  });

  /// Bytes of a generated image: the inline payload, or a download.
  Future<Uint8List> imageBytes(GeneratedImage image) async {
    final inline = image.imageBase64;
    if (inline != null && inline.isNotEmpty) {
      return base64Decode(inline.split(',').last);
    }
    final url = image.imageUrl;
    if (url == null || url.isEmpty) {
      throw Exception('This image has no data.');
    }
    // authHeadersForUrl attaches the bearer token only for our own serving
    // URLs; presigned and third-party hosts get no header.
    final response = await http
        .get(Uri.parse(url), headers: authHeadersForUrl(url))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Could not download the image.');
    }
    return response.bodyBytes;
  }

  Future<void> saveToGallery(Uint8List bytes, String name) =>
      Gal.putImageBytes(bytes, name: name);

  Map<String, dynamic> _extractDataMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) return data;
      return payload;
    }
    return <String, dynamic>{};
  }
}

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/sse_service.dart';
import '../models/photoshoot_models.dart';

/// Repository for photoshoot API operations
class PhotoshootRepository {
  final ApiClient _apiClient = ApiClient.instance;
  final SSEService _sseService = SSEService.instance;

  static const String _baseEndpoint = '${ApiConstants.apiVersion}/photoshoot';

  /// Get available use cases
  Future<List<UseCaseInfo>> getUseCases() async {
    final response = await _apiClient.get('$_baseEndpoint/use-cases');
    final data = _extractDataMap(response.data);
    final useCases = data['use_cases'] as List<dynamic>? ?? [];
    return useCases
        .map((e) => UseCaseInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get current user's photoshoot usage
  Future<PhotoshootUsage> getUsage() async {
    final response = await _apiClient.get('$_baseEndpoint/usage');
    final data = _extractDataMap(response.data);
    return PhotoshootUsage.fromJson(data);
  }

  /// Start photoshoot generation job
  /// Returns job_id for SSE subscription
  Future<PhotoshootJobResponse> startGeneration({
    required List<String> photos,
    required PhotoshootUseCase useCase,
    String? customPrompt,
    int numImages = 10,
    int batchSize = 10,
    PhotoshootAspectRatio aspectRatio = PhotoshootAspectRatio.square,
  }) async {
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

    final data = _extractDataMap(response.data);
    return PhotoshootJobResponse.fromJson(data);
  }

  /// Generate photos synchronously (used for retrying failed slots)
  Future<PhotoshootResult> generateSync({
    required List<String> photos,
    required PhotoshootUseCase useCase,
    String? customPrompt,
    int numImages = 1,
    PhotoshootAspectRatio aspectRatio = PhotoshootAspectRatio.square,
  }) async {
    final response = await _apiClient.post(
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

    final data = _extractDataMap(response.data);
    return PhotoshootResult.fromJson(data);
  }

  /// Subscribe to SSE events for real-time progress
  Stream<ServerSentEvent> subscribeToEvents(String jobId) {
    final path = ApiConstants.photoshootEvents(jobId);
    return _sseService.connect(path);
  }

  /// Cancel a running generation job
  Future<void> cancelJob(String jobId) async {
    await _apiClient.post(ApiConstants.photoshootCancel(jobId));
  }

  /// Get job status (fallback if SSE fails)
  Future<PhotoshootJobStatusResponse> getJobStatus(String jobId) async {
    final response = await _apiClient.get(ApiConstants.photoshootStatus(jobId));
    final data = _extractDataMap(response.data);
    return PhotoshootJobStatusResponse.fromJson(data);
  }

  Map<String, dynamic> _extractDataMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      // If no nested data, return payload itself
      return payload;
    }
    return <String, dynamic>{};
  }
}

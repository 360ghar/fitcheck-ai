import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/photoshoot_models.dart';

/// Repository for photoshoot API operations
class PhotoshootRepository {
  final ApiClient _apiClient = ApiClient.instance;

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

  /// Generate photoshoot images
  Future<PhotoshootResult> generate({
    required List<String> photos,
    required PhotoshootUseCase useCase,
    String? customPrompt,
    int numImages = 10,
  }) async {
    final response = await _apiClient.post(
      '$_baseEndpoint/generate',
      data: {
        'photos': photos,
        'use_case': useCase.apiValue,
        if (customPrompt != null && customPrompt.isNotEmpty)
          'custom_prompt': customPrompt,
        'num_images': numImages,
      },
    );

    final data = _extractDataMap(response.data);
    return PhotoshootResult.fromJson(data);
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

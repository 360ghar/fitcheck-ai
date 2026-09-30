import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/api_client.dart';

/// Try-on API calls. Dio failures are mapped to [AppException]s.
class TryOnRepository {
  ApiClient get _api => ApiClient.instance;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// The user's avatar URL, or null when none is set.
  Future<String?> fetchAvatarUrl() => _guard(() async {
    final response = await _api.get('${ApiConstants.users}/me');
    final avatar = extractDataMap(response.data)['avatar_url']?.toString();
    return (avatar == null || avatar.isEmpty) ? null : avatar;
  });

  /// Uploads [path] as the avatar and returns its new URL.
  Future<String> uploadAvatar(String path) => _guard(() async {
    final response = await _api.post(
      '${ApiConstants.users}/me/avatar',
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(path, filename: 'avatar.jpg'),
      }),
    );
    final avatar = extractDataMap(response.data)['avatar_url']?.toString();
    if (avatar == null || avatar.isEmpty) {
      throw Exception('The photo did not upload. Please try again.');
    }
    return avatar;
  });

  /// Runs a try-on and returns the result map (`image_url` and/or
  /// `image_base64`).
  Future<Map<String, dynamic>> generate(Map<String, dynamic> payload) =>
      _guard(() async {
        final response = await _api.postWithExtendedTimeout(
          ApiConstants.aiTryOn,
          data: payload,
        );
        return extractDataMap(response.data);
      });

  Future<Uint8List> downloadBytes(String url) => _guard(() async {
    final response = await _api.dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? const <int>[]);
  });

  Future<void> saveToGallery(Uint8List bytes, String name) =>
      Gal.putImageBytes(bytes, name: name);

  /// The request for the singular try-on API contract.
  static Map<String, dynamic> buildPayload(
    List<String> clothingImages, {
    required String style,
    required String background,
    required String pose,
  }) {
    if (clothingImages.length != 1) {
      throw ArgumentError('Try-on requires exactly one clothing image.');
    }
    return {
      'clothing_image': clothingImages.single,
      'style': style,
      'background': background,
      'pose': pose,
      'lighting': 'professional studio lighting',
      // URL-first: the backend stores the render and returns image_url; the
      // inline base64 appears only when the storage write fails.
      'save_to_storage': true,
    };
  }

  /// Normalizes a response payload to its result map. Accepts the envelope
  /// (`{"data": {...}}`), a bare object, and an array wrapper, which some
  /// deployments return for generation results.
  @visibleForTesting
  static Map<String, dynamic> extractDataMap(dynamic payload) {
    dynamic candidate = payload;
    if (payload is List) candidate = payload.isNotEmpty ? payload.first : null;
    if (candidate is Map<String, dynamic>) {
      final data = candidate['data'];
      if (data is Map<String, dynamic>) return data;
      return candidate;
    }
    return <String, dynamic>{};
  }
}

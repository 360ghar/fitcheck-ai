import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthRetryableFetchException;

/// Keeps refresh rate limits on the SDK's existing retry path. GoTrue treats
/// HTTP 429 as rejected credentials if it reaches its response parser.
class AuthRefreshHttpClient extends http.BaseClient {
  AuthRefreshHttpClient({required String supabaseUrl, http.Client? client})
    : _client = client ?? http.Client(),
      _tokenUrl = Uri.parse('$supabaseUrl/auth/v1/token');

  final http.Client _client;
  final Uri _tokenUrl;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _client.send(request);
    if (response.statusCode == 429 &&
        request.method == 'POST' &&
        request.url.scheme == _tokenUrl.scheme &&
        request.url.authority == _tokenUrl.authority &&
        request.url.path == _tokenUrl.path &&
        request.url.queryParameters['grant_type'] == 'refresh_token') {
      await response.stream.drain<void>();
      // The SDK owns bounded exponential backoff. It does not expose
      // Retry-After handling, so this client adds no separate retry loop.
      throw AuthRetryableFetchException(
        message: 'Session refresh is temporarily rate limited.',
        statusCode: '429',
      );
    }
    return response;
  }

  @override
  void close() => _client.close();
}

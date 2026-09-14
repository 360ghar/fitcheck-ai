import '../constants/api_constants.dart';

/// Whether a resolved URL may receive this app's session token.
/// Presigned objects use their query signature instead of bearer auth.
bool urlAcceptsAuthToken(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null ||
      !const {'http', 'https'}.contains(uri.scheme) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      _queryHasSignature(uri)) {
    return false;
  }

  // The exact configured API origin also covers local/staging development.
  final api = Uri.tryParse(ApiConstants.baseUrl);
  if (api != null &&
      uri.scheme == api.scheme &&
      uri.host == api.host &&
      uri.port == api.port) {
    return true;
  }

  return uri.scheme == 'https' &&
      uri.port == 443 &&
      const {
        'api.fitcheckaiapp.com',
        'images.fitcheckaiapp.com',
      }.contains(uri.host);
}

/// Whether the raw query carries an S3/R2 presignature parameter.
///
/// The query is inspected as it came off the wire instead of through
/// `uri.queryParameters`: that getter utf8-decodes every key and value, and a
/// valid-hex but non-UTF-8 escape (a Latin-1 filename such as
/// `?f=caf%E9.jpg`) makes it throw FormatException - inside widget build,
/// where this policy is evaluated for every image tile.
bool _queryHasSignature(Uri uri) {
  final raw = uri.query.toLowerCase();
  return raw.isNotEmpty &&
      raw.split('&').any((part) => part.startsWith('x-amz-'));
}

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

/// Repository for authentication-related API calls
class AuthRepository {
  /// Sync OAuth profile with backend
  /// This creates the user record in the backend database and initializes
  /// user preferences, body profiles, and other user-specific data
  Future<void> syncOAuthProfile() async {
    await ApiClient.instance.post(
      '${ApiConstants.auth}${ApiConstants.oauthSync}',
    );
  }

  /// Fetch current backend user profile
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final response = await ApiClient.instance.get('${ApiConstants.users}/me');
    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) return data;
    }
    return <String, dynamic>{};
  }
}

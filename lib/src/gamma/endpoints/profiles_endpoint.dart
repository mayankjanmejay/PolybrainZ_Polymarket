import '../../core/api_client.dart';
import '../models/profile.dart';

/// Endpoints for user profiles.
class ProfilesEndpoint {
  final ApiClient _client;

  ProfilesEndpoint(this._client);

  /// Get public profile by wallet address.
  Future<Profile> getByAddress(String address) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/profiles/$address',
    );
    return Profile.fromJson(response);
  }
}

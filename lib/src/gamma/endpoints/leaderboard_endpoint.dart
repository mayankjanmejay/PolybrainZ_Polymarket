import '../../core/api_client.dart';
import '../models/profile.dart';

/// Endpoints for Gamma leaderboard.
class GammaLeaderboardEndpoint {
  final ApiClient _client;

  GammaLeaderboardEndpoint(this._client);

  /// Get top traders by profit.
  ///
  /// Returns profiles sorted by total profit.
  Future<List<Profile>> getTopByProfit({int limit = 20, int offset = 0}) async {
    final response = await _client.get<List<dynamic>>(
      '/leaderboard',
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'order': 'profit',
        'ascending': 'false',
      },
    );
    return response
        .map((p) => Profile.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Get top traders by volume.
  Future<List<Profile>> getTopByVolume({int limit = 20, int offset = 0}) async {
    final response = await _client.get<List<dynamic>>(
      '/leaderboard',
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'order': 'volume',
        'ascending': 'false',
      },
    );
    return response
        .map((p) => Profile.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Get top traders by number of markets traded.
  Future<List<Profile>> getTopByMarketsTraded({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/leaderboard',
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'order': 'markets_traded',
        'ascending': 'false',
      },
    );
    return response
        .map((p) => Profile.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Get leaderboard with custom ordering.
  ///
  /// [order] - Field to order by (e.g., 'profit', 'volume', 'markets_traded')
  /// [ascending] - Sort direction
  Future<List<Profile>> getLeaderboard({
    int limit = 20,
    int offset = 0,
    String order = 'profit',
    bool ascending = false,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/leaderboard',
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'order': order,
        'ascending': ascending.toString(),
      },
    );
    return response
        .map((p) => Profile.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}

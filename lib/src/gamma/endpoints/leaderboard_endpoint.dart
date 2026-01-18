import '../../core/api_client.dart';
import '../../enums/gamma_leaderboard_order_by.dart';
import '../models/profile.dart';

/// Endpoints for Gamma leaderboard.
class GammaLeaderboardEndpoint {
  final ApiClient _client;

  GammaLeaderboardEndpoint(this._client);

  /// Get top traders by profit.
  ///
  /// Returns profiles sorted by total profit.
  Future<List<Profile>> getTopByProfit({int limit = 20, int offset = 0}) async {
    return getLeaderboard(
      limit: limit,
      offset: offset,
      order: GammaLeaderboardOrderBy.profit,
      ascending: false,
    );
  }

  /// Get top traders by volume.
  Future<List<Profile>> getTopByVolume({int limit = 20, int offset = 0}) async {
    return getLeaderboard(
      limit: limit,
      offset: offset,
      order: GammaLeaderboardOrderBy.volume,
      ascending: false,
    );
  }

  /// Get top traders by number of markets traded.
  Future<List<Profile>> getTopByMarketsTraded({
    int limit = 20,
    int offset = 0,
  }) async {
    return getLeaderboard(
      limit: limit,
      offset: offset,
      order: GammaLeaderboardOrderBy.marketsTraded,
      ascending: false,
    );
  }

  /// Get leaderboard with custom ordering.
  ///
  /// [order] - Field to order by (profit, volume, marketsTraded)
  /// [ascending] - Sort direction
  Future<List<Profile>> getLeaderboard({
    int limit = 20,
    int offset = 0,
    GammaLeaderboardOrderBy order = GammaLeaderboardOrderBy.profit,
    bool ascending = false,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/leaderboard',
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'order': order.value,
        'ascending': ascending.toString(),
      },
    );
    return response
        .map((p) => Profile.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}

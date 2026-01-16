import '../../core/api_client.dart';
import '../../enums/leaderboard_window.dart';
import '../../enums/leaderboard_type.dart';
import '../models/leaderboard_entry.dart';

/// Endpoints for leaderboard.
class LeaderboardEndpoint {
  final ApiClient _client;

  LeaderboardEndpoint(this._client);

  /// Get leaderboard rankings.
  ///
  /// [window] - Time window (1d, 7d, 30d, all)
  /// [type] - Ranking type (PROFIT or VOLUME)
  Future<List<LeaderboardEntry>> getLeaderboard({
    LeaderboardWindow window = LeaderboardWindow.all,
    LeaderboardType type = LeaderboardType.profit,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'window': window.toJson(),
      'type': type.toJson(),
    };

    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/leaderboard',
      queryParams: params,
    );

    return response
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific user's leaderboard rank.
  Future<LeaderboardEntry?> getUserRank(
    String userAddress, {
    LeaderboardWindow window = LeaderboardWindow.all,
    LeaderboardType type = LeaderboardType.profit,
  }) async {
    final params = <String, String>{
      'user': userAddress,
      'window': window.toJson(),
      'type': type.toJson(),
    };

    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/leaderboard/user',
        queryParams: params,
      );
      return LeaderboardEntry.fromJson(response);
    } catch (_) {
      return null; // User not on leaderboard
    }
  }
}

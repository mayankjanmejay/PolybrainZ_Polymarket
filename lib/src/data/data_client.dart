import '../core/api_client.dart';
import '../core/constants.dart';
import 'endpoints/positions_endpoint.dart';
import 'endpoints/trades_endpoint.dart';
import 'endpoints/activity_endpoint.dart';
import 'endpoints/holders_endpoint.dart';
import 'endpoints/value_endpoint.dart';
import 'endpoints/leaderboard_endpoint.dart';

/// Client for the Data API (positions, trades, activity).
class DataClient {
  final ApiClient _client;

  late final PositionsEndpoint positions;
  late final DataTradesEndpoint trades;
  late final ActivityEndpoint activity;
  late final HoldersEndpoint holders;
  late final ValueEndpoint value;
  late final LeaderboardEndpoint leaderboard;

  DataClient({
    String? baseUrl,
    ApiClient? client,
  }) : _client = client ??
            ApiClient(
              baseUrl: baseUrl ?? PolymarketConstants.dataBaseUrl,
            ) {
    positions = PositionsEndpoint(_client);
    trades = DataTradesEndpoint(_client);
    activity = ActivityEndpoint(_client);
    holders = HoldersEndpoint(_client);
    value = ValueEndpoint(_client);
    leaderboard = LeaderboardEndpoint(_client);
  }

  /// Health check.
  Future<bool> isHealthy() async {
    try {
      await _client.get<dynamic>('/health');
      return true;
    } catch (_) {
      return false;
    }
  }

  void close() => _client.close();
}

import '../../core/api_client.dart';
import '../../enums/sports_league.dart';
import '../../enums/sports_order_by.dart';
import '../models/team.dart';

/// Endpoints for sports data.
class SportsEndpoint {
  final ApiClient _client;

  SportsEndpoint(this._client);

  /// List teams with filters.
  ///
  /// [order] - Field to order by (name, league, abbreviation, createdAt)
  /// [ascending] - Sort direction (true = ascending, false = descending)
  Future<List<Team>> listTeams({
    int limit = 100,
    int offset = 0,
    SportsOrderBy? order,
    bool? ascending,
    List<SportsLeague>? leagues,
    List<String>? names,
    List<String>? abbreviations,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (order != null) params['order'] = order.value;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (leagues != null) {
      params['league'] = leagues.map((l) => l.value).join(',');
    }
    if (names != null) params['name'] = names.join(',');
    if (abbreviations != null) params['abbreviation'] = abbreviations.join(',');

    final response = await _client.get<List<dynamic>>(
      '/teams',
      queryParams: params,
    );

    return response
        .map((t) => Team.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Get sports metadata (leagues, market types, etc.)
  Future<Map<String, dynamic>> getMetadata() async {
    return await _client.get<Map<String, dynamic>>('/sports/metadata');
  }

  /// Get valid sports market types.
  Future<List<String>> getValidMarketTypes() async {
    final response = await _client.get<List<dynamic>>('/sports/market-types');
    return response.cast<String>();
  }
}

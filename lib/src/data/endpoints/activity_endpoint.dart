import '../../core/api_client.dart';
import '../../enums/activity_type.dart';
import '../../enums/sort_direction.dart';
import '../models/activity.dart';

/// Endpoints for on-chain activity.
class ActivityEndpoint {
  final ApiClient _client;

  ActivityEndpoint(this._client);

  /// Get activity for a user.
  ///
  /// [types] - Filter by activity types (TRADE, SPLIT, MERGE, REDEEM, etc.)
  Future<List<Activity>> getUserActivity({
    required String userAddress,
    List<ActivityType>? types,
    SortDirection? sortDirection,
    int? startTs,
    int? endTs,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'user': userAddress,
    };

    if (types != null && types.isNotEmpty) {
      params['type'] = types.map((t) => t.toJson()).join(',');
    }
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (startTs != null) params['startTs'] = startTs.toString();
    if (endTs != null) params['endTs'] = endTs.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/activity',
      queryParams: params,
    );

    return response
        .map((a) => Activity.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  /// Get activity for a specific market.
  Future<List<Activity>> getMarketActivity({
    required String conditionId,
    List<ActivityType>? types,
    SortDirection? sortDirection,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'market': conditionId,
    };

    if (types != null && types.isNotEmpty) {
      params['type'] = types.map((t) => t.toJson()).join(',');
    }
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/activity',
      queryParams: params,
    );

    return response
        .map((a) => Activity.fromJson(a as Map<String, dynamic>))
        .toList();
  }
}

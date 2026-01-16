import '../../core/api_client.dart';
import '../../enums/sort_by.dart';
import '../../enums/sort_direction.dart';
import '../models/position.dart';
import '../models/closed_position.dart';

/// Endpoints for user positions.
class PositionsEndpoint {
  final ApiClient _client;

  PositionsEndpoint(this._client);

  /// Get open positions for a user.
  ///
  /// [userAddress] - Wallet address (proxy wallet)
  /// [sizeThreshold] - Min position size to include
  /// [sortBy] - Sort field
  /// [sortDirection] - Sort direction
  Future<List<Position>> getPositions({
    required String userAddress,
    double? sizeThreshold,
    SortBy? sortBy,
    SortDirection? sortDirection,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'user': userAddress,
    };

    if (sizeThreshold != null) {
      params['sizeThreshold'] = sizeThreshold.toString();
    }
    if (sortBy != null) params['sortBy'] = sortBy.toJson();
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/positions',
      queryParams: params,
    );

    return response
        .map((p) => Position.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Get closed (resolved) positions for a user.
  Future<List<ClosedPosition>> getClosedPositions({
    required String userAddress,
    SortBy? sortBy,
    SortDirection? sortDirection,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'user': userAddress,
    };

    if (sortBy != null) params['sortBy'] = sortBy.toJson();
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/closed-positions',
      queryParams: params,
    );

    return response
        .map((p) => ClosedPosition.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Get positions for a specific market.
  Future<List<Position>> getMarketPositions({
    required String conditionId,
    double? sizeThreshold,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'market': conditionId,
    };

    if (sizeThreshold != null) {
      params['sizeThreshold'] = sizeThreshold.toString();
    }
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/positions',
      queryParams: params,
    );

    return response
        .map((p) => Position.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}

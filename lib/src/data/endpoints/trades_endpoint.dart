import '../../core/api_client.dart';
import '../../enums/sort_by.dart';
import '../../enums/sort_direction.dart';
import '../../enums/filter_type.dart';
import '../models/trade_record.dart';

/// Endpoints for trade history (Data API).
class DataTradesEndpoint {
  final ApiClient _client;

  DataTradesEndpoint(this._client);

  /// Get trades for a user.
  Future<List<TradeRecord>> getUserTrades({
    required String userAddress,
    SortBy? sortBy,
    SortDirection? sortDirection,
    FilterType? filterType,
    double? filterValue,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'user': userAddress,
    };

    if (sortBy != null) params['sortBy'] = sortBy.toJson();
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (filterType != null) params['filterType'] = filterType.toJson();
    if (filterValue != null) params['filterValue'] = filterValue.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/trades',
      queryParams: params,
    );

    return response
        .map((t) => TradeRecord.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Get trades for a specific market.
  Future<List<TradeRecord>> getMarketTrades({
    required String conditionId,
    SortBy? sortBy,
    SortDirection? sortDirection,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'market': conditionId,
    };

    if (sortBy != null) params['sortBy'] = sortBy.toJson();
    if (sortDirection != null) params['sortDir'] = sortDirection.toJson();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/trades',
      queryParams: params,
    );

    return response
        .map((t) => TradeRecord.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}

import '../../core/api_client.dart';
import '../models/clob_market.dart';
import '../models/simplified_market.dart';

/// CLOB market endpoints (different from Gamma markets).
class ClobMarketsEndpoint {
  final ApiClient _client;

  ClobMarketsEndpoint(this._client);

  /// List all CLOB markets with pagination.
  Future<ClobMarketListResponse> listMarkets({
    String? nextCursor,
  }) async {
    final params = <String, String>{};
    if (nextCursor != null) params['next_cursor'] = nextCursor;

    final response = await _client.get<Map<String, dynamic>>(
      '/markets',
      queryParams: params.isNotEmpty ? params : null,
    );

    return ClobMarketListResponse.fromJson(response);
  }

  /// Get a single market by condition ID.
  Future<ClobMarket> getMarket(String conditionId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/markets/$conditionId',
    );
    return ClobMarket.fromJson(response);
  }

  /// Get paginated markets for sampling.
  Future<ClobMarketListResponse> getSamplingMarkets({
    String? nextCursor,
  }) async {
    final params = <String, String>{};
    if (nextCursor != null) params['next_cursor'] = nextCursor;

    final response = await _client.get<Map<String, dynamic>>(
      '/sampling-markets',
      queryParams: params.isNotEmpty ? params : null,
    );

    return ClobMarketListResponse.fromJson(response);
  }

  /// Get simplified markets (reduced data for faster loading).
  Future<SimplifiedMarketListResponse> getSimplifiedMarkets({
    String? nextCursor,
  }) async {
    final params = <String, String>{};
    if (nextCursor != null) params['next_cursor'] = nextCursor;

    final response = await _client.get<Map<String, dynamic>>(
      '/sampling-simplified-markets',
      queryParams: params.isNotEmpty ? params : null,
    );

    return SimplifiedMarketListResponse.fromJson(response);
  }

  /// Get tick size for a token.
  Future<String> getTickSize(String tokenId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/tick-size',
      queryParams: {'token_id': tokenId},
    );
    return response['minimum_tick_size'] as String;
  }

  /// Get fee rate in basis points for a token.
  Future<int> getFeeRateBps(String tokenId) async {
    // Fee info is in market data
    final markets = await listMarkets();
    for (final market in markets.data) {
      for (final token in market.tokens) {
        if (token.tokenId == tokenId) {
          return (market.takerBaseFee * 10000).round();
        }
      }
    }
    return 0; // Default 0% fee
  }

  /// Check if market uses negative risk.
  Future<bool> getNegRisk(String tokenId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/neg-risk',
      queryParams: {'token_id': tokenId},
    );
    return response['neg_risk'] as bool;
  }
}

/// Response wrapper for market list with pagination.
class ClobMarketListResponse {
  final int limit;
  final int count;
  final String? nextCursor;
  final List<ClobMarket> data;

  ClobMarketListResponse({
    required this.limit,
    required this.count,
    this.nextCursor,
    required this.data,
  });

  factory ClobMarketListResponse.fromJson(Map<String, dynamic> json) {
    return ClobMarketListResponse(
      limit: json['limit'] as int,
      count: json['count'] as int,
      nextCursor: json['next_cursor'] as String?,
      data: (json['data'] as List)
          .map((e) => ClobMarket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Response wrapper for simplified market list.
class SimplifiedMarketListResponse {
  final int limit;
  final int count;
  final String? nextCursor;
  final List<SimplifiedMarket> data;

  SimplifiedMarketListResponse({
    required this.limit,
    required this.count,
    this.nextCursor,
    required this.data,
  });

  factory SimplifiedMarketListResponse.fromJson(Map<String, dynamic> json) {
    return SimplifiedMarketListResponse(
      limit: json['limit'] as int,
      count: json['count'] as int,
      nextCursor: json['next_cursor'] as String?,
      data: (json['data'] as List)
          .map((e) => SimplifiedMarket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

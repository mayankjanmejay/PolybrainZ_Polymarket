import '../../core/api_client.dart';
import '../models/holder.dart';

/// Endpoints for token holders.
class HoldersEndpoint {
  final ApiClient _client;

  HoldersEndpoint(this._client);

  /// Get holders of a specific token.
  Future<List<Holder>> getTokenHolders({
    required String tokenId,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'token': tokenId,
    };

    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/holders',
      queryParams: params,
    );

    return response
        .map((h) => Holder.fromJson(h as Map<String, dynamic>))
        .toList();
  }

  /// Get holders for a market (both outcomes).
  Future<List<Holder>> getMarketHolders({
    required String conditionId,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'market': conditionId,
    };

    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    final response = await _client.get<List<dynamic>>(
      '/holders',
      queryParams: params,
    );

    return response
        .map((h) => Holder.fromJson(h as Map<String, dynamic>))
        .toList();
  }
}

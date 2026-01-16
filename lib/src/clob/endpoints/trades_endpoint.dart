import '../../core/api_client.dart';
import '../../auth/auth_service.dart';
import '../models/trade.dart';

/// Trade history endpoints.
class ClobTradesEndpoint {
  final ApiClient _client;
  final AuthService? _auth;

  ClobTradesEndpoint(this._client, this._auth);

  /// Get trades (public or authenticated).
  ///
  /// If authenticated, returns your trades.
  /// Otherwise, returns market trades.
  Future<List<Trade>> getTrades({
    String? id,
    String? makerAddress,
    String? market,
    String? assetId,
    String? before,
    String? after,
  }) async {
    final params = <String, String>{};
    if (id != null) params['id'] = id;
    if (makerAddress != null) params['maker_address'] = makerAddress;
    if (market != null) params['market'] = market;
    if (assetId != null) params['asset_id'] = assetId;
    if (before != null) params['before'] = before;
    if (after != null) params['after'] = after;

    Map<String, String>? headers;
    if (_auth?.hasCredentials ?? false) {
      final path =
          '/trades${params.isNotEmpty ? '?${_encodeParams(params)}' : ''}';
      headers = _auth!.getAuthHeaders(
        method: 'GET',
        path: path,
      );
    }

    final response = await _client.get<List<dynamic>>(
      '/trades',
      queryParams: params.isNotEmpty ? params : null,
      headers: headers,
    );

    return response.map((t) => Trade.fromJson(t as Map<String, dynamic>)).toList();
  }

  String _encodeParams(Map<String, String> params) {
    return params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

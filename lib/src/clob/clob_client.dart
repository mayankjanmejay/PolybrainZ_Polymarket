import '../core/api_client.dart';
import '../core/constants.dart';
import '../auth/auth_service.dart';
import '../auth/models/api_credentials.dart';
import 'endpoints/markets_endpoint.dart';
import 'endpoints/orderbook_endpoint.dart';
import 'endpoints/pricing_endpoint.dart';
import 'endpoints/orders_endpoint.dart';
import 'endpoints/trades_endpoint.dart';

/// Client for the CLOB API (order book and trading).
class ClobClient {
  final ApiClient _client;
  final AuthService? _auth;

  late final ClobMarketsEndpoint markets;
  late final OrderbookEndpoint orderbook;
  late final PricingEndpoint pricing;
  late final OrdersEndpoint orders;
  late final ClobTradesEndpoint trades;

  ClobClient({
    String? baseUrl,
    ApiClient? client,
    ApiCredentials? credentials,
    String? privateKey,
    String? walletAddress,
    int chainId = PolymarketConstants.polygonChainId,
  })  : _client = client ??
            ApiClient(
              baseUrl: baseUrl ?? PolymarketConstants.clobBaseUrl,
            ),
        _auth = walletAddress != null
            ? AuthService(
                client: client ??
                    ApiClient(
                      baseUrl: baseUrl ?? PolymarketConstants.clobBaseUrl,
                    ),
                walletAddress: walletAddress,
                privateKey: privateKey,
                chainId: chainId,
              )
            : null {
    // Set credentials if provided
    if (_auth != null && credentials != null) {
      _auth.setCredentials(credentials);
    }

    markets = ClobMarketsEndpoint(_client);
    orderbook = OrderbookEndpoint(_client);
    pricing = PricingEndpoint(_client);
    orders = OrdersEndpoint(_client, _auth);
    trades = ClobTradesEndpoint(_client, _auth);
  }

  /// Get auth service for managing credentials.
  AuthService? get auth => _auth;

  /// Check if we have valid credentials for authenticated requests.
  bool get isAuthenticated => _auth?.hasCredentials ?? false;

  /// Health check.
  Future<bool> isHealthy() async {
    try {
      await _client.get<dynamic>('/');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get server time.
  Future<int> getServerTime() async {
    final response = await _client.get<Map<String, dynamic>>('/time');
    return response['timestamp'] as int;
  }

  void close() => _client.close();
}

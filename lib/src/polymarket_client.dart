import 'auth/models/api_credentials.dart';
import 'auth/auth_service.dart';
import 'core/constants.dart';
import 'gamma/gamma_client.dart';
import 'clob/clob_client.dart';
import 'data/data_client.dart';
import 'websocket/clob_websocket.dart';
import 'websocket/rtds_websocket.dart';

/// Main client for accessing all Polymarket APIs.
///
/// Use [PolymarketClient.public] for unauthenticated access to market data.
/// Use [PolymarketClient.authenticated] for trading operations.
class PolymarketClient {
  /// Client for Gamma API (market discovery, events, tags).
  final GammaClient gamma;

  /// Client for CLOB API (orderbook, pricing, orders).
  final ClobClient clob;

  /// Client for Data API (positions, trades, activity).
  final DataClient data;

  /// WebSocket client for real-time CLOB data.
  final ClobWebSocket clobWebSocket;

  /// WebSocket client for RTDS (crypto prices, comments).
  final RtdsWebSocket rtdsWebSocket;

  PolymarketClient._({
    required this.gamma,
    required this.clob,
    required this.data,
    required this.clobWebSocket,
    required this.rtdsWebSocket,
  });

  /// Create a public client with no authentication.
  ///
  /// Use this for:
  /// - Browsing markets and events
  /// - Reading orderbooks and prices
  /// - Getting user positions and trade history
  /// - Subscribing to real-time market data
  factory PolymarketClient.public({
    String? gammaBaseUrl,
    String? clobBaseUrl,
    String? dataBaseUrl,
    String? clobWssUrl,
    String? rtdsWssUrl,
  }) {
    return PolymarketClient._(
      gamma: GammaClient(baseUrl: gammaBaseUrl),
      clob: ClobClient(baseUrl: clobBaseUrl),
      data: DataClient(baseUrl: dataBaseUrl),
      clobWebSocket: ClobWebSocket(url: clobWssUrl),
      rtdsWebSocket: RtdsWebSocket(url: rtdsWssUrl),
    );
  }

  /// Create an authenticated client for trading.
  ///
  /// [credentials] - API credentials (key, secret, passphrase)
  /// [funder] - Your funded wallet address (proxy wallet)
  /// [privateKey] - Optional private key for L1 auth (creating new API keys)
  /// [chainId] - Polygon chain ID (default: 137)
  factory PolymarketClient.authenticated({
    required ApiCredentials credentials,
    required String funder,
    String? privateKey,
    int chainId = PolymarketConstants.polygonChainId,
    String? gammaBaseUrl,
    String? clobBaseUrl,
    String? dataBaseUrl,
    String? clobWssUrl,
    String? rtdsWssUrl,
  }) {
    final clobClient = ClobClient(
      baseUrl: clobBaseUrl,
      credentials: credentials,
      walletAddress: funder,
      privateKey: privateKey,
      chainId: chainId,
    );

    return PolymarketClient._(
      gamma: GammaClient(baseUrl: gammaBaseUrl),
      clob: clobClient,
      data: DataClient(baseUrl: dataBaseUrl),
      clobWebSocket: ClobWebSocket(
        url: clobWssUrl,
        auth: clobClient.auth,
      ),
      rtdsWebSocket: RtdsWebSocket(url: rtdsWssUrl),
    );
  }

  /// Create a client with a private key for deriving API credentials.
  ///
  /// After creation, call [clob.auth.createOrDeriveApiKey()] to get credentials.
  factory PolymarketClient.withPrivateKey({
    required String privateKey,
    required String walletAddress,
    int chainId = PolymarketConstants.polygonChainId,
    String? gammaBaseUrl,
    String? clobBaseUrl,
    String? dataBaseUrl,
    String? clobWssUrl,
    String? rtdsWssUrl,
  }) {
    final clobClient = ClobClient(
      baseUrl: clobBaseUrl,
      walletAddress: walletAddress,
      privateKey: privateKey,
      chainId: chainId,
    );

    return PolymarketClient._(
      gamma: GammaClient(baseUrl: gammaBaseUrl),
      clob: clobClient,
      data: DataClient(baseUrl: dataBaseUrl),
      clobWebSocket: ClobWebSocket(
        url: clobWssUrl,
        auth: clobClient.auth,
      ),
      rtdsWebSocket: RtdsWebSocket(url: rtdsWssUrl),
    );
  }

  /// Get the authentication service for the CLOB client.
  ///
  /// Use this to manage API credentials:
  /// - [auth.setCredentials()] - Set existing credentials
  /// - [auth.createOrDeriveApiKey()] - Create or derive credentials from private key
  /// - [auth.deleteApiKey()] - Delete current API key
  AuthService? get auth => clob.auth;

  /// Whether the client has valid authentication credentials.
  bool get isAuthenticated => clob.isAuthenticated;

  /// Close all connections and release resources.
  void close() {
    gamma.close();
    clob.close();
    data.close();
    clobWebSocket.dispose();
    rtdsWebSocket.dispose();
  }
}

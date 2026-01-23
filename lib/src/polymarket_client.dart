import 'package:web3dart/web3dart.dart';

import 'auth/models/api_credentials.dart';
import 'auth/auth_service.dart';
import 'core/constants.dart';
import 'core/exceptions.dart';
import 'enums/order_side.dart';
import 'enums/order_type.dart';
import 'gamma/gamma_client.dart';
import 'clob/clob_client.dart';
import 'clob/orders/order_builder.dart';
import 'clob/models/signed_order.dart';
import 'clob/models/order_response.dart';
import 'clob/signing/eip712_signer.dart';
import 'data/data_client.dart';
import 'wallet/polygon_client.dart';
import 'websocket/clob_websocket.dart';
import 'websocket/rtds_websocket.dart';

/// Main client for accessing all Polymarket APIs.
///
/// Use [PolymarketClient.public] for unauthenticated access to market data.
/// Use [PolymarketClient.authenticated] for trading operations.
/// Use [PolymarketClient.withTrading] for full trading with order signing and blockchain operations.
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

  /// Polygon client for blockchain operations (only available with withTrading).
  PolygonClient? _polygon;

  /// Private key for signing (only available with withTrading).
  String? _privateKey;

  /// Wallet address for trading.
  String? _walletAddress;

  PolymarketClient._({
    required this.gamma,
    required this.clob,
    required this.data,
    required this.clobWebSocket,
    required this.rtdsWebSocket,
    PolygonClient? polygon,
    String? privateKey,
    String? walletAddress,
  })  : _polygon = polygon,
        _privateKey = privateKey,
        _walletAddress = walletAddress;

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
      privateKey: privateKey,
      walletAddress: walletAddress,
    );
  }

  /// Create a trading-enabled client with full capabilities.
  ///
  /// This factory creates a client with:
  /// - Order signing and submission
  /// - Polygon blockchain operations (USDC balance, approvals)
  /// - All authenticated CLOB operations
  ///
  /// [credentials] - API credentials (key, secret, passphrase)
  /// [walletAddress] - Your funded wallet address
  /// [privateKey] - Private key for signing orders
  /// [polygonRpcUrl] - Optional custom Polygon RPC URL
  factory PolymarketClient.withTrading({
    required ApiCredentials credentials,
    required String walletAddress,
    required String privateKey,
    String? polygonRpcUrl,
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
      walletAddress: walletAddress,
      privateKey: privateKey,
      chainId: chainId,
    );

    final polygon = PolygonClient(
      rpcUrl: polygonRpcUrl,
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
      polygon: polygon,
      privateKey: privateKey,
      walletAddress: walletAddress,
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

  /// Get the Polygon client for blockchain operations.
  ///
  /// Only available when using [PolymarketClient.withTrading].
  /// Throws [AuthenticationException] if not available.
  PolygonClient get polygon {
    if (_polygon == null) {
      throw const AuthenticationException(
        'Polygon client not available. Use PolymarketClient.withTrading() to enable blockchain operations.',
      );
    }
    return _polygon!;
  }

  /// Whether trading capabilities are enabled.
  bool get hasTradingCapabilities => _polygon != null && _privateKey != null;

  /// Build and sign an order.
  ///
  /// [tokenId] - The conditional token ID to trade
  /// [side] - Buy or sell
  /// [size] - Number of shares
  /// [price] - Limit price (0.01 - 0.99)
  /// [negRisk] - Whether this is a negative risk market
  /// [expiration] - Optional order expiration duration
  ///
  /// Returns a [SignedOrder] ready for submission.
  SignedOrder buildSignedOrder({
    required String tokenId,
    required OrderSide side,
    required double size,
    required double price,
    bool negRisk = false,
    Duration? expiration,
  }) {
    if (_privateKey == null || _walletAddress == null) {
      throw const AuthenticationException(
        'Private key required. Use PolymarketClient.withTrading() constructor.',
      );
    }

    // Build order
    final order = OrderBuilder.buildLimitOrder(
      tokenId: tokenId,
      makerAddress: _walletAddress!,
      side: side,
      size: size,
      price: price,
      expiration: expiration,
    );

    // Determine verifying contract based on risk type
    final verifyingContract = negRisk
        ? PolymarketConstants.negRiskExchangeAddress
        : PolymarketConstants.exchangeAddress;

    // Sign order
    final signature = EIP712Signer.signOrder(
      order: order.toTypedDataMessage(),
      credentials: EthPrivateKey.fromHex(_privateKey!),
      verifyingContract: verifyingContract,
    );

    return SignedOrder(order: order, signature: signature);
  }

  /// Place an order (convenience method).
  ///
  /// Builds, signs, and submits an order in one call.
  ///
  /// [tokenId] - The conditional token ID to trade
  /// [side] - Buy or sell
  /// [size] - Number of shares
  /// [price] - Limit price (0.01 - 0.99)
  /// [negRisk] - Whether this is a negative risk market
  /// [orderType] - Order type (GTC, GTD, FOK, FAK)
  /// [postOnly] - If true, order will only be placed if it doesn't immediately match
  ///
  /// Returns the [OrderResponse] from the CLOB API.
  Future<OrderResponse> placeOrder({
    required String tokenId,
    required OrderSide side,
    required double size,
    required double price,
    bool negRisk = false,
    OrderType orderType = OrderType.gtc,
    bool postOnly = false,
  }) async {
    final signedOrder = buildSignedOrder(
      tokenId: tokenId,
      side: side,
      size: size,
      price: price,
      negRisk: negRisk,
    );

    return clob.orders.postOrder(
      signedOrder.toJson(),
      orderType: orderType,
      postOnly: postOnly,
    );
  }

  /// Close all connections and release resources.
  void close() {
    gamma.close();
    clob.close();
    data.close();
    clobWebSocket.dispose();
    rtdsWebSocket.dispose();
    _polygon?.dispose();
  }
}

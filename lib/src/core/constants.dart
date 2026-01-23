/// Base URLs and constants for Polymarket APIs.
class PolymarketConstants {
  PolymarketConstants._();

  // ============ API Base URLs ============

  /// Gamma API - Market discovery and metadata
  static const String gammaBaseUrl = 'https://gamma-api.polymarket.com';

  /// CLOB API - Order book and trading
  static const String clobBaseUrl = 'https://clob.polymarket.com';

  /// Data API - Positions, trades, activity
  static const String dataBaseUrl = 'https://data-api.polymarket.com';

  // ============ WebSocket URLs ============

  /// CLOB WebSocket - Order book updates, user orders
  static const String clobWssUrl =
      'wss://ws-subscriptions-clob.polymarket.com/ws/';

  /// RTDS WebSocket - Crypto prices, comments
  static const String rtdsWssUrl = 'wss://ws-live-data.polymarket.com';

  /// Sports WebSocket - Live game updates
  static const String sportsWssUrl = 'wss://sports-api.polymarket.com/ws';

  // ============ Chain Configuration ============

  /// Polygon mainnet chain ID
  static const int polygonChainId = 137;

  /// Exchange contract address
  static const String exchangeAddress =
      '0x4bFb41d5B3570DeFd03C39a9A4D8dE6Bd8B8982E';

  /// Neg Risk Exchange contract address
  static const String negRiskExchangeAddress =
      '0xC5d563A36AE78145C45a50134d48A1215220f80a';

  /// Neg Risk Adapter contract address
  static const String negRiskAdapterAddress =
      '0xd91E80cF2E7be2e162c6513ceD06f1dD0dA35296';

  /// Conditional Tokens Framework contract address
  static const String conditionalTokensAddress =
      '0x4D97DCd97eC945f40cF65F87097ACe5EA0476045';

  /// USDC Token contract address on Polygon
  static const String usdcAddress =
      '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174';

  // ============ RPC URLs ============

  /// Default Polygon RPC URL
  static const String polygonRpcUrl = 'https://polygon-rpc.com';

  /// Alternative Polygon RPC URLs for fallback
  static const List<String> alternativeRpcUrls = [
    'https://rpc-mainnet.matic.network',
    'https://matic-mainnet.chainstacklabs.com',
    'https://rpc-mainnet.maticvigil.com',
    'https://polygon.llamarpc.com',
  ];

  // ============ EIP-712 Constants ============

  /// Domain name for EIP-712 order signing
  static const String eip712DomainName = 'Polymarket CTF Exchange';

  /// Domain version for EIP-712 order signing
  static const String eip712DomainVersion = '1';

  // ============ API Defaults ============

  /// Default timeout for HTTP requests
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Default max retries for failed requests
  static const int defaultMaxRetries = 3;

  /// Default page size for paginated requests
  static const int defaultPageSize = 100;

  /// Max page size for paginated requests
  static const int maxPageSize = 500;

  // ============ WebSocket Defaults ============

  /// Heartbeat interval for WebSocket connections
  static const Duration wsHeartbeatInterval = Duration(seconds: 30);

  /// Reconnect delay after disconnect
  static const Duration wsReconnectDelay = Duration(seconds: 5);

  /// Max reconnect attempts
  static const int wsMaxReconnectAttempts = 10;

  // ============ Auth Header Names ============

  static const String headerPolyAddress = 'POLY_ADDRESS';
  static const String headerPolySignature = 'POLY_SIGNATURE';
  static const String headerPolyTimestamp = 'POLY_TIMESTAMP';
  static const String headerPolyNonce = 'POLY_NONCE';
  static const String headerPolyApiKey = 'POLY_API_KEY';
  static const String headerPolyPassphrase = 'POLY_PASSPHRASE';
}

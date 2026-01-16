# CLOB API

Order book and trading API. Partial authentication required.

---

## Base URL

```
https://clob.polymarket.com
```

---

## Authentication Requirements

| Endpoint Type | Auth Required |
|---------------|---------------|
| Public (markets, orderbooks, prices) | No |
| L1 (create/derive API keys) | Yes (private key) |
| L2 (orders, trades) | Yes (API credentials) |
| Builder | Yes (builder credentials) |

---

## src/clob/clob_client.dart

```dart
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
  }) : _client = client ?? ApiClient(
         baseUrl: baseUrl ?? PolymarketConstants.clobBaseUrl,
       ),
       _auth = walletAddress != null 
           ? AuthService(
               client: client ?? ApiClient(
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
```

---

## src/clob/endpoints/markets_endpoint.dart

```dart
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
```

---

## src/clob/endpoints/orderbook_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../models/order_book.dart';

/// Orderbook endpoints (public, no auth).
class OrderbookEndpoint {
  final ApiClient _client;

  OrderbookEndpoint(this._client);

  /// Get order book for a token.
  Future<OrderBook> getOrderBook(String tokenId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/book',
      queryParams: {'token_id': tokenId},
    );
    return OrderBook.fromJson(response);
  }

  /// Get order books for multiple tokens.
  Future<List<OrderBook>> getOrderBooks(List<String> tokenIds) async {
    final response = await _client.get<List<dynamic>>(
      '/books',
      queryParams: {'token_ids': tokenIds.join(',')},
    );
    return response
        .map((b) => OrderBook.fromJson(b as Map<String, dynamic>))
        .toList();
  }
}
```

---

## src/clob/endpoints/pricing_endpoint.dart

```dart
import '../../core/api_client.dart';
import '../../enums/order_side.dart';

/// Pricing endpoints (public, no auth).
class PricingEndpoint {
  final ApiClient _client;

  PricingEndpoint(this._client);

  /// Get best price for a token and side.
  Future<double> getPrice(String tokenId, OrderSide side) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/price',
      queryParams: {
        'token_id': tokenId,
        'side': side.toJson(),
      },
    );
    return double.parse(response['price'] as String);
  }

  /// Get prices for multiple tokens.
  Future<Map<String, double>> getPrices(
    List<String> tokenIds,
    OrderSide side,
  ) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/prices',
      queryParams: {
        'token_ids': tokenIds.join(','),
        'side': side.toJson(),
      },
    );
    
    return response.map((key, value) => 
        MapEntry(key, double.parse(value['price'] as String)));
  }

  /// Get midpoint price for a token.
  Future<double> getMidpoint(String tokenId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/midpoint',
      queryParams: {'token_id': tokenId},
    );
    return double.parse(response['mid'] as String);
  }

  /// Get midpoints for multiple tokens.
  Future<Map<String, double>> getMidpoints(List<String> tokenIds) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/midpoints',
      queryParams: {'token_ids': tokenIds.join(',')},
    );
    
    return response.map((key, value) => 
        MapEntry(key, double.parse(value['mid'] as String)));
  }

  /// Get spread for a token.
  Future<double> getSpread(String tokenId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/spread',
      queryParams: {'token_id': tokenId},
    );
    return double.parse(response['spread'] as String);
  }

  /// Get spreads for multiple tokens.
  Future<Map<String, double>> getSpreads(List<String> tokenIds) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/spreads',
      queryParams: {'token_ids': tokenIds.join(',')},
    );
    
    return response.map((key, value) => 
        MapEntry(key, double.parse(value['spread'] as String)));
  }

  /// Get last trade price for a token.
  Future<LastTradePrice> getLastTradePrice(String tokenId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/last-trade-price',
      queryParams: {'token_id': tokenId},
    );
    return LastTradePrice.fromJson(response);
  }

  /// Get price history for a token.
  /// 
  /// [interval] - Time interval (e.g., '1m', '5m', '1h', '1d')
  /// [fidelity] - Data fidelity (higher = more points)
  Future<List<PriceHistoryPoint>> getPriceHistory(
    String tokenId, {
    String interval = 'max',
    int fidelity = 100,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/prices-history',
      queryParams: {
        'token_id': tokenId,
        'interval': interval,
        'fidelity': fidelity.toString(),
      },
    );
    
    final history = response['history'] as List;
    return history
        .map((h) => PriceHistoryPoint.fromJson(h as Map<String, dynamic>))
        .toList();
  }
}

/// Last trade price response.
class LastTradePrice {
  final String price;
  final String side;
  final String size;
  final String feeRateBps;
  final String timestamp;

  LastTradePrice({
    required this.price,
    required this.side,
    required this.size,
    required this.feeRateBps,
    required this.timestamp,
  });

  factory LastTradePrice.fromJson(Map<String, dynamic> json) {
    return LastTradePrice(
      price: json['price'] as String,
      side: json['side'] as String,
      size: json['size'] as String,
      feeRateBps: json['fee_rate_bps'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  double get priceNum => double.parse(price);
}

/// Price history data point.
class PriceHistoryPoint {
  final int t; // timestamp
  final double p; // price

  PriceHistoryPoint({required this.t, required this.p});

  factory PriceHistoryPoint.fromJson(Map<String, dynamic> json) {
    return PriceHistoryPoint(
      t: json['t'] as int,
      p: (json['p'] as num).toDouble(),
    );
  }

  DateTime get timestamp => DateTime.fromMillisecondsSinceEpoch(t * 1000);
}
```

---

## src/clob/endpoints/orders_endpoint.dart

```dart
import 'dart:convert';

import '../../core/api_client.dart';
import '../../core/exceptions.dart';
import '../../auth/auth_service.dart';
import '../../enums/order_type.dart';
import '../models/order.dart';
import '../models/order_response.dart';

/// Order management endpoints (L2 auth required).
class OrdersEndpoint {
  final ApiClient _client;
  final AuthService? _auth;

  OrdersEndpoint(this._client, this._auth);

  /// Post a signed order.
  /// 
  /// [signedOrder] - The signed order from createOrder()
  /// [orderType] - Order type (GTC, GTD, FOK, FAK)
  /// [postOnly] - If true, order will only be placed if it doesn't immediately match
  Future<OrderResponse> postOrder(
    Map<String, dynamic> signedOrder, {
    OrderType orderType = OrderType.gtc,
    bool postOnly = false,
  }) async {
    _requireAuth();

    final body = {
      'order': signedOrder,
      'orderType': orderType.toJson(),
      if (postOnly) 'postOnly': true,
    };

    final bodyJson = jsonEncode(body);
    
    final response = await _client.post<Map<String, dynamic>>(
      '/order',
      body: body,
      headers: _auth!.getAuthHeaders(
        method: 'POST',
        path: '/order',
        body: bodyJson,
      ),
    );

    return OrderResponse.fromJson(response);
  }

  /// Post multiple orders in a batch (up to 15).
  Future<List<OrderResponse>> postOrders(
    List<Map<String, dynamic>> signedOrders, {
    List<OrderType>? orderTypes,
    List<bool>? postOnlyFlags,
  }) async {
    _requireAuth();

    if (signedOrders.length > 15) {
      throw const ValidationException('Maximum 15 orders per batch');
    }

    final body = signedOrders.asMap().entries.map((entry) {
      return {
        'order': entry.value,
        'orderType': orderTypes?[entry.key]?.toJson() ?? 'GTC',
        if (postOnlyFlags?[entry.key] ?? false) 'postOnly': true,
      };
    }).toList();

    final bodyJson = jsonEncode(body);

    final response = await _client.post<List<dynamic>>(
      '/orders',
      body: body,
      headers: _auth!.getAuthHeaders(
        method: 'POST',
        path: '/orders',
        body: bodyJson,
      ),
    );

    return response
        .map((r) => OrderResponse.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific order by ID.
  Future<Order> getOrder(String orderId) async {
    _requireAuth();

    final response = await _client.get<Map<String, dynamic>>(
      '/order/$orderId',
      headers: _auth!.getAuthHeaders(
        method: 'GET',
        path: '/order/$orderId',
      ),
    );

    return Order.fromJson(response);
  }

  /// Get all open orders.
  Future<List<Order>> getOpenOrders({
    String? market,
    String? assetId,
  }) async {
    _requireAuth();

    final params = <String, String>{};
    if (market != null) params['market'] = market;
    if (assetId != null) params['asset_id'] = assetId;

    final path = '/orders${params.isNotEmpty ? '?${_encodeParams(params)}' : ''}';

    final response = await _client.get<List<dynamic>>(
      '/orders',
      queryParams: params.isNotEmpty ? params : null,
      headers: _auth!.getAuthHeaders(
        method: 'GET',
        path: path,
      ),
    );

    return response
        .map((o) => Order.fromJson(o as Map<String, dynamic>))
        .toList();
  }

  /// Cancel an order.
  Future<void> cancelOrder(String orderId) async {
    _requireAuth();

    final body = {'orderID': orderId};
    final bodyJson = jsonEncode(body);

    await _client.delete<void>(
      '/order',
      body: body,
      headers: _auth!.getAuthHeaders(
        method: 'DELETE',
        path: '/order',
        body: bodyJson,
      ),
    );
  }

  /// Cancel multiple orders.
  Future<void> cancelOrders(List<String> orderIds) async {
    _requireAuth();

    final body = orderIds.map((id) => {'orderID': id}).toList();
    final bodyJson = jsonEncode(body);

    await _client.delete<void>(
      '/orders',
      body: body,
      headers: _auth!.getAuthHeaders(
        method: 'DELETE',
        path: '/orders',
        body: bodyJson,
      ),
    );
  }

  /// Cancel all open orders.
  Future<void> cancelAllOrders() async {
    _requireAuth();

    await _client.delete<void>(
      '/cancel-all',
      headers: _auth!.getAuthHeaders(
        method: 'DELETE',
        path: '/cancel-all',
      ),
    );
  }

  /// Cancel all orders for a specific market.
  Future<void> cancelMarketOrders(String market) async {
    _requireAuth();

    final body = {'market': market};
    final bodyJson = jsonEncode(body);

    await _client.delete<void>(
      '/cancel-market-orders',
      body: body,
      headers: _auth!.getAuthHeaders(
        method: 'DELETE',
        path: '/cancel-market-orders',
        body: bodyJson,
      ),
    );
  }

  /// Check if orders are scoring rewards.
  Future<Map<String, bool>> areOrdersScoringRewards(List<String> orderIds) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/orders-scoring',
      queryParams: {'order_ids': orderIds.join(',')},
    );

    return response.map((key, value) => MapEntry(key, value as bool));
  }

  void _requireAuth() {
    if (_auth == null || !_auth.hasCredentials) {
      throw const AuthenticationException(
        'Authentication required. Call setCredentials() first.',
      );
    }
  }

  String _encodeParams(Map<String, String> params) {
    return params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
```

---

## src/clob/endpoints/trades_endpoint.dart

```dart
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
      final path = '/trades${params.isNotEmpty ? '?${_encodeParams(params)}' : ''}';
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

    return response
        .map((t) => Trade.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  String _encodeParams(Map<String, String> params) {
    return params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
```

---

## src/clob/models/simplified_market.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'clob_token.dart';
import 'clob_rewards.dart';

part 'simplified_market.g.dart';

/// Simplified market data for faster loading.
@JsonSerializable(fieldRename: FieldRename.snake)
class SimplifiedMarket extends Equatable {
  final String conditionId;
  
  @JsonKey(defaultValue: false)
  final bool acceptingOrders;
  
  @JsonKey(defaultValue: false)
  final bool active;
  
  @JsonKey(defaultValue: false)
  final bool archived;
  
  @JsonKey(defaultValue: false)
  final bool closed;
  
  final ClobRewards? rewards;
  final List<SimplifiedToken> tokens;

  const SimplifiedMarket({
    required this.conditionId,
    this.acceptingOrders = false,
    this.active = false,
    this.archived = false,
    this.closed = false,
    this.rewards,
    required this.tokens,
  });

  factory SimplifiedMarket.fromJson(Map<String, dynamic> json) => 
      _$SimplifiedMarketFromJson(json);
  Map<String, dynamic> toJson() => _$SimplifiedMarketToJson(this);

  @override
  List<Object?> get props => [conditionId];
}

/// Simplified token data.
@JsonSerializable(fieldRename: FieldRename.snake)
class SimplifiedToken extends Equatable {
  final String outcome;
  final double price;
  final String tokenId;

  const SimplifiedToken({
    required this.outcome,
    required this.price,
    required this.tokenId,
  });

  factory SimplifiedToken.fromJson(Map<String, dynamic> json) => 
      _$SimplifiedTokenFromJson(json);
  Map<String, dynamic> toJson() => _$SimplifiedTokenToJson(this);

  @override
  List<Object?> get props => [tokenId];
}
```

---

## src/clob/models/trade.dart

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trade.g.dart';

/// A trade from the CLOB.
@JsonSerializable(fieldRename: FieldRename.snake)
class Trade extends Equatable {
  final String id;
  final String takerOrderId;
  final String market;
  final String assetId;
  final String side;
  final String size;
  final String price;
  final String status;
  final String matchTime;
  final String lastUpdate;
  final String outcome;
  final String? owner;
  final String? tradeOwner;
  final String? type;
  final String? feeRateBps;
  final List<MakerOrder>? makerOrders;
  final String? transactionHash;
  final String? bucketIndex;

  const Trade({
    required this.id,
    required this.takerOrderId,
    required this.market,
    required this.assetId,
    required this.side,
    required this.size,
    required this.price,
    required this.status,
    required this.matchTime,
    required this.lastUpdate,
    required this.outcome,
    this.owner,
    this.tradeOwner,
    this.type,
    this.feeRateBps,
    this.makerOrders,
    this.transactionHash,
    this.bucketIndex,
  });

  factory Trade.fromJson(Map<String, dynamic> json) => _$TradeFromJson(json);
  Map<String, dynamic> toJson() => _$TradeToJson(this);

  double get priceNum => double.tryParse(price) ?? 0.0;
  double get sizeNum => double.tryParse(size) ?? 0.0;

  @override
  List<Object?> get props => [id, market, assetId];
}

/// Maker order in a trade.
@JsonSerializable(fieldRename: FieldRename.snake)
class MakerOrder extends Equatable {
  final String orderId;
  final String assetId;
  final String matchedAmount;
  final String price;
  final String outcome;
  final String owner;

  const MakerOrder({
    required this.orderId,
    required this.assetId,
    required this.matchedAmount,
    required this.price,
    required this.outcome,
    required this.owner,
  });

  factory MakerOrder.fromJson(Map<String, dynamic> json) => 
      _$MakerOrderFromJson(json);
  Map<String, dynamic> toJson() => _$MakerOrderToJson(this);

  @override
  List<Object?> get props => [orderId, assetId];
}
```

---

## Barrel Export

### src/clob/clob.dart

```dart
export 'clob_client.dart';
export 'endpoints/markets_endpoint.dart';
export 'endpoints/orderbook_endpoint.dart';
export 'endpoints/pricing_endpoint.dart';
export 'endpoints/orders_endpoint.dart';
export 'endpoints/trades_endpoint.dart';
export 'models/models.dart';
```

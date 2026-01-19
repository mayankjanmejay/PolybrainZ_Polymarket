import '../../core/api_client.dart';
import '../../enums/order_side.dart';
import '../../enums/price_history_interval.dart';

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

    return response.map(
        (key, value) => MapEntry(key, double.parse(value['price'] as String)));
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

    return response
        .map((key, value) => MapEntry(key, double.parse(value['mid'] as String)));
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

    return response.map(
        (key, value) => MapEntry(key, double.parse(value['spread'] as String)));
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
  /// [interval] - Time interval (1m, 5m, 15m, 30m, 1h, 4h, 6h, 12h, 1d, 1w, max)
  /// [fidelity] - Data fidelity (higher = more points)
  Future<List<PriceHistoryPoint>> getPriceHistory(
    String tokenId, {
    PriceHistoryInterval interval = PriceHistoryInterval.max,
    int fidelity = 100,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/prices-history',
      queryParams: {
        'token_id': tokenId,
        'interval': interval.value,
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

  /// Get side as type-safe [OrderSide] enum.
  OrderSide get sideEnum => OrderSide.fromJson(side);
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

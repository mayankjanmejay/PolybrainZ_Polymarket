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

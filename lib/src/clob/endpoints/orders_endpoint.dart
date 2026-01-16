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
        'orderType': orderTypes?[entry.key].toJson() ?? 'GTC',
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

    final path =
        '/orders${params.isNotEmpty ? '?${_encodeParams(params)}' : ''}';

    final response = await _client.get<List<dynamic>>(
      '/orders',
      queryParams: params.isNotEmpty ? params : null,
      headers: _auth!.getAuthHeaders(
        method: 'GET',
        path: path,
      ),
    );

    return response.map((o) => Order.fromJson(o as Map<String, dynamic>)).toList();
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
  Future<Map<String, bool>> areOrdersScoringRewards(
      List<String> orderIds) async {
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

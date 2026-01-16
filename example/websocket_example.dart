// WebSocket streaming example for polybrainz_polymarket
//
// This example demonstrates how to use WebSocket connections
// for real-time market data and price updates.

import 'dart:async';
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  final client = PolymarketClient.public();

  print('=== Polymarket WebSocket Example ===\n');

  // Example 1: CLOB WebSocket - Real-time order book and prices
  await clobWebSocketExample(client);

  // Example 2: RTDS WebSocket - Crypto prices
  await rtdsWebSocketExample(client);

  // Clean up
  client.close();
}

/// Example: CLOB WebSocket for order book and price updates
Future<void> clobWebSocketExample(PolymarketClient client) async {
  print('--- CLOB WebSocket Example ---\n');

  try {
    // Connect to WebSocket
    print('Connecting to CLOB WebSocket...');
    await client.clobWebSocket.connect();
    print('Connected!\n');

    // Listen for connection state changes
    client.clobWebSocket.connectionState.listen((state) {
      print('Connection state: $state');
    });

    // Subscribe to order book updates for specific tokens
    // Replace with actual token IDs from Polymarket
    final tokenIds = [
      '71321045679252212594626385532706912750332728571942532289631379312455583992563',
    ];

    print('Subscribing to market data for ${tokenIds.length} token(s)...\n');
    client.clobWebSocket.subscribeToMarket(tokenIds);

    // Listen for order book updates
    final bookSubscription = client.clobWebSocket.bookUpdates.listen((book) {
      print('Order Book Update:');
      print('  Asset: ${book.assetId}');
      print('  Best Bid: ${book.bestBid}');
      print('  Best Ask: ${book.bestAsk}');
      print('  Spread: ${book.spread}');
      print('  Bids: ${book.bids.length}, Asks: ${book.asks.length}');
      print('');
    });

    // Listen for price changes
    final priceSubscription = client.clobWebSocket.priceChanges.listen((msg) {
      print('Price Change:');
      for (final change in msg.priceChanges) {
        print('  ${change.assetId}: ${change.price}');
      }
      print('');
    });

    // Listen for last trade prices
    final tradeSubscription =
        client.clobWebSocket.lastTradePrices.listen((msg) {
      print('Last Trade Price:');
      print('  Asset: ${msg.assetId}');
      print('  Price: ${msg.price}');
      print('  Side: ${msg.side}');
      print('  Size: ${msg.size}');
      print('');
    });

    // Wait for some updates
    print('Waiting for updates (10 seconds)...\n');
    await Future.delayed(const Duration(seconds: 10));

    // Clean up subscriptions
    await bookSubscription.cancel();
    await priceSubscription.cancel();
    await tradeSubscription.cancel();

    // Disconnect
    await client.clobWebSocket.disconnect();
    print('Disconnected from CLOB WebSocket.\n');
  } catch (e) {
    print('CLOB WebSocket error: $e\n');
  }
}

/// Example: RTDS WebSocket for crypto prices
Future<void> rtdsWebSocketExample(PolymarketClient client) async {
  print('--- RTDS WebSocket Example ---\n');

  try {
    // Connect and subscribe to crypto prices
    print('Connecting to RTDS WebSocket...');
    await client.rtdsWebSocket.connect(topics: [RtdsTopic.cryptoPrices]);
    print('Connected!\n');

    // Listen for crypto price updates
    final priceSubscription = client.rtdsWebSocket.cryptoPrices.listen((msg) {
      print('Crypto Prices Update:');
      final btc = msg.getPrice('BTC');
      final eth = msg.getPrice('ETH');
      if (btc != null) print('  BTC: \$${btc.toStringAsFixed(2)}');
      if (eth != null) print('  ETH: \$${eth.toStringAsFixed(2)}');
      print('');
    });

    // Wait for some updates
    print('Waiting for crypto price updates (10 seconds)...\n');
    await Future.delayed(const Duration(seconds: 10));

    // Clean up
    await priceSubscription.cancel();
    await client.rtdsWebSocket.disconnect();
    print('Disconnected from RTDS WebSocket.\n');
  } catch (e) {
    print('RTDS WebSocket error: $e\n');
  }
}

/// Example: Authenticated WebSocket for user order/trade updates
Future<void> authenticatedWebSocketExample() async {
  print('--- Authenticated WebSocket Example ---\n');

  // Create authenticated client
  final client = PolymarketClient.authenticated(
    credentials: const ApiCredentials(
      apiKey: 'your-api-key',
      secret: 'your-secret',
      passphrase: 'your-passphrase',
    ),
    funder: '0xYourWalletAddress',
  );

  try {
    await client.clobWebSocket.connect();

    // Subscribe to user channel for your orders/trades
    final tokenIds = ['your-token-id'];
    client.clobWebSocket.subscribeToUser(tokenIds);

    // Listen for your order updates
    client.clobWebSocket.userOrders.listen((order) {
      print('Order Update:');
      print('  ID: ${order.orderId}');
      print('  Action: ${order.action}');
      print('  Side: ${order.side}');
      print('  Price: ${order.price}');
      print('  Original Size: ${order.originalSize}');
      print('  Matched: ${order.sizeMatched}');
      print('  Remaining: ${order.remainingSize}');
      print('  Filled: ${order.isFilled}');
      print('');
    });

    // Listen for your trade updates
    client.clobWebSocket.userTrades.listen((trade) {
      print('Trade Update:');
      print('  ID: ${trade.tradeId}');
      print('  Status: ${trade.status}');
      print('  Side: ${trade.side}');
      print('  Price: ${trade.price}');
      print('  Size: ${trade.size}');
      print('  Tx: ${trade.transactionHash}');
      print('');
    });

    // Keep listening...
    await Future.delayed(const Duration(minutes: 5));
  } finally {
    client.close();
  }
}

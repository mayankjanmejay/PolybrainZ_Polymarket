// Trading example for polybrainz_polymarket
//
// This example demonstrates authenticated operations like
// viewing orders, positions, and portfolio data.
//
// NOTE: Actual order placement requires EIP-712 signing which
// needs a proper Ethereum library like web3dart.

import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  print('=== Polymarket Trading Example ===\n');

  // Create authenticated client
  // Replace with your actual credentials
  final client = PolymarketClient.authenticated(
    credentials: const ApiCredentials(
      apiKey: 'your-api-key',
      secret: 'your-secret',
      passphrase: 'your-passphrase',
    ),
    funder: '0xYourWalletAddress',
  );

  try {
    // Example 1: Get your positions
    await getPositionsExample(client);

    // Example 2: Get your trade history
    await getTradeHistoryExample(client);

    // Example 3: Get your orders
    await getOrdersExample(client);

    // Example 4: Get portfolio value
    await getPortfolioValueExample(client);

    // Example 5: Order management (viewing only - placing requires signing)
    await orderManagementExample(client);
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}

/// Example: Get your current positions
Future<void> getPositionsExample(PolymarketClient client) async {
  print('--- Your Positions ---\n');

  const walletAddress = '0xYourWalletAddress';

  try {
    // Get open positions
    final positions = await client.data.positions.getPositions(
      userAddress: walletAddress,
      sortBy: SortBy.current,
      sortDirection: SortDirection.desc,
    );

    if (positions.isEmpty) {
      print('No open positions found.\n');
      return;
    }

    print('Open Positions (${positions.length}):');
    for (final pos in positions) {
      print('  ${pos.title}');
      print('    Outcome: ${pos.outcome}');
      print('    Size: ${pos.size.toStringAsFixed(2)} shares');
      print('    Avg Price: \$${pos.avgPrice.toStringAsFixed(4)}');
      print('    Current Value: \$${pos.currentValue.toStringAsFixed(2)}');
      print('    P&L: \$${pos.cashPnl.toStringAsFixed(2)} (${pos.percentPnl.toStringAsFixed(2)}%)');
      print('');
    }

    // Get closed positions
    final closedPositions = await client.data.positions.getClosedPositions(
      userAddress: walletAddress,
      limit: 5,
    );

    if (closedPositions.isNotEmpty) {
      print('Recent Closed Positions:');
      for (final pos in closedPositions) {
        final result = pos.won ? 'WON' : 'LOST';
        print('  ${pos.title} - $result');
        print('    Payout: \$${pos.payout.toStringAsFixed(2)}');
        print('    P&L: \$${pos.cashPnl.toStringAsFixed(2)}');
        print('');
      }
    }
  } on ApiException catch (e) {
    print('API Error: ${e.message}\n');
  }
}

/// Example: Get your trade history
Future<void> getTradeHistoryExample(PolymarketClient client) async {
  print('--- Your Trade History ---\n');

  const walletAddress = '0xYourWalletAddress';

  try {
    final trades = await client.data.trades.getUserTrades(
      userAddress: walletAddress,
      sortDirection: SortDirection.desc,
      limit: 10,
    );

    if (trades.isEmpty) {
      print('No trades found.\n');
      return;
    }

    print('Recent Trades (${trades.length}):');
    for (final trade in trades) {
      final date = trade.timestampDate;
      print('  ${trade.title}');
      print('    Date: ${date.toString().substring(0, 19)}');
      print('    Side: ${trade.side}');
      print('    Size: ${trade.size.toStringAsFixed(2)} shares');
      print('    Price: \$${trade.price.toStringAsFixed(4)}');
      print('    USDC: \$${trade.usdcSize.toStringAsFixed(2)}');
      print('');
    }
  } on ApiException catch (e) {
    print('API Error: ${e.message}\n');
  }
}

/// Example: Get your open orders
Future<void> getOrdersExample(PolymarketClient client) async {
  print('--- Your Open Orders ---\n');

  try {
    final orders = await client.clob.orders.getOpenOrders();

    if (orders.isEmpty) {
      print('No open orders.\n');
      return;
    }

    print('Open Orders (${orders.length}):');
    for (final order in orders) {
      print('  Order ID: ${order.id}');
      print('    Side: ${order.side}');
      print('    Price: ${order.price}');
      print('    Original Size: ${order.originalSize}');
      print('    Size Matched: ${order.sizeMatched}');
      print('    Status: ${order.status}');
      print('');
    }
  } on AuthenticationException catch (e) {
    print('Auth Error: ${e.message}');
    print('Make sure you have valid API credentials.\n');
  } on ApiException catch (e) {
    print('API Error: ${e.message}\n');
  }
}

/// Example: Get your portfolio value
Future<void> getPortfolioValueExample(PolymarketClient client) async {
  print('--- Portfolio Value ---\n');

  const walletAddress = '0xYourWalletAddress';

  try {
    final value = await client.data.value.getValue(walletAddress);

    print('Wallet: ${value.proxyWallet}');
    print('Total Value: \$${value.totalValue.toStringAsFixed(2)}');
    print('Total P&L: \$${value.totalPnl.toStringAsFixed(2)}');
    print('P&L %: ${value.totalPercentPnl.toStringAsFixed(2)}%');
    print('');
  } on ApiException catch (e) {
    print('API Error: ${e.message}\n');
  }
}

/// Example: Order management operations
Future<void> orderManagementExample(PolymarketClient client) async {
  print('--- Order Management ---\n');

  // Check order book before placing order
  const tokenId = 'your-token-id';

  try {
    // Get current order book
    final book = await client.clob.orderbook.getOrderBook(tokenId);
    print('Order Book for $tokenId:');
    print('  Best Bid: ${book.bestBid}');
    print('  Best Ask: ${book.bestAsk}');
    print('  Spread: ${book.spread}');
    print('');

    // Get current prices
    final bidPrice = await client.clob.pricing.getPrice(tokenId, OrderSide.buy);
    final askPrice =
        await client.clob.pricing.getPrice(tokenId, OrderSide.sell);
    print('Current Prices:');
    print('  Buy Price: \$${bidPrice.toStringAsFixed(4)}');
    print('  Sell Price: \$${askPrice.toStringAsFixed(4)}');
    print('');

    // Get midpoint
    final midpoint = await client.clob.pricing.getMidpoint(tokenId);
    print('Midpoint: \$${midpoint.toStringAsFixed(4)}');
    print('');

    // NOTE: To actually place an order, you need to:
    // 1. Create a signed order using EIP-712 (requires web3dart)
    // 2. Post the signed order to the CLOB
    //
    // Example (pseudo-code):
    // final signedOrder = createSignedOrder(
    //   tokenId: tokenId,
    //   side: OrderSide.buy,
    //   price: 0.50,
    //   size: 10,
    // );
    // final response = await client.clob.orders.postOrder(
    //   signedOrder,
    //   orderType: OrderType.gtc,
    // );

    print('Order placement requires EIP-712 signing.');
    print('See Polymarket docs for signing implementation.\n');
  } on ApiException catch (e) {
    print('API Error: ${e.message}\n');
  }
}

/// Example: Cancel orders
Future<void> cancelOrdersExample(PolymarketClient client) async {
  print('--- Cancel Orders ---\n');

  try {
    // Cancel a specific order
    // await client.clob.orders.cancelOrder('order-id');

    // Cancel multiple orders
    // await client.clob.orders.cancelOrders(['order-1', 'order-2']);

    // Cancel all orders
    // await client.clob.orders.cancelAllOrders();

    // Cancel all orders for a specific market
    // await client.clob.orders.cancelMarketOrders('condition-id');

    print('Cancel operations require valid order IDs.\n');
  } on AuthenticationException catch (e) {
    print('Auth Error: ${e.message}\n');
  }
}

// Market discovery example for polybrainz_polymarket
//
// This example demonstrates how to discover markets, events,
// and explore Polymarket using the Gamma API.

import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  print('=== Polymarket Market Discovery Example ===\n');

  final client = PolymarketClient.public();

  try {
    // Example 1: Browse events
    await browseEventsExample(client);

    // Example 2: Browse markets
    await browseMarketsExample(client);

    // Example 3: Browse tags/categories
    await browseTagsExample(client);

    // Example 4: Search
    await searchExample(client);

    // Example 5: Get market details
    await marketDetailsExample(client);

    // Example 6: Get leaderboard
    await leaderboardExample(client);
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}

/// Example: Browse active events
Future<void> browseEventsExample(PolymarketClient client) async {
  print('--- Browse Events ---\n');

  try {
    // Get active events sorted by volume
    final events = await client.gamma.events.listEvents(
      limit: 10,
      closed: false,
      active: true,
      order: EventOrderBy.volume,
      ascending: false,
    );

    print('Top ${events.length} Active Events by Volume:');
    for (final event in events) {
      print('  ${event.title}');
      print('    Slug: ${event.slug}');
      print('    Markets: ${event.markets?.length ?? 0}');
      print('    Volume: \$${_formatNumber(event.volume ?? 0)}');
      print('    Liquidity: \$${_formatNumber(event.liquidity ?? 0)}');
      print('');
    }

    // Get featured events
    final featured = await client.gamma.events.listEvents(
      limit: 5,
      featured: true,
      closed: false,
    );

    if (featured.isNotEmpty) {
      print('Featured Events:');
      for (final event in featured) {
        print('  - ${event.title}');
      }
      print('');
    }
  } on ApiException catch (e) {
    print('API Error: ${e.message}\n');
  }
}

/// Example: Browse markets
Future<void> browseMarketsExample(PolymarketClient client) async {
  print('--- Browse Markets ---\n');

  try {
    // Get high volume markets
    final markets = await client.gamma.markets.listMarkets(
      limit: 10,
      active: true,
      closed: false,
      order: MarketOrderBy.volume,
      ascending: false,
    );

    print('Top ${markets.length} Markets by Volume:');
    for (final market in markets) {
      print('  ${market.question}');
      print('    Condition ID: ${market.conditionId}');
      print('    Volume: \$${_formatNumber(market.volumeNum ?? 0)}');

      // Show outcomes with prices using tokenIdsList getter
      final tokenIds = market.tokenIdsList;
      if (tokenIds.isNotEmpty) {
        print('    Token IDs: ${tokenIds.length}');
        for (final token in tokenIds.take(2)) {
          print('      - $token');
        }
      }
      print('');
    }

    // Get CLOB-tradable markets
    final tradable = await client.gamma.markets.getClobTradable(limit: 5);
    print('CLOB-Tradable Markets (${tradable.length}):');
    for (final m in tradable) {
      print('  - ${m.question}');
    }
    print('');
  } on ApiException catch (e) {
    print('API Error: ${e.message}\n');
  }
}

/// Example: Browse tags/categories
Future<void> browseTagsExample(PolymarketClient client) async {
  print('--- Browse Tags ---\n');

  try {
    final tags = await client.gamma.tags.listTags(limit: 20);

    print('Available Tags (${tags.length}):');
    for (final tag in tags) {
      print('  ${tag.label} (${tag.slug})');
    }
    print('');

    // Get events for a specific tag
    if (tags.isNotEmpty) {
      final tagId = tags.first.id;
      final taggedEvents = await client.gamma.events.listEvents(
        tagId: tagId,
        limit: 3,
        closed: false,
      );

      print('Events tagged "${tags.first.label}":');
      for (final event in taggedEvents) {
        print('  - ${event.title}');
      }
      print('');
    }
  } on ApiException catch (e) {
    print('API Error: ${e.message}\n');
  }
}

/// Example: Search for markets
Future<void> searchExample(PolymarketClient client) async {
  print('--- Search ---\n');

  try {
    // Search for events
    final results = await client.gamma.search.search(
      query: SearchQuery.bitcoin,
      limitPerType: 5,
    );

    print('Search results for "bitcoin":');

    final events = results.events ?? [];
    if (events.isNotEmpty) {
      print('  Events (${events.length}):');
      for (final event in events) {
        print('    - ${event.title}');
      }
    }

    final tags = results.tags ?? [];
    if (tags.isNotEmpty) {
      print('  Tags (${tags.length}):');
      for (final tag in tags) {
        print('    - ${tag.label}');
      }
    }

    final profiles = results.profiles ?? [];
    if (profiles.isNotEmpty) {
      print('  Profiles (${profiles.length}):');
      for (final profile in profiles) {
        print('    - ${profile.name ?? profile.proxyWallet}');
      }
    }
    print('');
  } on ApiException catch (e) {
    print('API Error: ${e.message}\n');
  }
}

/// Example: Get detailed market information
Future<void> marketDetailsExample(PolymarketClient client) async {
  print('--- Market Details ---\n');

  try {
    // First, get a market to examine
    final markets = await client.gamma.markets.listMarkets(
      limit: 1,
      active: true,
      closed: false,
    );

    if (markets.isEmpty) {
      print('No markets found.\n');
      return;
    }

    final market = markets.first;
    print('Market: ${market.question}');
    print('  Condition ID: ${market.conditionId}');
    print('  Slug: ${market.slug}');
    print('  Volume: \$${_formatNumber(market.volumeNum ?? 0)}');
    print('  Liquidity: \$${_formatNumber(market.liquidityNum ?? 0)}');
    print('  Active: ${market.active}');
    print('  Closed: ${market.closed}');
    print('');

    // Get order book from CLOB using tokenIdsList getter
    final tokenIds = market.tokenIdsList;
    if (tokenIds.isNotEmpty) {
      final tokenId = tokenIds.first;
      print('Order Book for token $tokenId:');

      final book = await client.clob.orderbook.getOrderBook(tokenId);
      print('  Best Bid: ${book.bestBid}');
      print('  Best Ask: ${book.bestAsk}');
      print('  Spread: ${book.spread}');
      print('  Bid Depth: ${book.bids.length} orders');
      print('  Ask Depth: ${book.asks.length} orders');
      print('');

      // Get price history
      final history = await client.clob.pricing.getPriceHistory(
        tokenId,
        interval: PriceHistoryInterval.day1,
        fidelity: 10,
      );

      if (history.isNotEmpty) {
        print('  Price History (last ${history.length} points):');
        for (final point in history.take(5)) {
          print(
              '    ${point.timestamp.toString().substring(0, 10)}: ${point.p.toStringAsFixed(4)}');
        }
      }
      print('');
    }

    // Get market holders
    final holders = await client.data.holders.getMarketHolders(
      conditionId: market.conditionId,
      limit: 5,
    );

    if (holders.isNotEmpty) {
      print('Top Holders:');
      for (final holder in holders) {
        final name = holder.pseudonym ?? holder.name ?? holder.proxyWallet;
        print('  $name: ${holder.amount.toStringAsFixed(2)} shares');
      }
      print('');
    }
  } on ApiException catch (e) {
    print('API Error: ${e.message}\n');
  }
}

/// Example: Get leaderboard
Future<void> leaderboardExample(PolymarketClient client) async {
  print('--- Leaderboard ---\n');

  try {
    // Get top traders by profit (all time)
    final profitLeaders = await client.data.leaderboard.getLeaderboard(
      window: LeaderboardWindow.all,
      type: LeaderboardType.profit,
      limit: 10,
    );

    print('Top 10 Traders by All-Time Profit:');
    for (final entry in profitLeaders) {
      final name = entry.pseudonym ?? entry.name ?? entry.proxyWallet;
      print('  #${entry.rank} $name');
      print('    Profit: \$${_formatNumber(entry.profit)}');
      print('    Volume: \$${_formatNumber(entry.volume)}');
      print('    Win Rate: ${(entry.winRate * 100).toStringAsFixed(1)}%');
      print('    Trades: ${entry.tradesCount}');
      print('');
    }

    // Get top traders by volume (7 days)
    final volumeLeaders = await client.data.leaderboard.getLeaderboard(
      window: LeaderboardWindow.day7,
      type: LeaderboardType.volume,
      limit: 5,
    );

    print('Top 5 Traders by 7-Day Volume:');
    for (final entry in volumeLeaders) {
      final name = entry.pseudonym ?? entry.name ?? entry.proxyWallet;
      print('  #${entry.rank} $name - \$${_formatNumber(entry.volume)}');
    }
    print('');
  } on ApiException catch (e) {
    print('API Error: ${e.message}\n');
  }
}

/// Helper function to format large numbers
String _formatNumber(double value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(2)}M';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(2)}K';
  } else {
    return value.toStringAsFixed(2);
  }
}

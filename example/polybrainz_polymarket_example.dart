import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  // Create a public client (no authentication required)
  final client = PolymarketClient.public();

  // Example: Get active events
  try {
    final events = await client.gamma.events.listEvents(
      limit: 5,
      closed: false,
    );

    print('Found ${events.length} active events:');
    for (final event in events) {
      print('  - ${event.title}');
    }
  } catch (e) {
    print('Error fetching events: $e');
  }

  // Example: Get order book for a token
  // (Replace with an actual token ID)
  // final book = await client.clob.orderbook.getOrderBook('token-id');
  // print('Best bid: ${book.bids.first.price}');

  // Clean up
  client.close();
}

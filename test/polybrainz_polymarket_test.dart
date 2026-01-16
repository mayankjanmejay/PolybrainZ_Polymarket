import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';
import 'package:test/test.dart';

void main() {
  group('PolymarketClient', () {
    test('can create public client', () {
      final client = PolymarketClient.public();
      expect(client.isAuthenticated, isFalse);
      client.close();
    });

    test('can create authenticated client', () {
      final client = PolymarketClient.authenticated(
        credentials: const ApiCredentials(
          apiKey: 'test-key',
          secret: 'test-secret',
          passphrase: 'test-passphrase',
        ),
        funder: '0x1234567890abcdef1234567890abcdef12345678',
      );
      expect(client.isAuthenticated, isTrue);
      client.close();
    });
  });

  group('Enums', () {
    test('OrderSide serialization', () {
      expect(OrderSide.buy.toJson(), equals('BUY'));
      expect(OrderSide.sell.toJson(), equals('SELL'));
      expect(OrderSide.fromJson('BUY'), equals(OrderSide.buy));
      expect(OrderSide.fromJson('SELL'), equals(OrderSide.sell));
    });

    test('OrderType serialization', () {
      expect(OrderType.gtc.toJson(), equals('GTC'));
      expect(OrderType.fok.toJson(), equals('FOK'));
      expect(OrderType.fromJson('GTC'), equals(OrderType.gtc));
    });
  });
}

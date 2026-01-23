import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';
import 'package:test/test.dart';

void main() {
  const testAddress = '0x1234567890123456789012345678901234567890';
  const testTokenId = '123456789012345678901234567890';

  group('OrderBuilder', () {
    group('buildLimitOrder', () {
      test('builds buy order with correct structure', () {
        final order = OrderBuilder.buildLimitOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.buy,
          size: 10.0,
          price: 0.55,
        );

        expect(order.maker, equals(testAddress));
        expect(order.signer, equals(testAddress));
        expect(order.taker, equals(OrderBuilder.zeroAddress));
        expect(order.tokenId, equals(testTokenId));
        expect(order.side, equals(0)); // 0 = buy
        expect(order.signatureType, equals(0)); // EOA default
      });

      test('builds sell order with correct structure', () {
        final order = OrderBuilder.buildLimitOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.sell,
          size: 10.0,
          price: 0.55,
        );

        expect(order.side, equals(1)); // 1 = sell
        expect(order.sideEnum, equals(OrderSide.sell));
      });

      test('calculates buy order amounts correctly', () {
        // Buy 10 shares at $0.50 each = $5.00 USDC
        final order = OrderBuilder.buildLimitOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.buy,
          size: 10.0,
          price: 0.50,
        );

        // Buy: maker gives USDC, receives shares
        // makerAmount = 10 * 0.50 * 1e6 = 5_000_000 (USDC in wei)
        // takerAmount = 10 * 1e6 = 10_000_000 (shares in wei)
        expect(order.makerAmount, equals(BigInt.from(5000000)));
        expect(order.takerAmount, equals(BigInt.from(10000000)));
        expect(order.size, closeTo(10.0, 0.001));
        expect(order.usdcAmount, closeTo(5.0, 0.001));
      });

      test('calculates sell order amounts correctly', () {
        // Sell 10 shares at $0.50 each = receive $5.00 USDC
        final order = OrderBuilder.buildLimitOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.sell,
          size: 10.0,
          price: 0.50,
        );

        // Sell: maker gives shares, receives USDC
        // makerAmount = 10 * 1e6 = 10_000_000 (shares in wei)
        // takerAmount = 10 * 0.50 * 1e6 = 5_000_000 (USDC in wei)
        expect(order.makerAmount, equals(BigInt.from(10000000)));
        expect(order.takerAmount, equals(BigInt.from(5000000)));
        expect(order.size, closeTo(10.0, 0.001));
        expect(order.usdcAmount, closeTo(5.0, 0.001));
      });

      test('generates unique salts for each order', () {
        final order1 = OrderBuilder.buildLimitOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.buy,
          size: 10.0,
          price: 0.50,
        );
        final order2 = OrderBuilder.buildLimitOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.buy,
          size: 10.0,
          price: 0.50,
        );

        expect(order1.salt, isNot(equals(order2.salt)));
      });

      test('sets expiration when provided', () {
        final order = OrderBuilder.buildLimitOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.buy,
          size: 10.0,
          price: 0.50,
          expiration: const Duration(hours: 1),
        );

        expect(order.hasExpiration, isTrue);
        expect(order.expiration, greaterThan(BigInt.zero));
        expect(order.expirationDateTime, isNotNull);
      });

      test('no expiration when not provided', () {
        final order = OrderBuilder.buildLimitOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.buy,
          size: 10.0,
          price: 0.50,
        );

        expect(order.hasExpiration, isFalse);
        expect(order.expiration, equals(BigInt.zero));
        expect(order.expirationDateTime, isNull);
      });

      test('throws on invalid price (too low)', () {
        expect(
          () => OrderBuilder.buildLimitOrder(
            tokenId: testTokenId,
            makerAddress: testAddress,
            side: OrderSide.buy,
            size: 10.0,
            price: 0.0,
          ),
          throwsArgumentError,
        );
      });

      test('throws on invalid price (too high)', () {
        expect(
          () => OrderBuilder.buildLimitOrder(
            tokenId: testTokenId,
            makerAddress: testAddress,
            side: OrderSide.buy,
            size: 10.0,
            price: 1.0,
          ),
          throwsArgumentError,
        );
      });

      test('throws on invalid price (negative)', () {
        expect(
          () => OrderBuilder.buildLimitOrder(
            tokenId: testTokenId,
            makerAddress: testAddress,
            side: OrderSide.buy,
            size: 10.0,
            price: -0.5,
          ),
          throwsArgumentError,
        );
      });

      test('throws on invalid size (zero)', () {
        expect(
          () => OrderBuilder.buildLimitOrder(
            tokenId: testTokenId,
            makerAddress: testAddress,
            side: OrderSide.buy,
            size: 0.0,
            price: 0.50,
          ),
          throwsArgumentError,
        );
      });

      test('throws on invalid size (negative)', () {
        expect(
          () => OrderBuilder.buildLimitOrder(
            tokenId: testTokenId,
            makerAddress: testAddress,
            side: OrderSide.buy,
            size: -10.0,
            price: 0.50,
          ),
          throwsArgumentError,
        );
      });

      test('accepts edge case prices', () {
        // Just above 0
        final order1 = OrderBuilder.buildLimitOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.buy,
          size: 10.0,
          price: 0.01,
        );
        expect(order1.price, closeTo(0.01, 0.001));

        // Just below 1
        final order2 = OrderBuilder.buildLimitOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.buy,
          size: 10.0,
          price: 0.99,
        );
        expect(order2.price, closeTo(0.99, 0.001));
      });
    });

    group('buildMarketOrder', () {
      test('builds buy market order', () {
        final order = OrderBuilder.buildMarketOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.buy,
          amount: 100.0, // $100 USDC
          price: 0.50,
        );

        expect(order.side, equals(0));
        expect(order.sideEnum, equals(OrderSide.buy));
      });

      test('builds sell market order', () {
        final order = OrderBuilder.buildMarketOrder(
          tokenId: testTokenId,
          makerAddress: testAddress,
          side: OrderSide.sell,
          amount: 50.0, // 50 shares
          price: 0.50,
        );

        expect(order.side, equals(1));
        expect(order.sideEnum, equals(OrderSide.sell));
      });
    });

    group('calculateUsdcRequired', () {
      test('calculates correct USDC for buy', () {
        final usdc = OrderBuilder.calculateUsdcRequired(
          size: 100.0,
          price: 0.55,
        );
        expect(usdc, closeTo(55.0, 0.001));
      });

      test('calculates for small amounts', () {
        final usdc = OrderBuilder.calculateUsdcRequired(
          size: 1.0,
          price: 0.01,
        );
        expect(usdc, closeTo(0.01, 0.0001));
      });
    });

    group('calculateUsdcExpected', () {
      test('calculates correct USDC for sell', () {
        final usdc = OrderBuilder.calculateUsdcExpected(
          size: 100.0,
          price: 0.55,
        );
        expect(usdc, closeTo(55.0, 0.001));
      });
    });
  });

  group('OrderStruct', () {
    test('toJson produces valid map', () {
      final order = OrderBuilder.buildLimitOrder(
        tokenId: testTokenId,
        makerAddress: testAddress,
        side: OrderSide.buy,
        size: 10.0,
        price: 0.50,
      );

      final json = order.toJson();

      expect(json['maker'], equals(testAddress));
      expect(json['signer'], equals(testAddress));
      expect(json['taker'], equals(OrderBuilder.zeroAddress));
      expect(json['tokenId'], equals(testTokenId));
      expect(json['side'], equals(0));
      expect(json['signatureType'], equals(0));
      expect(json['salt'], isA<String>());
      expect(json['makerAmount'], isA<String>());
      expect(json['takerAmount'], isA<String>());
      expect(json['expiration'], isA<String>());
      expect(json['nonce'], isA<String>());
      expect(json['feeRateBps'], isA<String>());
    });

    test('toTypedDataMessage produces BigInt values', () {
      final order = OrderBuilder.buildLimitOrder(
        tokenId: testTokenId,
        makerAddress: testAddress,
        side: OrderSide.buy,
        size: 10.0,
        price: 0.50,
      );

      final typedData = order.toTypedDataMessage();

      expect(typedData['salt'], isA<BigInt>());
      expect(typedData['tokenId'], isA<BigInt>());
      expect(typedData['makerAmount'], isA<BigInt>());
      expect(typedData['takerAmount'], isA<BigInt>());
      expect(typedData['expiration'], isA<BigInt>());
      expect(typedData['nonce'], isA<BigInt>());
      expect(typedData['feeRateBps'], isA<BigInt>());
    });

    test('price getter returns correct value for buy', () {
      final order = OrderBuilder.buildLimitOrder(
        tokenId: testTokenId,
        makerAddress: testAddress,
        side: OrderSide.buy,
        size: 10.0,
        price: 0.55,
      );

      expect(order.price, closeTo(0.55, 0.001));
    });

    test('price getter returns correct value for sell', () {
      final order = OrderBuilder.buildLimitOrder(
        tokenId: testTokenId,
        makerAddress: testAddress,
        side: OrderSide.sell,
        size: 10.0,
        price: 0.55,
      );

      expect(order.price, closeTo(0.55, 0.001));
    });

    test('size getter returns correct value', () {
      final order = OrderBuilder.buildLimitOrder(
        tokenId: testTokenId,
        makerAddress: testAddress,
        side: OrderSide.buy,
        size: 25.5,
        price: 0.50,
      );

      expect(order.size, closeTo(25.5, 0.001));
    });

    test('toString provides readable output', () {
      final order = OrderBuilder.buildLimitOrder(
        tokenId: testTokenId,
        makerAddress: testAddress,
        side: OrderSide.buy,
        size: 10.0,
        price: 0.55,
      );

      final str = order.toString();
      expect(str, contains('buy'));
      expect(str, contains('10'));
      expect(str, contains('0.55'));
    });

    test('equality works based on key fields', () {
      final order1 = OrderStruct(
        salt: BigInt.from(123),
        maker: testAddress,
        signer: testAddress,
        taker: OrderBuilder.zeroAddress,
        tokenId: testTokenId,
        makerAmount: BigInt.from(1000000),
        takerAmount: BigInt.from(2000000),
        expiration: BigInt.zero,
        nonce: BigInt.from(456),
        feeRateBps: BigInt.zero,
        side: 0,
        signatureType: 0,
      );

      final order2 = OrderStruct(
        salt: BigInt.from(123),
        maker: testAddress,
        signer: testAddress,
        taker: OrderBuilder.zeroAddress,
        tokenId: testTokenId,
        makerAmount: BigInt.from(1000000),
        takerAmount: BigInt.from(2000000),
        expiration: BigInt.zero,
        nonce: BigInt.from(456),
        feeRateBps: BigInt.zero,
        side: 0,
        signatureType: 0,
      );

      expect(order1, equals(order2));
    });
  });
}

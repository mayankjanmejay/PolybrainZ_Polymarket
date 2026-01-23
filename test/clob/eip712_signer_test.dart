import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';
import 'package:test/test.dart';
import 'package:webthree/webthree.dart';

void main() {
  // Test private key (DO NOT use in production)
  // This is a well-known test key - address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
  const testPrivateKey =
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

  late EthPrivateKey credentials;
  late String walletAddress;

  setUp(() {
    credentials = EthPrivateKey.fromHex(testPrivateKey);
    walletAddress = credentials.address.hexEip55;
  });

  group('EIP712Signer', () {
    group('signOrder', () {
      test('produces valid signature format', () async {
        final order = OrderBuilder.buildLimitOrder(
          tokenId: '123456789012345678901234567890',
          makerAddress: walletAddress,
          side: OrderSide.buy,
          size: 10.0,
          price: 0.55,
        );

        final signature = await EIP712Signer.signOrder(
          order: order.toTypedDataMessage(),
          credentials: credentials,
          verifyingContract: PolymarketConstants.exchangeAddress,
        );

        // Signature should be 0x + 130 hex chars (65 bytes: r(32) + s(32) + v(1))
        expect(signature.startsWith('0x'), isTrue);
        expect(signature.length, equals(132));
      });

      test('produces deterministic signatures for same input', () async {
        // Create identical orders (with same salt)
        final order = OrderStruct(
          salt: BigInt.from(12345),
          maker: walletAddress,
          signer: walletAddress,
          taker: OrderBuilder.zeroAddress,
          tokenId: '123456789012345678901234567890',
          makerAmount: BigInt.from(5000000),
          takerAmount: BigInt.from(10000000),
          expiration: BigInt.zero,
          nonce: BigInt.from(1),
          feeRateBps: BigInt.zero,
          side: 0,
          signatureType: 0,
        );

        final signature1 = await EIP712Signer.signOrder(
          order: order.toTypedDataMessage(),
          credentials: credentials,
          verifyingContract: PolymarketConstants.exchangeAddress,
        );

        final signature2 = await EIP712Signer.signOrder(
          order: order.toTypedDataMessage(),
          credentials: credentials,
          verifyingContract: PolymarketConstants.exchangeAddress,
        );

        expect(signature1, equals(signature2));
      });

      test('produces different signatures for different orders', () async {
        final order1 = OrderBuilder.buildLimitOrder(
          tokenId: '123456789012345678901234567890',
          makerAddress: walletAddress,
          side: OrderSide.buy,
          size: 10.0,
          price: 0.55,
        );

        final order2 = OrderBuilder.buildLimitOrder(
          tokenId: '123456789012345678901234567890',
          makerAddress: walletAddress,
          side: OrderSide.buy,
          size: 20.0, // Different size
          price: 0.55,
        );

        final signature1 = await EIP712Signer.signOrder(
          order: order1.toTypedDataMessage(),
          credentials: credentials,
          verifyingContract: PolymarketConstants.exchangeAddress,
        );

        final signature2 = await EIP712Signer.signOrder(
          order: order2.toTypedDataMessage(),
          credentials: credentials,
          verifyingContract: PolymarketConstants.exchangeAddress,
        );

        expect(signature1, isNot(equals(signature2)));
      });

      test('produces different signatures for different verifying contracts',
          () async {
        final order = OrderStruct(
          salt: BigInt.from(12345),
          maker: walletAddress,
          signer: walletAddress,
          taker: OrderBuilder.zeroAddress,
          tokenId: '123456789012345678901234567890',
          makerAmount: BigInt.from(5000000),
          takerAmount: BigInt.from(10000000),
          expiration: BigInt.zero,
          nonce: BigInt.from(1),
          feeRateBps: BigInt.zero,
          side: 0,
          signatureType: 0,
        );

        final signatureStandard = await EIP712Signer.signOrder(
          order: order.toTypedDataMessage(),
          credentials: credentials,
          verifyingContract: PolymarketConstants.exchangeAddress,
        );

        final signatureNegRisk = await EIP712Signer.signOrder(
          order: order.toTypedDataMessage(),
          credentials: credentials,
          verifyingContract: PolymarketConstants.negRiskExchangeAddress,
        );

        expect(signatureStandard, isNot(equals(signatureNegRisk)));
      });

      test('works with sell orders', () async {
        final order = OrderBuilder.buildLimitOrder(
          tokenId: '123456789012345678901234567890',
          makerAddress: walletAddress,
          side: OrderSide.sell,
          size: 10.0,
          price: 0.55,
        );

        final signature = await EIP712Signer.signOrder(
          order: order.toTypedDataMessage(),
          credentials: credentials,
          verifyingContract: PolymarketConstants.exchangeAddress,
        );

        expect(signature.startsWith('0x'), isTrue);
        expect(signature.length, equals(132));
      });

      test('works with expiration', () async {
        final order = OrderBuilder.buildLimitOrder(
          tokenId: '123456789012345678901234567890',
          makerAddress: walletAddress,
          side: OrderSide.buy,
          size: 10.0,
          price: 0.55,
          expiration: const Duration(hours: 24),
        );

        final signature = await EIP712Signer.signOrder(
          order: order.toTypedDataMessage(),
          credentials: credentials,
          verifyingContract: PolymarketConstants.exchangeAddress,
        );

        expect(signature.startsWith('0x'), isTrue);
        expect(signature.length, equals(132));
      });
    });

    group('signAuth', () {
      test('produces valid signature format', () async {
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        const nonce = 123456;

        final signature = await EIP712Signer.signAuth(
          address: walletAddress,
          timestamp: timestamp,
          nonce: nonce,
          credentials: credentials,
        );

        expect(signature.startsWith('0x'), isTrue);
        expect(signature.length, equals(132));
      });

      test('produces deterministic signatures for same input', () async {
        const timestamp = 1700000000;
        const nonce = 123456;

        final signature1 = await EIP712Signer.signAuth(
          address: walletAddress,
          timestamp: timestamp,
          nonce: nonce,
          credentials: credentials,
        );

        final signature2 = await EIP712Signer.signAuth(
          address: walletAddress,
          timestamp: timestamp,
          nonce: nonce,
          credentials: credentials,
        );

        expect(signature1, equals(signature2));
      });

      test('produces different signatures for different timestamps', () async {
        const nonce = 123456;

        final signature1 = await EIP712Signer.signAuth(
          address: walletAddress,
          timestamp: 1700000000,
          nonce: nonce,
          credentials: credentials,
        );

        final signature2 = await EIP712Signer.signAuth(
          address: walletAddress,
          timestamp: 1700000001,
          nonce: nonce,
          credentials: credentials,
        );

        expect(signature1, isNot(equals(signature2)));
      });

      test('produces different signatures for different nonces', () async {
        const timestamp = 1700000000;

        final signature1 = await EIP712Signer.signAuth(
          address: walletAddress,
          timestamp: timestamp,
          nonce: 123456,
          credentials: credentials,
        );

        final signature2 = await EIP712Signer.signAuth(
          address: walletAddress,
          timestamp: timestamp,
          nonce: 654321,
          credentials: credentials,
        );

        expect(signature1, isNot(equals(signature2)));
      });

      test('works with different chain IDs', () async {
        const timestamp = 1700000000;
        const nonce = 123456;

        final signaturePolygon = await EIP712Signer.signAuth(
          address: walletAddress,
          timestamp: timestamp,
          nonce: nonce,
          credentials: credentials,
          chainId: 137, // Polygon
        );

        final signatureMumbai = await EIP712Signer.signAuth(
          address: walletAddress,
          timestamp: timestamp,
          nonce: nonce,
          credentials: credentials,
          chainId: 80001, // Mumbai
        );

        expect(signaturePolygon, isNot(equals(signatureMumbai)));
      });
    });

    group('error handling', () {
      test('throws SigningException on invalid order', () async {
        expect(
          () async => await EIP712Signer.signOrder(
            order: {'invalid': 'data'},
            credentials: credentials,
            verifyingContract: PolymarketConstants.exchangeAddress,
          ),
          throwsA(isA<SigningException>()),
        );
      });
    });
  });

  group('SignedOrder', () {
    test('combines order and signature', () async {
      final order = OrderBuilder.buildLimitOrder(
        tokenId: '123456789012345678901234567890',
        makerAddress: walletAddress,
        side: OrderSide.buy,
        size: 10.0,
        price: 0.55,
      );

      final signature = await EIP712Signer.signOrder(
        order: order.toTypedDataMessage(),
        credentials: credentials,
        verifyingContract: PolymarketConstants.exchangeAddress,
      );

      final signedOrder = SignedOrder(order: order, signature: signature);

      expect(signedOrder.order, equals(order));
      expect(signedOrder.signature, equals(signature));
    });

    test('toJson includes order and signature', () async {
      final order = OrderBuilder.buildLimitOrder(
        tokenId: '123456789012345678901234567890',
        makerAddress: walletAddress,
        side: OrderSide.buy,
        size: 10.0,
        price: 0.55,
      );

      final signature = await EIP712Signer.signOrder(
        order: order.toTypedDataMessage(),
        credentials: credentials,
        verifyingContract: PolymarketConstants.exchangeAddress,
      );

      final signedOrder = SignedOrder(order: order, signature: signature);
      final json = signedOrder.toJson();

      expect(json['order'], isA<Map<String, dynamic>>());
      expect(json['signature'], equals(signature));
      expect(json['order']['maker'], equals(walletAddress));
    });
  });
}

@Tags(['integration'])
library trading_integration_test;

import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';
import 'package:test/test.dart';
import 'package:webthree/webthree.dart';

/// Integration tests that hit live Polymarket APIs.
///
/// Run with: dart test test/trading_integration_test.dart --tags integration
///
/// These tests verify:
/// 1. HD wallet generation produces valid addresses
/// 2. Order building produces correct format
/// 3. EIP-712 signing produces valid signatures
/// 4. Live API endpoints respond correctly
/// 5. The full trading flow works end-to-end (without submitting)
void main() {
  // Test private key (DO NOT use in production - this is a well-known test key)
  const testPrivateKey =
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

  late PolymarketClient publicClient;
  late EthPrivateKey testCredentials;
  late String testWalletAddress;

  setUpAll(() {
    publicClient = PolymarketClient.public();
    testCredentials = EthPrivateKey.fromHex(testPrivateKey);
    testWalletAddress = testCredentials.address.hexEip55;
  });

  tearDownAll(() {
    publicClient.close();
  });

  group('Live Wallet Tests', () {
    test('generated wallet has valid Ethereum address format', () {
      final mnemonic = HdWallet.generateMnemonic();
      final wallet = HdWallet.deriveWallet(mnemonic: mnemonic, index: 0);

      // Valid Ethereum address
      expect(wallet.address.startsWith('0x'), isTrue);
      expect(wallet.address.length, equals(42));

      // Valid private key
      expect(wallet.privateKey.startsWith('0x'), isTrue);
      expect(wallet.privateKey.length, equals(66));

      // Can create credentials from derived key
      final creds = EthPrivateKey.fromHex(wallet.privateKey);
      expect(creds.address.hexEip55, equals(wallet.address));
    });

    test('derived wallet can sign messages', () async {
      final mnemonic = HdWallet.generateMnemonic();
      final wallet = HdWallet.deriveWallet(mnemonic: mnemonic, index: 0);
      final creds = EthPrivateKey.fromHex(wallet.privateKey);

      // Sign a test auth message
      final signature = await EIP712Signer.signAuth(
        address: wallet.address,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        nonce: 12345,
        credentials: creds,
      );

      expect(signature.startsWith('0x'), isTrue);
      expect(signature.length, equals(132));
    });
  });

  group('Live Gamma API Tests', () {
    test('can fetch active events', () async {
      final events = await publicClient.gamma.events.listEvents(
        limit: 5,
        closed: false,
      );

      expect(events, isNotEmpty);
      expect(events.first.title, isNotEmpty);
      expect(events.first.markets, isNotNull);
    });

    test('can fetch markets with tokens', () async {
      final markets = await publicClient.gamma.markets.listMarkets(
        limit: 5,
        active: true,
      );

      expect(markets, isNotEmpty);

      // Find a market with tokens
      final marketWithTokens = markets.firstWhere(
        (m) => m.tokenIdsList.isNotEmpty,
        orElse: () => markets.first,
      );

      expect(marketWithTokens.conditionId, isNotEmpty);
    });

    // Note: Search API requires authentication, so we skip it in public client tests
    test('search API exists', () {
      // Verify the search endpoint is accessible
      expect(publicClient.gamma.search, isNotNull);
    });
  });

  group('Live CLOB API Tests', () {
    String? liveTokenId;

    setUpAll(() async {
      // Get a real token ID from CLOB markets API
      final response = await publicClient.clob.markets.listMarkets();

      if (response.data.isEmpty) {
        return; // Skip if no markets
      }

      // Try to find an active market with orderbook enabled
      for (final market in response.data) {
        if (market.tokens.isNotEmpty && market.active && market.enableOrderBook) {
          liveTokenId = market.tokens.first.tokenId;
          break;
        }
      }
    });

    test('can fetch order book for real token', () async {
      if (liveTokenId == null) {
        // Skip test if no suitable token found
        return;
      }

      try {
        final book =
            await publicClient.clob.orderbook.getOrderBook(liveTokenId!);
        expect(book, isNotNull);
        expect(book.assetId, equals(liveTokenId));
      } on ApiException catch (e) {
        // 404 is acceptable - means the market exists but has no orderbook data
        expect(e.statusCode, equals(404));
      }
    });

    test('can fetch price for real token', () async {
      if (liveTokenId == null) return;

      try {
        final price = await publicClient.clob.pricing.getPrice(
          liveTokenId!,
          OrderSide.buy,
        );

        expect(price, greaterThanOrEqualTo(0));
        expect(price, lessThanOrEqualTo(1));
      } on ApiException catch (e) {
        expect(e.statusCode, equals(404));
      }
    });

    test('can fetch midpoint for real token', () async {
      if (liveTokenId == null) return;

      try {
        final midpoint =
            await publicClient.clob.pricing.getMidpoint(liveTokenId!);

        expect(midpoint, greaterThanOrEqualTo(0));
        expect(midpoint, lessThanOrEqualTo(1));
      } on ApiException catch (e) {
        expect(e.statusCode, equals(404));
      }
    });

    test('can fetch spread for real token', () async {
      if (liveTokenId == null) return;

      try {
        final spread = await publicClient.clob.pricing.getSpread(liveTokenId!);

        expect(spread, greaterThanOrEqualTo(0));
      } on ApiException catch (e) {
        expect(e.statusCode, equals(404));
      }
    });
  });

  group('Order Building Integration Tests', () {
    String? liveTokenId;

    setUpAll(() async {
      // Get a real token ID from CLOB markets API
      final response = await publicClient.clob.markets.listMarkets();

      if (response.data.isEmpty) return;

      for (final market in response.data) {
        if (market.tokens.isNotEmpty && market.active && market.enableOrderBook) {
          liveTokenId = market.tokens.first.tokenId;
          break;
        }
      }
    });

    test('can build order for real token', () async {
      if (liveTokenId == null) return;

      // Try to get market price, use default if orderbook not available
      final price = await _getPrice(publicClient, liveTokenId!);

      final order = OrderBuilder.buildLimitOrder(
        tokenId: liveTokenId!,
        makerAddress: testWalletAddress,
        side: OrderSide.buy,
        size: 10.0,
        price: price.clamp(0.01, 0.99),
      );

      expect(order.tokenId, equals(liveTokenId));
      expect(order.maker, equals(testWalletAddress));
      expect(order.sideEnum, equals(OrderSide.buy));
    });

    test('can sign order for real token', () async {
      if (liveTokenId == null) return;

      final price = await _getPrice(publicClient, liveTokenId!);

      final order = OrderBuilder.buildLimitOrder(
        tokenId: liveTokenId!,
        makerAddress: testWalletAddress,
        side: OrderSide.buy,
        size: 10.0,
        price: price.clamp(0.01, 0.99),
      );

      final signature = await EIP712Signer.signOrder(
        order: order.toTypedDataMessage(),
        credentials: testCredentials,
        verifyingContract: PolymarketConstants.exchangeAddress,
      );

      expect(signature.startsWith('0x'), isTrue);
      expect(signature.length, equals(132));
    });

    test('full signed order flow with real token', () async {
      if (liveTokenId == null) return;

      final price = await _getPrice(publicClient, liveTokenId!);

      final order = OrderBuilder.buildLimitOrder(
        tokenId: liveTokenId!,
        makerAddress: testWalletAddress,
        side: OrderSide.buy,
        size: 10.0,
        price: price.clamp(0.01, 0.99),
      );

      final signature = await EIP712Signer.signOrder(
        order: order.toTypedDataMessage(),
        credentials: testCredentials,
        verifyingContract: PolymarketConstants.exchangeAddress,
      );

      final signedOrder = SignedOrder(order: order, signature: signature);
      final json = signedOrder.toJson();

      // Verify JSON structure matches API requirements
      expect(json['order'], isA<Map<String, dynamic>>());
      expect(json['signature'], isA<String>());
      expect(json['order']['salt'], isA<String>());
      expect(json['order']['maker'], equals(testWalletAddress));
      expect(json['order']['tokenId'], equals(liveTokenId));
    });
  });

  group('Trading Enum Tests', () {
    test('TickSize values are correct', () {
      expect(TickSize.point01.asDouble, equals(0.01));
      expect(TickSize.point001.asDouble, equals(0.001));
      expect(TickSize.point0001.asDouble, equals(0.0001));
    });

    test('NegRiskFlag exchange addresses are correct', () {
      expect(
        NegRiskFlag.standard.exchangeAddress,
        equals(PolymarketConstants.exchangeAddress),
      );
      expect(
        NegRiskFlag.negRisk.exchangeAddress,
        equals(PolymarketConstants.negRiskExchangeAddress),
      );
    });

    test('TimeInForce immediate check', () {
      expect(TimeInForce.gtc.isImmediate, isFalse);
      expect(TimeInForce.gtd.isImmediate, isFalse);
      expect(TimeInForce.fok.isImmediate, isTrue);
      expect(TimeInForce.ioc.isImmediate, isTrue);
    });
  });

  group('Trading Exception Tests', () {
    test('TradingException stores message', () {
      const ex = TradingException('Test error');
      expect(ex.message, equals('Test error'));
      expect(ex.toString(), contains('Test error'));
    });

    test('SigningException includes original error', () {
      final ex = SigningException(
        'Sign failed',
        originalError: Exception('inner'),
      );
      expect(ex.message, equals('Sign failed'));
      expect(ex.originalError, isNotNull);
    });

    test('InsufficientUsdcException includes amounts', () {
      const ex = InsufficientUsdcException(
        required: 100.0,
        available: 50.0,
      );
      expect(ex.required, equals(100.0));
      expect(ex.available, equals(50.0));
      expect(ex.shortfall, equals(50.0));
      expect(ex.message, contains('100'));
    });

    test('InsufficientGasException includes amounts', () {
      const ex = InsufficientGasException(
        required: 0.1,
        available: 0.05,
      );
      expect(ex.required, equals(0.1));
      expect(ex.available, equals(0.05));
      expect(ex.shortfall, closeTo(0.05, 0.001));
    });
  });

  group('Client Factory Tests', () {
    test('public client has no trading capabilities', () {
      final client = PolymarketClient.public();
      expect(client.hasTradingCapabilities, isFalse);
      expect(client.isAuthenticated, isFalse);
      client.close();
    });

    test('withPrivateKey client has private key but no polygon', () {
      final client = PolymarketClient.withPrivateKey(
        privateKey: testPrivateKey,
        walletAddress: testWalletAddress,
      );

      // Has auth capability but not full trading
      expect(client.auth, isNotNull);
      client.close();
    });

    test('withTrading client has full capabilities', () {
      final client = PolymarketClient.withTrading(
        credentials: const ApiCredentials(
          apiKey: 'test-key',
          secret: 'test-secret',
          passphrase: 'test-pass',
        ),
        walletAddress: testWalletAddress,
        privateKey: testPrivateKey,
      );

      expect(client.hasTradingCapabilities, isTrue);
      expect(client.isAuthenticated, isTrue);
      expect(() => client.polygon, returnsNormally);
      client.close();
    });

    test('buildSignedOrder requires trading client', () {
      final publicClient = PolymarketClient.public();

      expect(
        () => publicClient.buildSignedOrder(
          tokenId: '123',
          side: OrderSide.buy,
          size: 10.0,
          price: 0.50,
        ),
        throwsA(isA<AuthenticationException>()),
      );

      publicClient.close();
    });

    test('polygon getter throws on non-trading client', () {
      final client = PolymarketClient.authenticated(
        credentials: const ApiCredentials(
          apiKey: 'test',
          secret: 'test',
          passphrase: 'test',
        ),
        funder: testWalletAddress,
      );

      expect(
        () => client.polygon,
        throwsA(isA<AuthenticationException>()),
      );

      client.close();
    });
  });

  group('End-to-End Signing Flow', () {
    test('complete order signing matches expected format', () async {
      // Get real market data
      final markets = await publicClient.gamma.markets.listMarkets(
        limit: 5,
        active: true,
      );

      final market = markets.firstWhere(
        (m) => m.tokenIdsList.isNotEmpty,
      );

      final tokenId = market.tokenIdsList.first;

      // Build order
      final order = OrderBuilder.buildLimitOrder(
        tokenId: tokenId,
        makerAddress: testWalletAddress,
        side: OrderSide.buy,
        size: 5.0,
        price: 0.45,
      );

      // For Gamma API markets, we use standard exchange
      // In real usage, you'd check the CLOB market's negRisk field
      const verifyingContract = PolymarketConstants.exchangeAddress;

      final signature = await EIP712Signer.signOrder(
        order: order.toTypedDataMessage(),
        credentials: testCredentials,
        verifyingContract: verifyingContract,
      );

      // Create signed order
      final signedOrder = SignedOrder(order: order, signature: signature);

      // Verify complete JSON structure
      final json = signedOrder.toJson();

      // Required fields for CLOB API
      expect(json.containsKey('order'), isTrue);
      expect(json.containsKey('signature'), isTrue);

      final orderJson = json['order'] as Map<String, dynamic>;
      expect(orderJson.containsKey('salt'), isTrue);
      expect(orderJson.containsKey('maker'), isTrue);
      expect(orderJson.containsKey('signer'), isTrue);
      expect(orderJson.containsKey('taker'), isTrue);
      expect(orderJson.containsKey('tokenId'), isTrue);
      expect(orderJson.containsKey('makerAmount'), isTrue);
      expect(orderJson.containsKey('takerAmount'), isTrue);
      expect(orderJson.containsKey('expiration'), isTrue);
      expect(orderJson.containsKey('nonce'), isTrue);
      expect(orderJson.containsKey('feeRateBps'), isTrue);
      expect(orderJson.containsKey('side'), isTrue);
      expect(orderJson.containsKey('signatureType'), isTrue);

      // Values are strings for BigInt fields
      expect(orderJson['salt'], isA<String>());
      expect(orderJson['makerAmount'], isA<String>());
      expect(orderJson['takerAmount'], isA<String>());

      // Signature is valid format
      expect(json['signature'], startsWith('0x'));
      expect((json['signature'] as String).length, equals(132));
    });
  });

  group('CLOB Market negRisk Integration', () {
    test('can fetch CLOB market with negRisk info', () async {
      // Get a market from CLOB API which has negRisk field
      final response = await publicClient.clob.markets.listMarkets();

      if (response.data.isNotEmpty) {
        final market = response.data.first;

        // negRisk is a bool on ClobMarket
        expect(market.negRisk, isA<bool>());

        // Get correct exchange based on negRisk
        final exchange = market.negRisk
            ? PolymarketConstants.negRiskExchangeAddress
            : PolymarketConstants.exchangeAddress;

        expect(exchange.startsWith('0x'), isTrue);
      }
    });
  });
}

/// Helper to get price with fallback for missing orderbooks.
Future<double> _getPrice(PolymarketClient client, String tokenId) async {
  try {
    return await client.clob.pricing.getMidpoint(tokenId);
  } on ApiException {
    return 0.50; // Default price if orderbook not available
  }
}

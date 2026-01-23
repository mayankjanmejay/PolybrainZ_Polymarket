# PolyBrainZ Polymarket SDK - Trading Extension

**Extending `polybrainz_polymarket` for Live Trading Execution**

Version: 2.0.0  
Status: Ready for Implementation

---

## Table of Contents

1. [Overview](#1-overview)
2. [New Package Structure](#2-new-package-structure)
3. [Dependencies](#3-dependencies)
4. [CLOB Authentication Extension](#4-clob-authentication-extension)
5. [Order Execution](#5-order-execution)
6. [Order Signing (EIP-712)](#6-order-signing-eip-712)
7. [Wallet Operations](#7-wallet-operations)
8. [New Models](#8-new-models)
9. [New Enums](#9-new-enums)
10. [Client Extension](#10-client-extension)
11. [Usage Examples](#11-usage-examples)
12. [Contract Constants](#12-contract-constants)
13. [Error Handling](#13-error-handling)
14. [Testing](#14-testing)

---

## 1. Overview

### Current SDK Capabilities (v1.8.0)

```
polybrainz_polymarket/
├── gamma/      ← Market discovery (read-only)
├── clob/       ← Order book, pricing (read-only)
├── data/       ← Positions, trades (read-only)
└── websocket/  ← Real-time streams (read-only)
```

### New Capabilities (v2.0.0)

```
polybrainz_polymarket/
├── gamma/      ← Unchanged
├── clob/
│   ├── orderbook/   ← Unchanged
│   ├── pricing/     ← Unchanged
│   ├── orders/      ← EXTENDED: submitOrder(), cancelOrder()
│   ├── auth/        ← NEW: createApiKey(), deriveApiKey()
│   └── signing/     ← NEW: signOrder(), buildTypedData()
├── data/       ← Unchanged
├── websocket/  ← Unchanged
└── wallet/     ← NEW: HD wallet, USDC operations
```

---

## 2. New Package Structure

### Files to Add

```
lib/src/
├── clob/
│   ├── auth/
│   │   ├── clob_auth_service.dart       ← NEW
│   │   ├── api_key_creator.dart         ← NEW
│   │   └── request_signer.dart          ← NEW (refactor existing)
│   ├── orders/
│   │   ├── order_service.dart           ← EXTEND
│   │   ├── order_builder.dart           ← NEW
│   │   └── order_signer.dart            ← NEW
│   └── signing/
│       ├── eip712_signer.dart           ← NEW
│       ├── typed_data_builder.dart      ← NEW
│       └── domain_separator.dart        ← NEW
├── wallet/
│   ├── wallet_service.dart              ← NEW
│   ├── hd_wallet.dart                   ← NEW
│   ├── polygon_client.dart              ← NEW
│   └── usdc_operations.dart             ← NEW
└── models/
    ├── clob/
    │   ├── api_credentials.dart         ← EXISTS (extend)
    │   ├── signed_order.dart            ← NEW
    │   ├── order_request.dart           ← NEW
    │   └── order_response.dart          ← NEW
    └── wallet/
        ├── user_wallet.dart             ← NEW
        └── transaction_result.dart      ← NEW
```

---

## 3. Dependencies

### Add to pubspec.yaml

```yaml
dependencies:
  # Existing
  http: ^1.2.0
  web_socket_channel: ^2.4.0
  crypto: ^3.0.3
  convert: ^3.1.1
  
  # NEW - Wallet & Signing
  web3dart: ^2.7.3
  bip39: ^1.0.6
  bip32: ^2.0.0
  pointycastle: ^3.7.4
  
  # NEW - Encryption (for key storage)
  encrypt: ^5.0.3
```

---

## 4. CLOB Authentication Extension

### 4.1 ClobAuthService

```dart
// lib/src/clob/auth/clob_auth_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:web3dart/web3dart.dart';

/// Service for CLOB API authentication (L1 and L2)
class ClobAuthService {
  final http.Client _client;
  final String _baseUrl;

  ClobAuthService({
    http.Client? client,
    String baseUrl = 'https://clob.polymarket.com',
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  /// Create new API credentials by signing with wallet (L1 Auth)
  /// Call once per wallet, store the returned credentials
  Future<ApiCredentials> createApiKey({
    required EthPrivateKey credentials,
    required String walletAddress,
    int? nonce,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nonceValue = nonce ?? _generateNonce();

    // Build message to sign
    final message = _buildApiKeyMessage(timestamp, nonceValue);

    // Sign with wallet (personal_sign / EIP-191)
    final signature = credentials.signPersonalMessageToUint8List(
      Uint8List.fromList(utf8.encode(message)),
    );

    // Request API key from CLOB
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/api-key'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'address': walletAddress,
        'timestamp': timestamp,
        'nonce': nonceValue,
        'signature': '0x${_bytesToHex(signature)}',
      }),
    );

    if (response.statusCode != 200) {
      throw ClobAuthException(
        'Failed to create API key: ${response.body}',
        response.statusCode,
      );
    }

    final data = jsonDecode(response.body);
    return ApiCredentials(
      apiKey: data['apiKey'],
      secret: data['secret'],
      passphrase: data['passphrase'],
    );
  }

  /// Derive API credentials (if already created)
  Future<ApiCredentials> deriveApiKey({
    required EthPrivateKey credentials,
    required String walletAddress,
    int? nonce,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nonceValue = nonce ?? _generateNonce();

    final message = _buildApiKeyMessage(timestamp, nonceValue);
    final signature = credentials.signPersonalMessageToUint8List(
      Uint8List.fromList(utf8.encode(message)),
    );

    final response = await _client.get(
      Uri.parse('$_baseUrl/auth/derive-api-key'),
      headers: {
        'POLY_ADDRESS': walletAddress,
        'POLY_SIGNATURE': '0x${_bytesToHex(signature)}',
        'POLY_TIMESTAMP': timestamp.toString(),
        'POLY_NONCE': nonceValue.toString(),
      },
    );

    if (response.statusCode != 200) {
      throw ClobAuthException(
        'Failed to derive API key: ${response.body}',
        response.statusCode,
      );
    }

    final data = jsonDecode(response.body);
    return ApiCredentials(
      apiKey: data['apiKey'],
      secret: data['secret'],
      passphrase: data['passphrase'],
    );
  }

  /// Delete API credentials
  Future<void> deleteApiKey({
    required ApiCredentials credentials,
    required String walletAddress,
  }) async {
    final headers = signRequest(
      credentials: credentials,
      walletAddress: walletAddress,
      method: 'DELETE',
      path: '/auth/api-key',
    );

    final response = await _client.delete(
      Uri.parse('$_baseUrl/auth/api-key'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw ClobAuthException(
        'Failed to delete API key: ${response.body}',
        response.statusCode,
      );
    }
  }

  /// Sign a request for L2 authentication (HMAC-SHA256)
  /// Returns headers to include in authenticated requests
  Map<String, String> signRequest({
    required ApiCredentials credentials,
    required String walletAddress,
    required String method,
    required String path,
    String body = '',
  }) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).toString();
    final message = '$timestamp$method$path$body';

    final hmac = Hmac(sha256, base64Decode(credentials.secret));
    final signature = base64Encode(hmac.convert(utf8.encode(message)).bytes);

    return {
      'POLY_ADDRESS': walletAddress,
      'POLY_SIGNATURE': signature,
      'POLY_TIMESTAMP': timestamp,
      'POLY_API_KEY': credentials.apiKey,
      'POLY_PASSPHRASE': credentials.passphrase,
      'Content-Type': 'application/json',
    };
  }

  String _buildApiKeyMessage(int timestamp, int nonce) {
    return 'This message attests that I control the given wallet\n'
        'Nonce: $nonce\n'
        'Timestamp: $timestamp';
  }

  int _generateNonce() {
    final random = Random.secure();
    return random.nextInt(1 << 30);
  }

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

class ClobAuthException implements Exception {
  final String message;
  final int? statusCode;

  ClobAuthException(this.message, [this.statusCode]);

  @override
  String toString() => 'ClobAuthException: $message (status: $statusCode)';
}
```

---

## 5. Order Execution

### 5.1 OrderService Extension

```dart
// lib/src/clob/orders/order_service.dart

/// Extended OrderService with write operations
class OrderService {
  final http.Client _client;
  final String _baseUrl;
  final ClobAuthService _auth;

  OrderService({
    required ClobAuthService auth,
    http.Client? client,
    String baseUrl = 'https://clob.polymarket.com',
  })  : _auth = auth,
        _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  // ============ EXISTING READ METHODS ============

  /// Get open orders (existing)
  Future<List<Order>> getOpenOrders({
    required ApiCredentials credentials,
    required String walletAddress,
    String? market,
  }) async {
    final path = market != null 
        ? '/orders?market=$market' 
        : '/orders';
    
    final headers = _auth.signRequest(
      credentials: credentials,
      walletAddress: walletAddress,
      method: 'GET',
      path: path,
    );

    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw OrderException('Failed to get orders: ${response.body}');
    }

    final data = jsonDecode(response.body) as List;
    return data.map((o) => Order.fromJson(o)).toList();
  }

  // ============ NEW WRITE METHODS ============

  /// Submit a signed order to the CLOB
  Future<OrderResponse> submitOrder({
    required SignedOrder signedOrder,
    required ApiCredentials credentials,
    required String walletAddress,
  }) async {
    const path = '/order';
    final body = jsonEncode(signedOrder.toJson());

    final headers = _auth.signRequest(
      credentials: credentials,
      walletAddress: walletAddress,
      method: 'POST',
      path: path,
      body: body,
    );

    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw OrderException('Order submission failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return OrderResponse.fromJson(data);
  }

  /// Cancel an order by ID
  Future<void> cancelOrder({
    required String orderId,
    required ApiCredentials credentials,
    required String walletAddress,
  }) async {
    final path = '/order/$orderId';

    final headers = _auth.signRequest(
      credentials: credentials,
      walletAddress: walletAddress,
      method: 'DELETE',
      path: path,
    );

    final response = await _client.delete(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw OrderException('Cancel failed: ${response.body}');
    }
  }

  /// Cancel all open orders
  Future<CancelAllResponse> cancelAllOrders({
    required ApiCredentials credentials,
    required String walletAddress,
    String? market,
  }) async {
    final path = market != null 
        ? '/orders?market=$market' 
        : '/orders';

    final headers = _auth.signRequest(
      credentials: credentials,
      walletAddress: walletAddress,
      method: 'DELETE',
      path: path,
    );

    final response = await _client.delete(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw OrderException('Cancel all failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return CancelAllResponse.fromJson(data);
  }

  /// Cancel multiple orders by IDs
  Future<List<CancelResult>> cancelOrders({
    required List<String> orderIds,
    required ApiCredentials credentials,
    required String walletAddress,
  }) async {
    const path = '/orders/cancel';
    final body = jsonEncode({'orderIds': orderIds});

    final headers = _auth.signRequest(
      credentials: credentials,
      walletAddress: walletAddress,
      method: 'POST',
      path: path,
      body: body,
    );

    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw OrderException('Batch cancel failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as List;
    return data.map((r) => CancelResult.fromJson(r)).toList();
  }

  /// Check if order is scoring (fillable)
  Future<OrderScoringResponse> checkOrderScoring({
    required String orderId,
    required ApiCredentials credentials,
    required String walletAddress,
  }) async {
    final path = '/order/$orderId/scoring';

    final headers = _auth.signRequest(
      credentials: credentials,
      walletAddress: walletAddress,
      method: 'GET',
      path: path,
    );

    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw OrderException('Scoring check failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return OrderScoringResponse.fromJson(data);
  }
}

class OrderException implements Exception {
  final String message;
  OrderException(this.message);

  @override
  String toString() => 'OrderException: $message';
}
```

### 5.2 OrderBuilder

```dart
// lib/src/clob/orders/order_builder.dart

import 'dart:math';
import 'dart:typed_data';

/// Builds order parameters for CLOB submission
class OrderBuilder {
  /// Build an order struct
  static OrderStruct buildOrder({
    required String tokenId,
    required String makerAddress,
    required OrderSide side,
    required BigInt makerAmount,
    required BigInt takerAmount,
    int? expiration,
    int? nonce,
    int feeRateBps = 0,
    SignatureType signatureType = SignatureType.eoa,
  }) {
    return OrderStruct(
      salt: _generateSalt(),
      maker: makerAddress,
      signer: makerAddress,
      taker: '0x0000000000000000000000000000000000000000',
      tokenId: tokenId,
      makerAmount: makerAmount,
      takerAmount: takerAmount,
      expiration: BigInt.from(expiration ?? 0),
      nonce: BigInt.from(nonce ?? DateTime.now().millisecondsSinceEpoch),
      feeRateBps: BigInt.from(feeRateBps),
      side: side == OrderSide.buy ? 0 : 1,
      signatureType: signatureType.value,
    );
  }

  /// Build order from user-friendly parameters
  static OrderStruct buildMarketOrder({
    required String tokenId,
    required String makerAddress,
    required OrderSide side,
    required double amount,      // USDC amount for BUY, shares for SELL
    required double price,       // Price per share (0.01 - 0.99)
  }) {
    // USDC has 6 decimals, shares have 6 decimals
    final BigInt makerAmount;
    final BigInt takerAmount;

    if (side == OrderSide.buy) {
      // Buying: maker gives USDC, receives shares
      final usdcAmount = amount;
      final shares = amount / price;
      makerAmount = BigInt.from((usdcAmount * 1e6).round());
      takerAmount = BigInt.from((shares * 1e6).round());
    } else {
      // Selling: maker gives shares, receives USDC
      final shares = amount;
      final usdcAmount = shares * price;
      makerAmount = BigInt.from((shares * 1e6).round());
      takerAmount = BigInt.from((usdcAmount * 1e6).round());
    }

    return buildOrder(
      tokenId: tokenId,
      makerAddress: makerAddress,
      side: side,
      makerAmount: makerAmount,
      takerAmount: takerAmount,
    );
  }

  /// Build limit order with specific price
  static OrderStruct buildLimitOrder({
    required String tokenId,
    required String makerAddress,
    required OrderSide side,
    required double size,        // Number of shares
    required double price,       // Limit price (0.01 - 0.99)
    Duration? expiration,
  }) {
    final usdcAmount = size * price;

    final BigInt makerAmount;
    final BigInt takerAmount;

    if (side == OrderSide.buy) {
      makerAmount = BigInt.from((usdcAmount * 1e6).round());
      takerAmount = BigInt.from((size * 1e6).round());
    } else {
      makerAmount = BigInt.from((size * 1e6).round());
      takerAmount = BigInt.from((usdcAmount * 1e6).round());
    }

    final expirationTimestamp = expiration != null
        ? DateTime.now().add(expiration).millisecondsSinceEpoch ~/ 1000
        : 0;

    return buildOrder(
      tokenId: tokenId,
      makerAddress: makerAddress,
      side: side,
      makerAmount: makerAmount,
      takerAmount: takerAmount,
      expiration: expirationTimestamp,
    );
  }

  static BigInt _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return BigInt.parse(
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );
  }
}

/// Raw order struct matching CLOB contract
class OrderStruct {
  final BigInt salt;
  final String maker;
  final String signer;
  final String taker;
  final String tokenId;
  final BigInt makerAmount;
  final BigInt takerAmount;
  final BigInt expiration;
  final BigInt nonce;
  final BigInt feeRateBps;
  final int side;
  final int signatureType;

  OrderStruct({
    required this.salt,
    required this.maker,
    required this.signer,
    required this.taker,
    required this.tokenId,
    required this.makerAmount,
    required this.takerAmount,
    required this.expiration,
    required this.nonce,
    required this.feeRateBps,
    required this.side,
    required this.signatureType,
  });

  Map<String, dynamic> toJson() => {
    'salt': salt.toString(),
    'maker': maker,
    'signer': signer,
    'taker': taker,
    'tokenId': tokenId,
    'makerAmount': makerAmount.toString(),
    'takerAmount': takerAmount.toString(),
    'expiration': expiration.toString(),
    'nonce': nonce.toString(),
    'feeRateBps': feeRateBps.toString(),
    'side': side,
    'signatureType': signatureType,
  };

  /// Calculate implied price
  double get price {
    if (side == 0) {
      // Buy: price = makerAmount / takerAmount
      return makerAmount.toDouble() / takerAmount.toDouble();
    } else {
      // Sell: price = takerAmount / makerAmount
      return takerAmount.toDouble() / makerAmount.toDouble();
    }
  }

  /// Get size in shares
  double get size {
    if (side == 0) {
      return takerAmount.toDouble() / 1e6;
    } else {
      return makerAmount.toDouble() / 1e6;
    }
  }
}

enum SignatureType {
  eoa(0),
  poly(1),
  polyProxy(2);

  final int value;
  const SignatureType(this.value);
}
```

---

## 6. Order Signing (EIP-712)

### 6.1 EIP712Signer

```dart
// lib/src/clob/signing/eip712_signer.dart

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:pointycastle/digests/keccak.dart';

/// EIP-712 typed data signer for Polymarket orders
class EIP712Signer {
  /// Sign an order using EIP-712
  static SignedOrder signOrder({
    required OrderStruct order,
    required EthPrivateKey credentials,
    required String verifyingContract,
    int chainId = 137, // Polygon
  }) {
    // Build typed data
    final typedData = TypedDataBuilder.buildOrderTypedData(
      order: order,
      verifyingContract: verifyingContract,
      chainId: chainId,
    );

    // Hash the typed data
    final structHash = _hashTypedData(typedData);

    // Sign the hash
    final signature = credentials.signToEcSignature(structHash);
    final signatureHex = _encodeSignature(signature);

    return SignedOrder(
      order: order,
      signature: signatureHex,
    );
  }

  static Uint8List _hashTypedData(Map<String, dynamic> typedData) {
    final domainSeparator = _hashDomain(typedData['domain']);
    final structHash = _hashStruct(
      typedData['primaryType'],
      typedData['message'],
      typedData['types'],
    );

    // EIP-712: keccak256("\x19\x01" ++ domainSeparator ++ structHash)
    final encoded = Uint8List.fromList([
      0x19,
      0x01,
      ...domainSeparator,
      ...structHash,
    ]);

    return _keccak256(encoded);
  }

  static Uint8List _hashDomain(Map<String, dynamic> domain) {
    final typeHash = _keccak256(utf8.encode(
      'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'
    ));

    final encoded = _encodeValues([
      typeHash,
      _keccak256(utf8.encode(domain['name'])),
      _keccak256(utf8.encode(domain['version'])),
      _encodeBigInt(BigInt.from(domain['chainId'])),
      _encodeAddress(domain['verifyingContract']),
    ]);

    return _keccak256(encoded);
  }

  static Uint8List _hashStruct(
    String typeName,
    Map<String, dynamic> data,
    Map<String, List<Map<String, String>>> types,
  ) {
    final typeString = _encodeType(typeName, types);
    final typeHash = _keccak256(utf8.encode(typeString));

    final values = <Uint8List>[typeHash];
    for (final field in types[typeName]!) {
      final name = field['name']!;
      final type = field['type']!;
      values.add(_encodeField(type, data[name]));
    }

    return _keccak256(_encodeValues(values));
  }

  static String _encodeType(
    String typeName,
    Map<String, List<Map<String, String>>> types,
  ) {
    final params = types[typeName]!
        .map((f) => '${f['type']} ${f['name']}')
        .join(',');
    return '$typeName($params)';
  }

  static Uint8List _encodeField(String type, dynamic value) {
    if (type == 'uint256' || type == 'uint8') {
      if (value is BigInt) {
        return _encodeBigInt(value);
      } else if (value is int) {
        return _encodeBigInt(BigInt.from(value));
      } else {
        return _encodeBigInt(BigInt.parse(value.toString()));
      }
    } else if (type == 'address') {
      return _encodeAddress(value as String);
    } else if (type == 'string') {
      return _keccak256(utf8.encode(value as String));
    } else if (type == 'bytes32') {
      return _hexToBytes(value as String);
    }
    throw ArgumentError('Unsupported type: $type');
  }

  static Uint8List _encodeBigInt(BigInt value) {
    final bytes = Uint8List(32);
    var temp = value;
    for (var i = 31; i >= 0; i--) {
      bytes[i] = (temp & BigInt.from(0xff)).toInt();
      temp = temp >> 8;
    }
    return bytes;
  }

  static Uint8List _encodeAddress(String address) {
    final bytes = Uint8List(32);
    final addressBytes = _hexToBytes(address.replaceFirst('0x', ''));
    bytes.setRange(12, 32, addressBytes);
    return bytes;
  }

  static Uint8List _encodeValues(List<Uint8List> values) {
    final result = <int>[];
    for (final v in values) {
      result.addAll(v);
    }
    return Uint8List.fromList(result);
  }

  static Uint8List _keccak256(List<int> data) {
    final digest = KeccakDigest(256);
    return digest.process(Uint8List.fromList(data));
  }

  static Uint8List _hexToBytes(String hex) {
    final clean = hex.replaceFirst('0x', '');
    final result = Uint8List(clean.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  static String _encodeSignature(MsgSignature sig) {
    final r = _bigIntToBytes(sig.r, 32);
    final s = _bigIntToBytes(sig.s, 32);
    final v = sig.v;
    return '0x${_bytesToHex(Uint8List.fromList([...r, ...s, v]))}';
  }

  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final bytes = Uint8List(length);
    var temp = value;
    for (var i = length - 1; i >= 0; i--) {
      bytes[i] = (temp & BigInt.from(0xff)).toInt();
      temp = temp >> 8;
    }
    return bytes;
  }

  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
```

### 6.2 TypedDataBuilder

```dart
// lib/src/clob/signing/typed_data_builder.dart

/// Builds EIP-712 typed data structures for Polymarket
class TypedDataBuilder {
  static const String _domainName = 'Polymarket CTF Exchange';
  static const String _domainVersion = '1';

  /// Build typed data for order signing
  static Map<String, dynamic> buildOrderTypedData({
    required OrderStruct order,
    required String verifyingContract,
    int chainId = 137,
  }) {
    return {
      'types': {
        'EIP712Domain': [
          {'name': 'name', 'type': 'string'},
          {'name': 'version', 'type': 'string'},
          {'name': 'chainId', 'type': 'uint256'},
          {'name': 'verifyingContract', 'type': 'address'},
        ],
        'Order': [
          {'name': 'salt', 'type': 'uint256'},
          {'name': 'maker', 'type': 'address'},
          {'name': 'signer', 'type': 'address'},
          {'name': 'taker', 'type': 'address'},
          {'name': 'tokenId', 'type': 'uint256'},
          {'name': 'makerAmount', 'type': 'uint256'},
          {'name': 'takerAmount', 'type': 'uint256'},
          {'name': 'expiration', 'type': 'uint256'},
          {'name': 'nonce', 'type': 'uint256'},
          {'name': 'feeRateBps', 'type': 'uint256'},
          {'name': 'side', 'type': 'uint8'},
          {'name': 'signatureType', 'type': 'uint8'},
        ],
      },
      'primaryType': 'Order',
      'domain': {
        'name': _domainName,
        'version': _domainVersion,
        'chainId': chainId,
        'verifyingContract': verifyingContract,
      },
      'message': {
        'salt': order.salt,
        'maker': order.maker,
        'signer': order.signer,
        'taker': order.taker,
        'tokenId': BigInt.parse(order.tokenId),
        'makerAmount': order.makerAmount,
        'takerAmount': order.takerAmount,
        'expiration': order.expiration,
        'nonce': order.nonce,
        'feeRateBps': order.feeRateBps,
        'side': order.side,
        'signatureType': order.signatureType,
      },
    };
  }
}
```

---

## 7. Wallet Operations

### 7.1 HdWallet

```dart
// lib/src/wallet/hd_wallet.dart

import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';

/// HD Wallet generation and management
class HdWallet {
  /// Generate a new 24-word mnemonic
  static String generateMnemonic() {
    return bip39.generateMnemonic(strength: 256);
  }

  /// Validate a mnemonic phrase
  static bool validateMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }

  /// Derive a wallet from mnemonic at given index
  /// Path: m/44'/60'/0'/0/{index}
  static WalletCredentials deriveWallet({
    required String mnemonic,
    required int index,
  }) {
    if (!validateMnemonic(mnemonic)) {
      throw ArgumentError('Invalid mnemonic');
    }

    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/60'/0'/0/$index");

    final privateKeyHex = _bytesToHex(child.privateKey!);
    final credentials = EthPrivateKey.fromHex(privateKeyHex);
    final address = credentials.address.hexEip55;

    return WalletCredentials(
      address: address,
      privateKey: privateKeyHex,
      derivationIndex: index,
    );
  }

  /// Get EthPrivateKey from hex string
  static EthPrivateKey getCredentials(String privateKeyHex) {
    return EthPrivateKey.fromHex(privateKeyHex);
  }

  static String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Wallet credentials container
class WalletCredentials {
  final String address;
  final String privateKey;
  final int derivationIndex;

  WalletCredentials({
    required this.address,
    required this.privateKey,
    required this.derivationIndex,
  });

  /// Get web3dart credentials for signing
  EthPrivateKey get ethCredentials => EthPrivateKey.fromHex(privateKey);
}
```

### 7.2 PolygonClient

```dart
// lib/src/wallet/polygon_client.dart

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

/// Client for Polygon blockchain operations
class PolygonClient {
  final Web3Client _web3;
  final int chainId;

  static const String defaultRpc = 'https://polygon-rpc.com';

  PolygonClient({
    String rpcUrl = defaultRpc,
    this.chainId = 137,
    http.Client? httpClient,
  }) : _web3 = Web3Client(rpcUrl, httpClient ?? http.Client());

  /// Get native MATIC balance
  Future<double> getMaticBalance(String address) async {
    final balance = await _web3.getBalance(EthereumAddress.fromHex(address));
    return balance.getInWei.toDouble() / 1e18;
  }

  /// Get USDC balance
  Future<double> getUsdcBalance(String address) async {
    final contract = _usdcContract;
    final balanceOf = contract.function('balanceOf');

    final result = await _web3.call(
      contract: contract,
      function: balanceOf,
      params: [EthereumAddress.fromHex(address)],
    );

    final balance = result.first as BigInt;
    return balance.toDouble() / 1e6; // USDC has 6 decimals
  }

  /// Transfer USDC
  Future<String> transferUsdc({
    required EthPrivateKey credentials,
    required String toAddress,
    required double amount,
  }) async {
    final contract = _usdcContract;
    final transfer = contract.function('transfer');
    final amountWei = BigInt.from((amount * 1e6).round());

    final txHash = await _web3.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: transfer,
        parameters: [
          EthereumAddress.fromHex(toAddress),
          amountWei,
        ],
      ),
      chainId: chainId,
    );

    return txHash;
  }

  /// Approve USDC spending for a contract
  Future<String> approveUsdc({
    required EthPrivateKey credentials,
    required String spenderAddress,
    BigInt? amount,
  }) async {
    final contract = _usdcContract;
    final approve = contract.function('approve');
    
    // Max approval if not specified
    final approveAmount = amount ?? BigInt.parse(
      'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
      radix: 16,
    );

    final txHash = await _web3.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: approve,
        parameters: [
          EthereumAddress.fromHex(spenderAddress),
          approveAmount,
        ],
      ),
      chainId: chainId,
    );

    return txHash;
  }

  /// Check USDC allowance
  Future<double> getUsdcAllowance({
    required String ownerAddress,
    required String spenderAddress,
  }) async {
    final contract = _usdcContract;
    final allowance = contract.function('allowance');

    final result = await _web3.call(
      contract: contract,
      function: allowance,
      params: [
        EthereumAddress.fromHex(ownerAddress),
        EthereumAddress.fromHex(spenderAddress),
      ],
    );

    final amount = result.first as BigInt;
    return amount.toDouble() / 1e6;
  }

  /// Wait for transaction confirmation
  Future<TransactionReceipt?> waitForTransaction(
    String txHash, {
    Duration timeout = const Duration(minutes: 2),
    Duration pollInterval = const Duration(seconds: 2),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      final receipt = await _web3.getTransactionReceipt(txHash);
      if (receipt != null) {
        return receipt;
      }
      await Future.delayed(pollInterval);
    }

    return null;
  }

  DeployedContract get _usdcContract => DeployedContract(
    ContractAbi.fromJson(_usdcAbi, 'USDC'),
    EthereumAddress.fromHex(PolygonContracts.usdc),
  );

  void dispose() {
    _web3.dispose();
  }

  static const String _usdcAbi = '''[
    {"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},
    {"constant":false,"inputs":[{"name":"to","type":"address"},{"name":"value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"},
    {"constant":false,"inputs":[{"name":"spender","type":"address"},{"name":"value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"type":"function"},
    {"constant":true,"inputs":[{"name":"owner","type":"address"},{"name":"spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"type":"function"}
  ]''';
}
```

---

## 8. New Models

### 8.1 SignedOrder

```dart
// lib/src/models/clob/signed_order.dart

/// A signed order ready for CLOB submission
class SignedOrder {
  final OrderStruct order;
  final String signature;

  SignedOrder({
    required this.order,
    required this.signature,
  });

  Map<String, dynamic> toJson() => {
    'order': order.toJson(),
    'signature': signature,
  };

  /// Get the owner (maker) address
  String get owner => order.maker;

  /// Get order side
  OrderSide get side => order.side == 0 ? OrderSide.buy : OrderSide.sell;

  /// Get price
  double get price => order.price;

  /// Get size
  double get size => order.size;
}
```

### 8.2 OrderResponse

```dart
// lib/src/models/clob/order_response.dart

/// Response from CLOB after order submission
class OrderResponse {
  final String orderId;
  final String status;
  final String? transactionsHash;
  final DateTime? createdAt;
  final String? errorMsg;

  OrderResponse({
    required this.orderId,
    required this.status,
    this.transactionsHash,
    this.createdAt,
    this.errorMsg,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: json['id'] ?? json['orderID'] ?? '',
      status: json['status'] ?? 'unknown',
      transactionsHash: json['transactionsHash'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      errorMsg: json['errorMsg'],
    );
  }

  bool get isSuccess => status == 'live' || status == 'matched';
  bool get isFailed => status == 'failed' || errorMsg != null;
}
```

### 8.3 CancelAllResponse

```dart
// lib/src/models/clob/cancel_all_response.dart

class CancelAllResponse {
  final int cancelledCount;
  final int failedCount;
  final List<String> cancelledIds;
  final List<CancelFailure> failures;

  CancelAllResponse({
    required this.cancelledCount,
    required this.failedCount,
    required this.cancelledIds,
    required this.failures,
  });

  factory CancelAllResponse.fromJson(Map<String, dynamic> json) {
    return CancelAllResponse(
      cancelledCount: json['canceled'] ?? 0,
      failedCount: json['failed'] ?? 0,
      cancelledIds: List<String>.from(json['canceledIds'] ?? []),
      failures: (json['failures'] as List?)
          ?.map((f) => CancelFailure.fromJson(f))
          .toList() ?? [],
    );
  }
}

class CancelFailure {
  final String orderId;
  final String reason;

  CancelFailure({required this.orderId, required this.reason});

  factory CancelFailure.fromJson(Map<String, dynamic> json) {
    return CancelFailure(
      orderId: json['orderId'] ?? '',
      reason: json['reason'] ?? 'unknown',
    );
  }
}

class CancelResult {
  final String orderId;
  final bool success;
  final String? error;

  CancelResult({
    required this.orderId,
    required this.success,
    this.error,
  });

  factory CancelResult.fromJson(Map<String, dynamic> json) {
    return CancelResult(
      orderId: json['orderId'] ?? '',
      success: json['success'] ?? false,
      error: json['error'],
    );
  }
}
```

---

## 9. New Enums

### 9.1 Add to existing enums file

```dart
// lib/src/models/enums/trading_enums.dart

/// Order tick size (price precision)
enum TickSize {
  point01('0.01'),
  point001('0.001'),
  point0001('0.0001');

  final String value;
  const TickSize(this.value);

  double get asDouble => double.parse(value);
}

/// Negative risk flag
enum NegRiskFlag {
  standard(false),
  negRisk(true);

  final bool value;
  const NegRiskFlag(this.value);
}

/// Order time in force
enum TimeInForce {
  gtc('GTC'),   // Good Till Cancelled
  gtd('GTD'),   // Good Till Date
  fok('FOK'),   // Fill or Kill
  ioc('IOC');   // Immediate or Cancel (same as FAK)

  final String value;
  const TimeInForce(this.value);
}
```

---

## 10. Client Extension

### 10.1 Extended PolymarketClient

```dart
// lib/src/client/polymarket_client.dart (extend existing)

class PolymarketClient {
  // ... existing code ...

  // NEW: Auth service
  late final ClobAuthService clobAuth;
  
  // NEW: Polygon client
  late final PolygonClient polygon;

  /// Create authenticated client with trading capabilities
  factory PolymarketClient.withTrading({
    required ApiCredentials credentials,
    required String walletAddress,
    required String privateKey,
    String? polygonRpcUrl,
  }) {
    final client = PolymarketClient.authenticated(
      credentials: credentials,
      funder: walletAddress,
    );

    // Initialize trading components
    client.clobAuth = ClobAuthService();
    client.polygon = PolygonClient(
      rpcUrl: polygonRpcUrl ?? PolygonClient.defaultRpc,
    );

    return client;
  }

  /// Create API credentials from private key
  Future<ApiCredentials> createApiCredentials({
    required String privateKey,
    required String walletAddress,
  }) async {
    final credentials = EthPrivateKey.fromHex(privateKey);
    return clobAuth.createApiKey(
      credentials: credentials,
      walletAddress: walletAddress,
    );
  }

  /// Build and sign an order
  SignedOrder buildSignedOrder({
    required String tokenId,
    required OrderSide side,
    required double amount,
    required double price,
    required String walletAddress,
    required String privateKey,
    bool negRisk = false,
  }) {
    // Build order
    final order = OrderBuilder.buildLimitOrder(
      tokenId: tokenId,
      makerAddress: walletAddress,
      side: side,
      size: amount,
      price: price,
    );

    // Sign order
    final credentials = EthPrivateKey.fromHex(privateKey);
    final verifyingContract = negRisk
        ? PolygonContracts.negRiskCtfExchange
        : PolygonContracts.ctfExchange;

    return EIP712Signer.signOrder(
      order: order,
      credentials: credentials,
      verifyingContract: verifyingContract,
    );
  }

  /// Submit order (convenience method)
  Future<OrderResponse> placeOrder({
    required String tokenId,
    required OrderSide side,
    required double amount,
    required double price,
    required String walletAddress,
    required String privateKey,
    required ApiCredentials apiCredentials,
    bool negRisk = false,
  }) async {
    final signedOrder = buildSignedOrder(
      tokenId: tokenId,
      side: side,
      amount: amount,
      price: price,
      walletAddress: walletAddress,
      privateKey: privateKey,
      negRisk: negRisk,
    );

    return clob.orders.submitOrder(
      signedOrder: signedOrder,
      credentials: apiCredentials,
      walletAddress: walletAddress,
    );
  }
}
```

---

## 11. Usage Examples

### 11.1 Create API Credentials

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  // Your wallet private key (keep secret!)
  const privateKey = '0x...';
  const walletAddress = '0x...';

  final client = PolymarketClient.public();

  // Create API credentials (one-time setup)
  final credentials = await client.clobAuth.createApiKey(
    credentials: EthPrivateKey.fromHex(privateKey),
    walletAddress: walletAddress,
  );

  print('API Key: ${credentials.apiKey}');
  print('Secret: ${credentials.secret}');
  print('Passphrase: ${credentials.passphrase}');

  // Store these securely for future use!
}
```

### 11.2 Check Balances

```dart
void main() async {
  final polygon = PolygonClient();

  const walletAddress = '0x...';

  final maticBalance = await polygon.getMaticBalance(walletAddress);
  final usdcBalance = await polygon.getUsdcBalance(walletAddress);

  print('MATIC: $maticBalance');
  print('USDC: $usdcBalance');

  polygon.dispose();
}
```

### 11.3 Approve USDC for Trading

```dart
void main() async {
  final polygon = PolygonClient();
  final credentials = EthPrivateKey.fromHex('0x...');

  // Approve CTF Exchange to spend USDC
  final txHash = await polygon.approveUsdc(
    credentials: credentials,
    spenderAddress: PolygonContracts.ctfExchange,
  );

  print('Approval tx: $txHash');

  // Wait for confirmation
  final receipt = await polygon.waitForTransaction(txHash);
  print('Confirmed: ${receipt?.status}');

  polygon.dispose();
}
```

### 11.4 Place an Order

```dart
void main() async {
  const privateKey = '0x...';
  const walletAddress = '0x...';

  final apiCredentials = ApiCredentials(
    apiKey: 'your-api-key',
    secret: 'your-secret',
    passphrase: 'your-passphrase',
  );

  final client = PolymarketClient.withTrading(
    credentials: apiCredentials,
    walletAddress: walletAddress,
    privateKey: privateKey,
  );

  // Find a market
  final markets = await client.gamma.markets.listMarkets(limit: 1, active: true);
  final market = markets.first;
  final tokenId = market.clobTokenIds.first; // YES token

  // Place a buy order: 100 shares at $0.45
  final response = await client.placeOrder(
    tokenId: tokenId,
    side: OrderSide.buy,
    amount: 100,
    price: 0.45,
    walletAddress: walletAddress,
    privateKey: privateKey,
    apiCredentials: apiCredentials,
    negRisk: market.negRisk,
  );

  if (response.isSuccess) {
    print('Order placed! ID: ${response.orderId}');
  } else {
    print('Order failed: ${response.errorMsg}');
  }

  client.close();
}
```

### 11.5 Cancel Orders

```dart
void main() async {
  final client = PolymarketClient.authenticated(
    credentials: apiCredentials,
    funder: walletAddress,
  );

  // Cancel single order
  await client.clob.orders.cancelOrder(
    orderId: 'order-id-here',
    credentials: apiCredentials,
    walletAddress: walletAddress,
  );

  // Cancel all orders
  final result = await client.clob.orders.cancelAllOrders(
    credentials: apiCredentials,
    walletAddress: walletAddress,
  );

  print('Cancelled: ${result.cancelledCount}');
  print('Failed: ${result.failedCount}');

  client.close();
}
```

### 11.6 HD Wallet Generation

```dart
void main() {
  // Generate new mnemonic (store securely!)
  final mnemonic = HdWallet.generateMnemonic();
  print('Mnemonic: $mnemonic');

  // Derive wallets
  for (var i = 0; i < 5; i++) {
    final wallet = HdWallet.deriveWallet(
      mnemonic: mnemonic,
      index: i,
    );
    print('Wallet $i: ${wallet.address}');
  }
}
```

---

## 12. Contract Constants

```dart
// lib/src/constants/contracts.dart

/// Polygon Mainnet contract addresses
class PolygonContracts {
  PolygonContracts._();

  /// Chain ID
  static const int chainId = 137;

  /// USDC Token
  static const String usdc = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174';

  /// CTF Exchange (standard markets)
  static const String ctfExchange = '0x4D97DCd97eC945f40cF65F87097ACe5EA0476045';

  /// Neg Risk CTF Exchange (negative risk markets)
  static const String negRiskCtfExchange = '0xC5d563A36AE78145C45a50134d48A1215220f80a';

  /// Neg Risk Adapter
  static const String negRiskAdapter = '0xd91E80cF2E7be2e162c6513ceD06f1dD0dA35296';

  /// Conditional Tokens Framework
  static const String conditionalTokens = '0x4D97DCd97eC945f40cF65F87097ACe5EA0476045';

  /// CLOB API Base URL
  static const String clobBaseUrl = 'https://clob.polymarket.com';

  /// Gamma API Base URL
  static const String gammaBaseUrl = 'https://gamma-api.polymarket.com';

  /// Default Polygon RPC
  static const String defaultRpc = 'https://polygon-rpc.com';
  
  /// Alternative RPCs
  static const List<String> alternativeRpcs = [
    'https://rpc-mainnet.matic.network',
    'https://matic-mainnet.chainstacklabs.com',
    'https://rpc-mainnet.maticvigil.com',
    'https://polygon.llamarpc.com',
  ];
}
```

---

## 13. Error Handling

### 13.1 New Exception Classes

```dart
// lib/src/exceptions/trading_exceptions.dart

/// Base exception for trading operations
class TradingException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  TradingException(this.message, {this.statusCode, this.errorCode});

  @override
  String toString() => 'TradingException: $message';
}

/// Authentication failed
class ClobAuthException extends TradingException {
  ClobAuthException(String message, [int? statusCode])
      : super(message, statusCode: statusCode);
}

/// Order submission failed
class OrderSubmissionException extends TradingException {
  final String? orderId;

  OrderSubmissionException(String message, {this.orderId, int? statusCode})
      : super(message, statusCode: statusCode);
}

/// Insufficient balance
class InsufficientBalanceException extends TradingException {
  final double required;
  final double available;

  InsufficientBalanceException({
    required this.required,
    required this.available,
  }) : super('Insufficient balance: need $required, have $available');
}

/// Signing failed
class SigningException extends TradingException {
  SigningException(String message) : super(message);
}

/// Wallet operation failed
class WalletException extends TradingException {
  final String? txHash;

  WalletException(String message, {this.txHash}) : super(message);
}
```

---

## 14. Testing

### 14.1 Unit Tests

```dart
// test/clob/order_builder_test.dart

import 'package:test/test.dart';
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() {
  group('OrderBuilder', () {
    test('builds correct buy order', () {
      final order = OrderBuilder.buildLimitOrder(
        tokenId: '12345',
        makerAddress: '0xabc123',
        side: OrderSide.buy,
        size: 100,
        price: 0.45,
      );

      expect(order.side, equals(0)); // Buy
      expect(order.maker, equals('0xabc123'));
      expect(order.price, closeTo(0.45, 0.001));
      expect(order.size, closeTo(100, 0.1));
    });

    test('builds correct sell order', () {
      final order = OrderBuilder.buildLimitOrder(
        tokenId: '12345',
        makerAddress: '0xabc123',
        side: OrderSide.sell,
        size: 50,
        price: 0.60,
      );

      expect(order.side, equals(1)); // Sell
      expect(order.price, closeTo(0.60, 0.001));
      expect(order.size, closeTo(50, 0.1));
    });

    test('generates unique salts', () {
      final order1 = OrderBuilder.buildLimitOrder(
        tokenId: '12345',
        makerAddress: '0xabc123',
        side: OrderSide.buy,
        size: 100,
        price: 0.45,
      );

      final order2 = OrderBuilder.buildLimitOrder(
        tokenId: '12345',
        makerAddress: '0xabc123',
        side: OrderSide.buy,
        size: 100,
        price: 0.45,
      );

      expect(order1.salt, isNot(equals(order2.salt)));
    });
  });
}
```

### 14.2 Integration Tests

```dart
// test/integration/trading_flow_test.dart

import 'package:test/test.dart';
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() {
  group('Trading Flow Integration', () {
    late PolymarketClient client;
    late PolygonClient polygon;

    // Test wallet (use testnet or small amounts!)
    const testPrivateKey = '0x...';
    const testWalletAddress = '0x...';

    setUp(() {
      client = PolymarketClient.public();
      polygon = PolygonClient();
    });

    tearDown(() {
      client.close();
      polygon.dispose();
    });

    test('can check USDC balance', () async {
      final balance = await polygon.getUsdcBalance(testWalletAddress);
      expect(balance, greaterThanOrEqualTo(0));
    });

    test('can create API credentials', () async {
      final credentials = await client.clobAuth.createApiKey(
        credentials: EthPrivateKey.fromHex(testPrivateKey),
        walletAddress: testWalletAddress,
      );

      expect(credentials.apiKey, isNotEmpty);
      expect(credentials.secret, isNotEmpty);
      expect(credentials.passphrase, isNotEmpty);
    });

    test('can build and sign order', () {
      final order = OrderBuilder.buildLimitOrder(
        tokenId: '12345',
        makerAddress: testWalletAddress,
        side: OrderSide.buy,
        size: 10,
        price: 0.50,
      );

      final signedOrder = EIP712Signer.signOrder(
        order: order,
        credentials: EthPrivateKey.fromHex(testPrivateKey),
        verifyingContract: PolygonContracts.ctfExchange,
      );

      expect(signedOrder.signature, startsWith('0x'));
      expect(signedOrder.signature.length, equals(132)); // 65 bytes * 2 + 0x
    });
  });
}
```

---

## Appendix: CLOB API Endpoints

### Order Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /order | L2 | Submit order |
| DELETE | /order/{id} | L2 | Cancel order |
| GET | /orders | L2 | Get open orders |
| DELETE | /orders | L2 | Cancel all orders |
| POST | /orders/cancel | L2 | Cancel multiple |

### Auth Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /auth/api-key | L1 | Create API key |
| GET | /auth/derive-api-key | L1 | Derive API key |
| DELETE | /auth/api-key | L2 | Delete API key |

### Public Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | /book | None | Order book |
| GET | /price | None | Token price |
| GET | /midpoint | None | Mid price |
| GET | /spread | None | Bid-ask spread |

---

*End of SDK Extension Documentation*

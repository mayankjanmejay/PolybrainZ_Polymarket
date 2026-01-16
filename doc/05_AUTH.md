# Authentication

L1 (Private Key) and L2 (API Key) authentication for the CLOB API.

---

## Overview

The CLOB uses two levels of authentication:

| Level | Method | Use Cases |
|-------|--------|-----------|
| **L1** | Private key EIP-712 signing | Creating/deriving API keys |
| **L2** | API key + HMAC-SHA256 | All trading operations |

Public endpoints (market data, orderbooks) require NO authentication.

---

## src/auth/models/api_credentials.dart

```dart
import 'package:equatable/equatable.dart';

/// API credentials for L2 authentication.
/// 
/// These credentials are obtained through L1 authentication
/// and used for all trading operations.
class ApiCredentials extends Equatable {
  /// The API key
  final String apiKey;
  
  /// The secret for HMAC signing
  final String secret;
  
  /// The passphrase
  final String passphrase;

  const ApiCredentials({
    required this.apiKey,
    required this.secret,
    required this.passphrase,
  });

  /// Whether credentials are set
  bool get isValid => 
      apiKey.isNotEmpty && 
      secret.isNotEmpty && 
      passphrase.isNotEmpty;

  @override
  List<Object?> get props => [apiKey, secret, passphrase];
  
  @override
  String toString() => 'ApiCredentials(apiKey: ${apiKey.substring(0, 8)}...)';
}
```

---

## src/auth/l2_auth.dart

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'models/api_credentials.dart';
import '../core/constants.dart';

/// L2 Authentication using API credentials and HMAC-SHA256.
/// 
/// Used for all authenticated CLOB operations (orders, trades, etc.)
class L2Auth {
  final ApiCredentials credentials;
  final String walletAddress;

  L2Auth({
    required this.credentials,
    required this.walletAddress,
  });

  /// Generate authentication headers for a request.
  /// 
  /// [method] - HTTP method (GET, POST, DELETE)
  /// [path] - Request path (e.g., /order)
  /// [body] - Request body (for POST/DELETE with body)
  Map<String, String> getHeaders({
    required String method,
    required String path,
    String? body,
  }) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
    final signature = _createSignature(
      timestamp: timestamp,
      method: method,
      path: path,
      body: body,
    );

    return {
      PolymarketConstants.headerPolyAddress: walletAddress,
      PolymarketConstants.headerPolySignature: signature,
      PolymarketConstants.headerPolyTimestamp: timestamp,
      PolymarketConstants.headerPolyApiKey: credentials.apiKey,
      PolymarketConstants.headerPolyPassphrase: credentials.passphrase,
    };
  }

  /// Create HMAC-SHA256 signature.
  String _createSignature({
    required String timestamp,
    required String method,
    required String path,
    String? body,
  }) {
    // Message format: timestamp + method + path + body
    final message = '$timestamp$method$path${body ?? ''}';
    
    // Decode Base64 secret
    final secretBytes = base64Decode(credentials.secret);
    
    // Create HMAC-SHA256
    final hmac = Hmac(sha256, secretBytes);
    final digest = hmac.convert(utf8.encode(message));
    
    // Return Base64-encoded signature
    return base64Encode(digest.bytes);
  }
}
```

---

## src/auth/l1_auth.dart

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../core/constants.dart';
import '../core/exceptions.dart';

/// L1 Authentication using private key EIP-712 signing.
/// 
/// Used to create or derive API keys.
/// 
/// NOTE: This is a simplified implementation. For production,
/// consider using a proper Ethereum signing library like
/// web3dart or ethers.
class L1Auth {
  final String privateKey;
  final String walletAddress;
  final int chainId;

  L1Auth({
    required this.privateKey,
    required this.walletAddress,
    this.chainId = PolymarketConstants.polygonChainId,
  }) {
    if (!privateKey.startsWith('0x') || privateKey.length != 66) {
      throw const ValidationException(
        'Invalid private key format. Must be 0x-prefixed 64-character hex string.',
      );
    }
  }

  /// Generate authentication headers for L1 requests.
  /// 
  /// Used for creating/deriving API keys.
  Map<String, String> getHeaders() {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final nonce = _generateNonce();
    
    final message = _createEip712Message(timestamp, nonce);
    final signature = _signMessage(message);

    return {
      PolymarketConstants.headerPolyAddress: walletAddress,
      PolymarketConstants.headerPolySignature: signature,
      PolymarketConstants.headerPolyTimestamp: timestamp.toString(),
      PolymarketConstants.headerPolyNonce: nonce.toString(),
    };
  }

  /// Create EIP-712 typed data message.
  Map<String, dynamic> _createEip712Message(int timestamp, int nonce) {
    return {
      'types': {
        'EIP712Domain': [
          {'name': 'name', 'type': 'string'},
          {'name': 'version', 'type': 'string'},
          {'name': 'chainId', 'type': 'uint256'},
        ],
        'ClobAuth': [
          {'name': 'address', 'type': 'address'},
          {'name': 'timestamp', 'type': 'string'},
          {'name': 'nonce', 'type': 'uint256'},
          {'name': 'message', 'type': 'string'},
        ],
      },
      'primaryType': 'ClobAuth',
      'domain': {
        'name': 'ClobAuthDomain',
        'version': '1',
        'chainId': chainId,
      },
      'message': {
        'address': walletAddress,
        'timestamp': timestamp.toString(),
        'nonce': nonce,
        'message': 'This message attests that I control the given wallet',
      },
    };
  }

  /// Sign EIP-712 message with private key.
  /// 
  /// NOTE: This is a simplified placeholder. Real implementation
  /// requires proper EIP-712 hashing and ECDSA signing.
  String _signMessage(Map<String, dynamic> message) {
    // In a real implementation, you would:
    // 1. Hash the structured data according to EIP-712
    // 2. Sign with ECDSA using the private key
    // 3. Return the signature in 0x{r}{s}{v} format
    
    // This is a placeholder that won't work with the real API
    // Use web3dart or similar library for actual signing
    throw UnimplementedError(
      'EIP-712 signing requires a proper Ethereum library. '
      'Consider using web3dart package for signing.',
    );
  }

  /// Generate a random nonce.
  int _generateNonce() {
    return DateTime.now().microsecondsSinceEpoch;
  }
}

/// Helper class for EIP-712 type hashing.
/// 
/// NOTE: For production use, use a proper library like web3dart.
class Eip712 {
  Eip712._();

  /// Domain separator type hash
  static Uint8List get domainSeparatorTypeHash {
    return _keccak256(
      'EIP712Domain(string name,string version,uint256 chainId)',
    );
  }

  /// Keccak256 hash
  static Uint8List _keccak256(String input) {
    // Note: Dart's crypto package doesn't include keccak256
    // You'll need to use a package like pointycastle or web3dart
    throw UnimplementedError(
      'Keccak256 requires pointycastle or similar package',
    );
  }
}
```

---

## src/auth/auth_service.dart

```dart
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';
import 'models/api_credentials.dart';
import 'l1_auth.dart';
import 'l2_auth.dart';

/// Service for managing authentication.
class AuthService {
  final ApiClient _client;
  final String walletAddress;
  final String? privateKey;
  final int chainId;
  
  ApiCredentials? _credentials;
  L2Auth? _l2Auth;

  AuthService({
    required ApiClient client,
    required this.walletAddress,
    this.privateKey,
    this.chainId = PolymarketConstants.polygonChainId,
  }) : _client = client;

  /// Set API credentials directly (if already have them).
  void setCredentials(ApiCredentials credentials) {
    _credentials = credentials;
    _l2Auth = L2Auth(
      credentials: credentials,
      walletAddress: walletAddress,
    );
  }

  /// Get current credentials.
  ApiCredentials? get credentials => _credentials;

  /// Whether we have valid credentials.
  bool get hasCredentials => _credentials?.isValid ?? false;

  /// Get L2 auth headers for a request.
  /// 
  /// Throws if no credentials are set.
  Map<String, String> getAuthHeaders({
    required String method,
    required String path,
    String? body,
  }) {
    if (_l2Auth == null) {
      throw const AuthenticationException('No credentials set. Call setCredentials() first.');
    }
    return _l2Auth!.getHeaders(
      method: method,
      path: path,
      body: body,
    );
  }

  /// Create new API key (L1 auth required).
  /// 
  /// This creates a NEW key - use deriveApiKey if you want
  /// to get the same key back.
  Future<ApiCredentials> createApiKey() async {
    if (privateKey == null) {
      throw const AuthenticationException(
        'Private key required to create API key',
      );
    }

    final l1Auth = L1Auth(
      privateKey: privateKey!,
      walletAddress: walletAddress,
      chainId: chainId,
    );

    final response = await _client.post<Map<String, dynamic>>(
      '/auth/api-key',
      headers: l1Auth.getHeaders(),
    );

    final credentials = ApiCredentials(
      apiKey: response['apiKey'] as String,
      secret: response['secret'] as String,
      passphrase: response['passphrase'] as String,
    );

    setCredentials(credentials);
    return credentials;
  }

  /// Derive existing API key (L1 auth required).
  /// 
  /// Returns the same key for the same wallet - use this
  /// to recover existing credentials.
  Future<ApiCredentials> deriveApiKey() async {
    if (privateKey == null) {
      throw const AuthenticationException(
        'Private key required to derive API key',
      );
    }

    final l1Auth = L1Auth(
      privateKey: privateKey!,
      walletAddress: walletAddress,
      chainId: chainId,
    );

    final response = await _client.get<Map<String, dynamic>>(
      '/auth/derive-api-key',
      headers: l1Auth.getHeaders(),
    );

    final credentials = ApiCredentials(
      apiKey: response['apiKey'] as String,
      secret: response['secret'] as String,
      passphrase: response['passphrase'] as String,
    );

    setCredentials(credentials);
    return credentials;
  }

  /// Create or derive API key.
  /// 
  /// Tries to derive first, creates if not found.
  Future<ApiCredentials> createOrDeriveApiKey() async {
    try {
      return await deriveApiKey();
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return await createApiKey();
      }
      rethrow;
    }
  }

  /// Delete API key.
  Future<void> deleteApiKey() async {
    if (_credentials == null) {
      throw const AuthenticationException('No credentials to delete');
    }

    await _client.delete<void>(
      '/auth/api-key',
      headers: getAuthHeaders(
        method: 'DELETE',
        path: '/auth/api-key',
      ),
    );

    _credentials = null;
    _l2Auth = null;
  }
}
```

---

## Usage Example

```dart
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  // Option 1: Use existing credentials
  final credentials = ApiCredentials(
    apiKey: 'your-api-key',
    secret: 'your-secret',
    passphrase: 'your-passphrase',
  );
  
  final client = PolymarketClient.authenticated(
    credentials: credentials,
    funder: '0xYourWalletAddress',
  );
  
  // Option 2: Derive credentials from private key
  final clientWithKey = PolymarketClient(
    privateKey: '0xYourPrivateKey',
    funder: '0xYourWalletAddress',
  );
  
  // This will create or derive API credentials
  await clientWithKey.auth.createOrDeriveApiKey();
  
  // Now you can make authenticated requests
  final orders = await clientWithKey.clob.orders.getOpenOrders();
}
```

---

## Signature Types

When initializing with a private key, you need to specify the signature type:

| Type | Value | Description |
|------|-------|-------------|
| EOA | 0 | Standard externally owned account (MetaMask, hardware wallets) |
| Email/Magic | 1 | Magic link or email-based wallets |
| Browser Wallet | 2 | Browser extension wallets with proxy (Coinbase Wallet) |

```dart
enum SignatureType {
  eoa(0),           // Standard EOA
  emailMagic(1),    // Magic/Email wallet
  browserWallet(2); // Browser wallet with proxy
  
  const SignatureType(this.value);
  final int value;
}
```

The signature type affects how the CLOB verifies signatures. If using a proxy wallet (Magic, Coinbase Wallet), you must also provide the `funder` address - the actual address holding funds.

---

## Security Notes

1. **Never expose private keys** in code or logs
2. **Store credentials securely** - use secure storage, not plain files
3. **Rotate API keys** periodically for security
4. **Use environment variables** for sensitive data
5. **L1 signing** should ideally happen client-side (browser/mobile), not server-side

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
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
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

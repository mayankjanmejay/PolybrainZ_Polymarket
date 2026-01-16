import 'dart:typed_data';

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

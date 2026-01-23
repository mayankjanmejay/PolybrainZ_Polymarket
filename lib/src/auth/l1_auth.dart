import 'dart:math';

import 'package:web3dart/web3dart.dart';

import '../core/constants.dart';
import '../core/exceptions.dart';
import '../clob/signing/eip712_signer.dart';

/// L1 Authentication using private key EIP-712 signing.
///
/// Used to create or derive API keys from the CLOB API.
/// This requires signing a message with your wallet's private key
/// to prove ownership of the address.
class L1Auth {
  /// The private key (0x-prefixed hex string)
  final String privateKey;

  /// The wallet address
  final String walletAddress;

  /// Chain ID (default: Polygon mainnet)
  final int chainId;

  /// Web3dart credentials for signing
  final EthPrivateKey _credentials;

  L1Auth({
    required this.privateKey,
    required this.walletAddress,
    this.chainId = PolymarketConstants.polygonChainId,
  }) : _credentials = EthPrivateKey.fromHex(privateKey) {
    // Validate private key format
    if (!privateKey.startsWith('0x') || privateKey.length != 66) {
      throw const ValidationException(
        'Invalid private key format. Must be 0x-prefixed 64-character hex string.',
      );
    }

    // Validate that the private key matches the wallet address
    final derivedAddress = _credentials.address.hexEip55;
    if (derivedAddress.toLowerCase() != walletAddress.toLowerCase()) {
      throw ValidationException(
        'Private key does not match wallet address. '
        'Expected: $walletAddress, Got: $derivedAddress',
      );
    }
  }

  /// Generate authentication headers for L1 requests.
  ///
  /// These headers are used to create or derive API keys.
  Map<String, String> getHeaders() {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final nonce = _generateNonce();

    final signature = EIP712Signer.signAuth(
      address: walletAddress,
      timestamp: timestamp,
      nonce: nonce,
      credentials: _credentials,
      chainId: chainId,
    );

    return {
      PolymarketConstants.headerPolyAddress: walletAddress,
      PolymarketConstants.headerPolySignature: signature,
      PolymarketConstants.headerPolyTimestamp: timestamp.toString(),
      PolymarketConstants.headerPolyNonce: nonce.toString(),
    };
  }

  /// Get the credentials for signing.
  EthPrivateKey get credentials => _credentials;

  /// Generate a random nonce.
  int _generateNonce() {
    final random = Random.secure();
    return random.nextInt(1 << 30);
  }
}

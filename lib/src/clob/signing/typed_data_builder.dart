import '../../core/constants.dart';

/// Builds EIP-712 typed data structures for Polymarket orders.
class TypedDataBuilder {
  TypedDataBuilder._();

  /// Build typed data for order signing.
  ///
  /// The typed data follows the EIP-712 specification and matches
  /// the Polymarket CTF Exchange contract's expected format.
  static Map<String, dynamic> buildOrderTypedData({
    required Map<String, dynamic> order,
    required String verifyingContract,
    int chainId = PolymarketConstants.polygonChainId,
  }) {
    return {
      'types': _orderTypes,
      'primaryType': 'Order',
      'domain': {
        'name': PolymarketConstants.eip712DomainName,
        'version': PolymarketConstants.eip712DomainVersion,
        'chainId': chainId,
        'verifyingContract': verifyingContract,
      },
      'message': order,
    };
  }

  /// Build typed data for CLOB authentication.
  static Map<String, dynamic> buildAuthTypedData({
    required String address,
    required int timestamp,
    required int nonce,
    int chainId = PolymarketConstants.polygonChainId,
  }) {
    return {
      'types': _authTypes,
      'primaryType': 'ClobAuth',
      'domain': {
        'name': 'ClobAuthDomain',
        'version': '1',
        'chainId': chainId,
      },
      'message': {
        'address': address,
        'timestamp': timestamp.toString(),
        'nonce': nonce,
        'message': 'This message attests that I control the given wallet',
      },
    };
  }

  /// EIP-712 types for Order struct
  static const Map<String, List<Map<String, String>>> _orderTypes = {
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
  };

  /// EIP-712 types for CLOB auth
  static const Map<String, List<Map<String, String>>> _authTypes = {
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
  };
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/digests/keccak.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart';

import '../../core/constants.dart';
import '../../core/trading_exceptions.dart';
import 'typed_data_builder.dart';

/// EIP-712 typed data signer for Polymarket orders.
///
/// Implements the EIP-712 standard for signing structured data,
/// specifically for Polymarket CTF Exchange orders.
class EIP712Signer {
  EIP712Signer._();

  /// Sign an order using EIP-712.
  ///
  /// Returns the signature in 0x{r}{s}{v} format (65 bytes).
  static String signOrder({
    required Map<String, dynamic> order,
    required EthPrivateKey credentials,
    required String verifyingContract,
    int chainId = PolymarketConstants.polygonChainId,
  }) {
    try {
      final typedData = TypedDataBuilder.buildOrderTypedData(
        order: order,
        verifyingContract: verifyingContract,
        chainId: chainId,
      );

      return _signTypedData(typedData, credentials);
    } catch (e, st) {
      throw SigningException(
        'Failed to sign order: $e',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Sign CLOB authentication message.
  ///
  /// Returns the signature in 0x{r}{s}{v} format (65 bytes).
  static String signAuth({
    required String address,
    required int timestamp,
    required int nonce,
    required EthPrivateKey credentials,
    int chainId = PolymarketConstants.polygonChainId,
  }) {
    try {
      final typedData = TypedDataBuilder.buildAuthTypedData(
        address: address,
        timestamp: timestamp,
        nonce: nonce,
        chainId: chainId,
      );

      return _signTypedData(typedData, credentials);
    } catch (e, st) {
      throw SigningException(
        'Failed to sign auth: $e',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Sign EIP-712 typed data and return signature.
  static String _signTypedData(
    Map<String, dynamic> typedData,
    EthPrivateKey credentials,
  ) {
    final hash = _hashTypedData(typedData);
    final signature = credentials.signToEcSignature(hash);
    return _encodeSignature(signature);
  }

  /// Hash typed data according to EIP-712.
  static Uint8List _hashTypedData(Map<String, dynamic> typedData) {
    final domainSeparator = _hashDomain(
      typedData['domain'] as Map<String, dynamic>,
      typedData['types'] as Map<String, List<Map<String, String>>>,
    );
    final structHash = _hashStruct(
      typedData['primaryType'] as String,
      typedData['message'] as Map<String, dynamic>,
      typedData['types'] as Map<String, List<Map<String, String>>>,
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

  /// Hash domain separator.
  static Uint8List _hashDomain(
    Map<String, dynamic> domain,
    Map<String, List<Map<String, String>>> types,
  ) {
    final domainFields = types['EIP712Domain']!;
    final typeString = _encodeType('EIP712Domain', types);
    final typeHash = _keccak256(utf8.encode(typeString));

    final values = <Uint8List>[typeHash];
    for (final field in domainFields) {
      final name = field['name']!;
      final type = field['type']!;
      if (domain.containsKey(name)) {
        values.add(_encodeField(type, domain[name]));
      }
    }

    return _keccak256(_concatBytes(values));
  }

  /// Hash a struct.
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

    return _keccak256(_concatBytes(values));
  }

  /// Encode type string for hashing.
  static String _encodeType(
    String typeName,
    Map<String, List<Map<String, String>>> types,
  ) {
    final fields = types[typeName]!;
    final params = fields.map((f) => '${f['type']} ${f['name']}').join(',');
    return '$typeName($params)';
  }

  /// Encode a field value for hashing.
  static Uint8List _encodeField(String type, dynamic value) {
    if (type == 'uint256' || type == 'uint8') {
      return _encodeBigInt(_toBigInt(value));
    } else if (type == 'address') {
      return _encodeAddress(value as String);
    } else if (type == 'string') {
      return _keccak256(utf8.encode(value as String));
    } else if (type == 'bytes32') {
      return _hexToBytes(value as String);
    } else if (type == 'bytes') {
      return _keccak256(_hexToBytes(value as String));
    } else if (type == 'bool') {
      return _encodeBigInt(BigInt.from(value == true ? 1 : 0));
    }
    throw ArgumentError('Unsupported EIP-712 type: $type');
  }

  /// Convert various types to BigInt.
  static BigInt _toBigInt(dynamic value) {
    if (value is BigInt) return value;
    if (value is int) return BigInt.from(value);
    if (value is String) {
      if (value.startsWith('0x')) {
        return BigInt.parse(value.substring(2), radix: 16);
      }
      return BigInt.parse(value);
    }
    throw ArgumentError('Cannot convert to BigInt: $value');
  }

  /// Encode BigInt as 32 bytes.
  static Uint8List _encodeBigInt(BigInt value) {
    final bytes = Uint8List(32);
    var temp = value;
    for (var i = 31; i >= 0; i--) {
      bytes[i] = (temp & BigInt.from(0xff)).toInt();
      temp = temp >> 8;
    }
    return bytes;
  }

  /// Encode address as 32 bytes (left-padded).
  static Uint8List _encodeAddress(String address) {
    final bytes = Uint8List(32);
    final addressBytes = _hexToBytes(address.replaceFirst('0x', ''));
    bytes.setRange(12, 32, addressBytes);
    return bytes;
  }

  /// Concatenate byte arrays.
  static Uint8List _concatBytes(List<Uint8List> values) {
    final result = <int>[];
    for (final v in values) {
      result.addAll(v);
    }
    return Uint8List.fromList(result);
  }

  /// Keccak256 hash.
  static Uint8List _keccak256(List<int> data) {
    final digest = KeccakDigest(256);
    return digest.process(Uint8List.fromList(data));
  }

  /// Convert hex string to bytes.
  static Uint8List _hexToBytes(String hex) {
    final clean = hex.replaceFirst('0x', '');
    final result = Uint8List(clean.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  /// Encode signature as 0x{r}{s}{v} string.
  static String _encodeSignature(MsgSignature sig) {
    final r = _bigIntToBytes(sig.r, 32);
    final s = _bigIntToBytes(sig.s, 32);
    final v = sig.v;
    return '0x${_bytesToHex(Uint8List.fromList([...r, ...s, v]))}';
  }

  /// Convert BigInt to fixed-length bytes.
  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final bytes = Uint8List(length);
    var temp = value;
    for (var i = length - 1; i >= 0; i--) {
      bytes[i] = (temp & BigInt.from(0xff)).toInt();
      temp = temp >> 8;
    }
    return bytes;
  }

  /// Convert bytes to hex string.
  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

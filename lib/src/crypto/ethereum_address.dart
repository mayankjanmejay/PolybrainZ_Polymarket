import 'dart:typed_data';

import 'package:pointycastle/digests/keccak.dart';

/// Ethereum address (20 bytes).
///
/// This is an internal implementation that replaces webthree's EthereumAddress.
class EthereumAddress {
  final Uint8List _bytes;

  /// Create from raw bytes (must be exactly 20 bytes).
  EthereumAddress(Uint8List bytes)
      : _bytes = bytes.length == 20
            ? Uint8List.fromList(bytes)
            : throw ArgumentError('Address must be exactly 20 bytes');

  /// Create from hex string (with or without 0x prefix).
  factory EthereumAddress.fromHex(String hex) {
    final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
    if (clean.length != 40) {
      throw ArgumentError('Address must be 40 hex characters');
    }
    return EthereumAddress(_hexToBytes(clean));
  }

  /// Get the raw address bytes.
  Uint8List get addressBytes => Uint8List.fromList(_bytes);

  /// Get the address as hex string without 0x prefix.
  String get hex => _bytesToHex(_bytes);

  /// Get the address as hex string with 0x prefix.
  String get hexWith0x => '0x$hex';

  /// Get the address in EIP-55 checksum format.
  String get hexEip55 {
    final lowerHex = hex.toLowerCase();
    final hash = _keccak256(lowerHex.codeUnits);
    final hashHex = _bytesToHex(hash);

    final result = StringBuffer();
    for (var i = 0; i < lowerHex.length; i++) {
      final char = lowerHex[i];
      if (int.tryParse(char, radix: 16) != null && int.parse(char, radix: 16) >= 10) {
        // It's a letter (a-f)
        final hashChar = int.parse(hashHex[i], radix: 16);
        if (hashChar >= 8) {
          result.write(char.toUpperCase());
        } else {
          result.write(char);
        }
      } else {
        result.write(char);
      }
    }
    return '0x${result.toString()}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EthereumAddress) return false;
    for (var i = 0; i < 20; i++) {
      if (_bytes[i] != other._bytes[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => hex.hashCode;

  @override
  String toString() => hexEip55;

  static Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List _keccak256(List<int> data) {
    final digest = KeccakDigest(256);
    return digest.process(Uint8List.fromList(data));
  }
}

import 'dart:typed_data';

/// Ethereum signature with r, s, and v components.
///
/// This is an internal implementation that replaces webthree's MsgSignature.
class EthSignature {
  /// The r component of the signature.
  final BigInt r;

  /// The s component of the signature.
  final BigInt s;

  /// The recovery id (v) of the signature (27 or 28 for legacy, 0 or 1 for EIP-155).
  final int v;

  const EthSignature(this.r, this.s, this.v);

  /// Encode as 65-byte signature in r || s || v format.
  Uint8List toBytes() {
    final result = Uint8List(65);
    result.setRange(0, 32, _bigIntToBytes(r, 32));
    result.setRange(32, 64, _bigIntToBytes(s, 32));
    result[64] = v;
    return result;
  }

  /// Encode as hex string with 0x prefix.
  String toHex() {
    return '0x${_bytesToHex(toBytes())}';
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

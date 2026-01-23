import 'dart:typed_data';

import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/pointycastle.dart';

/// BIP32 HD wallet implementation using pointycastle 4.x directly.
///
/// This replaces the bip32 package which is stuck on pointycastle 3.x.
class Bip32 {
  static final _secp256k1 = ECCurve_secp256k1();
  static const _hardenedOffset = 0x80000000;

  final Uint8List _privateKey;
  final Uint8List _chainCode;

  Bip32._(this._privateKey, this._chainCode);

  /// Create a BIP32 node from seed bytes.
  factory Bip32.fromSeed(Uint8List seed) {
    if (seed.length < 16 || seed.length > 64) {
      throw ArgumentError('Seed must be between 16 and 64 bytes');
    }

    final hmac = HMac(SHA512Digest(), 128);
    hmac.init(KeyParameter(Uint8List.fromList('Bitcoin seed'.codeUnits)));
    final result = Uint8List(64);
    hmac.update(seed, 0, seed.length);
    hmac.doFinal(result, 0);

    return Bip32._(
      result.sublist(0, 32),
      result.sublist(32, 64),
    );
  }

  /// Get the private key bytes.
  Uint8List? get privateKey => _privateKey;

  /// Derive a child key using BIP32 path.
  ///
  /// Supports paths like "m/44'/60'/0'/0/0"
  Bip32 derivePath(String path) {
    final parts = path.split('/');
    Bip32 node = this;

    for (final part in parts) {
      if (part == 'm') continue;
      if (part.isEmpty) continue;

      final hardened = part.endsWith("'");
      final indexStr = hardened ? part.substring(0, part.length - 1) : part;
      final index = int.parse(indexStr);

      if (hardened) {
        node = node._deriveHardened(index);
      } else {
        node = node._deriveNormal(index);
      }
    }

    return node;
  }

  Bip32 _deriveHardened(int index) {
    final data = Uint8List(37);
    data[0] = 0;
    data.setRange(1, 33, _privateKey);
    _writeUint32BE(data, 33, index + _hardenedOffset);

    return _derive(data);
  }

  Bip32 _deriveNormal(int index) {
    final publicKey = _getPublicKey();
    final data = Uint8List(37);
    data.setRange(0, 33, publicKey);
    _writeUint32BE(data, 33, index);

    return _derive(data);
  }

  Bip32 _derive(Uint8List data) {
    final hmac = HMac(SHA512Digest(), 128);
    hmac.init(KeyParameter(_chainCode));
    final result = Uint8List(64);
    hmac.update(data, 0, data.length);
    hmac.doFinal(result, 0);

    final il = result.sublist(0, 32);
    final ir = result.sublist(32, 64);

    // Child private key = (IL + parent private key) mod n
    final ilInt = _bytesToBigInt(il);
    final pkInt = _bytesToBigInt(_privateKey);
    final n = _secp256k1.n;
    final childPkInt = (ilInt + pkInt) % n;

    if (ilInt >= n || childPkInt == BigInt.zero) {
      throw StateError('Invalid child key');
    }

    final childPk = _bigIntToBytes(childPkInt, 32);

    return Bip32._(childPk, ir);
  }

  Uint8List _getPublicKey() {
    final d = _bytesToBigInt(_privateKey);
    final q = _secp256k1.G * d;
    return _encodePointCompressed(q!);
  }

  Uint8List _encodePointCompressed(ECPoint point) {
    final x = point.x!.toBigInteger()!;
    final y = point.y!.toBigInteger()!;
    final result = Uint8List(33);
    result[0] = y.isOdd ? 0x03 : 0x02;
    final xBytes = _bigIntToBytes(x, 32);
    result.setRange(1, 33, xBytes);
    return result;
  }

  static BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      result = (result << 8) | BigInt.from(bytes[i]);
    }
    return result;
  }

  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final result = Uint8List(length);
    var temp = value;
    for (int i = length - 1; i >= 0; i--) {
      result[i] = (temp & BigInt.from(0xff)).toInt();
      temp = temp >> 8;
    }
    return result;
  }

  static void _writeUint32BE(Uint8List buffer, int offset, int value) {
    buffer[offset] = (value >> 24) & 0xff;
    buffer[offset + 1] = (value >> 16) & 0xff;
    buffer[offset + 2] = (value >> 8) & 0xff;
    buffer[offset + 3] = value & 0xff;
  }
}

import 'dart:typed_data';

import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/signers/ecdsa_signer.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/keccak.dart';
import 'package:pointycastle/macs/hmac.dart';

import 'eth_signature.dart';
import 'ethereum_address.dart';

/// Ethereum private key for signing transactions and messages.
///
/// This is an internal implementation that replaces webthree's EthPrivateKey,
/// using pointycastle 4.x directly to avoid dart_style version conflicts.
class EthPrivateKey {
  final Uint8List _privateKey;
  final ECPrivateKey _ecPrivateKey;

  EthPrivateKey._(this._privateKey, this._ecPrivateKey);

  /// Create from hex string (with or without 0x prefix).
  factory EthPrivateKey.fromHex(String hex) {
    final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
    if (clean.length != 64) {
      throw ArgumentError('Private key must be 32 bytes (64 hex characters)');
    }

    final bytes = _hexToBytes(clean);
    final d = _bytesToBigInt(bytes);
    final ecPrivateKey = ECPrivateKey(d, ECCurve_secp256k1());

    return EthPrivateKey._(bytes, ecPrivateKey);
  }

  /// Get the private key as bytes.
  Uint8List get privateKey => Uint8List.fromList(_privateKey);

  /// Get the private key as hex string (without 0x prefix).
  String get privateKeyHex => _bytesToHex(_privateKey);

  /// Get the Ethereum address derived from this private key.
  EthereumAddress get address {
    final params = ECCurve_secp256k1();
    final publicKey = params.G * _ecPrivateKey.d;

    // Get uncompressed public key (without 0x04 prefix)
    final x = _bigIntToBytes(publicKey!.x!.toBigInteger()!, 32);
    final y = _bigIntToBytes(publicKey.y!.toBigInteger()!, 32);
    final pubKeyBytes = Uint8List.fromList([...x, ...y]);

    // Keccak256 hash of public key
    final hash = _keccak256(pubKeyBytes);

    // Take last 20 bytes as address
    final addressBytes = hash.sublist(12);
    return EthereumAddress(addressBytes);
  }

  /// Sign a message hash and return the signature.
  ///
  /// The hash must be exactly 32 bytes.
  Future<EthSignature> signToSignature(Uint8List hash) async {
    if (hash.length != 32) {
      throw ArgumentError('Hash must be exactly 32 bytes');
    }

    final signer = ECDSASigner(null, HMac(KeccakDigest(256), 136));
    signer.init(
      true,
      PrivateKeyParameter<ECPrivateKey>(_ecPrivateKey),
    );

    final sig = signer.generateSignature(hash) as ECSignature;

    // Normalize s to lower half of curve order (EIP-2)
    final params = ECCurve_secp256k1();
    final halfN = params.n >> 1;
    BigInt s = sig.s;
    if (s > halfN) {
      s = params.n - s;
    }

    // Calculate recovery id (v)
    final v = _calculateRecoveryId(hash, sig.r, s, address);

    return EthSignature(sig.r, s, v);
  }

  /// Calculate recovery ID for signature verification.
  int _calculateRecoveryId(
      Uint8List hash, BigInt r, BigInt s, EthereumAddress expectedAddress) {
    final params = ECCurve_secp256k1();

    // Try v = 27 and v = 28
    for (int v = 0; v < 2; v++) {
      try {
        final recoveredKey = _recoverPublicKey(hash, r, s, v, params);
        if (recoveredKey != null) {
          final recoveredAddress = _publicKeyToAddress(recoveredKey);
          if (recoveredAddress.hex.toLowerCase() ==
              expectedAddress.hex.toLowerCase()) {
            return 27 + v;
          }
        }
      } catch (_) {
        continue;
      }
    }

    // Default to 27 if recovery fails
    return 27;
  }

  /// Recover public key from signature.
  ECPoint? _recoverPublicKey(
      Uint8List hash, BigInt r, BigInt s, int recId, ECDomainParameters params) {
    final n = params.n;
    final i = BigInt.from(recId ~/ 2);
    final x = r + (i * n);

    // Check if x is within valid range (use n as approximation for field prime)
    if (x >= params.n) return null;

    final R = _decompressKey(x, (recId & 1) == 1, params.curve);
    if (R == null || !(R * n)!.isInfinity) return null;

    final e = _bytesToBigInt(hash);
    final eInv = (n - e) % n;
    final rInv = r.modInverse(n);
    final srInv = (s * rInv) % n;
    final eInvrInv = (eInv * rInv) % n;

    final q = (params.G * eInvrInv)! + (R * srInv)!;
    return q;
  }

  /// Decompress an EC point.
  ECPoint? _decompressKey(BigInt x, bool yBit, ECCurve curve) {
    final compEnc = _bigIntToBytes(x, 32);
    final enc = Uint8List(33);
    enc[0] = yBit ? 0x03 : 0x02;
    enc.setRange(1, 33, compEnc);
    return curve.decodePoint(enc);
  }

  /// Convert public key to Ethereum address.
  EthereumAddress _publicKeyToAddress(ECPoint publicKey) {
    final x = _bigIntToBytes(publicKey.x!.toBigInteger()!, 32);
    final y = _bigIntToBytes(publicKey.y!.toBigInteger()!, 32);
    final pubKeyBytes = Uint8List.fromList([...x, ...y]);
    final hash = _keccak256(pubKeyBytes);
    return EthereumAddress(hash.sublist(12));
  }

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

  static BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
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

  static Uint8List _keccak256(List<int> data) {
    final digest = KeccakDigest(256);
    return digest.process(Uint8List.fromList(data));
  }
}

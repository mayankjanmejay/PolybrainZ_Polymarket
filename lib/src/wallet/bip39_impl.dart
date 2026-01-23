import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

import 'wordlist_english.dart';

/// BIP39 mnemonic implementation using pointycastle 4.x directly.
///
/// This replaces the bip39 package which is stuck on pointycastle 3.x.
class Bip39 {
  Bip39._();

  /// Generate a new mnemonic with specified strength (128 = 12 words, 256 = 24 words).
  static String generateMnemonic({int strength = 256}) {
    if (strength % 32 != 0 || strength < 128 || strength > 256) {
      throw ArgumentError('Strength must be 128, 160, 192, 224, or 256');
    }

    final random = Random.secure();
    final entropy = Uint8List(strength ~/ 8);
    for (int i = 0; i < entropy.length; i++) {
      entropy[i] = random.nextInt(256);
    }

    return _entropyToMnemonic(entropy);
  }

  /// Validate a mnemonic phrase.
  static bool validateMnemonic(String mnemonic) {
    try {
      _mnemonicToEntropy(mnemonic);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Convert mnemonic to seed bytes.
  static Uint8List mnemonicToSeed(String mnemonic, {String passphrase = ''}) {
    final mnemonicBytes = utf8.encode(_normalizeString(mnemonic));
    final salt = utf8.encode('mnemonic${_normalizeString(passphrase)}');

    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(Uint8List.fromList(salt), 2048, 64));

    return pbkdf2.process(Uint8List.fromList(mnemonicBytes));
  }

  static String _entropyToMnemonic(Uint8List entropy) {
    final entropyBits = _bytesToBits(entropy);
    final checksumBits = _deriveChecksumBits(entropy);
    final bits = entropyBits + checksumBits;

    final words = <String>[];
    for (int i = 0; i < bits.length; i += 11) {
      final index = int.parse(bits.substring(i, i + 11), radix: 2);
      words.add(englishWordlist[index]);
    }

    return words.join(' ');
  }

  static Uint8List _mnemonicToEntropy(String mnemonic) {
    final words = _normalizeString(mnemonic).split(' ');
    if (words.length % 3 != 0 || words.length < 12 || words.length > 24) {
      throw ArgumentError('Invalid mnemonic length');
    }

    final bits = StringBuffer();
    for (final word in words) {
      final index = englishWordlist.indexOf(word);
      if (index == -1) {
        throw ArgumentError('Invalid mnemonic word: $word');
      }
      bits.write(index.toRadixString(2).padLeft(11, '0'));
    }

    final bitsStr = bits.toString();
    final dividerIndex = (bitsStr.length / 33).floor() * 32;
    final entropyBits = bitsStr.substring(0, dividerIndex);
    final checksumBits = bitsStr.substring(dividerIndex);

    final entropy = _bitsToBytes(entropyBits);
    final newChecksumBits = _deriveChecksumBits(entropy);

    if (checksumBits != newChecksumBits) {
      throw ArgumentError('Invalid mnemonic checksum');
    }

    return entropy;
  }

  static String _bytesToBits(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(2).padLeft(8, '0')).join();
  }

  static Uint8List _bitsToBytes(String bits) {
    final bytes = Uint8List(bits.length ~/ 8);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(bits.substring(i * 8, (i + 1) * 8), radix: 2);
    }
    return bytes;
  }

  static String _deriveChecksumBits(Uint8List entropy) {
    final hash = crypto.sha256.convert(entropy).bytes;
    final checksumLength = entropy.length ~/ 4;
    return _bytesToBits(Uint8List.fromList(hash)).substring(0, checksumLength);
  }

  static String _normalizeString(String str) {
    return str.trim().split(RegExp(r'\s+')).join(' ').toLowerCase();
  }
}

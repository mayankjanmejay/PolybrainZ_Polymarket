import '../crypto/crypto.dart';
import 'bip32_impl.dart';
import 'bip39_impl.dart';
import 'wallet_credentials.dart';

/// HD Wallet generation and management.
///
/// Supports BIP-39 mnemonic phrases and BIP-32/BIP-44 derivation paths.
class HdWallet {
  HdWallet._();

  /// Standard Ethereum derivation path prefix (BIP-44)
  static const String derivationPathPrefix = "m/44'/60'/0'/0/";

  /// Generate a new 24-word mnemonic (256 bits of entropy).
  static String generateMnemonic() {
    return Bip39.generateMnemonic(strength: 256);
  }

  /// Generate a new 12-word mnemonic (128 bits of entropy).
  static String generateMnemonic12() {
    return Bip39.generateMnemonic(strength: 128);
  }

  /// Validate a mnemonic phrase.
  static bool validateMnemonic(String mnemonic) {
    return Bip39.validateMnemonic(mnemonic);
  }

  /// Derive a wallet from mnemonic at given index.
  ///
  /// Uses standard Ethereum derivation path: m/44'/60'/0'/0/{index}
  ///
  /// Throws [ArgumentError] if mnemonic is invalid.
  static WalletCredentials deriveWallet({
    required String mnemonic,
    required int index,
  }) {
    if (!validateMnemonic(mnemonic)) {
      throw ArgumentError('Invalid mnemonic phrase');
    }

    if (index < 0) {
      throw ArgumentError('Index must be non-negative');
    }

    final seed = Bip39.mnemonicToSeed(mnemonic);
    final root = Bip32.fromSeed(seed);
    final child = root.derivePath('$derivationPathPrefix$index');

    if (child.privateKey == null) {
      throw StateError('Failed to derive private key');
    }

    final privateKeyHex = _bytesToHex(child.privateKey!);
    final credentials = EthPrivateKey.fromHex(privateKeyHex);
    final address = credentials.address.hexEip55;

    return WalletCredentials(
      address: address,
      privateKey: '0x$privateKeyHex',
      derivationIndex: index,
    );
  }

  /// Derive multiple wallets from mnemonic.
  ///
  /// Returns a list of [count] wallets starting from [startIndex].
  static List<WalletCredentials> deriveWallets({
    required String mnemonic,
    required int count,
    int startIndex = 0,
  }) {
    if (count <= 0) {
      throw ArgumentError('Count must be positive');
    }

    return List.generate(
      count,
      (i) => deriveWallet(mnemonic: mnemonic, index: startIndex + i),
    );
  }

  /// Get EthPrivateKey from hex string.
  ///
  /// Accepts both 0x-prefixed and non-prefixed hex strings.
  static EthPrivateKey getCredentials(String privateKeyHex) {
    return EthPrivateKey.fromHex(privateKeyHex);
  }

  /// Get address from private key.
  static String getAddress(String privateKeyHex) {
    final credentials = getCredentials(privateKeyHex);
    return credentials.address.hexEip55;
  }

  /// Convert bytes to hex string.
  static String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

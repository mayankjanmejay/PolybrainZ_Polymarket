import 'package:equatable/equatable.dart';
import 'package:webthree/webthree.dart';

/// Wallet credentials container for HD wallet derived keys.
class WalletCredentials extends Equatable {
  /// Ethereum address (EIP-55 checksum format)
  final String address;

  /// Private key (0x-prefixed hex string)
  final String privateKey;

  /// Derivation index in HD wallet path
  final int derivationIndex;

  const WalletCredentials({
    required this.address,
    required this.privateKey,
    required this.derivationIndex,
  });

  /// Get web3dart credentials for signing transactions.
  EthPrivateKey get ethCredentials => EthPrivateKey.fromHex(privateKey);

  /// Get address in lowercase format.
  String get addressLower => address.toLowerCase();

  /// Get address as EthereumAddress.
  EthereumAddress get ethereumAddress => EthereumAddress.fromHex(address);

  /// Validate that the private key matches the address.
  bool validate() {
    try {
      final derived = ethCredentials.address.hexEip55;
      return derived.toLowerCase() == address.toLowerCase();
    } catch (_) {
      return false;
    }
  }

  @override
  List<Object?> get props => [address, derivationIndex];

  @override
  String toString() =>
      'WalletCredentials(address: $address, index: $derivationIndex)';
}

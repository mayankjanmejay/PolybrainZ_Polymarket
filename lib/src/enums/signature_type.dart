/// Signature type for authentication.
enum SignatureType {
  /// Standard externally owned account (MetaMask, hardware wallets)
  eoa(0),

  /// Magic link or email-based wallets
  emailMagic(1),

  /// Browser extension wallets with proxy (Coinbase Wallet)
  browserWallet(2);

  const SignatureType(this.value);
  final int value;

  int toJson() => value;

  static SignatureType fromJson(int json) {
    return SignatureType.values.firstWhere(
      (e) => e.value == json,
      orElse: () => eoa,
    );
  }
}

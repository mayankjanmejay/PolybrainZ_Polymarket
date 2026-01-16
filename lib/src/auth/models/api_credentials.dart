import 'package:equatable/equatable.dart';

/// API credentials for L2 authentication.
///
/// These credentials are obtained through L1 authentication
/// and used for all trading operations.
class ApiCredentials extends Equatable {
  /// The API key
  final String apiKey;

  /// The secret for HMAC signing
  final String secret;

  /// The passphrase
  final String passphrase;

  const ApiCredentials({
    required this.apiKey,
    required this.secret,
    required this.passphrase,
  });

  /// Whether credentials are set
  bool get isValid =>
      apiKey.isNotEmpty && secret.isNotEmpty && passphrase.isNotEmpty;

  @override
  List<Object?> get props => [apiKey, secret, passphrase];

  @override
  String toString() => 'ApiCredentials(apiKey: ${apiKey.substring(0, 8)}...)';
}

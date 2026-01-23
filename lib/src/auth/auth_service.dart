import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';
import 'models/api_credentials.dart';
import 'l1_auth.dart';
import 'l2_auth.dart';

/// Service for managing authentication.
class AuthService {
  final ApiClient _client;
  final String walletAddress;
  final String? privateKey;
  final int chainId;

  ApiCredentials? _credentials;
  L2Auth? _l2Auth;

  AuthService({
    required ApiClient client,
    required this.walletAddress,
    this.privateKey,
    this.chainId = PolymarketConstants.polygonChainId,
  }) : _client = client;

  /// Set API credentials directly (if already have them).
  void setCredentials(ApiCredentials credentials) {
    _credentials = credentials;
    _l2Auth = L2Auth(
      credentials: credentials,
      walletAddress: walletAddress,
    );
  }

  /// Get current credentials.
  ApiCredentials? get credentials => _credentials;

  /// Whether we have valid credentials.
  bool get hasCredentials => _credentials?.isValid ?? false;

  /// Get L2 auth headers for a request.
  ///
  /// Throws if no credentials are set.
  Map<String, String> getAuthHeaders({
    required String method,
    required String path,
    String? body,
  }) {
    if (_l2Auth == null) {
      throw const AuthenticationException(
          'No credentials set. Call setCredentials() first.');
    }
    return _l2Auth!.getHeaders(
      method: method,
      path: path,
      body: body,
    );
  }

  /// Create new API key (L1 auth required).
  ///
  /// This creates a NEW key - use deriveApiKey if you want
  /// to get the same key back.
  Future<ApiCredentials> createApiKey() async {
    if (privateKey == null) {
      throw const AuthenticationException(
        'Private key required to create API key',
      );
    }

    final l1Auth = L1Auth(
      privateKey: privateKey!,
      walletAddress: walletAddress,
      chainId: chainId,
    );

    final response = await _client.post<Map<String, dynamic>>(
      '/auth/api-key',
      headers: await l1Auth.getHeaders(),
    );

    final credentials = ApiCredentials(
      apiKey: response['apiKey'] as String,
      secret: response['secret'] as String,
      passphrase: response['passphrase'] as String,
    );

    setCredentials(credentials);
    return credentials;
  }

  /// Derive existing API key (L1 auth required).
  ///
  /// Returns the same key for the same wallet - use this
  /// to recover existing credentials.
  Future<ApiCredentials> deriveApiKey() async {
    if (privateKey == null) {
      throw const AuthenticationException(
        'Private key required to derive API key',
      );
    }

    final l1Auth = L1Auth(
      privateKey: privateKey!,
      walletAddress: walletAddress,
      chainId: chainId,
    );

    final response = await _client.get<Map<String, dynamic>>(
      '/auth/derive-api-key',
      headers: await l1Auth.getHeaders(),
    );

    final credentials = ApiCredentials(
      apiKey: response['apiKey'] as String,
      secret: response['secret'] as String,
      passphrase: response['passphrase'] as String,
    );

    setCredentials(credentials);
    return credentials;
  }

  /// Create or derive API key.
  ///
  /// Tries to derive first, creates if not found.
  Future<ApiCredentials> createOrDeriveApiKey() async {
    try {
      return await deriveApiKey();
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return await createApiKey();
      }
      rethrow;
    }
  }

  /// Delete API key.
  Future<void> deleteApiKey() async {
    if (_credentials == null) {
      throw const AuthenticationException('No credentials to delete');
    }

    await _client.delete<void>(
      '/auth/api-key',
      headers: getAuthHeaders(
        method: 'DELETE',
        path: '/auth/api-key',
      ),
    );

    _credentials = null;
    _l2Auth = null;
  }
}

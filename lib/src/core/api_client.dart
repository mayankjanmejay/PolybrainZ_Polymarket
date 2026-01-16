import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'constants.dart';
import 'exceptions.dart';

/// Base HTTP client for API requests.
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final Duration timeout;
  final int maxRetries;

  /// Headers to include with every request
  final Map<String, String> _defaultHeaders;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.timeout = PolymarketConstants.defaultTimeout,
    this.maxRetries = PolymarketConstants.defaultMaxRetries,
    Map<String, String>? defaultHeaders,
  })  : _httpClient = httpClient ?? http.Client(),
        _defaultHeaders = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?defaultHeaders,
        };

  /// Make a GET request.
  Future<T> get<T>(
    String path, {
    Map<String, String>? queryParams,
    T Function(dynamic json)? fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParams);
    final response = await _executeWithRetry(
      () => _httpClient.get(uri, headers: _mergeHeaders(headers)),
      method: 'GET',
      path: path,
    );
    return _parseResponse(response, fromJson);
  }

  /// Make a POST request.
  Future<T> post<T>(
    String path, {
    Object? body,
    T Function(dynamic json)? fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final response = await _executeWithRetry(
      () => _httpClient.post(
        uri,
        headers: _mergeHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      ),
      method: 'POST',
      path: path,
    );
    return _parseResponse(response, fromJson);
  }

  /// Make a DELETE request.
  Future<T> delete<T>(
    String path, {
    Object? body,
    T Function(dynamic json)? fromJson,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final response = await _executeWithRetry(
      () => _httpClient.delete(
        uri,
        headers: _mergeHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      ),
      method: 'DELETE',
      path: path,
    );
    return _parseResponse(response, fromJson);
  }

  /// Build URI with query parameters.
  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParams == null || queryParams.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams,
    });
  }

  /// Merge headers with defaults.
  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {
      ..._defaultHeaders,
      ...?headers,
    };
  }

  /// Execute request with retry logic.
  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request, {
    required String method,
    required String path,
  }) async {
    int attempts = 0;

    while (true) {
      attempts++;
      try {
        final response = await request().timeout(timeout);

        // Check for rate limiting
        if (response.statusCode == 429) {
          if (attempts >= maxRetries) {
            throw RateLimitException(
              'Rate limit exceeded after $attempts attempts',
              retryAfter: _parseRetryAfter(response.headers['retry-after']),
            );
          }

          final retryAfter = _parseRetryAfter(response.headers['retry-after']) ??
              Duration(seconds: attempts * 2);
          await Future.delayed(retryAfter);
          continue;
        }

        // Check for server errors (retry on 5xx)
        if (response.statusCode >= 500 && attempts < maxRetries) {
          await Future.delayed(Duration(seconds: attempts));
          continue;
        }

        return response;
      } on TimeoutException catch (e) {
        if (attempts >= maxRetries) {
          throw TimeoutException(
            'Request timed out after $attempts attempts',
            timeout: timeout,
            originalError: e,
          );
        }
        await Future.delayed(Duration(seconds: attempts));
      } on SocketException catch (e) {
        if (attempts >= maxRetries) {
          throw NetworkException(
            'Network error after $attempts attempts: ${e.message}',
            originalError: e,
          );
        }
        await Future.delayed(Duration(seconds: attempts));
      }
    }
  }

  /// Parse response body.
  T _parseResponse<T>(
    http.Response response,
    T Function(dynamic json)? fromJson,
  ) {
    // Handle error responses
    if (response.statusCode >= 400) {
      _handleErrorResponse(response);
    }

    // Parse JSON
    final dynamic json;
    try {
      json = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } on FormatException catch (e) {
      throw ApiException(
        'Invalid JSON response',
        statusCode: response.statusCode,
        responseBody: response.body,
        originalError: e,
      );
    }

    // Transform or return raw
    if (fromJson != null) {
      return fromJson(json);
    }
    return json as T;
  }

  /// Handle error responses.
  Never _handleErrorResponse(http.Response response) {
    final message = _extractErrorMessage(response);

    switch (response.statusCode) {
      case 400:
        throw ValidationException(message);
      case 401:
        throw AuthenticationException(message);
      case 403:
        throw AuthenticationException('Access denied: $message');
      case 404:
        throw NotFoundException(message);
      case 429:
        throw RateLimitException(
          message,
          retryAfter: _parseRetryAfter(response.headers['retry-after']),
        );
      default:
        if (response.statusCode >= 500) {
          throw ServerException(
            message,
            statusCode: response.statusCode,
            responseBody: response.body,
          );
        }
        throw ApiException(
          message,
          statusCode: response.statusCode,
          responseBody: response.body,
        );
    }
  }

  /// Extract error message from response.
  String _extractErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      if (json is Map) {
        return json['error'] ??
            json['message'] ??
            json['error_message'] ??
            json['errorMsg'] ??
            'Request failed with status ${response.statusCode}';
      }
    } catch (_) {}

    if (response.body.isNotEmpty && response.body.length < 200) {
      return response.body;
    }

    return 'Request failed with status ${response.statusCode}';
  }

  /// Parse Retry-After header.
  Duration? _parseRetryAfter(String? value) {
    if (value == null) return null;
    final seconds = int.tryParse(value);
    if (seconds != null) return Duration(seconds: seconds);
    return null;
  }

  /// Close the client.
  void close() {
    _httpClient.close();
  }
}

/// Extension for paginated requests.
extension PaginatedRequests on ApiClient {
  /// Fetch all pages of a paginated endpoint.
  Future<List<T>> getAllPages<T>({
    required String path,
    required T Function(Map<String, dynamic>) itemFromJson,
    String itemsKey = 'data',
    int pageSize = 100,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final allItems = <T>[];
    int offset = 0;

    while (true) {
      final response = await get<Map<String, dynamic>>(
        path,
        queryParams: {
          ...?queryParams,
          'limit': pageSize.toString(),
          'offset': offset.toString(),
        },
        headers: headers,
      );

      final items = response[itemsKey] as List?;
      if (items == null || items.isEmpty) break;

      for (final item in items) {
        allItems.add(itemFromJson(item as Map<String, dynamic>));
      }

      if (items.length < pageSize) break;
      offset += pageSize;
    }

    return allItems;
  }
}

// Test raw API response to see structure
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing raw Polymarket Tags API...');

  final client = http.Client();

  try {
    // Try the tags endpoint
    final response = await client.get(
      Uri.parse('https://gamma-api.polymarket.com/tags?limit=10'),
    );

    print('Status: ${response.statusCode}');
    print('Response:');

    final data = jsonDecode(response.body);
    final encoder = JsonEncoder.withIndent('  ');

    if (data is List && data.isNotEmpty) {
      print('First tag:');
      print(encoder.convert(data.first));

      print('\n\nAll tag keys:');
      final keys = (data.first as Map<String, dynamic>).keys.toList();
      print(keys);
    } else {
      print(encoder.convert(data));
    }

  } catch (e, st) {
    print('ERROR: $e');
    print('Stack: $st');
  }

  client.close();
}

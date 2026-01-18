// Test various Gamma API endpoints to find category data
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing Polymarket Gamma API endpoints...\n');

  final client = http.Client();
  final encoder = JsonEncoder.withIndent('  ');

  Future<void> testEndpoint(String name, String url) async {
    try {
      print('=== $name ===');
      final response = await client.get(Uri.parse(url));
      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          print('Got ${data.length} items');
          if (data.isNotEmpty) {
            print('First item keys: ${(data.first as Map<String, dynamic>).keys.toList()}');
            print('Sample: ${encoder.convert(data.first)}');
          }
        } else if (data is Map) {
          print('Response keys: ${data.keys.toList()}');
          if (data.length < 20) {
            print('Response: ${encoder.convert(data)}');
          }
        }
      } else {
        print('Error body: ${response.body.substring(0, 200)}');
      }
    } catch (e) {
      print('ERROR: $e');
    }
    print('\n');
  }

  // Test various endpoints
  await testEndpoint('Events (trending)', 'https://gamma-api.polymarket.com/events?limit=5&order=volume24hr&ascending=false&active=true');
  await testEndpoint('Categories', 'https://gamma-api.polymarket.com/categories?limit=20');
  await testEndpoint('Markets by tag (politics)', 'https://gamma-api.polymarket.com/markets?tag=politics&limit=3&active=true');
  await testEndpoint('Events by tag slug', 'https://gamma-api.polymarket.com/events?tag_slug=politics&limit=3');
  await testEndpoint('Featured', 'https://gamma-api.polymarket.com/events?featured=true&limit=3');

  client.close();
}

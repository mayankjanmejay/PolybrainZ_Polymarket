// Test tag_slug parameter in events API
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing tag_slug parameter in Gamma Events API...\n');

  final client = http.Client();

  Future<void> testTagSlug(String tagSlug) async {
    final uri = Uri.parse('https://gamma-api.polymarket.com/events').replace(queryParameters: {
      'tag_slug': tagSlug,
      'limit': '10',
      'active': 'true',
      'closed': 'false',
      'order': 'volume24hr',
      'ascending': 'false',
    });

    print('Testing tag_slug="$tagSlug"');
    print('URL: $uri');

    try {
      final response = await client.get(uri);
      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final events = jsonDecode(response.body) as List;
        print('Got ${events.length} events');

        if (events.isNotEmpty) {
          final first = events.first as Map<String, dynamic>;
          print('First event: ${first['title']}');
          final tags = first['tags'] as List? ?? [];
          print('Tags: ${tags.map((t) => t['slug']).join(', ')}');
        }
      } else {
        print('Error: ${response.body.substring(0, 200)}');
      }
    } catch (e) {
      print('ERROR: $e');
    }
    print('---\n');
  }

  // Test various tag slugs
  await testTagSlug('sports');
  await testTagSlug('politics');
  await testTagSlug('crypto');
  await testTagSlug('nba');
  await testTagSlug('basketball');

  client.close();
}

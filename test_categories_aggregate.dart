// Test aggregating categories from trending events
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing category aggregation from trending events...\n');

  final client = http.Client();

  try {
    // Fetch trending events
    final uri = Uri.parse('https://gamma-api.polymarket.com/events').replace(queryParameters: {
      'limit': '200',
      'active': 'true',
      'closed': 'false',
      'order': 'volume24hr',
      'ascending': 'false',
    });

    print('Fetching events from: $uri\n');

    final response = await client.get(uri);
    print('Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      print('Error: ${response.body}');
      return;
    }

    final events = jsonDecode(response.body) as List;
    print('Got ${events.length} events\n');

    // Aggregate tags from events
    final tagCounts = <String, Map<String, dynamic>>{};

    for (final event in events) {
      final tags = event['tags'] as List?;
      if (tags == null) continue;

      for (final tag in tags) {
        final slug = tag['slug'] as String? ?? '';
        if (slug.isEmpty) continue;

        if (!tagCounts.containsKey(slug)) {
          tagCounts[slug] = {
            'id': tag['id'] ?? 0,
            'label': tag['label'] ?? slug,
            'slug': slug,
            'eventCount': 0,
            'volume24hr': 0.0,
          };
        }
        tagCounts[slug]!['eventCount'] = (tagCounts[slug]!['eventCount'] as int) + 1;
        tagCounts[slug]!['volume24hr'] = (tagCounts[slug]!['volume24hr'] as double) +
            (event['volume24hr'] as num? ?? 0).toDouble();
      }
    }

    // Sort by event count
    final sortedTags = tagCounts.values.toList()
      ..sort((a, b) {
        final countCompare = (b['eventCount'] as int).compareTo(a['eventCount'] as int);
        if (countCompare != 0) return countCompare;
        return (b['volume24hr'] as double).compareTo(a['volume24hr'] as double);
      });

    print('Found ${sortedTags.length} unique tags/categories\n');
    print('Top 20 categories by event count:');
    print('-' * 50);

    for (var i = 0; i < 20 && i < sortedTags.length; i++) {
      final tag = sortedTags[i];
      final vol = (tag['volume24hr'] as double) / 1000000; // Convert to millions
      print('${i + 1}. ${tag['label']} (${tag['slug']})');
      print('   Events: ${tag['eventCount']}, Volume24hr: \$${vol.toStringAsFixed(2)}M');
    }

  } catch (e, st) {
    print('ERROR: $e');
    print('Stack: $st');
  }

  client.close();
}

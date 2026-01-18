// Quick test to verify listTags() works
import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';

void main() async {
  print('Testing polybrainz_polymarket SDK...');

  final client = PolymarketClient.public();

  try {
    print('\nFetching tags...');
    final tags = await client.gamma.tags.listTags(
      limit: 100,
    );

    print('Got ${tags.length} tags');

    if (tags.isEmpty) {
      print('WARNING: No tags returned!');
    } else {
      print('\nTop 10 tags by event count:');
      for (final tag in tags.take(10)) {
        print('  - ${tag.label} (slug: ${tag.slug}): ${tag.eventCount} events');
        print('    id: ${tag.id}, display: ${tag.display}, forceShow: ${tag.forceShow}');
      }
    }

    // Also test filtering
    final displayable = tags.where((t) => (t.eventCount ?? 0) > 0).toList();
    print('\nTags with eventCount > 0: ${displayable.length}');

  } catch (e, st) {
    print('ERROR: $e');
    print('Stack: $st');
  }

  client.close();
}

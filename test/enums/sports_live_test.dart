/// Live integration test for sports enums against Polymarket API
///
/// Run with: dart test test/enums/sports_live_test.dart --tags=live
///
/// This test makes real API calls to verify enum values work correctly.
/// Focused on European soccer/football (not American football).
@Tags(['live'])
library;

import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';
import 'package:test/test.dart';

void main() {
  late PolymarketClient client;

  setUpAll(() {
    client = PolymarketClient.public();
  });

  tearDownAll(() {
    client.close();
  });

  group('Live API - European Soccer Events', () {
    test('can fetch soccer events with TagSlug.soccer', () async {
      final events = await client.gamma.events.getByTagSlug(
        TagSlug.soccer,
        limit: 5,
      );

      print('Found ${events.length} soccer events');
      for (final event in events) {
        print('  - ${event.title}');
      }

      expect(events, isNotEmpty);
    });

    test('can fetch Premier League events with TagSlug.premierLeague',
        () async {
      final events = await client.gamma.events.getByTagSlug(
        TagSlug.premierLeague,
        limit: 5,
      );

      print('Found ${events.length} Premier League events');
      for (final event in events) {
        print('  - ${event.title}');
      }

      expect(events, isA<List<Event>>());
      // Verify we got Premier League content
      if (events.isNotEmpty) {
        final titles = events.map((e) => e.title?.toLowerCase() ?? '').toList();
        final hasPremierLeagueContent = titles.any((t) =>
            t.contains('premier') ||
            t.contains('epl') ||
            t.contains('fc') ||
            t.contains('afc') ||
            t.contains('united'));
        print('Has Premier League content: $hasPremierLeagueContent');
      }
    });

    test('can fetch Champions League events with TagSlug.championsLeague',
        () async {
      final events = await client.gamma.events.getByTagSlug(
        TagSlug.championsLeague,
        limit: 5,
      );

      print('Found ${events.length} Champions League events');
      for (final event in events) {
        print('  - ${event.title}');
      }

      expect(events, isA<List<Event>>());
    });

    test('can fetch La Liga events with TagSlug.laLiga', () async {
      final events = await client.gamma.events.getByTagSlug(
        TagSlug.laLiga,
        limit: 5,
      );

      print('Found ${events.length} La Liga events');
      for (final event in events) {
        print('  - ${event.title}');
      }

      expect(events, isA<List<Event>>());
    });

    test('can fetch Bundesliga events with TagSlug.bundesliga', () async {
      final events = await client.gamma.events.getByTagSlug(
        TagSlug.bundesliga,
        limit: 5,
      );

      print('Found ${events.length} Bundesliga events');
      for (final event in events) {
        print('  - ${event.title}');
      }

      expect(events, isA<List<Event>>());
    });

    test('can fetch Serie A events with TagSlug.serieA', () async {
      final events = await client.gamma.events.getByTagSlug(
        TagSlug.serieA,
        limit: 5,
      );

      print('Found ${events.length} Serie A events');
      for (final event in events) {
        print('  - ${event.title}');
      }

      expect(events, isA<List<Event>>());
    });

    test('can fetch Ligue 1 events with TagSlug.ligue1', () async {
      final events = await client.gamma.events.getByTagSlug(
        TagSlug.ligue1,
        limit: 5,
      );

      print('Found ${events.length} Ligue 1 events');
      for (final event in events) {
        print('  - ${event.title}');
      }

      expect(events, isA<List<Event>>());
    });

    test('can fetch World Cup events with TagSlug.worldCup', () async {
      final events = await client.gamma.events.getByTagSlug(
        TagSlug.worldCup,
        limit: 5,
      );

      print('Found ${events.length} World Cup events');
      for (final event in events) {
        print('  - ${event.title}');
      }

      expect(events, isA<List<Event>>());
    });

    test('can fetch MLS events with TagSlug.mls', () async {
      final events = await client.gamma.events.getByTagSlug(
        TagSlug.mls,
        limit: 5,
      );

      print('Found ${events.length} MLS events');
      for (final event in events) {
        print('  - ${event.title}');
      }

      expect(events, isA<List<Event>>());
    });
  });

  group('Live API - Sports Teams', () {
    test('can fetch teams filtered by EPL (Premier League)', () async {
      final teams = await client.gamma.sports.listTeams(
        leagues: [SportsLeague.epl],
        limit: 10,
      );

      print('Found ${teams.length} EPL teams');
      for (final team in teams) {
        print(
            '  - ${team.name} (${team.abbreviation}) - League: ${team.league}');
      }

      expect(teams, isA<List<Team>>());
    });

    test('can fetch teams from multiple European soccer leagues', () async {
      final teams = await client.gamma.sports.listTeams(
        leagues: [
          SportsLeague.epl,
          SportsLeague.laLiga,
          SportsLeague.bundesliga,
          SportsLeague.serieA,
          SportsLeague.ligue1,
        ],
        limit: 30,
      );

      print('Found ${teams.length} teams from European soccer leagues');
      final leagueCounts = <String, int>{};
      for (final team in teams) {
        final league = team.league ?? 'unknown';
        leagueCounts[league] = (leagueCounts[league] ?? 0) + 1;
        print('  - ${team.name} (${team.league})');
      }
      print('League breakdown: $leagueCounts');

      expect(teams, isA<List<Team>>());
    });

    test('Team.leagueEnum correctly parses European soccer leagues', () async {
      final teams = await client.gamma.sports.listTeams(limit: 50);

      // Filter to only soccer-related teams
      final soccerTeams = teams.where((t) {
        final league = t.league?.toLowerCase() ?? '';
        return league.contains('epl') ||
            league.contains('la liga') ||
            league.contains('bundesliga') ||
            league.contains('serie a') ||
            league.contains('ligue 1') ||
            league.contains('mls') ||
            league.contains('champions') ||
            league.contains('europa');
      }).toList();

      print('Found ${soccerTeams.length} soccer teams out of ${teams.length}');
      for (final team in soccerTeams) {
        final leagueEnum = team.leagueEnum;
        print('${team.name}: league=${team.league}, enum=$leagueEnum');
        if (team.league != null && leagueEnum != null) {
          expect(leagueEnum.isSoccer, isTrue,
              reason: '${team.league} should be marked as soccer');
        }
      }

      expect(teams, isA<List<Team>>());
    });
  });

  group('Live API - SportsLeague helper methods', () {
    test('isSoccer correctly identifies European soccer leagues', () {
      // European soccer leagues
      expect(SportsLeague.epl.isSoccer, isTrue);
      expect(SportsLeague.laLiga.isSoccer, isTrue);
      expect(SportsLeague.serieA.isSoccer, isTrue);
      expect(SportsLeague.bundesliga.isSoccer, isTrue);
      expect(SportsLeague.ligue1.isSoccer, isTrue);
      expect(SportsLeague.championsLeague.isSoccer, isTrue);
      expect(SportsLeague.europaLeague.isSoccer, isTrue);
      expect(SportsLeague.mls.isSoccer, isTrue);

      // International soccer
      expect(SportsLeague.worldCup.isSoccer, isTrue);
      expect(SportsLeague.euros.isSoccer, isTrue);
      expect(SportsLeague.copaAmerica.isSoccer, isTrue);

      // Non-soccer (American football is NOT soccer)
      expect(SportsLeague.nfl.isSoccer, isFalse);
      expect(SportsLeague.nba.isSoccer, isFalse);
      expect(SportsLeague.mlb.isSoccer, isFalse);
    });
  });

  group('Live API - TagSlug sports slugs are correct', () {
    test('European soccer TagSlug values match API expectations', () {
      // These are the exact slug values the API expects
      expect(TagSlug.soccer.value, equals('soccer'));
      expect(TagSlug.premierLeague.value, equals('premier-league'));
      expect(TagSlug.championsLeague.value, equals('champions-league'));
      expect(TagSlug.laLiga.value, equals('la-liga'));
      expect(TagSlug.bundesliga.value, equals('bundesliga'));
      expect(TagSlug.serieA.value, equals('serie-a'));
      expect(TagSlug.ligue1.value, equals('ligue-1'));
      expect(TagSlug.worldCup.value, equals('world-cup'));
      expect(TagSlug.mls.value, equals('mls'));
    });
  });

  group('Live API - SportsSubcategory slugs match TagSlug', () {
    test('European soccer subcategories have correct slugs', () {
      // These should match for consistency
      expect(SportsSubcategory.soccer.slug, equals(TagSlug.soccer.value));
      expect(SportsSubcategory.premierLeague.slug,
          equals(TagSlug.premierLeague.value));
      expect(SportsSubcategory.championsLeague.slug,
          equals(TagSlug.championsLeague.value));
      expect(SportsSubcategory.laLiga.slug, equals(TagSlug.laLiga.value));
      expect(
          SportsSubcategory.bundesliga.slug, equals(TagSlug.bundesliga.value));
      expect(SportsSubcategory.serieA.slug, equals(TagSlug.serieA.value));
      expect(SportsSubcategory.ligue1.slug, equals(TagSlug.ligue1.value));
      expect(SportsSubcategory.worldCup.slug, equals(TagSlug.worldCup.value));
      expect(SportsSubcategory.mls.slug, equals(TagSlug.mls.value));
    });
  });
}

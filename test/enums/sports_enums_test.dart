import 'package:polybrainz_polymarket/polybrainz_polymarket.dart';
import 'package:test/test.dart';

void main() {
  group('SportsLeague', () {
    group('values', () {
      test('NFL has correct value', () {
        expect(SportsLeague.nfl.value, equals('NFL'));
        expect(SportsLeague.nfl.toJson(), equals('NFL'));
      });

      test('NBA has correct value', () {
        expect(SportsLeague.nba.value, equals('NBA'));
      });

      test('EPL (Premier League) has correct value', () {
        expect(SportsLeague.epl.value, equals('EPL'));
      });

      test('NCAA Football has correct value', () {
        expect(SportsLeague.ncaaFootball.value, equals('NCAA Football'));
      });

      test('Champions League has correct value', () {
        expect(SportsLeague.championsLeague.value, equals('Champions League'));
      });
    });

    group('fromJson', () {
      test('parses NFL (uppercase)', () {
        expect(SportsLeague.fromJson('NFL'), equals(SportsLeague.nfl));
      });

      test('parses nfl (lowercase)', () {
        expect(SportsLeague.fromJson('nfl'), equals(SportsLeague.nfl));
      });

      test('parses EPL', () {
        expect(SportsLeague.fromJson('EPL'), equals(SportsLeague.epl));
      });

      test('parses by enum name', () {
        expect(SportsLeague.fromJson('championsLeague'),
            equals(SportsLeague.championsLeague));
      });

      test('throws on unknown value', () {
        expect(
          () => SportsLeague.fromJson('UNKNOWN'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('tryFromJson', () {
      test('returns null for unknown value', () {
        expect(SportsLeague.tryFromJson('UNKNOWN'), isNull);
      });

      test('returns null for null input', () {
        expect(SportsLeague.tryFromJson(null), isNull);
      });

      test('parses valid values', () {
        expect(SportsLeague.tryFromJson('NFL'), equals(SportsLeague.nfl));
        expect(SportsLeague.tryFromJson('La Liga'), equals(SportsLeague.laLiga));
      });
    });

    group('helper methods', () {
      test('isUsMajor identifies US major leagues', () {
        expect(SportsLeague.nfl.isUsMajor, isTrue);
        expect(SportsLeague.nba.isUsMajor, isTrue);
        expect(SportsLeague.mlb.isUsMajor, isTrue);
        expect(SportsLeague.nhl.isUsMajor, isTrue);
        expect(SportsLeague.mls.isUsMajor, isTrue);
        expect(SportsLeague.epl.isUsMajor, isFalse);
      });

      test('isSoccer identifies soccer/football leagues', () {
        expect(SportsLeague.epl.isSoccer, isTrue);
        expect(SportsLeague.laLiga.isSoccer, isTrue);
        expect(SportsLeague.serieA.isSoccer, isTrue);
        expect(SportsLeague.bundesliga.isSoccer, isTrue);
        expect(SportsLeague.ligue1.isSoccer, isTrue);
        expect(SportsLeague.championsLeague.isSoccer, isTrue);
        expect(SportsLeague.mls.isSoccer, isTrue);
        expect(SportsLeague.worldCup.isSoccer, isTrue);
        expect(SportsLeague.nfl.isSoccer, isFalse); // American football
        expect(SportsLeague.nba.isSoccer, isFalse);
      });

      test('isCombatSport identifies combat sports', () {
        expect(SportsLeague.ufc.isCombatSport, isTrue);
        expect(SportsLeague.boxing.isCombatSport, isTrue);
        expect(SportsLeague.pfl.isCombatSport, isTrue);
        expect(SportsLeague.bellator.isCombatSport, isTrue);
        expect(SportsLeague.nfl.isCombatSport, isFalse);
      });

      test('isMotorsport identifies motorsports', () {
        expect(SportsLeague.f1.isMotorsport, isTrue);
        expect(SportsLeague.nascar.isMotorsport, isTrue);
        expect(SportsLeague.indycar.isMotorsport, isTrue);
        expect(SportsLeague.motoGP.isMotorsport, isTrue);
        expect(SportsLeague.nfl.isMotorsport, isFalse);
      });
    });
  });

  group('SportsSubcategory', () {
    group('values', () {
      test('NFL has correct slug', () {
        expect(SportsSubcategory.nfl.slug, equals('nfl'));
        expect(SportsSubcategory.nfl.label, equals('NFL'));
      });

      test('Premier League has correct slug (hyphenated)', () {
        expect(SportsSubcategory.premierLeague.slug, equals('premier-league'));
        expect(SportsSubcategory.premierLeague.label, equals('Premier League'));
      });

      test('Soccer has correct slug', () {
        expect(SportsSubcategory.soccer.slug, equals('soccer'));
        expect(SportsSubcategory.soccer.label, equals('Soccer'));
      });

      test('College Football has correct slug', () {
        expect(SportsSubcategory.cfb.slug, equals('cfb'));
        expect(SportsSubcategory.cfb.label, equals('College Football'));
      });
    });

    group('fromJson', () {
      test('parses by slug', () {
        expect(
            SportsSubcategory.fromJson('nfl'), equals(SportsSubcategory.nfl));
        expect(SportsSubcategory.fromJson('premier-league'),
            equals(SportsSubcategory.premierLeague));
      });

      test('parses by name', () {
        expect(SportsSubcategory.fromJson('premierLeague'),
            equals(SportsSubcategory.premierLeague));
      });

      test('returns other for unknown values', () {
        expect(SportsSubcategory.fromJson('unknown'),
            equals(SportsSubcategory.other));
      });
    });

    group('bySlug', () {
      test('finds by exact slug match', () {
        expect(
            SportsSubcategory.bySlug('soccer'), equals(SportsSubcategory.soccer));
        expect(SportsSubcategory.bySlug('premier-league'),
            equals(SportsSubcategory.premierLeague));
      });

      test('returns null for unknown slug', () {
        expect(SportsSubcategory.bySlug('unknown'), isNull);
      });
    });

    group('toJson', () {
      test('returns slug', () {
        expect(SportsSubcategory.nfl.toJson(), equals('nfl'));
        expect(
            SportsSubcategory.premierLeague.toJson(), equals('premier-league'));
      });
    });
  });

  group('SportsMarketType', () {
    group('values', () {
      test('winner has correct value', () {
        expect(SportsMarketType.winner.value, equals('winner'));
      });

      test('spread has correct value', () {
        expect(SportsMarketType.spread.value, equals('spread'));
      });

      test('player_prop has underscore', () {
        expect(SportsMarketType.playerProp.value, equals('player_prop'));
      });
    });

    group('fromJson', () {
      test('parses winner', () {
        expect(
            SportsMarketType.fromJson('winner'), equals(SportsMarketType.winner));
      });

      test('is case insensitive', () {
        expect(
            SportsMarketType.fromJson('WINNER'), equals(SportsMarketType.winner));
        expect(
            SportsMarketType.fromJson('Winner'), equals(SportsMarketType.winner));
      });

      test('throws on unknown value', () {
        expect(
          () => SportsMarketType.fromJson('unknown'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('tryFromJson', () {
      test('returns null for unknown', () {
        expect(SportsMarketType.tryFromJson('unknown'), isNull);
      });

      test('returns null for null', () {
        expect(SportsMarketType.tryFromJson(null), isNull);
      });

      test('parses valid values', () {
        expect(SportsMarketType.tryFromJson('spread'),
            equals(SportsMarketType.spread));
      });
    });
  });

  group('TagSlug sports presets', () {
    group('NFL', () {
      test('has correct value', () {
        expect(TagSlug.nfl.value, equals('nfl'));
      });
    });

    group('Soccer', () {
      test('has correct value', () {
        expect(TagSlug.soccer.value, equals('soccer'));
      });
    });

    group('Premier League', () {
      test('has correct hyphenated value', () {
        expect(TagSlug.premierLeague.value, equals('premier-league'));
      });
    });

    group('Champions League', () {
      test('has correct hyphenated value', () {
        expect(TagSlug.championsLeague.value, equals('champions-league'));
      });
    });

    group('sportsPresets list', () {
      test('contains major sports', () {
        expect(TagSlug.sportsPresets, contains(TagSlug.sports));
        expect(TagSlug.sportsPresets, contains(TagSlug.nfl));
        expect(TagSlug.sportsPresets, contains(TagSlug.nba));
        expect(TagSlug.sportsPresets, contains(TagSlug.soccer));
        expect(TagSlug.sportsPresets, contains(TagSlug.premierLeague));
        expect(TagSlug.sportsPresets, contains(TagSlug.championsLeague));
      });

      test('all presets have non-empty values', () {
        for (final preset in TagSlug.sportsPresets) {
          expect(preset.value.isNotEmpty, isTrue,
              reason: 'Preset should have non-empty value');
        }
      });
    });

    group('fromJson/fromValue', () {
      test('finds sports presets', () {
        expect(TagSlug.fromJson('nfl'), equals(TagSlug.nfl));
        expect(TagSlug.fromJson('soccer'), equals(TagSlug.soccer));
        expect(
            TagSlug.fromJson('premier-league'), equals(TagSlug.premierLeague));
      });

      test('creates custom for unknown', () {
        final custom = TagSlug.fromJson('unknown-sport');
        expect(custom.value, equals('unknown-sport'));
      });
    });

    group('tryFromPreset', () {
      test('finds existing presets', () {
        expect(TagSlug.tryFromPreset('nfl'), equals(TagSlug.nfl));
        expect(TagSlug.tryFromPreset('NFL'), equals(TagSlug.nfl)); // case insensitive
      });

      test('returns null for non-presets', () {
        expect(TagSlug.tryFromPreset('unknown'), isNull);
      });
    });
  });

  group('Integration - enum value consistency', () {
    test('SportsSubcategory and TagSlug have matching football slugs', () {
      // These should be consistent across enums
      expect(SportsSubcategory.nfl.slug, equals(TagSlug.nfl.value));
      expect(SportsSubcategory.soccer.slug, equals(TagSlug.soccer.value));
      expect(SportsSubcategory.premierLeague.slug,
          equals(TagSlug.premierLeague.value));
      expect(SportsSubcategory.championsLeague.slug,
          equals(TagSlug.championsLeague.value));
      expect(SportsSubcategory.mls.slug, equals(TagSlug.mls.value));
      expect(SportsSubcategory.worldCup.slug, equals(TagSlug.worldCup.value));
    });

    test('all football-related subcategories exist in TagSlug', () {
      // Football/soccer related
      expect(TagSlug.tryFromPreset(SportsSubcategory.soccer.slug), isNotNull);
      expect(TagSlug.tryFromPreset(SportsSubcategory.premierLeague.slug),
          isNotNull);
      expect(TagSlug.tryFromPreset(SportsSubcategory.laLiga.slug), isNotNull);
      expect(
          TagSlug.tryFromPreset(SportsSubcategory.bundesliga.slug), isNotNull);
      expect(TagSlug.tryFromPreset(SportsSubcategory.serieA.slug), isNotNull);
      expect(TagSlug.tryFromPreset(SportsSubcategory.ligue1.slug), isNotNull);
      expect(TagSlug.tryFromPreset(SportsSubcategory.championsLeague.slug),
          isNotNull);
      expect(TagSlug.tryFromPreset(SportsSubcategory.mls.slug), isNotNull);
      expect(TagSlug.tryFromPreset(SportsSubcategory.worldCup.slug), isNotNull);
    });
  });
}

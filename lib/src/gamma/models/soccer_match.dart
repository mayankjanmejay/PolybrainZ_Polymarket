import 'package:equatable/equatable.dart';
import 'event.dart';
import 'market.dart';

/// A structured representation of a soccer match with its markets.
///
/// Soccer matches on Polymarket typically have 3 markets:
/// - Team A Win (moneyline)
/// - Draw
/// - Team B Win (moneyline)
///
/// This class extracts and structures these markets from an Event.
class SoccerMatch extends Equatable {
  /// The parent event
  final Event event;

  /// Team A (home team) name
  final String teamA;

  /// Team B (away team) name
  final String teamB;

  /// Market for Team A winning
  final Market? teamAWinMarket;

  /// Market for a draw
  final Market? drawMarket;

  /// Market for Team B winning
  final Market? teamBWinMarket;

  /// Match date/time (from event endDate, which is match time)
  final DateTime? matchTime;

  /// League/competition tag slug (e.g., 'premier-league')
  final String? league;

  const SoccerMatch({
    required this.event,
    required this.teamA,
    required this.teamB,
    this.teamAWinMarket,
    this.drawMarket,
    this.teamBWinMarket,
    this.matchTime,
    this.league,
  });

  /// Event ID
  String get eventId => event.id;

  /// Event slug
  String? get slug => event.slug;

  /// Event title (e.g., "Sunderland AFC vs. Burnley FC")
  String? get title => event.title;

  /// Whether the match is still active (not ended/resolved)
  bool get isActive => event.active && !event.closed && !event.ended;

  /// Whether all 3 markets exist (full match coverage)
  bool get hasAllMarkets =>
      teamAWinMarket != null && drawMarket != null && teamBWinMarket != null;

  /// Whether the draw market exists
  bool get hasDrawMarket => drawMarket != null;

  /// Whether the match is accepting orders
  bool get isAcceptingOrders =>
      (teamAWinMarket?.acceptingOrders ?? false) ||
      (drawMarket?.acceptingOrders ?? false) ||
      (teamBWinMarket?.acceptingOrders ?? false);

  // === Price Getters ===

  /// Price for Team A to win (probability)
  double get teamAWinPrice => teamAWinMarket?.yesPrice ?? 0.0;

  /// Price for Draw (probability)
  double get drawPrice => drawMarket?.yesPrice ?? 0.0;

  /// Price for Team B to win (probability)
  double get teamBWinPrice => teamBWinMarket?.yesPrice ?? 0.0;

  /// Price for "No Draw" (1 - drawPrice, for hedge strategies)
  double get noDrawPrice => drawMarket?.noPrice ?? 0.0;

  // === Token ID Getters (for trading) ===

  /// CLOB token IDs for Team A Win market [Yes, No]
  List<String> get teamAWinTokenIds => teamAWinMarket?.tokenIdsList ?? [];

  /// CLOB token IDs for Draw market [Yes, No]
  List<String> get drawTokenIds => drawMarket?.tokenIdsList ?? [];

  /// CLOB token IDs for Team B Win market [Yes, No]
  List<String> get teamBWinTokenIds => teamBWinMarket?.tokenIdsList ?? [];

  // === Liquidity Getters ===

  /// Total liquidity across all markets
  double get totalLiquidity =>
      (teamAWinMarket?.liquidityNum ?? 0) +
      (drawMarket?.liquidityNum ?? 0) +
      (teamBWinMarket?.liquidityNum ?? 0);

  /// Draw market liquidity
  double get drawLiquidity => drawMarket?.liquidityNum ?? 0;

  // === Volume Getters ===

  /// Total volume across all markets
  double get totalVolume =>
      (teamAWinMarket?.volumeNum ?? 0) +
      (drawMarket?.volumeNum ?? 0) +
      (teamBWinMarket?.volumeNum ?? 0);

  /// Attempt to parse a SoccerMatch from an Event.
  ///
  /// Returns null if the event doesn't look like a soccer match
  /// (e.g., missing expected market structure).
  static SoccerMatch? fromEvent(Event event, {String? league}) {
    if (event.markets == null || event.markets!.isEmpty) {
      return null;
    }

    // Parse team names from title (format: "Team A vs. Team B")
    final title = event.title ?? '';
    final vsMatch = RegExp(r'(.+?)\s+vs\.?\s+(.+)', caseSensitive: false)
        .firstMatch(title);

    if (vsMatch == null) {
      return null; // Not a match format
    }

    final teamA = vsMatch.group(1)?.trim() ?? '';
    final teamB = vsMatch.group(2)?.trim() ?? '';

    if (teamA.isEmpty || teamB.isEmpty) {
      return null;
    }

    // Find the markets
    Market? teamAWinMarket;
    Market? drawMarket;
    Market? teamBWinMarket;

    for (final market in event.markets!) {
      final slug = market.slug?.toLowerCase() ?? '';
      final question = market.question?.toLowerCase() ?? '';

      if (slug.endsWith('-draw') || question.contains('end in a draw')) {
        drawMarket = market;
      } else if (question.contains(teamA.toLowerCase()) &&
          question.contains('win')) {
        teamAWinMarket = market;
      } else if (question.contains(teamB.toLowerCase()) &&
          question.contains('win')) {
        teamBWinMarket = market;
      }
    }

    // Must have at least the draw market for hedge strategies
    if (drawMarket == null) {
      return null;
    }

    return SoccerMatch(
      event: event,
      teamA: teamA,
      teamB: teamB,
      teamAWinMarket: teamAWinMarket,
      drawMarket: drawMarket,
      teamBWinMarket: teamBWinMarket,
      matchTime: event.endDate,
      league: league,
    );
  }

  /// Create a list of SoccerMatch from a list of Events.
  ///
  /// Filters out events that don't match the soccer match structure.
  static List<SoccerMatch> fromEvents(List<Event> events, {String? league}) {
    return events
        .map((e) => SoccerMatch.fromEvent(e, league: league))
        .whereType<SoccerMatch>()
        .toList();
  }

  @override
  List<Object?> get props => [eventId, teamA, teamB];

  @override
  String toString() =>
      'SoccerMatch($teamA vs $teamB, draw: ${drawPrice.toStringAsFixed(2)})';
}

/// Type-safe enum for sports market types.
///
/// Use with endpoints that support sports market type filtering.
///
/// ```dart
/// final markets = await client.gamma.markets.listMarkets(
///   sportsMarketTypes: [SportsMarketType.winner, SportsMarketType.spread],
/// );
/// ```
enum SportsMarketType {
  /// Winner/moneyline market
  winner('winner'),

  /// Point spread market
  spread('spread'),

  /// Over/under totals market
  total('total'),

  /// Moneyline market (same as winner)
  moneyline('moneyline'),

  /// Proposition bet
  prop('prop'),

  /// Player prop market
  playerProp('player_prop'),

  /// Game prop market
  gameProp('game_prop'),

  /// Team total market
  teamTotal('team_total'),

  /// First half market
  firstHalf('first_half'),

  /// Second half market
  secondHalf('second_half'),

  /// First quarter market
  firstQuarter('first_quarter'),

  /// Live/in-game market
  live('live'),

  /// Futures market
  futures('futures'),

  /// Championship winner
  championship('championship'),

  /// Division winner
  division('division'),

  /// Conference winner
  conference('conference'),

  /// MVP award
  mvp('mvp'),

  /// Season totals
  seasonTotal('season_total'),

  /// Head to head matchup
  headToHead('head_to_head');

  final String value;
  const SportsMarketType(this.value);

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static SportsMarketType fromJson(String json) {
    return SportsMarketType.values.firstWhere(
      (e) => e.value.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown SportsMarketType: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static SportsMarketType? tryFromJson(String? json) {
    if (json == null) return null;
    return SportsMarketType.values.cast<SportsMarketType?>().firstWhere(
          (e) => e?.value.toLowerCase() == json.toLowerCase(),
          orElse: () => null,
        );
  }
}

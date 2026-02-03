/// Type-safe enum for sports leagues.
///
/// Use with endpoints that support league filtering.
///
/// ```dart
/// final teams = await client.gamma.sports.listTeams(
///   leagues: [SportsLeague.nfl, SportsLeague.nba],
/// );
/// ```
enum SportsLeague {
  // === North American Leagues ===

  /// National Football League
  nfl('NFL'),

  /// National Basketball Association
  nba('NBA'),

  /// Major League Baseball
  mlb('MLB'),

  /// National Hockey League
  nhl('NHL'),

  /// Major League Soccer
  mls('MLS'),

  /// Women's National Basketball Association
  wnba('WNBA'),

  /// Canadian Football League
  cfl('CFL'),

  // === College Sports ===

  /// NCAA Football
  ncaaFootball('NCAA Football'),

  /// NCAA Basketball
  ncaaBasketball('NCAA Basketball'),

  /// College Football Playoff
  cfp('CFP'),

  // === European Soccer - Top Leagues ===

  /// English Premier League
  epl('EPL'),

  /// La Liga (Spain)
  laLiga('La Liga'),

  /// Serie A (Italy)
  serieA('Serie A'),

  /// Bundesliga (Germany)
  bundesliga('Bundesliga'),

  /// Ligue 1 (France)
  ligue1('Ligue 1'),

  /// Portuguese Primeira Liga
  primeiraLiga('Primeira Liga'),

  /// Scottish Premiership
  scottishPremiership('Scottish Premiership'),

  // === European Soccer - Second Tier ===

  /// EFL Championship (English 2nd tier)
  eflChampionship('EFL Championship'),

  /// Serie B (Italian 2nd tier)
  serieB('Serie B'),

  // === European Competitions ===

  /// UEFA Champions League
  championsLeague('Champions League'),

  /// UEFA Europa League
  europaLeague('Europa League'),

  /// UEFA Conference League
  conferenceLeague('Conference League'),

  // === Domestic Cups ===

  /// FA Cup (England)
  faCup('FA Cup'),

  /// Carabao Cup / EFL Cup (England)
  carabaoCup('Carabao Cup'),

  /// Copa del Rey (Spain)
  copaDelRey('Copa del Rey'),

  /// DFB-Pokal (Germany)
  dfbPokal('DFB-Pokal'),

  /// Coupe de France (France)
  coupeDeFrance('Coupe de France'),

  // === International Soccer ===

  /// FIFA World Cup
  worldCup('World Cup'),

  /// UEFA European Championship
  euros('Euros'),

  /// Copa America
  copaAmerica('Copa America'),

  // === Combat Sports ===

  /// Ultimate Fighting Championship
  ufc('UFC'),

  /// Professional boxing
  boxing('Boxing'),

  /// Professional Fighters League
  pfl('PFL'),

  /// Bellator MMA
  bellator('Bellator'),

  // === Motorsports ===

  /// Formula 1
  f1('F1'),

  /// NASCAR
  nascar('NASCAR'),

  /// IndyCar
  indycar('IndyCar'),

  /// MotoGP
  motoGP('MotoGP'),

  // === Other Sports ===

  /// Professional Golf Association
  pga('PGA'),

  /// LPGA Tour
  lpga('LPGA'),

  /// Association of Tennis Professionals
  atp('ATP'),

  /// Women's Tennis Association
  wta('WTA'),

  /// Olympic Games
  olympics('Olympics'),

  /// X Games
  xGames('X Games'),

  /// Esports
  esports('Esports'),

  /// Cricket
  cricket('Cricket'),

  /// Rugby
  rugby('Rugby'),

  /// Australian Football League
  afl('AFL');

  final String value;
  const SportsLeague(this.value);

  /// Convert to JSON string
  String toJson() => value;

  /// Parse from JSON string (throws on invalid)
  static SportsLeague fromJson(String json) {
    return SportsLeague.values.firstWhere(
      (e) =>
          e.value.toLowerCase() == json.toLowerCase() ||
          e.name.toLowerCase() == json.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown SportsLeague: $json'),
    );
  }

  /// Try to parse from JSON string (returns null on invalid)
  static SportsLeague? tryFromJson(String? json) {
    if (json == null) return null;
    return SportsLeague.values.cast<SportsLeague?>().firstWhere(
          (e) =>
              e?.value.toLowerCase() == json.toLowerCase() ||
              e?.name.toLowerCase() == json.toLowerCase(),
          orElse: () => null,
        );
  }

  /// Check if this is a US major league
  bool get isUsMajor =>
      this == nfl || this == nba || this == mlb || this == nhl || this == mls;

  /// Check if this is a soccer/football league
  bool get isSoccer =>
      // Top European leagues
      this == epl ||
      this == laLiga ||
      this == serieA ||
      this == bundesliga ||
      this == ligue1 ||
      this == primeiraLiga ||
      this == scottishPremiership ||
      // Second tier
      this == eflChampionship ||
      this == serieB ||
      // European competitions
      this == championsLeague ||
      this == europaLeague ||
      this == conferenceLeague ||
      // Domestic cups
      this == faCup ||
      this == carabaoCup ||
      this == copaDelRey ||
      this == dfbPokal ||
      this == coupeDeFrance ||
      // International
      this == worldCup ||
      this == euros ||
      this == copaAmerica ||
      // Americas
      this == mls;

  /// Check if this is a combat sport
  bool get isCombatSport =>
      this == ufc || this == boxing || this == pfl || this == bellator;

  /// Check if this is a motorsport
  bool get isMotorsport =>
      this == f1 || this == nascar || this == indycar || this == motoGP;
}

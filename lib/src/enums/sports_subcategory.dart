/// Subcategories for sports markets.
enum SportsSubcategory {
  /// NFL Football
  nfl('nfl', 'NFL'),

  /// NBA Basketball
  nba('nba', 'NBA'),

  /// MLB Baseball
  mlb('mlb', 'MLB'),

  /// NHL Hockey
  nhl('nhl', 'NHL'),

  /// College Football
  cfb('cfb', 'College Football'),

  /// College Basketball
  cbb('cbb', 'College Basketball'),

  /// Soccer/Football
  soccer('soccer', 'Soccer'),

  /// Premier League
  premierLeague('premier-league', 'Premier League'),

  /// La Liga
  laLiga('la-liga', 'La Liga'),

  /// Bundesliga
  bundesliga('bundesliga', 'Bundesliga'),

  /// Serie A
  serieA('serie-a', 'Serie A'),

  /// Ligue 1
  ligue1('ligue-1', 'Ligue 1'),

  /// Champions League
  championsLeague('champions-league', 'Champions League'),

  /// MLS
  mls('mls', 'MLS'),

  /// World Cup
  worldCup('world-cup', 'World Cup'),

  /// Tennis
  tennis('tennis', 'Tennis'),

  /// Golf
  golf('golf', 'Golf'),

  /// PGA
  pga('pga', 'PGA'),

  /// Boxing
  boxing('boxing', 'Boxing'),

  /// UFC/MMA
  mma('mma', 'MMA'),

  /// UFC
  ufc('ufc', 'UFC'),

  /// Formula 1
  f1('f1', 'Formula 1'),

  /// NASCAR
  nascar('nascar', 'NASCAR'),

  /// Olympics
  olympics('olympics', 'Olympics'),

  /// Cricket
  cricket('cricket', 'Cricket'),

  /// Rugby
  rugby('rugby', 'Rugby'),

  /// Esports
  esports('esports', 'Esports'),

  /// Horse Racing
  horseRacing('horse-racing', 'Horse Racing'),

  /// Cycling
  cycling('cycling', 'Cycling'),

  /// Swimming
  swimming('swimming', 'Swimming'),

  /// Track and Field
  trackAndField('track-and-field', 'Track and Field'),

  /// Wrestling
  wrestling('wrestling', 'Wrestling'),

  /// Darts
  darts('darts', 'Darts'),

  /// Snooker
  snooker('snooker', 'Snooker'),

  /// Other sports
  other('other-sports', 'Other Sports');

  final String slug;
  final String label;

  const SportsSubcategory(this.slug, this.label);

  String toJson() => slug;

  static SportsSubcategory fromJson(String json) {
    return SportsSubcategory.values.firstWhere(
      (e) => e.slug == json || e.name == json,
      orElse: () => SportsSubcategory.other,
    );
  }

  static SportsSubcategory? bySlug(String slug) {
    try {
      return SportsSubcategory.values.firstWhere((e) => e.slug == slug);
    } catch (_) {
      return null;
    }
  }
}

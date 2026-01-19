/// Type-safe tag slug for filtering events and markets by category.
///
/// Use preset constants for common tags or [TagSlug.custom] for user-created tags.
///
/// ```dart
/// // Using preset
/// final events = await client.gamma.events.listEvents(
///   tagSlug: TagSlug.politics,
/// );
///
/// // Using custom tag
/// final events = await client.gamma.events.listEvents(
///   tagSlug: TagSlug.custom('my-custom-tag'),
/// );
///
/// // From MarketCategory
/// final events = await client.gamma.events.listEvents(
///   tagSlug: TagSlug.fromCategory(MarketCategory.crypto),
/// );
/// ```
sealed class TagSlug {
  /// The slug value to send to the API
  String get value;

  const TagSlug();

  /// Convert to JSON string
  String toJson() => value;

  // ============================================================
  // MAIN CATEGORIES
  // ============================================================

  /// Politics - Political events and elections
  static const TagSlug politics = _PresetTagSlug('politics');

  /// Sports - Athletic events and competitions
  static const TagSlug sports = _PresetTagSlug('sports');

  /// Crypto - Cryptocurrency and blockchain
  static const TagSlug crypto = _PresetTagSlug('crypto');

  /// Business - Business and economics
  static const TagSlug business = _PresetTagSlug('business');

  /// Entertainment - Movies, TV, music, celebrities
  static const TagSlug entertainment = _PresetTagSlug('entertainment');

  /// Pop Culture - Pop culture trends
  static const TagSlug popCulture = _PresetTagSlug('pop-culture');

  /// Science - Science and research
  static const TagSlug science = _PresetTagSlug('science');

  /// Tech - Technology
  static const TagSlug tech = _PresetTagSlug('tech');

  /// Finance - Financial markets
  static const TagSlug finance = _PresetTagSlug('finance');

  /// News - Current news events
  static const TagSlug news = _PresetTagSlug('news');

  /// World - Global and world events
  static const TagSlug world = _PresetTagSlug('world');

  // ============================================================
  // POLITICS SUBCATEGORIES
  // ============================================================

  /// US Presidential Election
  static const TagSlug election = _PresetTagSlug('election');

  /// Trump-related markets
  static const TagSlug trump = _PresetTagSlug('trump');

  /// Biden-related markets
  static const TagSlug biden = _PresetTagSlug('biden');

  /// Harris-related markets
  static const TagSlug harris = _PresetTagSlug('harris');

  /// US Congress
  static const TagSlug congress = _PresetTagSlug('congress');

  /// US Senate
  static const TagSlug senate = _PresetTagSlug('senate');

  /// US House
  static const TagSlug house = _PresetTagSlug('house');

  /// Supreme Court
  static const TagSlug supremeCourt = _PresetTagSlug('supreme-court');

  /// Governor elections
  static const TagSlug governor = _PresetTagSlug('governor');

  /// Republicans/GOP
  static const TagSlug republicans = _PresetTagSlug('republicans');

  /// Democrats
  static const TagSlug democrats = _PresetTagSlug('democrats');

  // ============================================================
  // SPORTS SUBCATEGORIES
  // ============================================================

  /// NFL Football
  static const TagSlug nfl = _PresetTagSlug('nfl');

  /// NBA Basketball
  static const TagSlug nba = _PresetTagSlug('nba');

  /// MLB Baseball
  static const TagSlug mlb = _PresetTagSlug('mlb');

  /// NHL Hockey
  static const TagSlug nhl = _PresetTagSlug('nhl');

  /// College Football
  static const TagSlug cfb = _PresetTagSlug('cfb');

  /// College Basketball
  static const TagSlug cbb = _PresetTagSlug('cbb');

  /// Soccer/Football
  static const TagSlug soccer = _PresetTagSlug('soccer');

  /// Premier League
  static const TagSlug premierLeague = _PresetTagSlug('premier-league');

  /// La Liga
  static const TagSlug laLiga = _PresetTagSlug('la-liga');

  /// Bundesliga
  static const TagSlug bundesliga = _PresetTagSlug('bundesliga');

  /// Serie A
  static const TagSlug serieA = _PresetTagSlug('serie-a');

  /// Ligue 1
  static const TagSlug ligue1 = _PresetTagSlug('ligue-1');

  /// Champions League
  static const TagSlug championsLeague = _PresetTagSlug('champions-league');

  /// MLS
  static const TagSlug mls = _PresetTagSlug('mls');

  /// World Cup
  static const TagSlug worldCup = _PresetTagSlug('world-cup');

  /// Tennis
  static const TagSlug tennis = _PresetTagSlug('tennis');

  /// Golf
  static const TagSlug golf = _PresetTagSlug('golf');

  /// PGA
  static const TagSlug pga = _PresetTagSlug('pga');

  /// Boxing
  static const TagSlug boxing = _PresetTagSlug('boxing');

  /// MMA/UFC
  static const TagSlug mma = _PresetTagSlug('mma');

  /// UFC
  static const TagSlug ufc = _PresetTagSlug('ufc');

  /// Formula 1
  static const TagSlug f1 = _PresetTagSlug('f1');

  /// NASCAR
  static const TagSlug nascar = _PresetTagSlug('nascar');

  /// Olympics
  static const TagSlug olympics = _PresetTagSlug('olympics');

  /// Cricket
  static const TagSlug cricket = _PresetTagSlug('cricket');

  /// Rugby
  static const TagSlug rugby = _PresetTagSlug('rugby');

  /// Esports
  static const TagSlug esports = _PresetTagSlug('esports');

  /// Horse Racing
  static const TagSlug horseRacing = _PresetTagSlug('horse-racing');

  /// Super Bowl
  static const TagSlug superBowl = _PresetTagSlug('super-bowl');

  /// NBA Finals
  static const TagSlug nbaFinals = _PresetTagSlug('nba-finals');

  /// World Series
  static const TagSlug worldSeries = _PresetTagSlug('world-series');

  /// Stanley Cup
  static const TagSlug stanleyCup = _PresetTagSlug('stanley-cup');

  /// March Madness
  static const TagSlug marchMadness = _PresetTagSlug('march-madness');

  /// Heisman Trophy
  static const TagSlug heismanTrophy = _PresetTagSlug('heisman-trophy');

  /// Tour de France
  static const TagSlug tourDeFrance = _PresetTagSlug('tour-de-france');

  /// UEFA Nations League
  static const TagSlug uefaNationsLeague = _PresetTagSlug('uefa-nations-league');

  // ============================================================
  // CRYPTO SUBCATEGORIES
  // ============================================================

  /// Bitcoin
  static const TagSlug bitcoin = _PresetTagSlug('bitcoin');

  /// Ethereum
  static const TagSlug ethereum = _PresetTagSlug('ethereum');

  /// Solana
  static const TagSlug solana = _PresetTagSlug('solana');

  /// XRP
  static const TagSlug xrp = _PresetTagSlug('xrp');

  /// Dogecoin
  static const TagSlug doge = _PresetTagSlug('doge');

  /// Cardano
  static const TagSlug cardano = _PresetTagSlug('cardano');

  /// Polygon
  static const TagSlug polygon = _PresetTagSlug('polygon');

  /// DeFi
  static const TagSlug defi = _PresetTagSlug('defi');

  /// NFTs
  static const TagSlug nft = _PresetTagSlug('nft');

  /// ETFs (crypto-related)
  static const TagSlug etfs = _PresetTagSlug('etfs');

  /// Cryptocurrency (general)
  static const TagSlug cryptocurrency = _PresetTagSlug('cryptocurrency');

  // ============================================================
  // BUSINESS/FINANCE SUBCATEGORIES
  // ============================================================

  /// Economy
  static const TagSlug economy = _PresetTagSlug('economy');

  /// GDP
  static const TagSlug gdp = _PresetTagSlug('gdp');

  /// Inflation
  static const TagSlug inflation = _PresetTagSlug('inflation');

  /// Interest Rates
  static const TagSlug interestRates = _PresetTagSlug('interest-rates');

  /// Federal Reserve
  static const TagSlug fed = _PresetTagSlug('fed');

  /// IPOs
  static const TagSlug ipos = _PresetTagSlug('ipos');

  /// CEOs
  static const TagSlug ceos = _PresetTagSlug('ceos');

  /// Layoffs
  static const TagSlug layoffs = _PresetTagSlug('layoffs');

  /// Trade War
  static const TagSlug tradeWar = _PresetTagSlug('trade-war');

  /// Bank of Japan
  static const TagSlug bankOfJapan = _PresetTagSlug('bank-of-japan');

  /// Bank of Canada
  static const TagSlug bankOfCanada = _PresetTagSlug('bank-of-canada');

  /// Monetary Policy
  static const TagSlug monetaryPolicy = _PresetTagSlug('monetary-policy');

  // ============================================================
  // ENTERTAINMENT SUBCATEGORIES
  // ============================================================

  /// Movies
  static const TagSlug movies = _PresetTagSlug('movies');

  /// TV Shows
  static const TagSlug tv = _PresetTagSlug('tv');

  /// Music
  static const TagSlug music = _PresetTagSlug('music');

  /// Album releases
  static const TagSlug album = _PresetTagSlug('album');

  /// Oscars
  static const TagSlug oscars = _PresetTagSlug('oscars');

  /// Grammys
  static const TagSlug grammys = _PresetTagSlug('grammys');

  /// Emmys
  static const TagSlug emmys = _PresetTagSlug('emmys');

  /// Billboard Hot 100
  static const TagSlug billboardHot100 = _PresetTagSlug('billboard-hot-100');

  /// Rotten Tomatoes
  static const TagSlug rottenTomatoes = _PresetTagSlug('rotten-tomatoes');

  /// YouTube
  static const TagSlug youtube = _PresetTagSlug('youtube');

  /// TikTok
  static const TagSlug tiktok = _PresetTagSlug('tiktok');

  /// Streaming
  static const TagSlug streaming = _PresetTagSlug('streaming');

  /// Netflix
  static const TagSlug netflix = _PresetTagSlug('netflix');

  // ============================================================
  // SCIENCE/TECH SUBCATEGORIES
  // ============================================================

  /// AI/Artificial Intelligence
  static const TagSlug ai = _PresetTagSlug('ai');

  /// OpenAI
  static const TagSlug openai = _PresetTagSlug('openai');

  /// ChatGPT
  static const TagSlug chatgpt = _PresetTagSlug('chatgpt');

  /// SpaceX
  static const TagSlug spacex = _PresetTagSlug('spacex');

  /// NASA
  static const TagSlug nasa = _PresetTagSlug('nasa');

  /// Space
  static const TagSlug space = _PresetTagSlug('space');

  /// Climate
  static const TagSlug climate = _PresetTagSlug('climate');

  /// Tesla
  static const TagSlug tesla = _PresetTagSlug('tesla');

  /// Apple
  static const TagSlug apple = _PresetTagSlug('apple');

  /// Google
  static const TagSlug google = _PresetTagSlug('google');

  /// Microsoft
  static const TagSlug microsoft = _PresetTagSlug('microsoft');

  /// Amazon
  static const TagSlug amazon = _PresetTagSlug('amazon');

  /// Meta
  static const TagSlug meta = _PresetTagSlug('meta');

  // ============================================================
  // WORLD/GEOPOLITICS SUBCATEGORIES
  // ============================================================

  /// Ukraine
  static const TagSlug ukraine = _PresetTagSlug('ukraine');

  /// Russia
  static const TagSlug russia = _PresetTagSlug('russia');

  /// China
  static const TagSlug china = _PresetTagSlug('china');

  /// Israel
  static const TagSlug israel = _PresetTagSlug('israel');

  /// Iran
  static const TagSlug iran = _PresetTagSlug('iran');

  /// Middle East
  static const TagSlug middleEast = _PresetTagSlug('middle-east');

  /// Europe
  static const TagSlug europe = _PresetTagSlug('europe');

  /// UK/Britain
  static const TagSlug uk = _PresetTagSlug('uk');

  /// France
  static const TagSlug france = _PresetTagSlug('france');

  /// Germany
  static const TagSlug germany = _PresetTagSlug('germany');

  /// Japan
  static const TagSlug japan = _PresetTagSlug('japan');

  /// India
  static const TagSlug india = _PresetTagSlug('india');

  /// Brazil
  static const TagSlug brazil = _PresetTagSlug('brazil');

  /// Mexico
  static const TagSlug mexico = _PresetTagSlug('mexico');

  /// Canada
  static const TagSlug canada = _PresetTagSlug('canada');

  /// Australia
  static const TagSlug australia = _PresetTagSlug('australia');

  /// South Korea
  static const TagSlug southKorea = _PresetTagSlug('south-korea');

  /// Poland
  static const TagSlug poland = _PresetTagSlug('poland');

  /// Ireland
  static const TagSlug ireland = _PresetTagSlug('ireland');

  /// Moldova
  static const TagSlug moldova = _PresetTagSlug('moldova');

  /// War/Conflict
  static const TagSlug war = _PresetTagSlug('war');

  /// NATO
  static const TagSlug nato = _PresetTagSlug('nato');

  /// UN
  static const TagSlug un = _PresetTagSlug('un');

  /// EU
  static const TagSlug eu = _PresetTagSlug('eu');

  // ============================================================
  // PEOPLE/PERSONALITIES
  // ============================================================

  /// Elon Musk
  static const TagSlug elonMusk = _PresetTagSlug('elon-musk');

  /// Joe Rogan
  static const TagSlug joeRogan = _PresetTagSlug('joe-rogan');

  /// Kanye West / Ye
  static const TagSlug kanyeWest = _PresetTagSlug('kanye-west');

  /// Putin
  static const TagSlug putin = _PresetTagSlug('putin');

  /// Netanyahu
  static const TagSlug netanyahu = _PresetTagSlug('netanyahu');

  /// Pope Francis
  static const TagSlug popeFrancis = _PresetTagSlug('pope-francis');

  /// Taylor Swift
  static const TagSlug taylorSwift = _PresetTagSlug('taylor-swift');

  // ============================================================
  // MISCELLANEOUS POPULAR TAGS
  // ============================================================

  /// Legal proceedings/cases
  static const TagSlug legalProceedings = _PresetTagSlug('legal-proceedings');

  /// Legal cases
  static const TagSlug legalCases = _PresetTagSlug('legal-cases');

  /// Social media
  static const TagSlug socialMedia = _PresetTagSlug('social-media');

  /// Podcast
  static const TagSlug podcast = _PresetTagSlug('podcast');

  /// Reddit
  static const TagSlug reddit = _PresetTagSlug('reddit');

  /// OnlyFans
  static const TagSlug onlyfans = _PresetTagSlug('onlyfans');

  /// Volcano
  static const TagSlug volcano = _PresetTagSlug('volcano');

  /// Global temperature
  static const TagSlug globalTemp = _PresetTagSlug('global-temp');

  // ============================================================
  // ALL PRESETS
  // ============================================================

  /// All preset tag slugs
  static const List<TagSlug> allPresets = [
    // Main categories
    politics, sports, crypto, business, entertainment, popCulture, science,
    tech, finance, news, world,
    // Politics
    election, trump, biden, harris, congress, senate, house, supremeCourt,
    governor, republicans, democrats,
    // Sports
    nfl, nba, mlb, nhl, cfb, cbb, soccer, premierLeague, laLiga, bundesliga,
    serieA, ligue1, championsLeague, mls, worldCup, tennis, golf, pga, boxing,
    mma, ufc, f1, nascar, olympics, cricket, rugby, esports, horseRacing,
    superBowl, nbaFinals, worldSeries, stanleyCup, marchMadness, heismanTrophy,
    tourDeFrance, uefaNationsLeague,
    // Crypto
    bitcoin, ethereum, solana, xrp, doge, cardano, polygon, defi, nft, etfs,
    cryptocurrency,
    // Business
    economy, gdp, inflation, interestRates, fed, ipos, ceos, layoffs, tradeWar,
    bankOfJapan, bankOfCanada, monetaryPolicy,
    // Entertainment
    movies, tv, music, album, oscars, grammys, emmys, billboardHot100,
    rottenTomatoes, youtube, tiktok, streaming, netflix,
    // Science/Tech
    ai, openai, chatgpt, spacex, nasa, space, climate, tesla, apple, google,
    microsoft, amazon, meta,
    // World
    ukraine, russia, china, israel, iran, middleEast, europe, uk, france,
    germany, japan, india, brazil, mexico, canada, australia, southKorea,
    poland, ireland, moldova, war, nato, un, eu,
    // People
    elonMusk, joeRogan, kanyeWest, putin, netanyahu, popeFrancis, taylorSwift,
    // Misc
    legalProceedings, legalCases, socialMedia, podcast, reddit, onlyfans,
    volcano, globalTemp,
  ];

  /// Main category presets
  static const List<TagSlug> categoryPresets = [
    politics, sports, crypto, business, entertainment, popCulture, science,
    tech, finance, news, world,
  ];

  /// Politics-related presets
  static const List<TagSlug> politicsPresets = [
    politics, election, trump, biden, harris, congress, senate, house,
    supremeCourt, governor, republicans, democrats,
  ];

  /// Sports-related presets
  static const List<TagSlug> sportsPresets = [
    sports, nfl, nba, mlb, nhl, cfb, cbb, soccer, premierLeague, laLiga,
    bundesliga, serieA, ligue1, championsLeague, mls, worldCup, tennis, golf,
    pga, boxing, mma, ufc, f1, nascar, olympics, cricket, rugby, esports,
    horseRacing, superBowl, nbaFinals, worldSeries, stanleyCup, marchMadness,
    heismanTrophy, tourDeFrance, uefaNationsLeague,
  ];

  /// Crypto-related presets
  static const List<TagSlug> cryptoPresets = [
    crypto, bitcoin, ethereum, solana, xrp, doge, cardano, polygon, defi, nft,
    etfs, cryptocurrency,
  ];

  /// Business/Finance presets
  static const List<TagSlug> businessPresets = [
    business, finance, economy, gdp, inflation, interestRates, fed, ipos, ceos,
    layoffs, tradeWar, bankOfJapan, bankOfCanada, monetaryPolicy,
  ];

  /// Entertainment presets
  static const List<TagSlug> entertainmentPresets = [
    entertainment, popCulture, movies, tv, music, album, oscars, grammys, emmys,
    billboardHot100, rottenTomatoes, youtube, tiktok, streaming, netflix,
  ];

  /// Science/Tech presets
  static const List<TagSlug> scienceTechPresets = [
    science, tech, ai, openai, chatgpt, spacex, nasa, space, climate, tesla,
    apple, google, microsoft, amazon, meta,
  ];

  /// World/Geopolitics presets
  static const List<TagSlug> worldPresets = [
    world, ukraine, russia, china, israel, iran, middleEast, europe, uk, france,
    germany, japan, india, brazil, mexico, canada, australia, southKorea,
    poland, ireland, moldova, war, nato, un, eu,
  ];

  // ============================================================
  // FACTORY METHODS
  // ============================================================

  /// Create a custom tag slug for user-created or unlisted tags.
  ///
  /// Throws [ArgumentError] if the slug is empty or contains only whitespace.
  ///
  /// ```dart
  /// final events = await client.gamma.events.listEvents(
  ///   tagSlug: TagSlug.custom('my-custom-tag'),
  /// );
  /// ```
  factory TagSlug.custom(String slug) {
    final trimmed = slug.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(slug, 'slug', 'Cannot be empty or whitespace');
    }
    return _CustomTagSlug(trimmed);
  }

  /// Try to find a preset matching the given slug value.
  ///
  /// Returns `null` if no preset matches.
  static TagSlug? tryFromPreset(String value) {
    final lower = value.toLowerCase();
    for (final preset in allPresets) {
      if (preset.value.toLowerCase() == lower) {
        return preset;
      }
    }
    return null;
  }

  /// Find a preset matching the given slug value, or create a custom slug.
  ///
  /// If a preset matches the value, returns that preset.
  /// Otherwise, creates a custom slug with the given value.
  static TagSlug fromValue(String value) {
    return tryFromPreset(value) ?? TagSlug.custom(value);
  }

  /// Parse from JSON string.
  ///
  /// Attempts to match a preset first, then creates a custom slug.
  static TagSlug fromJson(String json) {
    return fromValue(json);
  }

  @override
  String toString() => 'TagSlug($value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagSlug && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Preset tag slug (immutable singleton)
class _PresetTagSlug extends TagSlug {
  @override
  final String value;

  const _PresetTagSlug(this.value);
}

/// Custom tag slug (user-provided)
class _CustomTagSlug extends TagSlug {
  @override
  final String value;

  const _CustomTagSlug(this.value);
}

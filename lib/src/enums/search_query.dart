/// A type-safe search query that supports both predefined topics and custom text.
///
/// Use factory constructors for common searches, or [SearchQuery.custom] for any text.
///
/// ```dart
/// // Predefined queries
/// final results = await search(query: SearchQuery.bitcoin);
/// final results = await search(query: SearchQuery.election);
///
/// // Custom query
/// final results = await search(query: SearchQuery.custom('my search'));
/// ```
sealed class SearchQuery {
  const SearchQuery._();

  /// Get the query string value
  String get value;

  // ============================================
  // Custom Query
  // ============================================

  /// Create a custom search query with any text.
  ///
  /// Throws [ArgumentError] if query is empty or only whitespace.
  ///
  /// ```dart
  /// final query = SearchQuery.custom('my search');
  /// ```
  factory SearchQuery.custom(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(query, 'query', 'Cannot be empty or whitespace');
    }
    return _CustomQuery(trimmed);
  }

  // ============================================
  // Preset Lookup
  // ============================================

  /// Try to find a preset query matching the given value.
  ///
  /// Returns `null` if no preset matches. Use this to reconstruct
  /// a SearchQuery from an API response string.
  ///
  /// ```dart
  /// final query = SearchQuery.tryFromPreset('bitcoin');
  /// // Returns SearchQuery.bitcoin
  ///
  /// final unknown = SearchQuery.tryFromPreset('unknown');
  /// // Returns null
  /// ```
  static SearchQuery? tryFromPreset(String value) {
    final lower = value.toLowerCase();
    for (final preset in allPresets) {
      if (preset.value.toLowerCase() == lower) {
        return preset;
      }
    }
    return null;
  }

  /// Find a preset query matching the given value, or create a custom query.
  ///
  /// This never returns null - if no preset matches, returns a custom query.
  ///
  /// ```dart
  /// final query = SearchQuery.fromValue('bitcoin');
  /// // Returns SearchQuery.bitcoin
  ///
  /// final custom = SearchQuery.fromValue('my custom search');
  /// // Returns SearchQuery.custom('my custom search')
  /// ```
  static SearchQuery fromValue(String value) {
    return tryFromPreset(value) ?? SearchQuery.custom(value);
  }

  // ============================================
  // Crypto / Web3
  // ============================================

  /// Search for Bitcoin-related markets
  static const SearchQuery bitcoin = _PresetQuery('bitcoin', 'Bitcoin');

  /// Search for Ethereum-related markets
  static const SearchQuery ethereum = _PresetQuery('ethereum', 'Ethereum');

  /// Search for Solana-related markets
  static const SearchQuery solana = _PresetQuery('solana', 'Solana');

  /// Search for crypto-related markets
  static const SearchQuery crypto = _PresetQuery('crypto', 'Crypto');

  /// Search for DeFi-related markets
  static const SearchQuery defi = _PresetQuery('defi', 'DeFi');

  /// Search for NFT-related markets
  static const SearchQuery nft = _PresetQuery('nft', 'NFT');

  /// Search for memecoin-related markets
  static const SearchQuery memecoin = _PresetQuery('memecoin', 'Memecoin');

  /// Search for altcoin-related markets
  static const SearchQuery altcoin = _PresetQuery('altcoin', 'Altcoin');

  // ============================================
  // Politics
  // ============================================

  /// Search for election-related markets
  static const SearchQuery election = _PresetQuery('election', 'Election');

  /// Search for Trump-related markets
  static const SearchQuery trump = _PresetQuery('trump', 'Trump');

  /// Search for Biden-related markets
  static const SearchQuery biden = _PresetQuery('biden', 'Biden');

  /// Search for presidential markets
  static const SearchQuery president = _PresetQuery('president', 'President');

  /// Search for Congress-related markets
  static const SearchQuery congress = _PresetQuery('congress', 'Congress');

  /// Search for Senate-related markets
  static const SearchQuery senate = _PresetQuery('senate', 'Senate');

  /// Search for Supreme Court-related markets
  static const SearchQuery supremeCourt =
      _PresetQuery('supreme court', 'Supreme Court');

  /// Search for policy-related markets
  static const SearchQuery policy = _PresetQuery('policy', 'Policy');

  // ============================================
  // Sports
  // ============================================

  /// Search for NFL-related markets
  static const SearchQuery nfl = _PresetQuery('nfl', 'NFL');

  /// Search for NBA-related markets
  static const SearchQuery nba = _PresetQuery('nba', 'NBA');

  /// Search for MLB-related markets
  static const SearchQuery mlb = _PresetQuery('mlb', 'MLB');

  /// Search for NHL-related markets
  static const SearchQuery nhl = _PresetQuery('nhl', 'NHL');

  /// Search for soccer-related markets
  static const SearchQuery soccer = _PresetQuery('soccer', 'Soccer');

  /// Search for football-related markets
  static const SearchQuery football = _PresetQuery('football', 'Football');

  /// Search for basketball-related markets
  static const SearchQuery basketball = _PresetQuery('basketball', 'Basketball');

  /// Search for UFC/MMA-related markets
  static const SearchQuery ufc = _PresetQuery('ufc', 'UFC');

  /// Search for boxing-related markets
  static const SearchQuery boxing = _PresetQuery('boxing', 'Boxing');

  /// Search for tennis-related markets
  static const SearchQuery tennis = _PresetQuery('tennis', 'Tennis');

  /// Search for golf-related markets
  static const SearchQuery golf = _PresetQuery('golf', 'Golf');

  /// Search for Olympics-related markets
  static const SearchQuery olympics = _PresetQuery('olympics', 'Olympics');

  /// Search for Super Bowl-related markets
  static const SearchQuery superBowl = _PresetQuery('super bowl', 'Super Bowl');

  /// Search for World Cup-related markets
  static const SearchQuery worldCup = _PresetQuery('world cup', 'World Cup');

  // ============================================
  // Entertainment / Pop Culture
  // ============================================

  /// Search for Oscar-related markets
  static const SearchQuery oscars = _PresetQuery('oscars', 'Oscars');

  /// Search for Grammy-related markets
  static const SearchQuery grammys = _PresetQuery('grammys', 'Grammys');

  /// Search for Emmy-related markets
  static const SearchQuery emmys = _PresetQuery('emmys', 'Emmys');

  /// Search for movie-related markets
  static const SearchQuery movies = _PresetQuery('movies', 'Movies');

  /// Search for TV-related markets
  static const SearchQuery tv = _PresetQuery('tv', 'TV');

  /// Search for music-related markets
  static const SearchQuery music = _PresetQuery('music', 'Music');

  /// Search for celebrity-related markets
  static const SearchQuery celebrity = _PresetQuery('celebrity', 'Celebrity');

  /// Search for Taylor Swift-related markets
  static const SearchQuery taylorSwift =
      _PresetQuery('taylor swift', 'Taylor Swift');

  /// Search for streaming-related markets
  static const SearchQuery streaming = _PresetQuery('streaming', 'Streaming');

  // ============================================
  // Business / Finance
  // ============================================

  /// Search for stock-related markets
  static const SearchQuery stocks = _PresetQuery('stocks', 'Stocks');

  /// Search for Fed/Federal Reserve-related markets
  static const SearchQuery fed = _PresetQuery('fed', 'Fed');

  /// Search for interest rate-related markets
  static const SearchQuery interestRates =
      _PresetQuery('interest rates', 'Interest Rates');

  /// Search for inflation-related markets
  static const SearchQuery inflation = _PresetQuery('inflation', 'Inflation');

  /// Search for recession-related markets
  static const SearchQuery recession = _PresetQuery('recession', 'Recession');

  /// Search for IPO-related markets
  static const SearchQuery ipo = _PresetQuery('ipo', 'IPO');

  /// Search for Tesla-related markets
  static const SearchQuery tesla = _PresetQuery('tesla', 'Tesla');

  /// Search for Apple-related markets
  static const SearchQuery apple = _PresetQuery('apple', 'Apple');

  /// Search for Google-related markets
  static const SearchQuery google = _PresetQuery('google', 'Google');

  /// Search for Amazon-related markets
  static const SearchQuery amazon = _PresetQuery('amazon', 'Amazon');

  /// Search for Microsoft-related markets
  static const SearchQuery microsoft = _PresetQuery('microsoft', 'Microsoft');

  /// Search for Elon Musk-related markets
  static const SearchQuery elonMusk = _PresetQuery('elon musk', 'Elon Musk');

  // ============================================
  // Science / Technology
  // ============================================

  /// Search for AI-related markets
  static const SearchQuery ai = _PresetQuery('ai', 'AI');

  /// Search for OpenAI-related markets
  static const SearchQuery openai = _PresetQuery('openai', 'OpenAI');

  /// Search for ChatGPT-related markets
  static const SearchQuery chatgpt = _PresetQuery('chatgpt', 'ChatGPT');

  /// Search for SpaceX-related markets
  static const SearchQuery spacex = _PresetQuery('spacex', 'SpaceX');

  /// Search for NASA-related markets
  static const SearchQuery nasa = _PresetQuery('nasa', 'NASA');

  /// Search for climate-related markets
  static const SearchQuery climate = _PresetQuery('climate', 'Climate');

  /// Search for space-related markets
  static const SearchQuery space = _PresetQuery('space', 'Space');

  /// Search for Mars-related markets
  static const SearchQuery mars = _PresetQuery('mars', 'Mars');

  // ============================================
  // World Events
  // ============================================

  /// Search for war-related markets
  static const SearchQuery war = _PresetQuery('war', 'War');

  /// Search for Ukraine-related markets
  static const SearchQuery ukraine = _PresetQuery('ukraine', 'Ukraine');

  /// Search for Russia-related markets
  static const SearchQuery russia = _PresetQuery('russia', 'Russia');

  /// Search for China-related markets
  static const SearchQuery china = _PresetQuery('china', 'China');

  /// Search for Israel-related markets
  static const SearchQuery israel = _PresetQuery('israel', 'Israel');

  /// Search for Middle East-related markets
  static const SearchQuery middleEast =
      _PresetQuery('middle east', 'Middle East');

  // ============================================
  // All Presets List
  // ============================================

  /// Get all available preset queries
  static List<SearchQuery> get allPresets => [
        // Crypto
        bitcoin,
        ethereum,
        solana,
        crypto,
        defi,
        nft,
        memecoin,
        altcoin,
        // Politics
        election,
        trump,
        biden,
        president,
        congress,
        senate,
        supremeCourt,
        policy,
        // Sports
        nfl,
        nba,
        mlb,
        nhl,
        soccer,
        football,
        basketball,
        ufc,
        boxing,
        tennis,
        golf,
        olympics,
        superBowl,
        worldCup,
        // Entertainment
        oscars,
        grammys,
        emmys,
        movies,
        tv,
        music,
        celebrity,
        taylorSwift,
        streaming,
        // Business
        stocks,
        fed,
        interestRates,
        inflation,
        recession,
        ipo,
        tesla,
        apple,
        google,
        amazon,
        microsoft,
        elonMusk,
        // Science/Tech
        ai,
        openai,
        chatgpt,
        spacex,
        nasa,
        climate,
        space,
        mars,
        // World
        war,
        ukraine,
        russia,
        china,
        israel,
        middleEast,
      ];

  /// Get preset queries by category
  static List<SearchQuery> get cryptoPresets =>
      [bitcoin, ethereum, solana, crypto, defi, nft, memecoin, altcoin];

  static List<SearchQuery> get politicsPresets =>
      [election, trump, biden, president, congress, senate, supremeCourt, policy];

  static List<SearchQuery> get sportsPresets => [
        nfl,
        nba,
        mlb,
        nhl,
        soccer,
        football,
        basketball,
        ufc,
        boxing,
        tennis,
        golf,
        olympics,
        superBowl,
        worldCup
      ];

  static List<SearchQuery> get entertainmentPresets =>
      [oscars, grammys, emmys, movies, tv, music, celebrity, taylorSwift, streaming];

  static List<SearchQuery> get businessPresets => [
        stocks,
        fed,
        interestRates,
        inflation,
        recession,
        ipo,
        tesla,
        apple,
        google,
        amazon,
        microsoft,
        elonMusk
      ];

  static List<SearchQuery> get sciencePresets =>
      [ai, openai, chatgpt, spacex, nasa, climate, space, mars];

  static List<SearchQuery> get worldPresets =>
      [war, ukraine, russia, china, israel, middleEast];
}

/// Internal: Preset query with a display label
final class _PresetQuery extends SearchQuery {
  @override
  final String value;
  final String label;

  const _PresetQuery(this.value, this.label) : super._();

  @override
  String toString() => 'SearchQuery.$label($value)';
}

/// Internal: Custom user-provided query
final class _CustomQuery extends SearchQuery {
  @override
  final String value;

  const _CustomQuery(this.value) : super._();

  @override
  String toString() => 'SearchQuery.custom($value)';
}

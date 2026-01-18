/// Subcategories for business markets.
enum BusinessSubcategory {
  /// Tech companies
  tech('tech-companies', 'Tech Companies'),

  /// Apple
  apple('apple', 'Apple'),

  /// Google/Alphabet
  google('google', 'Google'),

  /// Microsoft
  microsoft('microsoft', 'Microsoft'),

  /// Amazon
  amazon('amazon', 'Amazon'),

  /// Meta/Facebook
  meta('meta', 'Meta'),

  /// Tesla
  tesla('tesla', 'Tesla'),

  /// Nvidia
  nvidia('nvidia', 'Nvidia'),

  /// OpenAI
  openai('openai', 'OpenAI'),

  /// SpaceX
  spacex('spacex', 'SpaceX'),

  /// Twitter/X
  twitter('twitter', 'Twitter/X'),

  /// Elon Musk
  elonMusk('elon-musk', 'Elon Musk'),

  /// IPOs
  ipo('ipo', 'IPOs'),

  /// Mergers & Acquisitions
  mergers('mergers', 'M&A'),

  /// Earnings
  earnings('earnings', 'Earnings'),

  /// Stock market
  stockMarket('stock-market', 'Stock Market'),

  /// S&P 500
  sp500('sp500', 'S&P 500'),

  /// Dow Jones
  dow('dow-jones', 'Dow Jones'),

  /// Nasdaq
  nasdaq('nasdaq', 'Nasdaq'),

  /// Federal Reserve
  fed('fed', 'Federal Reserve'),

  /// Interest rates
  interestRates('interest-rates', 'Interest Rates'),

  /// Inflation
  inflation('inflation', 'Inflation'),

  /// Recession
  recession('recession', 'Recession'),

  /// Employment/Jobs
  employment('employment', 'Employment'),

  /// GDP
  gdp('gdp', 'GDP'),

  /// Oil/Energy
  oil('oil', 'Oil/Energy'),

  /// Real estate
  realEstate('real-estate', 'Real Estate'),

  /// Banking
  banking('banking', 'Banking'),

  /// Venture capital
  vc('vc', 'Venture Capital'),

  /// Startups
  startups('startups', 'Startups'),

  /// Layoffs
  layoffs('layoffs', 'Layoffs'),

  /// CEO changes
  ceo('ceo', 'CEO Changes'),

  /// Other business
  other('other-business', 'Other Business');

  final String slug;
  final String label;

  const BusinessSubcategory(this.slug, this.label);

  String toJson() => slug;

  static BusinessSubcategory fromJson(String json) {
    return BusinessSubcategory.values.firstWhere(
      (e) => e.slug == json || e.name == json,
      orElse: () => BusinessSubcategory.other,
    );
  }

  static BusinessSubcategory? bySlug(String slug) {
    try {
      return BusinessSubcategory.values.firstWhere((e) => e.slug == slug);
    } catch (_) {
      return null;
    }
  }
}

import '../gamma/models/event.dart';
import '../gamma/models/market.dart';
import '../gamma/models/tag.dart';
import 'market_category.dart';
import 'politics_subcategory.dart';
import 'sports_subcategory.dart';
import 'crypto_subcategory.dart';
import 'pop_culture_subcategory.dart';
import 'business_subcategory.dart';
import 'science_subcategory.dart';

/// Result of category detection containing category and subcategories.
class CategoryResult {
  /// The main category detected.
  final MarketCategory category;

  /// Detected subcategories (can be multiple).
  final List<dynamic> subcategories;

  /// Raw tag slugs that were used for detection.
  final List<String> tagSlugs;

  const CategoryResult({
    required this.category,
    this.subcategories = const [],
    this.tagSlugs = const [],
  });

  @override
  String toString() =>
      'CategoryResult(category: ${category.label}, subcategories: ${subcategories.length}, tags: $tagSlugs)';
}

/// Utility class for detecting categories and subcategories from events, markets, and tags.
class CategoryDetector {
  CategoryDetector._();

  /// Detect category from a single tag slug.
  static MarketCategory detectCategoryFromSlug(String slug) {
    final normalized = slug.toLowerCase();

    // Politics
    if (_isPoliticsSlug(normalized)) return MarketCategory.politics;

    // Sports
    if (_isSportsSlug(normalized)) return MarketCategory.sports;

    // Crypto
    if (_isCryptoSlug(normalized)) return MarketCategory.crypto;

    // Pop Culture
    if (_isPopCultureSlug(normalized)) return MarketCategory.popCulture;

    // Business
    if (_isBusinessSlug(normalized)) return MarketCategory.business;

    // Science
    if (_isScienceSlug(normalized)) return MarketCategory.science;

    // Try to match by enum
    return MarketCategory.bySlug(slug) ?? MarketCategory.other;
  }

  /// Detect full category result from a list of tag slugs.
  static CategoryResult detectFromTagSlugs(List<String> slugs) {
    if (slugs.isEmpty) {
      return const CategoryResult(category: MarketCategory.other);
    }

    // Count category occurrences
    final categoryCounts = <MarketCategory, int>{};
    final detectedSubcategories = <dynamic>[];

    for (final slug in slugs) {
      final category = detectCategoryFromSlug(slug);
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;

      // Detect subcategories
      final subcategory = _detectSubcategory(slug, category);
      if (subcategory != null && !detectedSubcategories.contains(subcategory)) {
        detectedSubcategories.add(subcategory);
      }
    }

    // Get the most common category (excluding "other" if we have alternatives)
    MarketCategory bestCategory = MarketCategory.other;
    int bestCount = 0;

    for (final entry in categoryCounts.entries) {
      if (entry.key != MarketCategory.other && entry.value > bestCount) {
        bestCategory = entry.key;
        bestCount = entry.value;
      }
    }

    // If only "other" was found, use it
    if (bestCategory == MarketCategory.other &&
        categoryCounts.containsKey(MarketCategory.other)) {
      bestCategory = MarketCategory.other;
    }

    return CategoryResult(
      category: bestCategory,
      subcategories: detectedSubcategories,
      tagSlugs: slugs,
    );
  }

  /// Detect category from a list of Tag objects.
  static CategoryResult detectFromTags(List<Tag> tags) {
    final slugs = tags
        .where((t) => t.slug != null)
        .map((t) => t.slug!)
        .toList();
    return detectFromTagSlugs(slugs);
  }

  /// Detect category from an Event.
  static CategoryResult detectFromEvent(Event event) {
    final slugs = <String>[];

    // Get slugs from event's tags if available
    if (event.tags != null) {
      for (final tag in event.tags!) {
        if (tag.slug != null) {
          slugs.add(tag.slug!);
        }
      }
    }

    // Also check the event slug itself for hints
    if (event.slug != null) {
      slugs.add(event.slug!);
    }

    return detectFromTagSlugs(slugs);
  }

  /// Detect category from a Market.
  static CategoryResult detectFromMarket(Market market) {
    final slugs = <String>[];

    // Get slugs from market's tags if available
    if (market.tags != null) {
      for (final tag in market.tags!) {
        if (tag.slug != null) {
          slugs.add(tag.slug!);
        }
      }
    }

    // Also check the market slug itself for hints
    if (market.slug != null) {
      slugs.add(market.slug!);
    }

    return detectFromTagSlugs(slugs);
  }

  /// Detect categories from a list of Events.
  static List<CategoryResult> detectFromEvents(List<Event> events) {
    return events.map(detectFromEvent).toList();
  }

  /// Detect categories from a list of Markets.
  static List<CategoryResult> detectFromMarkets(List<Market> markets) {
    return markets.map(detectFromMarket).toList();
  }

  /// Get unique categories from a list of Events.
  static Set<MarketCategory> getUniqueCategoriesFromEvents(List<Event> events) {
    return events.map((e) => detectFromEvent(e).category).toSet();
  }

  /// Get unique categories from a list of Markets.
  static Set<MarketCategory> getUniqueCategoriesFromMarkets(
      List<Market> markets) {
    return markets.map((m) => detectFromMarket(m).category).toSet();
  }

  /// Group events by category.
  static Map<MarketCategory, List<Event>> groupEventsByCategory(
      List<Event> events) {
    final result = <MarketCategory, List<Event>>{};
    for (final event in events) {
      final category = detectFromEvent(event).category;
      result.putIfAbsent(category, () => []).add(event);
    }
    return result;
  }

  /// Group markets by category.
  static Map<MarketCategory, List<Market>> groupMarketsByCategory(
      List<Market> markets) {
    final result = <MarketCategory, List<Market>>{};
    for (final market in markets) {
      final category = detectFromMarket(market).category;
      result.putIfAbsent(category, () => []).add(market);
    }
    return result;
  }

  /// Get all available categories.
  static List<MarketCategory> getAllCategories() {
    return MarketCategory.values.toList();
  }

  /// Get all subcategories for a given category.
  static List<dynamic> getSubcategoriesFor(MarketCategory category) {
    switch (category) {
      case MarketCategory.politics:
        return PoliticsSubcategory.values;
      case MarketCategory.sports:
        return SportsSubcategory.values;
      case MarketCategory.crypto:
        return CryptoSubcategory.values;
      case MarketCategory.popCulture:
        return PopCultureSubcategory.values;
      case MarketCategory.business:
        return BusinessSubcategory.values;
      case MarketCategory.science:
      case MarketCategory.technology:
        return ScienceSubcategory.values;
      default:
        return [];
    }
  }

  // Private helper methods for category detection

  static bool _isPoliticsSlug(String slug) {
    const keywords = [
      'politic',
      'election',
      'trump',
      'biden',
      'harris',
      'democrat',
      'republican',
      'congress',
      'senate',
      'house',
      'president',
      'vote',
      'ballot',
      'campaign',
      'governor',
      'mayor',
      'parliament',
      'prime-minister',
      'government',
      'legislation',
      'policy',
      'supreme-court',
      'geopolitic',
    ];
    return keywords.any((k) => slug.contains(k));
  }

  static bool _isSportsSlug(String slug) {
    const keywords = [
      'sport',
      'nfl',
      'nba',
      'mlb',
      'nhl',
      'soccer',
      'football',
      'basketball',
      'baseball',
      'hockey',
      'tennis',
      'golf',
      'boxing',
      'ufc',
      'mma',
      'f1',
      'formula',
      'nascar',
      'olympics',
      'cricket',
      'rugby',
      'premier-league',
      'champions-league',
      'world-cup',
      'super-bowl',
      'march-madness',
      'esport',
    ];
    return keywords.any((k) => slug.contains(k));
  }

  static bool _isCryptoSlug(String slug) {
    const keywords = [
      'crypto',
      'bitcoin',
      'btc',
      'ethereum',
      'eth',
      'solana',
      'sol',
      'xrp',
      'doge',
      'defi',
      'nft',
      'blockchain',
      'token',
      'coin',
      'web3',
      'dao',
      'binance',
      'coinbase',
      'stablecoin',
      'altcoin',
      'memecoin',
    ];
    return keywords.any((k) => slug.contains(k));
  }

  static bool _isPopCultureSlug(String slug) {
    const keywords = [
      'pop-culture',
      'celebrity',
      'movie',
      'film',
      'tv',
      'television',
      'music',
      'oscar',
      'grammy',
      'emmy',
      'award',
      'netflix',
      'disney',
      'marvel',
      'star-wars',
      'youtube',
      'tiktok',
      'influencer',
      'streaming',
      'entertainment',
      'reality-tv',
      'bachelor',
      'kardashian',
      'taylor-swift',
      'kanye',
      'drake',
    ];
    return keywords.any((k) => slug.contains(k));
  }

  static bool _isBusinessSlug(String slug) {
    const keywords = [
      'business',
      'stock',
      'market',
      'ipo',
      'merger',
      'earnings',
      'apple',
      'google',
      'microsoft',
      'amazon',
      'meta',
      'tesla',
      'nvidia',
      'openai',
      'spacex',
      'fed',
      'interest-rate',
      'inflation',
      'recession',
      'gdp',
      'employment',
      'jobs',
      'economy',
      'finance',
      'bank',
      'sp500',
      'dow',
      'nasdaq',
      'elon-musk',
    ];
    return keywords.any((k) => slug.contains(k));
  }

  static bool _isScienceSlug(String slug) {
    const keywords = [
      'science',
      'tech',
      'ai',
      'artificial-intelligence',
      'chatgpt',
      'llm',
      'machine-learning',
      'robot',
      'space',
      'nasa',
      'spacex',
      'mars',
      'moon',
      'rocket',
      'climate',
      'weather',
      'hurricane',
      'earthquake',
      'energy',
      'solar',
      'nuclear',
      'ev',
      'electric-vehicle',
      'biotech',
      'medicine',
      'vaccine',
      'covid',
      'fda',
      'quantum',
      'physics',
      'astronomy',
      'ufo',
    ];
    return keywords.any((k) => slug.contains(k));
  }

  static dynamic _detectSubcategory(String slug, MarketCategory category) {
    switch (category) {
      case MarketCategory.politics:
        return PoliticsSubcategory.bySlug(slug);
      case MarketCategory.sports:
        return SportsSubcategory.bySlug(slug);
      case MarketCategory.crypto:
        return CryptoSubcategory.bySlug(slug);
      case MarketCategory.popCulture:
        return PopCultureSubcategory.bySlug(slug);
      case MarketCategory.business:
        return BusinessSubcategory.bySlug(slug);
      case MarketCategory.science:
      case MarketCategory.technology:
        return ScienceSubcategory.bySlug(slug);
      default:
        return null;
    }
  }
}

/// Extension on List<Event> to add category detection.
extension EventListCategoryExtension on List<Event> {
  /// Detect categories for all events.
  List<CategoryResult> detectCategories() {
    return CategoryDetector.detectFromEvents(this);
  }

  /// Get unique categories.
  Set<MarketCategory> get uniqueCategories {
    return CategoryDetector.getUniqueCategoriesFromEvents(this);
  }

  /// Group by category.
  Map<MarketCategory, List<Event>> groupByCategory() {
    return CategoryDetector.groupEventsByCategory(this);
  }
}

/// Extension on List<Market> to add category detection.
extension MarketListCategoryExtension on List<Market> {
  /// Detect categories for all markets.
  List<CategoryResult> detectCategories() {
    return CategoryDetector.detectFromMarkets(this);
  }

  /// Get unique categories.
  Set<MarketCategory> get uniqueCategories {
    return CategoryDetector.getUniqueCategoriesFromMarkets(this);
  }

  /// Group by category.
  Map<MarketCategory, List<Market>> groupByCategory() {
    return CategoryDetector.groupMarketsByCategory(this);
  }
}

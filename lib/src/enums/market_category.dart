/// Main categories for Polymarket events and markets.
enum MarketCategory {
  /// Political events and elections
  politics('politics', 'Politics'),

  /// Sports and athletic events
  sports('sports', 'Sports'),

  /// Cryptocurrency and blockchain
  crypto('crypto', 'Crypto'),

  /// Pop culture, entertainment, celebrities
  popCulture('pop-culture', 'Pop Culture'),

  /// Business and economics
  business('business', 'Business'),

  /// Science and technology
  science('science', 'Science'),

  /// Global and world events
  world('world', 'World'),

  /// Financial markets
  finance('finance', 'Finance'),

  /// Entertainment and media
  entertainment('entertainment', 'Entertainment'),

  /// Technology
  technology('technology', 'Technology'),

  /// Health and medicine
  health('health', 'Health'),

  /// Climate and environment
  climate('climate', 'Climate'),

  /// Legal and court cases
  legal('legal', 'Legal'),

  /// Gaming and esports
  gaming('gaming', 'Gaming'),

  /// Education
  education('education', 'Education'),

  /// Social media
  socialMedia('social-media', 'Social Media'),

  /// AI and machine learning
  ai('ai', 'AI'),

  /// Space and astronomy
  space('space', 'Space'),

  /// Elections (subset of politics)
  elections('elections', 'Elections'),

  /// News events
  news('news', 'News'),

  /// Other/miscellaneous
  other('other', 'Other');

  final String slug;
  final String label;

  const MarketCategory(this.slug, this.label);

  /// Convert to JSON string (slug)
  String toJson() => slug;

  /// Create from JSON string
  static MarketCategory fromJson(String json) {
    return MarketCategory.values.firstWhere(
      (e) => e.slug == json || e.name == json,
      orElse: () => MarketCategory.other,
    );
  }

  /// Get category by slug
  static MarketCategory? bySlug(String slug) {
    try {
      return MarketCategory.values.firstWhere((e) => e.slug == slug);
    } catch (_) {
      return null;
    }
  }
}

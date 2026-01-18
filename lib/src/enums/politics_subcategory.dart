/// Subcategories for political markets.
enum PoliticsSubcategory {
  /// US Presidential elections
  usPresidential('us-presidential', 'US Presidential'),

  /// US Congressional elections
  usCongress('us-congress', 'US Congress'),

  /// US Senate
  usSenate('us-senate', 'US Senate'),

  /// US House of Representatives
  usHouse('us-house', 'US House'),

  /// US State and local elections
  usState('us-state', 'US State'),

  /// US Political figures
  usPoliticians('us-politicians', 'US Politicians'),

  /// Democratic Party
  democrats('democrats', 'Democrats'),

  /// Republican Party
  republicans('republicans', 'Republicans'),

  /// Trump-related
  trump('trump', 'Trump'),

  /// Biden-related
  biden('biden', 'Biden'),

  /// Harris-related
  harris('harris', 'Harris'),

  /// International politics
  international('international', 'International'),

  /// UK politics
  uk('uk-politics', 'UK Politics'),

  /// European politics
  europe('europe-politics', 'European Politics'),

  /// France politics
  france('france-politics', 'France Politics'),

  /// Germany politics
  germany('germany-politics', 'Germany Politics'),

  /// Canadian politics
  canada('canada-politics', 'Canadian Politics'),

  /// Australian politics
  australia('australia-politics', 'Australian Politics'),

  /// Brazil politics
  brazil('brazil-politics', 'Brazil Politics'),

  /// India politics
  india('india-politics', 'India Politics'),

  /// China politics
  china('china-politics', 'China Politics'),

  /// Middle East politics
  middleEast('middle-east', 'Middle East'),

  /// Policy and legislation
  policy('policy', 'Policy'),

  /// Supreme Court
  supremeCourt('supreme-court', 'Supreme Court'),

  /// Government
  government('government', 'Government'),

  /// Geopolitics
  geopolitics('geopolitics', 'Geopolitics'),

  /// Elections (general)
  elections('elections', 'Elections');

  final String slug;
  final String label;

  const PoliticsSubcategory(this.slug, this.label);

  String toJson() => slug;

  static PoliticsSubcategory fromJson(String json) {
    return PoliticsSubcategory.values.firstWhere(
      (e) => e.slug == json || e.name == json,
      orElse: () => PoliticsSubcategory.elections,
    );
  }

  static PoliticsSubcategory? bySlug(String slug) {
    try {
      return PoliticsSubcategory.values.firstWhere((e) => e.slug == slug);
    } catch (_) {
      return null;
    }
  }
}

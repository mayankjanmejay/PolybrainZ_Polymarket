/// Subcategories for pop culture markets.
enum PopCultureSubcategory {
  /// Movies
  movies('movies', 'Movies'),

  /// Television
  tv('tv', 'Television'),

  /// Music
  music('music', 'Music'),

  /// Celebrities
  celebrities('celebrities', 'Celebrities'),

  /// Awards shows
  awards('awards', 'Awards'),

  /// Oscars
  oscars('oscars', 'Oscars'),

  /// Grammys
  grammys('grammys', 'Grammys'),

  /// Emmys
  emmys('emmys', 'Emmys'),

  /// Golden Globes
  goldenGlobes('golden-globes', 'Golden Globes'),

  /// Netflix
  netflix('netflix', 'Netflix'),

  /// Disney
  disney('disney', 'Disney'),

  /// Marvel
  marvel('marvel', 'Marvel'),

  /// DC Comics
  dc('dc', 'DC'),

  /// Star Wars
  starWars('star-wars', 'Star Wars'),

  /// Video games
  videoGames('video-games', 'Video Games'),

  /// Streaming
  streaming('streaming', 'Streaming'),

  /// YouTube
  youtube('youtube', 'YouTube'),

  /// TikTok
  tiktok('tiktok', 'TikTok'),

  /// Twitter/X
  twitter('twitter', 'Twitter/X'),

  /// Influencers
  influencers('influencers', 'Influencers'),

  /// Podcasts
  podcasts('podcasts', 'Podcasts'),

  /// Books
  books('books', 'Books'),

  /// Comics
  comics('comics', 'Comics'),

  /// Anime
  anime('anime', 'Anime'),

  /// Kpop
  kpop('kpop', 'K-Pop'),

  /// Reality TV
  realityTv('reality-tv', 'Reality TV'),

  /// Bachelor/Bachelorette
  bachelor('bachelor', 'Bachelor'),

  /// Survivor
  survivor('survivor', 'Survivor'),

  /// Memes
  memes('memes', 'Memes'),

  /// Fashion
  fashion('fashion', 'Fashion'),

  /// Other pop culture
  other('other-pop-culture', 'Other');

  final String slug;
  final String label;

  const PopCultureSubcategory(this.slug, this.label);

  String toJson() => slug;

  static PopCultureSubcategory fromJson(String json) {
    return PopCultureSubcategory.values.firstWhere(
      (e) => e.slug == json || e.name == json,
      orElse: () => PopCultureSubcategory.other,
    );
  }

  static PopCultureSubcategory? bySlug(String slug) {
    try {
      return PopCultureSubcategory.values.firstWhere((e) => e.slug == slug);
    } catch (_) {
      return null;
    }
  }
}

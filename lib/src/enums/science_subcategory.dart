/// Subcategories for science and technology markets.
enum ScienceSubcategory {
  /// Artificial Intelligence
  ai('ai', 'AI'),

  /// ChatGPT
  chatgpt('chatgpt', 'ChatGPT'),

  /// Large Language Models
  llm('llm', 'LLMs'),

  /// Machine Learning
  machineLearning('machine-learning', 'Machine Learning'),

  /// Robotics
  robotics('robotics', 'Robotics'),

  /// Self-driving cars
  selfDriving('self-driving', 'Self-Driving'),

  /// Space exploration
  space('space', 'Space'),

  /// SpaceX
  spacex('spacex', 'SpaceX'),

  /// NASA
  nasa('nasa', 'NASA'),

  /// Mars
  mars('mars', 'Mars'),

  /// Moon
  moon('moon', 'Moon'),

  /// Rockets
  rockets('rockets', 'Rockets'),

  /// Satellites
  satellites('satellites', 'Satellites'),

  /// Climate change
  climate('climate', 'Climate'),

  /// Weather
  weather('weather', 'Weather'),

  /// Hurricanes
  hurricanes('hurricanes', 'Hurricanes'),

  /// Earthquakes
  earthquakes('earthquakes', 'Earthquakes'),

  /// Energy
  energy('energy', 'Energy'),

  /// Solar
  solar('solar', 'Solar'),

  /// Nuclear
  nuclear('nuclear', 'Nuclear'),

  /// Electric vehicles
  ev('ev', 'Electric Vehicles'),

  /// Biotechnology
  biotech('biotech', 'Biotech'),

  /// Genetics
  genetics('genetics', 'Genetics'),

  /// Medicine
  medicine('medicine', 'Medicine'),

  /// Vaccines
  vaccines('vaccines', 'Vaccines'),

  /// COVID
  covid('covid', 'COVID'),

  /// Drug approvals
  drugApprovals('drug-approvals', 'Drug Approvals'),

  /// FDA
  fda('fda', 'FDA'),

  /// Quantum computing
  quantum('quantum', 'Quantum'),

  /// Physics
  physics('physics', 'Physics'),

  /// Astronomy
  astronomy('astronomy', 'Astronomy'),

  /// UFOs/UAPs
  ufo('ufo', 'UFOs/UAPs'),

  /// Other science
  other('other-science', 'Other Science');

  final String slug;
  final String label;

  const ScienceSubcategory(this.slug, this.label);

  String toJson() => slug;

  static ScienceSubcategory fromJson(String json) {
    return ScienceSubcategory.values.firstWhere(
      (e) => e.slug == json || e.name == json,
      orElse: () => ScienceSubcategory.other,
    );
  }

  static ScienceSubcategory? bySlug(String slug) {
    try {
      return ScienceSubcategory.values.firstWhere((e) => e.slug == slug);
    } catch (_) {
      return null;
    }
  }
}

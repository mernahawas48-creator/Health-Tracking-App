class NutritionApiConfig {
  const NutritionApiConfig._();

  // Demo key is only for development. Use your own key before release:
  // flutter run --dart-define=USDA_API_KEY=your_key_here
  static const usdaApiKey = String.fromEnvironment(
    'USDA_API_KEY',
    defaultValue: 'E6QpOahlXllQKiFnUmXYpVBkOBj1EcqIdFQ40QzE',
  );
}

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeLabel on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}

class NutritionFood {
  const NutritionFood({
    required this.fdcId,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.brandName,
    this.dataType,
    this.description,
  });

  final int fdcId;
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final String? brandName;
  final String? dataType;
  final String? description;

  bool get isBranded => dataType == 'Branded';

  String get sourceLabel {
    switch (dataType) {
      case 'Branded':
        return 'Branded product';
      case 'Foundation':
        return 'USDA Foundation Food';
      case 'SR Legacy':
        return 'USDA Reference Food';
      case 'Survey (FNDDS)':
        return 'USDA Survey Food';
      default:
        return 'USDA Food Database';
    }
  }

  String? get displayDescription {
    final details = description?.trim();
    if (details == null ||
        details.isEmpty ||
        details.toLowerCase() == name.toLowerCase()) {
      return null;
    }
    return details;
  }

  factory NutritionFood.fromUsdaJson(Map<String, dynamic> json) {
    final nutrients = (json['foodNutrients'] as List? ?? []);

    double nutrient(String nutrientName) {
      for (final rawNutrient in nutrients) {
        final nutrient = rawNutrient as Map<String, dynamic>;
        final name = nutrient['nutrientName'] ?? nutrient['nutrient']?['name'];
        if (name == nutrientName) {
          return ((nutrient['value'] ?? nutrient['amount'] ?? 0) as num)
              .toDouble();
        }
      }
      return 0;
    }

    final brand = (json['brandOwner'] ?? json['brandName']) as String?;
    final additionalDescription = json['additionalDescriptions'] as String?;

    return NutritionFood(
      fdcId: (json['fdcId'] as num).toInt(),
      name: (json['description'] as String? ?? 'Unknown food').trim(),
      caloriesPer100g: nutrient('Energy'),
      proteinPer100g: nutrient('Protein'),
      carbsPer100g: nutrient('Carbohydrate, by difference'),
      fatPer100g: nutrient('Total lipid (fat)'),
      brandName: brand?.trim(),
      dataType: json['dataType'] as String?,
      description: additionalDescription,
    );
  }
}

class FoodLog {
  const FoodLog({
    required this.id,
    required this.food,
    required this.amountGrams,
    required this.mealType,
    required this.loggedAt,
  });

  final String id;
  final NutritionFood food;
  final double amountGrams;
  final MealType mealType;
  final DateTime loggedAt;

  double get multiplier => amountGrams / 100;
  double get calories => food.caloriesPer100g * multiplier;
  double get protein => food.proteinPer100g * multiplier;
  double get carbs => food.carbsPer100g * multiplier;
  double get fat => food.fatPer100g * multiplier;
}

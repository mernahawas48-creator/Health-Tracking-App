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
  });
  final int fdcId;
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  factory NutritionFood.fromUsdaJson(Map<String, dynamic> json) {
    final nutrients = (json['foodNutrients'] as List? ?? []).cast<Map>();
    double nutrient(String name) {
      for (final item in nutrients) {
        if (item['nutrientName'] == name || item['nutrient']?['name'] == name)
          return ((item['value'] ?? item['amount'] ?? 0) as num).toDouble();
      }
      return 0;
    }

    return NutritionFood(
      fdcId: (json['fdcId'] as num).toInt(),
      name: json['description'] as String? ?? 'Unknown food',
      caloriesPer100g: nutrient('Energy'),
      proteinPer100g: nutrient('Protein'),
      carbsPer100g: nutrient('Carbohydrate, by difference'),
      fatPer100g: nutrient('Total lipid (fat)'),
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

import 'package:meditrack/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';

class MealIdeasPage extends StatelessWidget {
  const MealIdeasPage({super.key, required this.remainingCalories});

  final double remainingCalories;

  List<_MealIdea> get _ideas {
    final lightIdeas = [
      const _MealIdea('Greek yogurt & berries', 'Snack', 220, 18, 28, 5, [
        'Greek yogurt',
        'Fresh berries',
        'Chia seeds',
      ]),
      const _MealIdea('Apple & peanut butter', 'Snack', 240, 7, 31, 11, [
        'Apple',
        'Natural peanut butter',
      ]),
    ];
    final balancedIdeas = [
      const _MealIdea('Chicken rice bowl', 'Lunch', 480, 39, 52, 12, [
        'Grilled chicken',
        'Brown rice',
        'Mixed vegetables',
      ]),
      const _MealIdea('Tuna whole-grain sandwich', 'Lunch', 420, 31, 45, 10, [
        'Tuna',
        'Whole-grain bread',
        'Lettuce and tomato',
      ]),
    ];
    final dinnerIdeas = [
      const _MealIdea('Salmon & vegetables', 'Dinner', 560, 38, 42, 24, [
        'Baked salmon',
        'Sweet potato',
        'Steamed broccoli',
      ]),
      const _MealIdea('Lentil pasta bowl', 'Dinner', 530, 28, 68, 13, [
        'Lentil pasta',
        'Tomato sauce',
        'Side salad',
      ]),
    ];

    if (remainingCalories <= 250) return lightIdeas;
    if (remainingCalories <= 500) return [...balancedIdeas, ...lightIdeas];
    return [...dinnerIdeas, ...balancedIdeas, ...lightIdeas];
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final ideas = _ideas;
    return Scaffold(
      backgroundColor: context.appCanvas,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        foregroundColor: context.appText,
        elevation: 0,
        centerTitle: true,
        title: Text(
          strings.text('mealIdeas'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.appMutedSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: Appcolors.Primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${AppStrings.of(context).caloriesRemaining(remainingCalories.round())}. ${AppStrings.of(context).text('remainingIdeas')}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            strings.text('suggestedForYou'),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...ideas.map((idea) => _MealIdeaCard(idea: idea)),
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 24),
            child: Text(
              strings.text('suggestionsDisclaimer'),
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appSecondaryText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealIdeaCard extends StatelessWidget {
  const _MealIdeaCard({required this.idea});

  final _MealIdea idea;

  MealType get _mealType {
    switch (idea.meal) {
      case 'Snack':
        return MealType.snack;
      case 'Lunch':
        return MealType.lunch;
      default:
        return MealType.dinner;
    }
  }

  void _addToLog(BuildContext context) {
    Navigator.pop(
      context,
      FoodLog(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        food: NutritionFood(
          fdcId: -1,
          name: idea.name,
          caloriesPer100g: idea.calories.toDouble(),
          proteinPer100g: idea.protein.toDouble(),
          carbsPer100g: idea.carbs.toDouble(),
          fatPer100g: idea.fat.toDouble(),
        ),
        amountGrams: 100,
        mealType: _mealType,
        loggedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: context.appMutedSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.restaurant_rounded, color: Appcolors.Primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.of(context).mealIdea(idea.name),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppStrings.of(context).mealLabel(idea.meal.toLowerCase()),
                      style: TextStyle(color: context.appSecondaryText),
                    ),
                  ],
                ),
              ),
              Text(
                '${idea.calories} kcal',
                style: TextStyle(
                  color: Appcolors.Primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            idea.ingredients.map(AppStrings.of(context).ingredient).join(' • '),
            style: TextStyle(color: context.appSecondaryText),
          ),
          const SizedBox(height: 12),
          Text(
            '${AppStrings.of(context).text('protein')} ${idea.protein}g   ${AppStrings.of(context).text('carbs')} ${idea.carbs}g   ${AppStrings.of(context).text('fat')} ${idea.fat}g',
            style: TextStyle(fontSize: 12, color: context.appSecondaryText),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _addToLog(context),
              icon: Icon(Icons.add),
              label: Text(AppStrings.of(context).text('addToMeals')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Appcolors.Primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealIdea {
  const _MealIdea(
    this.name,
    this.meal,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.ingredients,
  );
  final String name;
  final String meal;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> ingredients;
}

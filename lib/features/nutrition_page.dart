import 'package:flutter/material.dart';
import 'package:meditrack/features/food_search_page.dart';
import 'package:meditrack/features/meal_ideas_page.dart';
import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/themes/appcolors.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({
    super.key,
    required this.foodLogs,
    this.calorieGoal = 1800,
  });
  final List<FoodLog> foodLogs;
  final int calorieGoal;
  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  Future<void> _searchFood() async {
    final log = await Navigator.push<FoodLog>(
      context,
      MaterialPageRoute(builder: (_) => const FoodSearchPage()),
    );
    if (log != null) setState(() => widget.foodLogs.add(log));
  }

  Future<void> _openMealIdeas() async {
    final log = await Navigator.push<FoodLog>(
      context,
      MaterialPageRoute(
        builder: (_) => MealIdeasPage(remainingCalories: _remaining),
      ),
    );
    if (log != null) setState(() => widget.foodLogs.add(log));
  }

  double get _consumed =>
      widget.foodLogs.fold(0, (total, item) => total + item.calories);
  double get _remaining =>
      (widget.calorieGoal - _consumed).clamp(0, widget.calorieGoal.toDouble());
  double get _progress => (_consumed / widget.calorieGoal).clamp(0, 1);

  String get _suggestion {
    if (_remaining == 0)
      return 'You reached today\'s calorie goal. Choose water or a light snack if needed.';
    if (_remaining <= 250)
      return 'Light option: Greek yogurt with fruit, or an apple with a few nuts.';
    if (_remaining <= 500)
      return 'Balanced option: grilled chicken, vegetables, and a small serving of rice.';
    return 'You have room for a balanced meal: protein, vegetables, and a whole-grain carbohydrate.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      appBar: AppBar(
        backgroundColor: Appcolors.White,
        foregroundColor: Appcolors.Black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Nutrition',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _searchFood,
        backgroundColor: Appcolors.Primary,
        foregroundColor: Appcolors.White,
        icon: const Icon(Icons.search),
        label: const Text('Search food'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Appcolors.White,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Appcolors.Grey3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s calories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_consumed.round()} / ${widget.calorieGoal} kcal',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Appcolors.Primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 10,
                    color: Appcolors.Primary,
                    backgroundColor: const Color(0xffDDF4F5),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_remaining.round()} kcal remaining',
                  style: const TextStyle(color: Appcolors.Grey1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xffEEF8F8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Appcolors.Primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Healthy suggestion',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_suggestion),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _openMealIdeas,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Browse healthy meal ideas'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Today\'s meals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (widget.foodLogs.isEmpty)
            const _EmptyMeals()
          else
            ...MealType.values.map(
              (meal) => _MealSection(
                meal: meal,
                logs: widget.foodLogs
                    .where((log) => log.mealType == meal)
                    .toList(),
              ),
            ),
          const SizedBox(height: 88),
        ],
      ),
    );
  }
}

class _EmptyMeals extends StatelessWidget {
  const _EmptyMeals();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 24),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.restaurant_menu_rounded, size: 48, color: Appcolors.Grey2),
          SizedBox(height: 8),
          Text(
            'No meals logged today',
            style: TextStyle(color: Appcolors.Grey2),
          ),
        ],
      ),
    ),
  );
}

class _MealSection extends StatelessWidget {
  const _MealSection({required this.meal, required this.logs});
  final MealType meal;
  final List<FoodLog> logs;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Appcolors.White,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Appcolors.Grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meal.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...logs.map(
            (log) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant_rounded,
                    color: Appcolors.Primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${log.food.name} (${log.amountGrams.round()}g)',
                    ),
                  ),
                  Text(
                    '${log.calories.round()} kcal',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

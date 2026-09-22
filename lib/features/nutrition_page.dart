import 'package:meditrack/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/features/nutrition/nutrition_cubit.dart';
import 'package:meditrack/features/food_search_page.dart';
import 'package:meditrack/features/meal_ideas_page.dart';
import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key, required this.calorieGoal});
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
    if (log == null) return;
    if (mounted) await context.read<NutritionCubit>().add(log);
  }

  Future<void> _openMealIdeas() async {
    final log = await Navigator.push<FoodLog>(
      context,
      MaterialPageRoute(
        builder: (_) => MealIdeasPage(remainingCalories: _remaining),
      ),
    );
    if (log == null) return;
    if (mounted) await context.read<NutritionCubit>().add(log);
  }

  double get _consumed => context.read<NutritionCubit>().state.calories;
  double get _remaining =>
      (widget.calorieGoal - _consumed).clamp(0, widget.calorieGoal.toDouble());
  double get _progress => (_consumed / widget.calorieGoal).clamp(0, 1);

  String _suggestion(AppStrings strings) {
    if (_remaining == 0) return strings.text('nutritionGoalReached');
    if (_remaining <= 250) return strings.text('nutritionLightSuggestion');
    if (_remaining <= 500) return strings.text('nutritionBalancedSuggestion');
    return strings.text('nutritionRoomSuggestion');
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return BlocListener<NutritionCubit, NutritionState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.isArabic
                ? 'تعذر حفظ التغذية. حاول مرة أخرى.'
                : 'Could not save nutrition. Try again.',
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: context.appCanvas,
        appBar: AppBar(
          backgroundColor: context.appSurface,
          foregroundColor: context.appText,
          elevation: 0,
          centerTitle: true,
          title: Text(
            strings.text('nutrition'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _searchFood,
          backgroundColor: Appcolors.Primary,
          foregroundColor: context.appOnPrimary,
          icon: Icon(Icons.search),
          label: Text(strings.text('searchFood')),
        ),
        body: BlocBuilder<NutritionCubit, NutritionState>(
          builder: (context, state) => state.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.appSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.appOutline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.text('todayCalories'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${_consumed.round()} / ${widget.calorieGoal} kcal',
                            style: TextStyle(
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
                              backgroundColor: context.appMutedSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            strings.caloriesRemaining(_remaining.round()),
                            style: TextStyle(color: context.appSecondaryText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: context.appMutedSurface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: Appcolors.Primary,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  strings.text('healthySuggestion'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(_suggestion(strings)),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: _openMealIdeas,
                            icon: Icon(Icons.auto_awesome_rounded),
                            label: Text(strings.text('mealIdeas')),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      strings.text('todayMeals'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.logs.isEmpty)
                      _EmptyMeals()
                    else
                      ...MealType.values.map(
                        (meal) => _MealSection(
                          meal: meal,
                          logs: state.logs
                              .where((log) => log.mealType == meal)
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 88),
                  ],
                ),
        ),
      ),
    );
  }
}

class _EmptyMeals extends StatelessWidget {
  const _EmptyMeals();
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 24),
    child: Center(
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            size: 48,
            color: context.appSecondaryText,
          ),
          SizedBox(height: 8),
          Text(
            AppStrings.of(context).text('noMealsLogged'),
            style: TextStyle(color: context.appSecondaryText),
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
        color: context.appSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(context).mealLabel(meal.name),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...logs.map(
            (log) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.restaurant_rounded, color: Appcolors.Primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${log.food.name} (${log.amountGrams.round()}g)',
                    ),
                  ),
                  Text(
                    '${log.calories.round()} kcal',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

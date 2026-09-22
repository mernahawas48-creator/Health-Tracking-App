import 'package:meditrack/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/features/nutrition/nutrition_cubit.dart';
import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';

enum _FoodFilter { all, generic, branded }

class FoodSearchPage extends StatefulWidget {
  const FoodSearchPage({super.key});

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final _controller = TextEditingController();
  List<NutritionFood> get _foods => context.read<NutritionCubit>().state.foods;
  bool get _loading => context.read<NutritionCubit>().state.searching;
  String? get _error => context.read<NutritionCubit>().state.searchError;
  _FoodFilter _filter = _FoodFilter.all;

  List<NutritionFood> get _filteredFoods {
    switch (_filter) {
      case _FoodFilter.all:
        return _foods;
      case _FoodFilter.generic:
        return _foods.where((food) => !food.isBranded).toList();
      case _FoodFilter.branded:
        return _foods.where((food) => food.isBranded).toList();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    await context.read<NutritionCubit>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      backgroundColor: context.appCanvas,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        foregroundColor: context.appText,
        elevation: 0,
        title: Text(strings.text('searchFood')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: strings.text('searchFoodHint'),
                prefixIcon: Icon(Icons.search, color: Appcolors.Primary),
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _search,
                ),
                filled: true,
                fillColor: context.appSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.appOutline),
                ),
              ),
            ),
          ),
          BlocBuilder<NutritionCubit, NutritionState>(
            builder: (context, state) => state.foods.isNotEmpty
                ? _buildFilters()
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: BlocBuilder<NutritionCubit, NutritionState>(
              builder: (context, state) => _buildResults(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterChip(AppStrings.of(context).text('all'), _FoodFilter.all),
          const SizedBox(width: 8),
          _filterChip(
            AppStrings.of(context).text('generic'),
            _FoodFilter.generic,
          ),
          const SizedBox(width: 8),
          _filterChip(
            AppStrings.of(context).text('branded'),
            _FoodFilter.branded,
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, _FoodFilter filter) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == filter,
      selectedColor: Appcolors.Primary,
      labelStyle: TextStyle(
        color: _filter == filter ? context.appOnPrimary : context.appText,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) => setState(() => _filter = filter),
    );
  }

  Widget _buildResults() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null)
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppStrings.of(context).text(_error!),
            textAlign: TextAlign.center,
          ),
        ),
      );
    if (_foods.isEmpty)
      return Center(
        child: Text(
          AppStrings.of(context).text('searchFoodEmpty'),
          style: TextStyle(color: context.appSecondaryText),
        ),
      );
    if (_filteredFoods.isEmpty)
      return Center(
        child: Text(
          AppStrings.of(context).text('noFilteredFoods'),
          style: TextStyle(color: context.appSecondaryText),
        ),
      );

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _filteredFoods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _FoodResult(food: _filteredFoods[index]),
    );
  }
}

class _FoodResult extends StatelessWidget {
  const _FoodResult({required this.food});

  final NutritionFood food;

  Future<void> _openAddFoodPage(BuildContext context) async {
    final log = await Navigator.push<FoodLog>(
      context,
      MaterialPageRoute(builder: (_) => _AddFoodPage(food: food)),
    );
    if (log != null && context.mounted) Navigator.pop(context, log);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openAddFoodPage(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appOutline),
        ),
        child: Row(
          children: [
            Icon(Icons.restaurant_rounded, color: Appcolors.Primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (food.brandName != null && food.brandName!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      food.brandName!,
                      style: TextStyle(
                        color: context.appText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (food.displayDescription != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      food.displayDescription!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.appSecondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _InfoLabel(text: food.sourceLabel),
                      _InfoLabel(
                        text: '${food.caloriesPer100g.round()} kcal / 100g',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.appSecondaryText),
          ],
        ),
      ),
    );
  }
}

class _InfoLabel extends StatelessWidget {
  const _InfoLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: context.appMutedSurface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: Appcolors.Primary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _AddFoodPage extends StatefulWidget {
  const _AddFoodPage({required this.food});
  final NutritionFood food;
  @override
  State<_AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<_AddFoodPage> {
  double _grams = 100;
  MealType _meal = MealType.breakfast;

  @override
  Widget build(BuildContext context) {
    final multiplier = _grams / 100;
    final calories = widget.food.caloriesPer100g * multiplier;
    return Scaffold(
      backgroundColor: context.appCanvas,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        foregroundColor: context.appText,
        elevation: 0,
        title: Text(AppStrings.of(context).text('addFood')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.food.name,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            if (widget.food.brandName != null)
              Text(
                widget.food.brandName!,
                style: TextStyle(color: context.appSecondaryText),
              ),
            const SizedBox(height: 8),
            Text(
              AppStrings.of(context).nutritionSummary(
                calories: calories.round(),
                protein: (widget.food.proteinPer100g * multiplier).round(),
              ),
              style: TextStyle(color: context.appSecondaryText),
            ),
            const SizedBox(height: 28),
            Text(
              AppStrings.of(context).text('servingAmount'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _grams,
              min: 25,
              max: 500,
              divisions: 19,
              label: '${_grams.round()}g',
              activeColor: Appcolors.Primary,
              onChanged: (value) => setState(() => _grams = value),
            ),
            Center(
              child: Text(
                '${_grams.round()} ${AppStrings.of(context).text('grams')}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.of(context).text('meal'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values
                  .map(
                    (meal) => ChoiceChip(
                      label: Text(AppStrings.of(context).mealLabel(meal.name)),
                      selected: _meal == meal,
                      selectedColor: Appcolors.Primary,
                      labelStyle: TextStyle(
                        color: _meal == meal
                            ? context.appOnPrimary
                            : context.appText,
                      ),
                      onSelected: (_) => setState(() => _meal = meal),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                  context,
                  FoodLog(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    food: widget.food,
                    amountGrams: _grams,
                    mealType: _meal,
                    loggedAt: DateTime.now(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Appcolors.Primary,
                  foregroundColor: context.appOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(AppStrings.of(context).text('addToMeals')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

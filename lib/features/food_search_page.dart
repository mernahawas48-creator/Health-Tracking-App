import 'package:flutter/material.dart';
import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/services/usda_food_service.dart';
import 'package:meditrack/themes/appcolors.dart';

class FoodSearchPage extends StatefulWidget {
  const FoodSearchPage({super.key});
  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final _controller = TextEditingController();
  final _service = UsdaFoodService();
  List<NutritionFood> _foods = [];
  bool _loading = false;
  String? _error;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final foods = await _service.search(query);
      if (mounted) setState(() => _foods = foods);
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'Could not load food data. Check your internet and API key.',
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xffF9F7FB),
    appBar: AppBar(
      backgroundColor: Appcolors.White,
      foregroundColor: Appcolors.Black,
      elevation: 0,
      title: const Text('Search food'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Search banana, chicken, rice...',
              prefixIcon: const Icon(Icons.search, color: Appcolors.Primary),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _search,
              ),
              filled: true,
              fillColor: Appcolors.White,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Appcolors.Grey3),
              ),
            ),
          ),
        ),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          Expanded(
            child: Center(child: Text(_error!, textAlign: TextAlign.center)),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _foods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _FoodResult(food: _foods[index]),
            ),
          ),
      ],
    ),
  );
}

class _FoodResult extends StatelessWidget {
  const _FoodResult({required this.food});
  final NutritionFood food;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final log = await Navigator.push<FoodLog>(
        context,
        MaterialPageRoute(builder: (_) => _AddFoodPage(food: food)),
      );
      if (log != null && context.mounted) Navigator.pop(context, log);
    },
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Appcolors.White,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Appcolors.Grey3),
      ),
      child: Row(
        children: [
          const Icon(Icons.restaurant_rounded, color: Appcolors.Primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${food.caloriesPer100g.round()} kcal per 100g',
                  style: const TextStyle(color: Appcolors.Grey2),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Appcolors.Grey2),
        ],
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
    final calories = widget.food.caloriesPer100g * _grams / 100;
    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      appBar: AppBar(
        backgroundColor: Appcolors.White,
        foregroundColor: Appcolors.Black,
        elevation: 0,
        title: const Text('Add food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.food.name,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${calories.round()} kcal • Protein ${(widget.food.proteinPer100g * _grams / 100).round()}g',
              style: const TextStyle(color: Appcolors.Grey1),
            ),
            const SizedBox(height: 28),
            const Text(
              'Serving amount',
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
                '${_grams.round()} grams',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Meal', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values
                  .map(
                    (meal) => ChoiceChip(
                      label: Text(meal.label),
                      selected: _meal == meal,
                      selectedColor: Appcolors.Primary,
                      labelStyle: TextStyle(
                        color: _meal == meal
                            ? Appcolors.White
                            : Appcolors.Black,
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
                  foregroundColor: Appcolors.White,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Add to today\'s meals'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

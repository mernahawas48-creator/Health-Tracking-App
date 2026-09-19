import 'package:flutter/material.dart';
import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/services/usda_food_service.dart';
import 'package:meditrack/themes/appcolors.dart';

enum _FoodFilter { all, generic, branded }

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

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final foods = await _service.search(query);
      if (mounted) setState(() => _foods = foods);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not load food data. Check your internet and API key.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          if (_foods.isNotEmpty) _buildFilters(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterChip('All', _FoodFilter.all),
          const SizedBox(width: 8),
          _filterChip('Generic', _FoodFilter.generic),
          const SizedBox(width: 8),
          _filterChip('Branded', _FoodFilter.branded),
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
        color: _filter == filter ? Appcolors.White : Appcolors.Black2,
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
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    if (_foods.isEmpty)
      return const Center(
        child: Text(
          'Search for a food to see nutrition data.',
          style: TextStyle(color: Appcolors.Grey2),
        ),
      );
    if (_filteredFoods.isEmpty)
      return const Center(
        child: Text(
          'No foods match this filter.',
          style: TextStyle(color: Appcolors.Grey2),
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
                  if (food.brandName != null && food.brandName!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      food.brandName!,
                      style: const TextStyle(
                        color: Appcolors.Black2,
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
                      style: const TextStyle(
                        color: Appcolors.Grey2,
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
            const Icon(Icons.chevron_right_rounded, color: Appcolors.Grey2),
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
      color: const Color(0xffE3F7F8),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
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
            if (widget.food.brandName != null)
              Text(
                widget.food.brandName!,
                style: const TextStyle(color: Appcolors.Grey1),
              ),
            const SizedBox(height: 8),
            Text(
              '${calories.round()} kcal • Protein ${(widget.food.proteinPer100g * multiplier).round()}g',
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

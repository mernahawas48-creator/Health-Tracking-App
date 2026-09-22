import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/services/nutrition_repository.dart';
import 'package:meditrack/services/usda_food_service.dart';

class NutritionState {
  const NutritionState({
    this.logs = const [],
    this.foods = const [],
    this.loading = false,
    this.searching = false,
    this.error,
    this.searchError,
  });
  final List<FoodLog> logs;
  final List<NutritionFood> foods;
  final bool loading;
  final bool searching;
  final String? error;
  final String? searchError;
  double get calories => logs.fold(0, (total, log) => total + log.calories);
  double get protein => logs.fold(0, (total, log) => total + log.protein);
  double get carbs => logs.fold(0, (total, log) => total + log.carbs);
  double get fat => logs.fold(0, (total, log) => total + log.fat);
}

class NutritionCubit extends Cubit<NutritionState> {
  NutritionCubit(this._repository, this._foodService)
    : super(const NutritionState());
  final NutritionRepository _repository;
  final UsdaFoodService _foodService;

  Future<void> load() async {
    emit(NutritionState(logs: state.logs, foods: state.foods, loading: true));
    try {
      emit(
        NutritionState(logs: await _repository.loadToday(), foods: state.foods),
      );
    } catch (_) {
      emit(
        NutritionState(
          logs: state.logs,
          foods: state.foods,
          error: 'nutrition',
        ),
      );
    }
  }

  Future<void> add(FoodLog log) => _save([...state.logs, log]);
  Future<void> remove(FoodLog log) =>
      _save(state.logs.where((item) => item.id != log.id).toList());
  Future<void> update(FoodLog log) => _save([
    for (final item in state.logs)
      if (item.id == log.id) log else item,
  ]);

  Future<void> _save(List<FoodLog> logs) async {
    try {
      await _repository.saveToday(logs);
      emit(NutritionState(logs: List.unmodifiable(logs), foods: state.foods));
    } catch (_) {
      emit(
        NutritionState(
          logs: state.logs,
          foods: state.foods,
          error: 'nutrition',
        ),
      );
    }
  }

  Future<void> search(String query) async {
    emit(NutritionState(logs: state.logs, foods: state.foods, searching: true));
    try {
      final foods = await _foodService.search(query);
      emit(NutritionState(logs: state.logs, foods: foods));
    } catch (_) {
      emit(
        NutritionState(
          logs: state.logs,
          foods: state.foods,
          searchError: 'foodLoadError',
        ),
      );
    }
  }
}

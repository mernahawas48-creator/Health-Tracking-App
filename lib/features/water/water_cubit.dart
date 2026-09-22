import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/services/habit_streak_service.dart';
import 'package:meditrack/services/water_repository.dart';

class WaterState {
  const WaterState({
    this.intakeMl = 0,
    this.draftMl,
    this.streak = 0,
    this.loading = false,
    this.error,
  });
  final int intakeMl;
  final int? draftMl;
  final int streak;
  final bool loading;
  final String? error;
  int get displayedMl => draftMl ?? intakeMl;
  double progress(int goalMl) =>
      goalMl <= 0 ? 0 : (displayedMl / goalMl).clamp(0.0, 1.0);
  int remaining(int goalMl) => (goalMl - displayedMl).clamp(0, goalMl);
}

class WaterCubit extends Cubit<WaterState> {
  WaterCubit(this._repository) : super(const WaterState());
  final WaterRepository _repository;
  bool _editRequested = false;

  Future<void> load() async {
    emit(
      WaterState(intakeMl: state.intakeMl, streak: state.streak, loading: true),
    );
    try {
      final intake = await _repository.loadToday();
      final streak = await HabitStreakService.currentStreak(HabitType.water);
      emit(
        WaterState(
          intakeMl: intake,
          draftMl: _editRequested ? intake : null,
          streak: streak,
        ),
      );
    } catch (_) {
      emit(
        WaterState(
          intakeMl: state.intakeMl,
          streak: state.streak,
          error: 'water',
        ),
      );
    }
  }

  void beginEdit() {
    _editRequested = true;
    if (!state.loading) {
      emit(
        WaterState(
          intakeMl: state.intakeMl,
          draftMl: state.intakeMl,
          streak: state.streak,
        ),
      );
    }
  }

  void add(int amount) => emit(
    WaterState(
      intakeMl: state.intakeMl,
      draftMl: state.displayedMl + amount,
      streak: state.streak,
    ),
  );

  void reset() => emit(
    WaterState(intakeMl: state.intakeMl, draftMl: 0, streak: state.streak),
  );

  void discard() {
    _editRequested = false;
    emit(WaterState(intakeMl: state.intakeMl, streak: state.streak));
  }

  Future<bool> save(int goalMl) async {
    final intake = state.displayedMl;
    try {
      await _repository.saveToday(intake);
      await HabitStreakService.updateToday(
        habit: HabitType.water,
        isCompleted: intake >= goalMl,
      );
      final streak = await HabitStreakService.currentStreak(HabitType.water);
      emit(WaterState(intakeMl: intake, streak: streak));
      _editRequested = false;
      return true;
    } catch (_) {
      emit(
        WaterState(
          intakeMl: state.intakeMl,
          draftMl: intake,
          streak: state.streak,
          error: 'water',
        ),
      );
      return false;
    }
  }
}

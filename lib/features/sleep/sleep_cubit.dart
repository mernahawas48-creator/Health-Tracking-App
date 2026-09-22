import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/services/habit_streak_service.dart';
import 'package:meditrack/services/sleep_repository.dart';

class SleepState {
  const SleepState({
    this.minutes = 0,
    this.streak = 0,
    this.bedtimeMinutes,
    this.wakeUpMinutes,
    this.loading = false,
    this.error,
  });
  final int minutes;
  final int streak;
  final int? bedtimeMinutes;
  final int? wakeUpMinutes;
  final bool loading;
  final String? error;
  double progress(int goalMinutes) =>
      goalMinutes <= 0 ? 0 : (minutes / goalMinutes).clamp(0.0, 1.0);
}

class SleepCubit extends Cubit<SleepState> {
  SleepCubit(this._repository) : super(const SleepState());
  final SleepRepository _repository;

  Future<void> load() async {
    emit(
      SleepState(minutes: state.minutes, streak: state.streak, loading: true),
    );
    try {
      final record = await _repository.loadRecordToday();
      final streak = await HabitStreakService.currentStreak(HabitType.sleep);
      emit(
        SleepState(
          minutes: record.durationMinutes,
          bedtimeMinutes: record.bedtimeMinutes,
          wakeUpMinutes: record.wakeUpMinutes,
          streak: streak,
        ),
      );
    } catch (_) {
      emit(
        SleepState(
          minutes: state.minutes,
          streak: state.streak,
          error: 'sleep',
        ),
      );
    }
  }

  Future<bool> save(
    int minutes, {
    int? bedtimeMinutes,
    int? wakeUpMinutes,
  }) async {
    try {
      await _repository.saveRecordToday(
        SleepRecord(
          durationMinutes: minutes,
          bedtimeMinutes: bedtimeMinutes,
          wakeUpMinutes: wakeUpMinutes,
        ),
      );
      await HabitStreakService.updateToday(
        habit: HabitType.sleep,
        isCompleted: minutes >= 7 * 60 && minutes <= 9 * 60,
      );
      final streak = await HabitStreakService.currentStreak(HabitType.sleep);
      emit(
        SleepState(
          minutes: minutes,
          bedtimeMinutes: bedtimeMinutes,
          wakeUpMinutes: wakeUpMinutes,
          streak: streak,
        ),
      );
      return true;
    } catch (_) {
      emit(
        SleepState(
          minutes: state.minutes,
          streak: state.streak,
          error: 'sleep',
        ),
      );
      return false;
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';

enum HabitType { water, sleep }

class HabitStreakService {
  static String _key(HabitType habit) => '${habit.name}_completed_dates';

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static Future<void> updateToday({
    required HabitType habit,
    required bool isCompleted,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final dates = preferences.getStringList(_key(habit)) ?? [];
    final today = _dateKey(DateTime.now());

    if (isCompleted && !dates.contains(today)) {
      dates.add(today);
    } else if (!isCompleted) {
      dates.remove(today);
    }

    await preferences.setStringList(_key(habit), dates);
  }

  static Future<int> currentStreak(HabitType habit) async {
    final preferences = await SharedPreferences.getInstance();
    final dates = preferences.getStringList(_key(habit)) ?? [];
    return _count(dates.toSet());
  }

  static int _count(Set<String> completedDates) {
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    if (!completedDates.contains(_dateKey(day))) {
      day = DateTime(day.year, day.month, day.day - 1);
    }

    var streak = 0;
    while (completedDates.contains(_dateKey(day))) {
      streak++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return streak;
  }
}

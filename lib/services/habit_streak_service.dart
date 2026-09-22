import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditrack/services/account_firestore.dart';

enum HabitType { water, sleep }

class HabitStreakService {
  static AccountFirestore? account;

  static String _key(HabitType habit) => '${habit.name}_completed_dates';
  static String _collection(HabitType habit) =>
      habit == HabitType.water ? 'waterLogs' : 'sleepLogs';

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static Future<void> updateToday({
    required HabitType habit,
    required bool isCompleted,
  }) async {
    final cloud = account;
    if (cloud != null) {
      final uid = cloud.uid;
      await cloud
          .user(uid)
          .collection(_collection(habit))
          .doc(_dateKey(DateTime.now()))
          .set({'completed': isCompleted}, SetOptions(merge: true));
      return;
    }
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
    final cloud = account;
    if (cloud != null) {
      final uid = cloud.uid;
      final snapshot = await cloud
          .user(uid)
          .collection(_collection(habit))
          .where('completed', isEqualTo: true)
          .get();
      await cloud.assertOwner(uid);
      return _count(snapshot.docs.map((doc) => doc.id).toSet());
    }
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

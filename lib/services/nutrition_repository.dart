import 'dart:convert';

import 'package:meditrack/models/nutrition_food.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NutritionRepository {
  static const _storageKey = 'nutrition_logs_v1';

  Future<List<FoodLog>> loadToday() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_storageKey) ?? [];
    final today = DateTime.now();
    final logs = <FoodLog>[];

    for (final value in values) {
      try {
        final log = FoodLog.fromJson(jsonDecode(value) as Map<String, dynamic>);
        if (_isSameDay(log.loggedAt, today)) logs.add(log);
      } on FormatException {
        // Ignore a malformed local record instead of blocking Nutrition.
      }
    }
    return logs;
  }

  Future<void> saveToday(List<FoodLog> logs) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      logs.map((log) => jsonEncode(log.toJson())).toList(),
    );
  }

  bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

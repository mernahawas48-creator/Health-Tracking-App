import 'dart:convert';

import 'package:meditrack/models/nutrition_food.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NutritionRepository {
  static const _storageKey = 'nutrition_logs_v1';

  Future<List<FoodLog>> loadToday() async {
    return loadForDate(DateTime.now());
  }

  /// Keeps the complete on-device history; screens can later request any day.
  Future<List<FoodLog>> loadForDate(DateTime date) async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_storageKey) ?? [];
    final logs = <FoodLog>[];

    for (final value in values) {
      try {
        final log = FoodLog.fromJson(jsonDecode(value) as Map<String, dynamic>);
        if (_isSameDay(log.loggedAt, date)) logs.add(log);
      } on FormatException {
        // Ignore a malformed local record instead of blocking Nutrition.
      }
    }
    return logs;
  }

  Future<void> saveToday(List<FoodLog> logs) async {
    final preferences = await SharedPreferences.getInstance();
    final current = preferences.getStringList(_storageKey) ?? [];
    final otherDays = <String>[];
    for (final value in current) {
      try {
        final log = FoodLog.fromJson(jsonDecode(value) as Map<String, dynamic>);
        if (!_isSameDay(log.loggedAt, DateTime.now())) otherDays.add(value);
      } on FormatException {
        // Drop malformed records while preserving valid history.
      }
    }
    await preferences.setStringList(_storageKey, [
      ...otherDays,
      ...logs.map((log) => jsonEncode(log.toJson())),
    ]);
  }

  bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

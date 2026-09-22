import 'dart:convert';

import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/services/account_firestore.dart';
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

class FirestoreNutritionRepository extends NutritionRepository {
  FirestoreNutritionRepository(this._account);
  final AccountFirestore _account;

  @override
  Future<List<FoodLog>> loadForDate(DateTime date) async {
    final uid = _account.uid;
    final snapshot = await _account
        .user(uid)
        .collection('nutritionLogs')
        .where('date', isEqualTo: _dateKey(date))
        .get();
    await _account.assertOwner(uid);
    return snapshot.docs.map((doc) => FoodLog.fromJson(doc.data())).toList();
  }

  @override
  Future<List<FoodLog>> loadToday() => loadForDate(DateTime.now());

  @override
  Future<void> saveToday(List<FoodLog> logs) async {
    final uid = _account.uid;
    final collection = _account.user(uid).collection('nutritionLogs');
    final today = _dateKey(DateTime.now());
    final previous = await collection.where('date', isEqualTo: today).get();
    await _account.assertOwner(uid);
    final batch = collection.firestore.batch();
    final ids = logs.map((item) => item.id).toSet();
    for (final doc in previous.docs) {
      if (!ids.contains(doc.id)) batch.delete(doc.reference);
    }
    for (final log in logs) {
      batch.set(collection.doc(log.id), {
        ...log.toJson(),
        'date': _dateKey(log.loggedAt),
      });
    }
    await _account.assertOwner(uid);
    await batch.commit();
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

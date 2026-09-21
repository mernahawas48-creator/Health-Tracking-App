import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SleepRepository {
  static const _storageKey = 'sleep_today_v1';

  Future<int> loadToday() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_storageKey);
    if (value == null) return 0;

    try {
      final record = jsonDecode(value) as Map<String, dynamic>;
      if (record['date'] != _todayKey()) return 0;
      return (record['sleepMinutes'] as num?)?.toInt() ?? 0;
    } on FormatException {
      return 0;
    }
  }

  Future<void> saveToday(int sleepMinutes) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode({'date': _todayKey(), 'sleepMinutes': sleepMinutes}),
    );
  }

  String _todayKey() {
    final today = DateTime.now();
    return '${today.year}-${today.month}-${today.day}';
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditrack/services/account_firestore.dart';

class SleepRepository {
  static const _storageKey = 'sleep_records_v2';
  static const _legacyKey = 'sleep_today_v1';

  Future<int> loadToday() => loadForDate(DateTime.now());

  Future<int> loadForDate(DateTime date) async {
    final preferences = await SharedPreferences.getInstance();
    final records = _records(preferences);
    return (records[_dateKey(date)] as num?)?.toInt() ?? 0;
  }

  Future<void> saveToday(int sleepMinutes) =>
      saveForDate(DateTime.now(), sleepMinutes);

  Future<void> saveForDate(DateTime date, int sleepMinutes) async {
    final preferences = await SharedPreferences.getInstance();
    final records = _records(preferences)..[_dateKey(date)] = sleepMinutes;
    await preferences.setString(_storageKey, jsonEncode(records));
  }

  Map<String, dynamic> _records(SharedPreferences preferences) {
    Map<String, dynamic> records;
    try {
      records = Map<String, dynamic>.from(
        jsonDecode(preferences.getString(_storageKey) ?? '{}') as Map,
      );
    } catch (_) {
      records = {};
    }
    try {
      final legacy =
          jsonDecode(preferences.getString(_legacyKey) ?? '{}') as Map;
      final date = legacy['date'];
      if (date is String && legacy['sleepMinutes'] is num) {
        records.putIfAbsent(date, () => legacy['sleepMinutes']);
      }
    } catch (_) {
      // A malformed legacy value does not block current-day tracking.
    }
    return records;
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';
}

class FirestoreSleepRepository extends SleepRepository {
  FirestoreSleepRepository(this._account);
  final AccountFirestore _account;

  @override
  Future<int> loadToday() => loadForDate(DateTime.now());

  @override
  Future<int> loadForDate(DateTime date) async {
    final uid = _account.uid;
    final doc = await _account
        .user(uid)
        .collection('sleepLogs')
        .doc(_key(date))
        .get();
    await _account.assertOwner(uid);
    return (doc.data()?['sleepMinutes'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> saveToday(int sleepMinutes) =>
      saveForDate(DateTime.now(), sleepMinutes);

  @override
  Future<void> saveForDate(DateTime date, int sleepMinutes) async {
    final uid = _account.uid;
    await _account.user(uid).collection('sleepLogs').doc(_key(date)).set({
      'sleepMinutes': sleepMinutes,
    });
  }

  String _key(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

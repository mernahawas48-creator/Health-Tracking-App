import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditrack/services/account_firestore.dart';

class WaterRepository {
  static const _storageKey = 'water_records_v2';
  static const _legacyKey = 'water_today_v1';

  Future<int> loadToday() => loadForDate(DateTime.now());

  Future<int> loadForDate(DateTime date) async {
    final preferences = await SharedPreferences.getInstance();
    final records = _records(preferences);
    return (records[_dateKey(date)] as num?)?.toInt() ?? 0;
  }

  Future<void> saveToday(int waterMl) => saveForDate(DateTime.now(), waterMl);

  Future<void> saveForDate(DateTime date, int waterMl) async {
    final preferences = await SharedPreferences.getInstance();
    final records = _records(preferences)..[_dateKey(date)] = waterMl;
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
      if (date is String && legacy['waterMl'] is num) {
        records.putIfAbsent(date, () => legacy['waterMl']);
      }
    } catch (_) {
      // A malformed legacy value does not block current-day tracking.
    }
    return records;
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';
}

class FirestoreWaterRepository extends WaterRepository {
  FirestoreWaterRepository(this._account);
  final AccountFirestore _account;

  @override
  Future<int> loadToday() => loadForDate(DateTime.now());

  @override
  Future<int> loadForDate(DateTime date) async {
    final uid = _account.uid;
    final doc = await _account
        .user(uid)
        .collection('waterLogs')
        .doc(_key(date))
        .get();
    await _account.assertOwner(uid);
    return (doc.data()?['waterMl'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> saveToday(int waterMl) => saveForDate(DateTime.now(), waterMl);

  @override
  Future<void> saveForDate(DateTime date, int waterMl) async {
    final uid = _account.uid;
    await _account.user(uid).collection('waterLogs').doc(_key(date)).set({
      'waterMl': waterMl,
    });
  }

  String _key(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

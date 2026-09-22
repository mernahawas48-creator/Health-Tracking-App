import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SleepRecord {
  const SleepRecord({
    required this.durationMinutes,
    this.bedtimeMinutes,
    this.wakeUpMinutes,
  });

  final int durationMinutes;
  final int? bedtimeMinutes;
  final int? wakeUpMinutes;

  Map<String, dynamic> toJson() => {
    'durationMinutes': durationMinutes,
    'bedtimeMinutes': bedtimeMinutes,
    'wakeUpMinutes': wakeUpMinutes,
  };

  factory SleepRecord.fromJson(Object? value) {
    if (value is num) return SleepRecord(durationMinutes: value.toInt());
    final json = value is Map ? Map<String, dynamic>.from(value) : const {};
    return SleepRecord(
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      bedtimeMinutes: (json['bedtimeMinutes'] as num?)?.toInt(),
      wakeUpMinutes: (json['wakeUpMinutes'] as num?)?.toInt(),
    );
  }
}

class SleepRepository {
  static const _storageKey = 'sleep_records_v2';
  static const _legacyKey = 'sleep_today_v1';

  Future<int> loadToday() => loadForDate(DateTime.now());

  Future<int> loadForDate(DateTime date) async {
    return (await loadRecordForDate(date)).durationMinutes;
  }

  Future<SleepRecord> loadRecordToday() => loadRecordForDate(DateTime.now());

  Future<SleepRecord> loadRecordForDate(DateTime date) async {
    final preferences = await SharedPreferences.getInstance();
    final records = _records(preferences);
    final value =
        records[_dateKey(date)] ??
        records['${date.year}-${date.month}-${date.day}'];
    return SleepRecord.fromJson(value);
  }

  Future<void> saveToday(int sleepMinutes) =>
      saveForDate(DateTime.now(), sleepMinutes);

  Future<void> saveForDate(DateTime date, int sleepMinutes) async {
    final existing = await loadRecordForDate(date);
    await saveRecordForDate(
      date,
      SleepRecord(
        durationMinutes: sleepMinutes,
        bedtimeMinutes: existing.bedtimeMinutes,
        wakeUpMinutes: existing.wakeUpMinutes,
      ),
    );
  }

  Future<void> saveRecordToday(SleepRecord record) =>
      saveRecordForDate(DateTime.now(), record);

  Future<void> saveRecordForDate(DateTime date, SleepRecord record) async {
    final preferences = await SharedPreferences.getInstance();
    final records = _records(preferences)..[_dateKey(date)] = record.toJson();
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

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
